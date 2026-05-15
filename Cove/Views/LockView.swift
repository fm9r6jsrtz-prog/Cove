import SwiftUI

// MARK: - LockView

struct LockView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.colorScheme) var colorScheme

    @State private var enteredPIN = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var wrongAttempts = 0

    private var dateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE · MMM d"
        return fmt.string(from: .now)
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Cove")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(t.text)
                        Text(dateString)
                            .font(.system(size: 14))
                            .foregroundColor(t.text2)
                    }
                    Spacer()
                    if store.canUseFaceID {
                        Button { store.triggerFaceID() } label: {
                            Image(systemName: store.lockScanState == .scanning ? "faceid" : "faceid")
                                .font(.system(size: 26, weight: .light))
                                .foregroundColor(store.lockScanState == .scanning ? t.accent : t.text2)
                                .frame(width: 44, height: 44)
                                .background(t.surface.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .disabled(store.lockScanState == .scanning)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 64)

                Spacer()

                // PIN dots
                HStack(spacing: 18) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i < enteredPIN.count ? t.accent : Color(.systemGray5))
                            .frame(width: 14, height: 14)
                            .scaleEffect(i < enteredPIN.count ? 1.15 : 1)
                            .animation(.spring(duration: 0.2), value: enteredPIN.count)
                    }
                }
                .offset(x: shakeOffset)
                .padding(.bottom, 40)

                // PIN pad
                PINPad(accent: t.accent, onDigit: handleDigit, onDelete: handleDelete)

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Stored on-device · no cloud")
                        .font(.system(size: 12))
                }
                .foregroundColor(t.text3)
                .padding(.bottom, 44)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if store.canUseFaceID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    store.triggerFaceID()
                }
            }
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var background: some View {
        if colorScheme == .dark {
            RadialGradient(colors: [t.accent.opacity(0.2), Color.black],
                           center: .top, startRadius: 0,
                           endRadius: UIScreen.main.bounds.height)
            .ignoresSafeArea()
        } else {
            RadialGradient(colors: [t.accentTint, Color(UIColor.systemGroupedBackground)],
                           center: .top, startRadius: 0,
                           endRadius: UIScreen.main.bounds.height)
            .ignoresSafeArea()
        }
    }

    // MARK: - PIN logic

    private func handleDigit(_ d: String) {
        guard enteredPIN.count < 4 else { return }
        enteredPIN += d
        if enteredPIN.count == 4 { verifyPIN() }
    }

    private func handleDelete() {
        guard !enteredPIN.isEmpty else { return }
        enteredPIN.removeLast()
    }

    private func verifyPIN() {
        if store.verifyAppPIN(enteredPIN) {
            store.unlock()
        } else {
            wrongAttempts += 1
            shake()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                enteredPIN = ""
            }
        }
    }

    private func shake() {
        withAnimation(.linear(duration: 0.07).repeatCount(5, autoreverses: true)) {
            shakeOffset = -12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shakeOffset = 0
        }
    }
}

// MARK: - PINPad

struct PINPad: View {
    let accent: Color
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    private let rows = [["1","2","3"],["4","5","6"],["7","8","9"],["","0","⌫"]]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 22) {
                    ForEach(row, id: \.self) { key in
                        PINKey(key: key, accent: accent, onDigit: onDigit, onDelete: onDelete)
                    }
                }
            }
        }
    }
}

private struct PINKey: View {
    let key: String
    let accent: Color
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    @State private var pressed = false

    var body: some View {
        Group {
            if key == "⌫" {
                Button { onDelete() } label: {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(Color(.label))
                        .frame(width: 80, height: 80)
                }
            } else if key.isEmpty {
                Color.clear.frame(width: 80, height: 80)
            } else {
                Button { onDigit(key) } label: {
                    Text(key)
                        .font(.system(size: 30, weight: .light, design: .rounded))
                        .foregroundColor(Color(.label))
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color(UIColor.systemFill))
                                .opacity(pressed ? 0.6 : 1)
                        )
                }
                ._onButtonGesture(pressing: { p in
                    withAnimation(.easeOut(duration: 0.1)) { pressed = p }
                }, perform: {})
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore

    @State private var step: Int = 0
    @State private var userName: String = ""
    @State private var selectedAccent: String = "sage"
    @State private var selectedDark: Bool = false
    @State private var newPIN: String = ""
    @State private var confirmPIN: String = ""
    @State private var pinStage: PINStage = .enter

    enum PINStage { case enter, confirm, mismatch }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { i in
                        Capsule()
                            .fill(i == step ? accentColor : Color(.systemGray4))
                            .frame(width: i == step ? 22 : 7, height: 7)
                            .animation(.spring(duration: 0.3), value: step)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 8)

                ZStack {
                    if step == 0 { WelcomeStep(accent: accentColor, onNext: next).transition(stepTransition) }
                    if step == 1 { NameStep(name: $userName, accent: accentColor, onNext: next).transition(stepTransition) }
                    if step == 2 { AccentStep(selected: $selectedAccent, onNext: { store.accentName = selectedAccent; next() }).transition(stepTransition) }
                    if step == 3 { AppearanceStep(isDark: $selectedDark, accent: accentColor, onNext: { store.themeDark = selectedDark; next() }).transition(stepTransition) }
                    if step == 4 { SetPINStep(
                        newPIN: $newPIN,
                        confirmPIN: $confirmPIN,
                        stage: $pinStage,
                        accent: accentColor,
                        onFinish: finish
                    ).transition(stepTransition) }
                }
                .animation(.spring(duration: 0.4), value: step)
            }
        }
    }

    private var stepTransition: AnyTransition {
        .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity))
    }

    private var accentColor: Color {
        coveAccents[selectedAccent]?.accent ?? Color(hex: "6B9B7E")
    }

    private func next() {
        withAnimation { step = min(step + 1, 4) }
    }

    private func finish() {
        store.accentName = selectedAccent
        store.themeDark = selectedDark
        store.userName = userName
        store.setAppPIN(newPIN)
        store.completeOnboarding()
    }
}

// MARK: - Step 0: Welcome

private struct WelcomeStep: View {
    let accent: Color
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle().fill(accent.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(accent)
            }
            .padding(.bottom, 32)

            Text("Welcome to Cove")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Text("A daily planner that stays yours.\nPrivate, offline, and distraction-free.")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.bottom, 40)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                FeatureRow(icon: "lock.fill",                 iconColor: accent,               title: "On-device only",    detail: "Nothing leaves your iPhone. Ever.")
                Divider().padding(.leading, 60)
                FeatureRow(icon: "scope",                     iconColor: Color(.systemOrange), title: "Focus with intent", detail: "Block distractions, earn back time.")
                Divider().padding(.leading, 60)
                FeatureRow(icon: "chart.line.uptrend.xyaxis", iconColor: Color(.systemGreen),  title: "Build real habits",  detail: "Streaks, history, and routines that stick.")
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)

            Spacer()
            OnboardingCTA(label: "Get started", accent: accent, action: onNext)
                .padding(.bottom, 48)
        }
    }
}

// MARK: - Step 1: Name

private struct NameStep: View {
    @Binding var name: String
    let accent: Color
    let onNext: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle().fill(accent.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: "person.fill")
                    .font(.system(size: 52, weight: .light)).foregroundColor(accent)
            }
            .padding(.bottom, 32)

            Text("What should we call you?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10).padding(.horizontal, 24)

            Text("Just your first name is great.")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .padding(.bottom, 40)

            TextField("Your name", text: $name)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.label))
                .tint(accent)
                .focused($focused)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 40)

            Spacer()
            OnboardingCTA(label: "Continue", accent: accent,
                          disabled: name.trimmingCharacters(in: .whitespaces).isEmpty,
                          action: onNext)
                .padding(.bottom, 48)
        }
        .onAppear { focused = true }
    }
}

// MARK: - Step 2: Accent

private struct AccentStep: View {
    @Binding var selected: String
    let onNext: () -> Void

    private let options: [(key: String, label: String, color: Color)] = [
        ("sage",     "Sage",     Color(hex: "6B9B7E")),
        ("indigo",   "Indigo",   Color(hex: "6C5CE7")),
        ("rose",     "Rose",     Color(hex: "E05A47")),
        ("graphite", "Graphite", Color(hex: "5A5A6E")),
    ]
    private var accent: Color { options.first(where: { $0.key == selected })?.color ?? Color(hex: "6B9B7E") }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle().fill(accent.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 52, weight: .light)).foregroundColor(accent)
            }
            .padding(.bottom, 32).animation(.spring(duration: 0.3), value: selected)

            Text("Choose your color")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label)).padding(.bottom, 10)

            Text("You can change this anytime in Settings.")
                .font(.system(size: 17)).foregroundColor(Color(.secondaryLabel))
                .padding(.bottom, 48)

            HStack(spacing: 20) {
                ForEach(options, id: \.key) { opt in
                    Button { withAnimation(.spring(duration: 0.3)) { selected = opt.key } } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle().fill(opt.color).frame(width: 60, height: 60)
                                if selected == opt.key {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                }
                            }
                            .shadow(color: opt.color.opacity(0.4), radius: selected == opt.key ? 12 : 0, y: 4)
                            .scaleEffect(selected == opt.key ? 1.12 : 1)
                            .animation(.spring(duration: 0.3), value: selected)

                            Text(opt.label)
                                .font(.system(size: 13, weight: selected == opt.key ? .semibold : .regular))
                                .foregroundColor(selected == opt.key ? opt.color : Color(.secondaryLabel))
                        }
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
            OnboardingCTA(label: "Continue", accent: accent, action: onNext).padding(.bottom, 48)
        }
    }
}

// MARK: - Step 3: Appearance

private struct AppearanceStep: View {
    @Binding var isDark: Bool
    let accent: Color
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle().fill(accent.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: isDark ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 52, weight: .light)).foregroundColor(accent)
            }
            .padding(.bottom, 32).animation(.spring(duration: 0.3), value: isDark)

            Text("How do you like it?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label)).padding(.bottom, 10)

            Text("Match your vibe — switch anytime.")
                .font(.system(size: 17)).foregroundColor(Color(.secondaryLabel))
                .padding(.bottom, 48)

            HStack(spacing: 16) {
                AppearanceCard(icon: "sun.max.fill", label: "Light", selected: !isDark, accent: accent) {
                    withAnimation(.spring(duration: 0.3)) { isDark = false }
                }
                AppearanceCard(icon: "moon.fill", label: "Dark", selected: isDark, accent: accent) {
                    withAnimation(.spring(duration: 0.3)) { isDark = true }
                }
            }
            .padding(.horizontal, 40)

            Spacer()
            OnboardingCTA(label: "Continue", accent: accent, action: onNext).padding(.bottom, 48)
        }
    }
}

private struct AppearanceCard: View {
    let icon: String; let label: String; let selected: Bool; let accent: Color; let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(selected ? accent : Color(.tertiaryLabel))
                Text(label)
                    .font(.system(size: 15, weight: selected ? .semibold : .regular))
                    .foregroundColor(selected ? accent : Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(selected ? accent : Color.clear, lineWidth: 2))
            )
            .scaleEffect(selected ? 1.03 : 1)
            .animation(.spring(duration: 0.3), value: selected)
        }.buttonStyle(.plain)
    }
}

// MARK: - Step 4: Set PIN

private struct SetPINStep: View {
    @Binding var newPIN: String
    @Binding var confirmPIN: String
    @Binding var stage: OnboardingView.PINStage
    let accent: Color
    let onFinish: () -> Void

    @State private var shakeOffset: CGFloat = 0

    private var activePIN: Binding<String> {
        stage == .enter ? $newPIN : $confirmPIN
    }

    private var title: String {
        switch stage {
        case .enter:    return "Create your PIN"
        case .confirm:  return "Confirm your PIN"
        case .mismatch: return "PINs didn't match"
        }
    }

    private var subtitle: String {
        switch stage {
        case .enter:    return "Choose a 4-digit code to lock Cove."
        case .confirm:  return "Enter it one more time."
        case .mismatch: return "Let's try again."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle().fill(accent.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: stage == .mismatch ? "exclamationmark.lock.fill" : "lock.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(stage == .mismatch ? Color(.systemRed) : accent)
            }
            .padding(.bottom, 32)
            .animation(.spring(duration: 0.3), value: stage)

            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label)).padding(.bottom, 10)

            Text(subtitle)
                .font(.system(size: 17)).foregroundColor(Color(.secondaryLabel))
                .padding(.bottom, 40)

            // Dots
            HStack(spacing: 18) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(i < activePIN.wrappedValue.count ? accent : Color(.systemGray5))
                        .frame(width: 14, height: 14)
                        .scaleEffect(i < activePIN.wrappedValue.count ? 1.15 : 1)
                        .animation(.spring(duration: 0.2), value: activePIN.wrappedValue.count)
                }
            }
            .offset(x: shakeOffset)
            .padding(.bottom, 36)

            PINPad(accent: accent, onDigit: handleDigit, onDelete: handleDelete)

            Spacer()
        }
    }

    private func handleDigit(_ d: String) {
        guard activePIN.wrappedValue.count < 4 else { return }
        activePIN.wrappedValue += d
        if activePIN.wrappedValue.count == 4 { checkPIN() }
    }

    private func handleDelete() {
        guard !activePIN.wrappedValue.isEmpty else { return }
        activePIN.wrappedValue.removeLast()
    }

    private func checkPIN() {
        if stage == .enter {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { stage = .confirm }
            }
        } else {
            if confirmPIN == newPIN {
                onFinish()
            } else {
                shake()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation { stage = .mismatch }
                    newPIN = ""; confirmPIN = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { stage = .enter }
                    }
                }
            }
        }
    }

    private func shake() {
        withAnimation(.linear(duration: 0.07).repeatCount(5, autoreverses: true)) { shakeOffset = -12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { shakeOffset = 0 }
    }
}

// MARK: - Shared helpers

struct OnboardingCTA: View {
    let label: String
    let accent: Color
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(disabled ? Color(.systemGray4) : accent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(disabled)
        .padding(.horizontal, 20)
        .animation(.spring(duration: 0.2), value: disabled)
    }
}

private struct FeatureRow: View {
    let icon: String; let iconColor: Color; let title: String; let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                .frame(width: 34, height: 34).background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(Color(.label))
                Text(detail).font(.system(size: 13)).foregroundColor(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

// MARK: - Previews

#Preview("Lock Screen") {
    LockView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}

#Preview("Onboarding") {
    OnboardingView()
        .environmentObject(AppStore())
}
