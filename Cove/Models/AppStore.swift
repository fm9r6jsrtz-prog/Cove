import SwiftUI
import LocalAuthentication

class AppStore: ObservableObject {

    // MARK: - App gate
    @Published var isLocked: Bool = true
    @Published var hasOnboarded: Bool = UserDefaults.standard.bool(forKey: "cove.onboarded")
    @Published var lockScanState: LockScanState = .idle

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
    @Published var tasks: [CoveTask] = CoveTask.defaults
    @Published var events: [CalendarEvent] = CalendarEvent.today
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
    @Published var habits: [Habit] = Habit.defaults

    var habitCompletionPct: Int {
        let total = habits.count * 7
        let done = habits.flatMap(\.weekHistory).filter { $0 }.count
        return total > 0 ? Int(Double(done) / Double(total) * 100) : 0
    }

    var bestStreak: Int { habits.map(\.streak).max() ?? 0 }

    // MARK: - Journal
    @Published var journalEntries: [JournalEntry] = [
        JournalEntry(
            title: "A quieter morning than expected.",
            body: "Standup ran short, so I took the long way back to my desk. The cherry tree by the window has finally finished dropping its petals — there's a soft pink ring on the sidewalk.\n\nTrying to keep deep work blocks honest this week. Phone in the drawer at 9:30, no exceptions. So far so good.",
            mood: 0
        )
    ]
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
    @Published var tomorrowTop3: [String] = ["Finish Locket spec · sections 6–8", "Send Q3 plan to Jordan", "Sign lease addendum"]

    // MARK: - Settings toggles
    @Published var requireFaceID = true
    @Published var wipeAfterFails = true
    @Published var iCloudSync = false
    @Published var analyticsEnabled = false
    @Published var crashReportsEnabled = false

    // MARK: - Auth / Lock

    func triggerFaceID() {
        lockScanState = .scanning
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Unlock Cove") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        withAnimation(.spring(duration: 0.4)) { self.lockScanState = .success }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(duration: 0.4)) { self.isLocked = false }
                        }
                    } else {
                        withAnimation { self.lockScanState = .idle }
                    }
                }
            }
        } else {
            // Simulator / no biometrics — just unlock with a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(duration: 0.4)) { self.lockScanState = .success }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(duration: 0.4)) { self.isLocked = false }
                }
            }
        }
    }

    func completeOnboarding() {
        hasOnboarded = true
        UserDefaults.standard.set(true, forKey: "cove.onboarded")
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
