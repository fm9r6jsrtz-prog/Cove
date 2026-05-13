import SwiftUI

// MARK: - CoveTabBar

struct CoveTabBar: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CoveTab.allCases) { tab in
                TabItem(tab: tab, isActive: store.selectedTab == tab, t: t)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.25)) { store.selectedTab = tab }
                    }
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 58)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 18, y: 6)
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 24)
    }
}

private struct TabItem: View {
    let tab: CoveTab
    let isActive: Bool
    let t: CoveTheme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .medium))
            if isActive {
                Text(tab.label)
                    .font(.sfPro(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, isActive ? 14 : 8)
        .padding(.vertical, 8)
        .background(isActive ? t.accent.opacity(0.15) : Color.clear)
        .foregroundColor(isActive ? t.accent : t.text2)
        .clipShape(Capsule())
        .frame(maxWidth: isActive ? .infinity : nil)
        .animation(.spring(duration: 0.25), value: isActive)
    }

    var iconName: String {
        switch tab {
        case .today:    return "calendar"
        case .calendar: return "square.grid.3x3"
        case .focus:    return "scope"
        case .habits:   return "chart.line.uptrend.xyaxis"
        case .journal:  return "doc.text"
        }
    }
}

// MARK: - CoveListRow

struct CoveListRow: View {
    @Environment(\.coveTheme) var t

    let title: String
    var subtitle: String? = nil
    var iconName: String? = nil
    var iconBg: Color? = nil
    var value: String? = nil
    var isToggle: Bool = false
    @Binding var toggleValue: Bool
    var showChevron: Bool = false
    var isLast: Bool = false
    var isDanger: Bool = false
    var action: (() -> Void)? = nil

    init(title: String, subtitle: String? = nil,
         iconName: String? = nil, iconBg: Color? = nil,
         value: String? = nil,
         isToggle: Bool = false, toggleValue: Binding<Bool> = .constant(false),
         showChevron: Bool = false, isLast: Bool = false,
         isDanger: Bool = false, action: (() -> Void)? = nil) {
        self.title = title; self.subtitle = subtitle
        self.iconName = iconName; self.iconBg = iconBg
        self.value = value; self.isToggle = isToggle
        self._toggleValue = toggleValue; self.showChevron = showChevron
        self.isLast = isLast; self.isDanger = isDanger; self.action = action
    }

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                if let n = iconName {
                    Image(systemName: n)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 29, height: 29)
                        .background((iconBg ?? t.accent).cornerRadius(7))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.sfPro(size: 17))
                        .foregroundColor(isDanger ? t.red : t.text)
                    if let sub = subtitle {
                        Text(sub)
                            .font(.sfPro(size: 13))
                            .foregroundColor(t.text2)
                    }
                }
                Spacer()
                if let v = value {
                    Text(v)
                        .font(.sfPro(size: 17))
                        .foregroundColor(t.text2)
                }
                if isToggle {
                    Toggle("", isOn: $toggleValue)
                        .labelsHidden()
                        .tint(t.green)
                }
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(t.text3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, subtitle != nil ? 10 : 12)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Divider().padding(.leading, iconName != nil ? 57 : 16)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CoveSection (grouped container)

struct CoveSection<Content: View>: View {
    @Environment(\.coveTheme) var t
    var header: String? = nil
    var footer: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let h = header {
                Text(h.uppercased())
                    .font(.sfPro(size: 13))
                    .foregroundColor(t.text2)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 7)
            }
            VStack(spacing: 0) { content }
                .background(t.surface.cornerRadius(10))
                .padding(.horizontal, 16)
            if let f = footer {
                Text(f)
                    .font(.sfPro(size: 13))
                    .foregroundColor(t.text2)
                    .padding(.horizontal, 32)
                    .padding(.top, 7)
                    .lineSpacing(2)
            }
        }
        .padding(.bottom, 28)
    }
}

// MARK: - AppIconBadge

struct AppIconBadge: View {
    let app: BlockedApp
    var size: CGFloat = 36
    var locked: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(app.letter)
                .font(.system(size: size * 0.44, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(app.bgColor)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
                .opacity(locked ? 0.38 : 1)
                .grayscale(locked ? 0.5 : 0)

            if locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(Color.black)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    .offset(x: 4, y: -4)
            }
        }
    }
}

// MARK: - PillButton

struct CovePillButton: View {
    @Environment(\.coveTheme) var t
    let systemImage: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(t.text)
                .frame(width: 36, height: 36)
                .background(t.systemFill)
                .clipShape(Circle())
        }
    }
}

// MARK: - FocusBanner (slim strip shown on Today)

struct CoveFocusBanner: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        if store.focusActive {
            HStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "scope")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(t.accent)
                        .clipShape(Circle())

                    Circle()
                        .fill(t.green)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(t.bg, lineWidth: 1.5))
                        .offset(x: 2, y: -2)
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text("Deep work")
                            .font(.sfPro(size: 13, weight: .semibold))
                        Text("· \(store.focusSession.remainingSeconds / 60) min · \(store.focusSession.blockedApps.count) apps blocked")
                            .font(.sfPro(size: 13))
                    }
                    .foregroundColor(t.text)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(t.text3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(t.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(t.accent.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .onTapGesture { store.showFocusSession = true }
        }
    }
}

// MARK: - Stat card (daily/weekly review)

struct StatCard: View {
    @Environment(\.coveTheme) var t
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.sfRounded(size: 18, weight: .bold))
                .foregroundColor(tint)
                .monospacedDigit()
            Text(label)
                .font(.sfPro(size: 11, weight: .medium))
                .foregroundColor(t.text2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(t.surface.cornerRadius(14))
    }
}

// MARK: - View modifiers

extension View {
    func coveCard(radius: CGFloat = 18) -> some View {
        self
            .background(Color(UIColor.systemBackground).cornerRadius(radius))
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    func shimmer() -> some View {
        self.redacted(reason: .placeholder)
    }
}
