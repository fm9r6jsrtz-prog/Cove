import SwiftUI

// MARK: - FocusView

struct FocusView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("THIS WEEK · 14H 22M")
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(t.accent)
                            .tracking(0.5)
                        Text("Focus")
                            .font(.sfRounded(size: 30, weight: .bold))
                            .foregroundColor(t.text)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .padding(.bottom, 20)

                    // Main CTA card
                    FocusMainCard()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                    // On today section
                    OnTodaySection()
                        .padding(.bottom, 20)

                    // Earn-back card
                    EarnBackCard()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                    // Mini cards row
                    HStack(spacing: 12) {
                        BlockListMiniCard()
                        CooldownMiniCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .background(t.bg)

            CoveTabBar()
        }
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $store.showFocusSession) {
            FocusSessionView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
        .fullScreenCover(isPresented: $store.showBlockedOverride) {
            BlockedOverrideView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
        .sheet(isPresented: $store.showLockRules) {
            LockRulesView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
        .sheet(isPresented: $store.showEarnBack) {
            EarnBackView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
    }
}

// MARK: - FocusMainCard

private struct FocusMainCard: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var timeString: String {
        let m = store.focusSession.remainingSeconds / 60
        let s = store.focusSession.remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Concentric circles decoration
            ConcentricCirclesDecoration()

            VStack(alignment: .leading, spacing: 0) {
                if store.focusActive {
                    // Active session state
                    VStack(alignment: .leading, spacing: 6) {
                        Text("In session · \(timeString) left")
                            .font(.sfPro(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(0.2)

                        Text(store.focusSession.taskTitle)
                            .font(.sfRounded(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("6 apps blocked")
                            .font(.sfPro(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 20)

                    HStack(spacing: 10) {
                        Button {
                            store.showFocusSession = true
                        } label: {
                            Text("Open session")
                                .font(.sfPro(size: 16, weight: .semibold))
                                .foregroundColor(t.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }

                        Button {
                            store.endFocusSession()
                        } label: {
                            Text("End early")
                                .font(.sfPro(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }
                } else {
                    // Idle state
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ready when you are")
                            .font(.sfPro(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(0.2)

                        Text("Start a focus session")
                            .font(.sfRounded(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("Apps lock automatically. You choose the task and the time.")
                            .font(.sfPro(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(3)
                    }
                    .padding(.bottom, 20)

                    HStack(spacing: 10) {
                        Button {
                            store.startFocusSession()
                        } label: {
                            Text("Start · 45 min")
                                .font(.sfPro(size: 16, weight: .semibold))
                                .foregroundColor(t.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }

                        Button {
                            // Custom duration picker
                        } label: {
                            Text("Custom…")
                                .font(.sfPro(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(22)
        }
        .background(
            LinearGradient(
                colors: [t.accent, t.accent.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: t.accent.opacity(0.3), radius: 18, y: 8)
    }
}

// MARK: - Concentric Circles Decoration

private struct ConcentricCirclesDecoration: View {
    var body: some View {
        ZStack {
            ForEach([160, 210, 260, 310].indices, id: \.self) { i in
                let size = CGFloat([160, 210, 260, 310][i])
                Circle()
                    .stroke(Color.white, lineWidth: 1)
                    .opacity(0.15)
                    .frame(width: size, height: size)
            }
        }
        .offset(x: 60, y: -40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .clipped()
    }
}

// MARK: - OnTodaySection

private struct OnTodaySection: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    struct LockRow {
        let timeRange: String
        let name: String
        let rule: String
        let status: LockStatus
    }

    enum LockStatus {
        case done, next, queued

        var label: String {
            switch self {
            case .done:   return "Done"
            case .next:   return "Next"
            case .queued: return "Queued"
            }
        }

        var color: Color {
            switch self {
            case .done:   return Color(.systemGreen)
            case .next:   return Color(hex: "6B9B7E")
            case .queued: return Color(.systemGray3)
            }
        }
    }

    let rows: [LockRow] = [
        LockRow(timeRange: "09:30–11:00", name: "Deep work", rule: "Calendar block", status: .done),
        LockRow(timeRange: "14:30–15:45", name: "Design review", rule: "Calendar block", status: .next),
        LockRow(timeRange: "16:30–17:30", name: "Run", rule: "Time window", status: .queued),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ON TODAY · 3 AUTO-LOCKS")
                    .font(.sfPro(size: 12, weight: .semibold))
                    .foregroundColor(t.accent)
                    .tracking(0.5)
                Spacer()
                Button {
                    store.showLockRules = true
                } label: {
                    Text("Rules")
                        .font(.sfPro(size: 14, weight: .medium))
                        .foregroundColor(t.accent)
                }
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { i in
                    let row = rows[i]
                    HStack(spacing: 12) {
                        // Tint bar left
                        RoundedRectangle(cornerRadius: 2)
                            .fill(row.status.color)
                            .frame(width: 3, height: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.name)
                                .font(.sfPro(size: 15, weight: .semibold))
                                .foregroundColor(t.text)
                            Text("\(row.timeRange) · \(row.rule)")
                                .font(.sfPro(size: 12))
                                .foregroundColor(t.text2)
                        }

                        Spacer()

                        Text(row.status.label)
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(row.status == .queued ? t.text2 : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(row.status == .queued ? t.systemFill : row.status.color)
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        if i < rows.count - 1 {
                            Divider().padding(.leading, 31)
                        }
                    }
                }
            }
            .background(t.surface.cornerRadius(16))
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - EarnBackCard

private struct EarnBackCard: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        Button {
            store.showEarnBack = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(t.green)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Earn-back · \(store.earnedMinutes) min available")
                        .font(.sfPro(size: 14, weight: .semibold))
                        .foregroundColor(t.text)
                    Text("Finish 1 more task to unlock 5 more minutes.")
                        .font(.sfPro(size: 13))
                        .foregroundColor(t.text2)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(t.text3)
            }
            .padding(16)
            .background(t.surface.cornerRadius(16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - BlockListMiniCard

private struct BlockListMiniCard: View {
    @Environment(\.coveTheme) var t

    let apps = Array(BlockedApp.defaults.prefix(5))

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Default block list")
                .font(.sfPro(size: 13, weight: .semibold))
                .foregroundColor(t.text)

            HStack(spacing: -6) {
                ForEach(apps) { app in
                    AppIconBadge(app: app, size: 32, locked: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(t.surface.cornerRadius(16))
    }
}

// MARK: - CooldownMiniCard

private struct CooldownMiniCard: View {
    @Environment(\.coveTheme) var t

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "hourglass")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(t.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("60s cooldown")
                    .font(.sfPro(size: 13, weight: .semibold))
                    .foregroundColor(t.text)
                Text("Before any unlock")
                    .font(.sfPro(size: 12))
                    .foregroundColor(t.text2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(t.surface.cornerRadius(16))
    }
}

// MARK: - FocusSessionView

struct FocusSessionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private var remainingFormatted: String {
        let m = store.focusSession.remainingSeconds / 60
        let s = store.focusSession.remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private var totalMinutes: Int {
        store.focusSession.totalSeconds / 60
    }

    private var progress: Double {
        store.focusSession.progress
    }

    var body: some View {
        ZStack {
            // Dark gradient background
            RadialGradient(
                colors: [t.accent.opacity(0.35), Color.black.opacity(0.92)],
                center: .top,
                startRadius: 60,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Session pill
                    HStack(spacing: 6) {
                        Circle()
                            .fill(t.green)
                            .frame(width: 8, height: 8)
                        Text("Focus · in session")
                            .font(.sfPro(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())

                    Spacer()

                    Button {
                        store.endFocusSession()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 32)

                // Current task label
                VStack(spacing: 6) {
                    Text("Current task")
                        .font(.sfPro(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(0.3)

                    Text(store.focusSession.taskTitle)
                        .font(.sfRounded(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)

                // Ring timer
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 12)
                        .frame(width: 260, height: 260)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: 1.0 - progress)
                        .stroke(
                            t.accent,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    // Center content
                    VStack(spacing: 4) {
                        Text(remainingFormatted)
                            .font(.sfRounded(size: 64, weight: .bold))
                            .foregroundColor(.white)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 1), value: store.focusSession.remainingSeconds)

                        Text("of \(totalMinutes) min")
                            .font(.sfPro(size: 15))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.bottom, 44)

                // Blocked apps section
                VStack(spacing: 14) {
                    Text("Blocked while focused")
                        .font(.sfPro(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))

                    HStack(spacing: 12) {
                        ForEach(store.focusSession.blockedApps.prefix(6)) { app in
                            AppIconBadge(app: app, size: 38, locked: true)
                        }
                    }
                }
                .padding(.bottom, 44)

                Spacer()

                // Bottom buttons
                VStack(spacing: 12) {
                    Button {
                        store.pauseFocusSession()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: store.focusSession.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(store.focusSession.isRunning ? "Pause" : "Resume")
                                .font(.sfPro(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                    }

                    Button {
                        store.endFocusSession()
                    } label: {
                        Text("End session")
                            .font(.sfPro(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }
}

// MARK: - BlockedOverrideView

struct BlockedOverrideView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let instagramApp = BlockedApp(name: "Instagram", letter: "I", bgColor: Color(hex: "D62976"))

    var body: some View {
        ZStack {
            t.accentTint.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // App info header
                    VStack(spacing: 10) {
                        AppIconBadge(app: instagramApp, size: 56, locked: false)

                        VStack(spacing: 4) {
                            Text("Instagram")
                                .font(.sfRounded(size: 20, weight: .bold))
                                .foregroundColor(t.text)

                            Text("Blocked by Cove · until 11:00")
                                .font(.sfPro(size: 13))
                                .foregroundColor(t.text2)
                        }
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                    // Focus context
                    VStack(spacing: 8) {
                        Text("YOU SAID THIS MATTERS")
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(t.accent)
                            .tracking(0.6)

                        Text("Deep work · Locket spec")
                            .font(.sfRounded(size: 26, weight: .bold))
                            .foregroundColor(t.text)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 16)

                    // Explanation
                    Text("You set a focus block until 11:00. Opening Instagram right now will interrupt your deep work window and log an override.")
                        .font(.sfPro(size: 15))
                        .foregroundColor(t.text2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)

                    // User's note card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your note")
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(t.text2)

                        Text("\"Finish sections 6–8 of the Locket spec before the design review. No distractions until I'm done.\"")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(t.text)
                            .lineSpacing(5)
                            .italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(t.surface.cornerRadius(16))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                    // Buttons
                    VStack(spacing: 12) {
                        // Back to focus — primary
                        Button {
                            store.showBlockedOverride = false
                        } label: {
                            Text("Back to focus")
                                .font(.sfPro(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(t.accent)
                                .clipShape(Capsule())
                        }

                        // Cooldown unlock button
                        CooldownUnlockButton()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    // Footnote
                    Text("This unlock will appear in your weekly review.")
                        .font(.sfPro(size: 12))
                        .foregroundColor(t.text3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 44)
                }
            }
        }
    }
}

private struct CooldownUnlockButton: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        Button {
            if store.overrideCooldown == 0 {
                store.showBlockedOverride = false
            }
        } label: {
            HStack(spacing: 10) {
                // Small countdown ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2.5)
                        .frame(width: 22, height: 22)

                    if store.overrideCooldown > 0 {
                        Circle()
                            .trim(from: 0, to: CGFloat(60 - store.overrideCooldown) / 60.0)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .frame(width: 22, height: 22)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: store.overrideCooldown)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text(store.overrideCooldown > 0
                     ? "Let me through in \(store.overrideCooldown)s"
                     : "Let me through")
                    .font(.sfPro(size: 16, weight: .medium))
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 1), value: store.overrideCooldown)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(store.overrideCooldown == 0 ? t.red : Color.black.opacity(0.15))
            .clipShape(Capsule())
        }
        .disabled(store.overrideCooldown > 0)
        .animation(.easeInOut(duration: 0.25), value: store.overrideCooldown == 0)
    }
}

// MARK: - LockRulesView

struct LockRulesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Title & description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lock rules")
                            .font(.sfRounded(size: 28, weight: .bold))
                            .foregroundColor(t.text)

                        Text("Choose when Cove locks your apps automatically.")
                            .font(.sfPro(size: 15))
                            .foregroundColor(t.text2)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    // Triggers section
                    CoveSection(header: "Triggers") {
                        CoveListRow(
                            title: "During calendar focus blocks",
                            isToggle: true,
                            toggleValue: $store.lockOnCalendarBlocks
                        )
                        CoveListRow(
                            title: "Time windows",
                            isToggle: true,
                            toggleValue: $store.lockTimeWindows
                        )
                        CoveListRow(
                            title: "Until tasks complete",
                            isToggle: true,
                            toggleValue: $store.lockUntilTasks
                        )
                        CoveListRow(
                            title: "While focus session running",
                            isToggle: true,
                            toggleValue: $store.lockDuringFocus
                        )
                        CoveListRow(
                            title: "Tap to lock now",
                            isToggle: true,
                            toggleValue: $store.lockTapToLock,
                            isLast: true
                        )
                    }

                    // Block list section
                    CoveSection(header: "Block list") {
                        CoveListRow(
                            title: "Apps & sites",
                            value: "9 selected",
                            showChevron: true
                        )
                        CoveListRow(
                            title: "Messages exception",
                            isToggle: true,
                            toggleValue: $store.messagesException,
                            isLast: true
                        )
                    }

                    // Override behaviour section
                    CoveSection(header: "If I tap a blocked app") {
                        CoveListRow(
                            title: "Cooldown",
                            value: "60 seconds",
                            showChevron: true
                        )
                        CoveListRow(
                            title: "Show my note",
                            isToggle: true,
                            toggleValue: $store.showMyNote
                        )
                        CoveListRow(
                            title: "Log overrides",
                            isToggle: true,
                            toggleValue: $store.logOverrides,
                            isLast: true
                        )
                    }

                    Spacer(minLength: 44)
                }
            }
            .background(t.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Focus")
                                .font(.sfPro(size: 17))
                        }
                        .foregroundColor(t.accent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.sfPro(size: 17, weight: .semibold))
                            .foregroundColor(t.accent)
                    }
                }
            }
        }
    }
}

// MARK: - EarnBackView

struct EarnBackView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) var dismiss

    private let qualifyingTasks: [(title: String, minutes: Int, done: Bool)] = [
        ("Call dentist", 5, true),
        ("Send proposal", 7, true),
        ("Pick up dry cleaning", 5, false),
        ("Confirm hotel booking", 3, false),
    ]

    private let unlockedApps: [BlockedApp] = Array(BlockedApp.defaults.prefix(6))

    private var capMinutes: Int { 30 }
    private var progress: Double { min(Double(store.earnedMinutes) / Double(capMinutes), 1.0) }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AVAILABLE · \(store.earnedMinutes) MIN")
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(t.green)
                            .tracking(0.5)

                        Text("Earn-back")
                            .font(.sfRounded(size: 28, weight: .bold))
                            .foregroundColor(t.text)

                        Text("Complete tasks to unlock screen time. Earned time applies to your blocked apps.")
                            .font(.sfPro(size: 15))
                            .foregroundColor(t.text2)
                            .lineSpacing(3)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Big progress card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 16) {
                            // Big number
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(store.earnedMinutes)")
                                    .font(.sfRounded(size: 56, weight: .bold))
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                                Text("min")
                                    .font(.sfRounded(size: 22, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.75))
                            }

                            // Progress bar
                            VStack(alignment: .leading, spacing: 8) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 8)
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: geo.size.width * progress, height: 8)
                                            .animation(.spring(duration: 0.6), value: progress)
                                    }
                                }
                                .frame(height: 8)

                                Text("+5 min more when you finish the next task.")
                                    .font(.sfPro(size: 13))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                        .padding(22)

                        // Cap label
                        VStack(spacing: 2) {
                            Text("Cap")
                                .font(.sfPro(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text("30 min")
                                .font(.sfPro(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(14)
                    }
                    .background(
                        LinearGradient(
                            colors: [t.green.opacity(0.85), Color(hex: "34C759").opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: t.green.opacity(0.25), radius: 14, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)

                    // Qualifying tasks
                    CoveSection(header: "Qualifying tasks") {
                        ForEach(qualifyingTasks.indices, id: \.self) { i in
                            let task = qualifyingTasks[i]
                            HStack(spacing: 12) {
                                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(task.done ? t.green : t.text3)

                                Text(task.title)
                                    .font(.sfPro(size: 16))
                                    .foregroundColor(task.done ? t.text2 : t.text)
                                    .strikethrough(task.done, color: t.text3)

                                Spacer()

                                Text("+\(task.minutes)m")
                                    .font(.sfPro(size: 13, weight: .semibold))
                                    .foregroundColor(task.done ? t.green : t.text3)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(task.done ? t.green.opacity(0.12) : t.systemFill)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .overlay(alignment: .bottom) {
                                if i < qualifyingTasks.count - 1 {
                                    Divider().padding(.leading, 50)
                                }
                            }
                        }
                    }

                    // Use time on section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("USE \(store.earnedMinutes) MINUTES ON…")
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(t.text2)
                            .tracking(0.4)
                            .padding(.horizontal, 20)

                        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(unlockedApps) { app in
                                AppIconBadge(app: app, size: 42, locked: false)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 44)
                }
            }
            .background(t.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Focus")
                                .font(.sfPro(size: 17))
                        }
                        .foregroundColor(t.accent)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FocusView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
