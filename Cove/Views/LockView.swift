import SwiftUI

// MARK: - LockView

struct LockView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.colorScheme) var colorScheme

    private var dateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE · MMM d"
        return fmt.string(from: .now)
    }

    private var ringColor: Color {
        switch store.lockScanState {
        case .idle:     return Color(.systemGray4)
        case .scanning: return t.accent
        case .success:  return Color(.systemGreen)
        }
    }

    private var statusText: String {
        switch store.lockScanState {
        case .idle:     return "Look at your iPhone to unlock"
        case .scanning: return "Scanning…"
        case .success:  return "Unlocked"
        }
    }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                Text("Cove")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(t.text)
                    .padding(.top, 96)

                Text(dateString)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(t.text2)
                    .padding(.top, 6)

                Spacer()

                Button(action: { store.triggerFaceID() }) {
                    faceIDRing
                }
                .buttonStyle(.plain)
                .disabled(store.lockScanState != .idle)

                Text(statusText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(store.lockScanState == .success ? Color(.systemGreen) : t.text2)
                    .padding(.top, 22)
                    .animation(.easeInOut(duration: 0.2), value: store.lockScanState)

                Spacer()

                VStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(t.text3)
                        Text("End-to-end on this device · no cloud")
                            .font(.system(size: 12))
                            .foregroundColor(t.text3)
                    }

                    Button("Use Passcode") { store.triggerFaceID() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(t.accent)
                }
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                store.triggerFaceID()
            }
        }
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        if colorScheme == .dark {
            RadialGradient(colors: [t.accent.opacity(0.25), Color.black],
                           center: .top, startRadius: 0,
                           endRadius: UIScreen.main.bounds.height * 0.85)
            .ignoresSafeArea()
        } else {
            RadialGradient(colors: [t.accentTint, Color.white],
                           center: .top, startRadius: 0,
                           endRadius: UIScreen.main.bounds.height * 0.85)
            .ignoresSafeArea()
        }
    }

    private var faceIDRing: some View {
        ZStack {
            Circle()
                .fill(ringColor.opacity(store.lockScanState == .scanning ? 0.35 : 0))
                .frame(width: 160, height: 160)
                .blur(radius: 18)

            Circle()
                .strokeBorder(ringColor, lineWidth: store.lockScanState == .idle ? 1.5 : 2.5)
                .frame(width: 132, height: 132)
                .animation(.spring(duration: 0.4), value: store.lockScanState)

            Group {
                switch store.lockScanState {
                case .idle:
                    Image(systemName: "faceid")
                        .font(.system(size: 52, weight: .ultraLight))
                        .foregroundColor(Color(.systemGray2))
                case .scanning:
                    Image(systemName: "faceid")
                        .font(.system(size: 52, weight: .light))
                        .foregroundColor(t.accent)
                case .success:
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.systemGreen))
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.85)))
            .animation(.spring(duration: 0.35), value: store.lockScanState)
        }
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore

    @State private var step: Int = 0
    @State private var userName: String = ""
    @State private var selectedAccent: String = "sage"
    @State private var selectedDark: Bool = false

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

                // Step content
                ZStack {
                    if step == 0 { WelcomeStep(accent: accentColor, onNext: next) }
                    if step == 1 { NameStep(name: $userName, accent: accentColor, onNext: next) }
                    if step == 2 { AccentStep(selected: $selectedAccent, onNext: next) }
                    if step == 3 { AppearanceStep(isDark: $selectedDark, accent: accentColor, onNext: next) }
                    if step == 4 { FaceIDStep(accent: accentColor, onFinish: finish) }
                }
                .animation(.spring(duration: 0.4), value: step)
            }
        }
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
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 120, height: 120)
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
                FeatureRow(icon: "lock.fill",            iconColor: accent,               title: "On-device only",       detail: "Nothing leaves your iPhone. Ever.")
                Divider().padding(.leading, 60)
                FeatureRow(icon: "scope",                iconColor: Color(.systemOrange), title: "Focus with intent",    detail: "Block distractions, earn back time.")
                Divider().padding(.leading, 60)
                FeatureRow(icon: "chart.line.uptrend.xyaxis", iconColor: Color(.systemGreen),  title: "Build real habits",    detail: "Streaks, history, and routines that stick.")
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
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "person.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(accent)
            }
            .padding(.bottom, 32)

            Text("What should we call you?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                .padding(.horizontal, 24)

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

            OnboardingCTA(label: "Continue", accent: accent, disabled: name.trimmingCharacters(in: .whitespaces).isEmpty, action: onNext)
                .padding(.bottom, 48)
        }
        .onAppear { focused = true }
    }
}

// MARK: - Step 2: Accent Color

private struct AccentStep: View {
    @Binding var selected: String
    let onNext: () -> Void

    private let options: [(key: String, label: String, color: Color)] = [
        ("sage",     "Sage",     Color(hex: "6B9B7E")),
        ("indigo",   "Indigo",   Color(hex: "6C5CE7")),
        ("rose",     "Rose",     Color(hex: "E05A47")),
        ("graphite", "Graphite", Color(hex: "5A5A6E")),
    ]

    private var accent: Color {
        options.first(where: { $0.key == selected })?.color ?? Color(hex: "6B9B7E")
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(accent)
            }
            .padding(.bottom, 32)
            .animation(.spring(duration: 0.3), value: selected)

            Text("Choose your color")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .padding(.bottom, 10)

            Text("You can change this anytime in Settings.")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .padding(.bottom, 48)

            HStack(spacing: 20) {
                ForEach(options, id: \.key) { option in
                    Button {
                        withAnimation(.spring(duration: 0.3)) { selected = option.key }
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 60, height: 60)
                                if selected == option.key {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .shadow(color: option.color.opacity(0.4), radius: selected == option.key ? 12 : 0, y: 4)
                            .scaleEffect(selected == option.key ? 1.12 : 1)
                            .animation(.spring(duration: 0.3), value: selected)

                            Text(option.label)
                                .font(.system(size: 13, weight: selected == option.key ? .semibold : .regular))
                                .foregroundColor(selected == option.key ? option.color : Color(.secondaryLabel))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            OnboardingCTA(label: "Continue", accent: accent, action: onNext)
                .padding(.bottom, 48)
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
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: isDark ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(accent)
            }
            .padding(.bottom, 32)
            .animation(.spring(duration: 0.3), value: isDark)

            Text("How do you like it?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .padding(.bottom, 10)

            Text("Match your vibe — switch anytime.")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
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

            OnboardingCTA(label: "Continue", accent: accent, action: onNext)
                .padding(.bottom, 48)
        }
    }
}

private struct AppearanceCard: View {
    let icon: String
    let label: String
    let selected: Bool
    let accent: Color
    let action: () -> Void

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
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(selected ? accent : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(selected ? 1.03 : 1)
            .animation(.spring(duration: 0.3), value: selected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 4: Face ID

private struct FaceIDStep: View {
    let accent: Color
    let onFinish: () -> Void
    @State private var enabled = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: enabled ? "lock.shield.fill" : "faceid")
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(enabled ? Color(.systemGreen) : accent)
            }
            .padding(.bottom, 32)
            .animation(.spring(duration: 0.3), value: enabled)

            Text("Keep Cove private")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .padding(.bottom, 10)

            Text("Face ID locks your planner when you're away.\nNothing is shared with Apple.")
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.bottom, 48)
                .padding(.horizontal, 24)

            if !enabled {
                Button {
                    withAnimation { enabled = true }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.system(size: 18, weight: .medium))
                        Text("Enable Face ID")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 20)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(.systemGreen))
                    Text("Face ID enabled")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.systemGreen))
                }
                .frame(height: 52)
            }

            Spacer()

            VStack(spacing: 14) {
                OnboardingCTA(label: "Start using Cove", accent: accent, action: onFinish)

                Button("Skip for now") { onFinish() }
                    .font(.system(size: 15))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Shared helpers

private struct OnboardingCTA: View {
    let label: String
    let accent: Color
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(disabled ? Color(.systemGray4) : accent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(disabled)
        .padding(.horizontal, 20)
        .animation(.spring(duration: 0.2), value: disabled)
    }
}

private struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.label))
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundColor(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
