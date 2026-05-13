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

    private var ringGlowOpacity: Double {
        store.lockScanState == .scanning ? 0.35 : 0
    }

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            VStack(spacing: 0) {
                // Wordmark
                Text("Cove")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(t.text)
                    .padding(.top, 96)

                // Date
                Text(dateString)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(t.text2)
                    .padding(.top, 6)

                Spacer()

                // Face ID ring
                Button(action: { store.triggerFaceID() }) {
                    faceIDRing
                }
                .buttonStyle(.plain)
                .disabled(store.lockScanState != .idle)

                // Status text
                Text(statusText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(store.lockScanState == .success ? Color(.systemGreen) : t.text2)
                    .padding(.top, 22)
                    .animation(.easeInOut(duration: 0.2), value: store.lockScanState)

                Spacer()

                // Footer
                VStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(t.text3)
                        Text("End-to-end on this device · no cloud")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(t.text3)
                    }

                    Button("Use Passcode") {
                        store.triggerFaceID()
                    }
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

    // MARK: - Subviews

    @ViewBuilder
    private var backgroundGradient: some View {
        if colorScheme == .dark {
            RadialGradient(
                colors: [t.accent.opacity(0.25), Color.black],
                center: .top,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.85
            )
            .ignoresSafeArea()
        } else {
            RadialGradient(
                colors: [t.accentTint, Color.white],
                center: .top,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.85
            )
            .ignoresSafeArea()
        }
    }

    private var faceIDRing: some View {
        ZStack {
            // Glow layer (scanning state)
            Circle()
                .fill(ringColor.opacity(ringGlowOpacity))
                .frame(width: 160, height: 160)
                .blur(radius: 18)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: store.lockScanState)

            // Outer ring
            Circle()
                .strokeBorder(ringColor, lineWidth: store.lockScanState == .idle ? 1.5 : 2.5)
                .frame(width: 132, height: 132)
                .animation(.spring(duration: 0.4), value: store.lockScanState)

            // Inner content
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
    @Environment(\.coveTheme) var t
    @State private var currentPage: Int = 0

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page dots
                pageDots
                    .padding(.top, 20)

                // Single-page content (page 1 is the main onboarding)
                if currentPage == 0 {
                    mainPage
                }

                Spacer()
            }
        }
    }

    // MARK: - Main Page

    private var mainPage: some View {
        VStack(spacing: 0) {
            Spacer()

            // Shield icon
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundColor(t.accent)
                .padding(.bottom, 28)

            // Title
            Text("Welcome to Cove")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            // Subtitle
            Text("A daily planner that stays yours.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)

            // Bullet rows
            VStack(spacing: 0) {
                FeatureRow(
                    icon: "calendar",
                    iconColor: t.accent,
                    title: "Your day, your way",
                    detail: "Schedule, tasks, habits, and journal — all in one calm space."
                )
                Divider().padding(.leading, 60)
                FeatureRow(
                    icon: "lock.fill",
                    iconColor: Color(.systemBlue),
                    title: "On-device only",
                    detail: "Nothing leaves your iPhone unless you choose to back it up."
                )
                Divider().padding(.leading, 60)
                FeatureRow(
                    icon: "clock.badge.xmark",
                    iconColor: Color(.systemOrange),
                    title: "No tracking, ever",
                    detail: "Zero analytics. No ads. No identifiers. No accounts."
                )
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)

            Spacer()

            // CTA button
            Button(action: { store.completeOnboarding() }) {
                Text("Set up Cove")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(t.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Legal text
            Text("By continuing you agree to our brief terms.\nWe never collect your data.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.bottom, 36)
        }
    }

    // MARK: - Page Dots

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? t.accent : Color(.systemGray4))
                    .frame(width: i == currentPage ? 22 : 7, height: 7)
                    .animation(.spring(duration: 0.3), value: currentPage)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - FeatureRow (private helper)

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
                    .font(.system(size: 13, weight: .regular))
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
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
