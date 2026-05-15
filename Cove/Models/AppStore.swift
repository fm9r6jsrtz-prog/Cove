import SwiftUI
import LocalAuthentication
import CryptoKit

class AppStore: ObservableObject {

    // MARK: - App gate
    @Published var isLocked: Bool = true
    @Published var hasOnboarded: Bool = UserDefaults.standard.bool(forKey: "cove.onboarded")
    @Published var lockScanState: LockScanState = .idle
    @Published var userName: String = UserDefaults.standard.string(forKey: "cove.name") ?? ""

    enum LockScanState { case idle, scanning, success }

    // MARK: - Theme
    @Published var themeDark: Bool = UserDefaults.standard.bool(forKey: "cove.dark") {
        didSet { UserDefaults.standard.set(themeDark, forKey: "cove.dark") }
    }
    @Published var accentName: String = UserDefaults.standard.string(forKey: "cove.accent") ?? "sage" {
        didSet { UserDefaults.standard.set(accentName, forKey: "cove.accent") }
    }
    @Published var dayLayout: DayLayout = DayLayout(rawValue: UserDefaults.standard.string(forKey: "cove.layout") ?? "timeline") ?? .timeline {
        didSet { UserDefaults.standard.set(dayLayout.rawValue, forKey: "cove.layout") }
    }

    var theme: CoveTheme { CoveTheme(dark: themeDark, accentName: accentName) }

    // MARK: - Navigation
    @Published var selectedTab: CoveTab = .today
    @Published var calendarMode: CalendarMode = .week

    enum CalendarMode { case day, week, month }

    // MARK: - Today / Tasks
    @Published var tasks: [CoveTask] = []
    @Published var events: [CalendarEvent] = []
    @Published var showTaskSheet = false
    @Published var showQuickCapture = false
    @Published var showEnergyCheckin = false
    @Published var newTaskText = ""

    var doneTasks: [CoveTask] { tasks.filter(\.done) }
    var pendingTasks: [CoveTask] { tasks.filter { !$0.done } }
    var earnedMinutes: Int { tasks.filter(\.done).prefix(4).reduce(0) { $0 + $1.earnMinutes } }

    // MARK: - Focus
    @Published var focusSession: FocusSession = FocusSession()
    @Published var focusActive: Bool = false
    @Published var showFocusSession = false
    @Published var showBlockedOverride = false
    @Published var showLockRules = false
    @Published var showEarnBack = false
    @Published var overrideCooldown: Int = 60
    private var focusTimer: Timer?
    private var overrideTimer: Timer?

    // Lock rule toggles
    @Published var lockOnCalendarBlocks = true
    @Published var lockTimeWindows = true
    @Published var lockUntilTasks = true
    @Published var lockDuringFocus = true
    @Published var lockTapToLock = false
    @Published var messagesException = true
    @Published var showMyNote = true
    @Published var logOverrides = true

    // MARK: - Habits
    @Published var habits: [Habit] = []

    var habitCompletionPct: Int {
        let total = habits.count * 7
        let done = habits.flatMap(\.weekHistory).filter { $0 }.count
        return total > 0 ? Int(Double(done) / Double(total) * 100) : 0
    }

    var bestStreak: Int { habits.map(\.streak).max() ?? 0 }

    // MARK: - Journal
    @Published var journalEntries: [JournalEntry] = []
    @Published var currentJournalMood: Int = 0
    @Published var journalBody: String = ""

    // MARK: - Routines
    @Published var routines: [Routine] = Routine.defaults
    @Published var showRoutines = false

    // MARK: - Daily & Weekly Review
    @Published var showDailyReview = false
    @Published var showWeeklyReview = false
    @Published var dailyReviewEnergy: Int = 3
    @Published var dailyWin: String = ""
    @Published var tomorrowTop3: [String] = ["", "", ""]

    // MARK: - Settings toggles
    @Published var requireFaceID = true
    @Published var wipeAfterFails = true
    @Published var iCloudSync = false
    @Published var analyticsEnabled = false
    @Published var crashReportsEnabled = false

    // MARK: - PIN

    var hasAppPIN: Bool { UserDefaults.standard.string(forKey: "cove.pinHash") != nil }

    func setAppPIN(_ pin: String) {
        UserDefaults.standard.set(hashPIN(pin), forKey: "cove.pinHash")
    }

    func verifyAppPIN(_ pin: String) -> Bool {
        guard let stored = UserDefaults.standard.string(forKey: "cove.pinHash") else { return false }
        return hashPIN(pin) == stored
    }

    private func hashPIN(_ pin: String) -> String {
        let digest = SHA256.hash(data: Data(pin.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Auth / Lock

    var canUseFaceID: Bool {
        let ctx = LAContext(); var e: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &e)
    }

    func triggerFaceID() {
        guard canUseFaceID else { return }
        lockScanState = .scanning
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Unlock Cove") { success, _ in
            DispatchQueue.main.async {
                if success {
                    self.unlock()
                } else {
                    withAnimation { self.lockScanState = .idle }
                }
            }
        }
    }

    func unlock() {
        withAnimation(.spring(duration: 0.4)) { isLocked = false; lockScanState = .idle }
    }

    func completeOnboarding() {
        hasOnboarded = true
        isLocked = false
        UserDefaults.standard.set(true, forKey: "cove.onboarded")
        UserDefaults.standard.set(userName, forKey: "cove.name")
        UserDefaults.standard.set(accentName, forKey: "cove.accent")
        UserDefaults.standard.set(themeDark, forKey: "cove.dark")
    }

    func lock() {
        lockScanState = .idle
        withAnimation { isLocked = true }
    }

    // MARK: - Focus

    func startFocusSession(minutes: Int = 45, task: String = "Deep work · Locket spec") {
        focusSession = FocusSession(taskTitle: task, totalSeconds: minutes * 60, remainingSeconds: minutes * 60, isRunning: true)
        focusActive = true
        showFocusSession = true
        focusTimer?.invalidate()
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.focusSession.remainingSeconds > 0 {
                self.focusSession.remainingSeconds -= 1
            } else {
                self.endFocusSession()
            }
        }
    }

    func pauseFocusSession() {
        focusSession.isRunning.toggle()
        if focusSession.isRunning {
            focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.focusSession.remainingSeconds -= 1
            }
        } else {
            focusTimer?.invalidate()
        }
    }

    func endFocusSession() {
        focusActive = false
        focusSession.isRunning = false
        showFocusSession = false
        focusTimer?.invalidate()
        focusTimer = nil
    }

    func startOverrideCooldown() {
        overrideCooldown = 60
        showBlockedOverride = true
        overrideTimer?.invalidate()
        overrideTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.overrideCooldown > 0 {
                self.overrideCooldown -= 1
            } else {
                self.overrideTimer?.invalidate()
            }
        }
    }

    // MARK: - Tasks

    func toggleTask(_ task: CoveTask) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation(.spring(duration: 0.3)) { tasks[idx].done.toggle() }
    }

    func addTask(title: String, tag: String = "Personal") {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation { tasks.insert(CoveTask(title: title, tag: tag), at: 0) }
    }

    // MARK: - Habits

    func toggleHabit(_ habit: Habit) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        withAnimation(.spring(duration: 0.3)) {
            habits[idx].completedToday.toggle()
            if habits[idx].completedToday {
                habits[idx].streak += 1
                habits[idx].weekHistory[6] = true
            } else {
                habits[idx].streak = max(0, habits[idx].streak - 1)
                habits[idx].weekHistory[6] = false
            }
        }
    }

    // MARK: - Journal

    func saveJournalEntry() {
        let entry = JournalEntry(title: String(journalBody.prefix(60)), body: journalBody, mood: currentJournalMood)
        journalEntries.insert(entry, at: 0)
        journalBody = ""
    }

    // MARK: - Routines

    func advanceRoutineStep(_ routine: Routine) {
        guard let idx = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        if routines[idx].currentStep < routines[idx].steps.count - 1 {
            withAnimation { routines[idx].currentStep += 1 }
        } else {
            withAnimation { routines[idx].isRunning = false; routines[idx].currentStep = 0 }
        }
    }

    func startRoutine(_ routine: Routine) {
        guard let idx = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        for i in routines.indices { routines[i].isRunning = false }
        withAnimation { routines[idx].isRunning = true; routines[idx].currentStep = 0 }
    }
}
