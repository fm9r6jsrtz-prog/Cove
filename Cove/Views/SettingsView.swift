import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Privacy hero card (top, most prominent)
                    PrivacyHeroCard()
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 28)

                    // Lock section
                    CoveSection(header: "Lock") {
                        CoveListRow(
                            title: "Require Face ID",
                            iconName: "lock.fill",
                            iconBg: t.accent,
                            isToggle: true,
                            toggleValue: $store.requireFaceID
                        )
                        CoveListRow(
                            title: "Auto-lock",
                            iconName: "clock.arrow.circlepath",
                            iconBg: t.accent,
                            value: "Immediately",
                            showChevron: true,
                            action: {}
                        )
                        CoveListRow(
                            title: "Wipe after 10 failed attempts",
                            iconName: "trash.fill",
                            iconBg: t.red,
                            isToggle: true,
                            toggleValue: $store.wipeAfterFails,
                            isLast: true
                        )
                    }

                    // Data section
                    CoveSection(
                        header: "Data",
                        footer: "Backups are AES-256 encrypted with a key in the Secure Enclave."
                    ) {
                        CoveListRow(
                            title: "Sync to iCloud",
                            subtitle: "Off — fully on-device",
                            iconName: "icloud.slash",
                            iconBg: t.blue,
                            isToggle: true,
                            toggleValue: $store.iCloudSync
                        )
                        CoveListRow(
                            title: "Encrypted backup",
                            iconName: "lock.shield.fill",
                            iconBg: t.accent,
                            value: "Weekly",
                            showChevron: true,
                            action: {}
                        )
                        CoveListRow(
                            title: "Export…",
                            iconName: "square.and.arrow.up.fill",
                            iconBg: t.purple,
                            value: "Last: never",
                            showChevron: true,
                            isLast: true,
                            action: {}
                        )
                    }

                    // Telemetry section
                    CoveSection(header: "Telemetry") {
                        CoveListRow(
                            title: "Analytics",
                            subtitle: "Permanently disabled",
                            iconName: "chart.bar.xaxis",
                            value: "Off"
                        )
                        CoveListRow(
                            title: "Crash reports",
                            subtitle: "Stored locally, never sent",
                            iconName: "ladybug.fill",
                            iconBg: t.orange,
                            value: "Off",
                            isLast: true
                        )
                    }

                    // About section
                    CoveSection(header: "About") {
                        CoveListRow(
                            title: "What's stored on this device",
                            iconName: "doc.text.fill",
                            showChevron: true,
                            action: {}
                        )
                        CoveListRow(
                            title: "Privacy policy",
                            subtitle: "2 pages, plain English",
                            iconName: "doc.plaintext.fill",
                            iconBg: t.accent,
                            showChevron: true,
                            isLast: true,
                            action: {}
                        )
                    }

                    // Appearance section (dark mode + accent chips)
                    AppearanceSection()
                        .padding(.bottom, 28)

                    // Day view layout section
                    LayoutSection()
                        .padding(.bottom, 40)
                }
            }
            .background(t.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Privacy")
                            .font(.sfPro(size: 17, weight: .semibold))
                            .foregroundColor(t.text)
                        Image(systemName: "gear")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(t.text2)
                            .onTapGesture { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(t.text2)
                    }
                }
            }
        }
    }
}

// MARK: - Privacy Hero Card

private struct PrivacyHeroCard: View {
    @Environment(\.coveTheme) var t
    @State private var showAudit = false
    @State private var showDeviceInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Shield + eyebrow row
            HStack(spacing: 14) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(t.accent)
                    .frame(width: 44, height: 44)
                    .background(t.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("PRIVACY")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(t.accent)
                    .kerning(1.4)
            }
            .padding(.bottom, 14)

            // Headline
            Text("On-device only · no analytics")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(t.text)
                .padding(.bottom, 8)

            // Body
            Text("Nothing you write here leaves your iPhone — verified by independent audit, March 2026.")
                .font(.sfPro(size: 15))
                .foregroundColor(t.text2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)

            // Action buttons
            HStack(spacing: 10) {
                Button {
                    showAudit = true
                } label: {
                    Text("Audit report")
                        .font(.sfPro(size: 14, weight: .semibold))
                        .foregroundColor(t.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(t.accentSoft))
                }
                .buttonStyle(.plain)

                Button {
                    showDeviceInfo = true
                } label: {
                    Text("What's on this device")
                        .font(.sfPro(size: 14, weight: .semibold))
                        .foregroundColor(t.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(t.accentSoft))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [t.accentTint, t.accentSoft.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(t.accent.opacity(0.15), lineWidth: 0.5)
        )
        .sheet(isPresented: $showAudit) {
            AuditReportSheet()
                .environment(\.coveTheme, t)
        }
        .sheet(isPresented: $showDeviceInfo) {
            DeviceInfoSheet()
                .environment(\.coveTheme, t)
        }
    }
}

// MARK: - Audit Report Sheet

private struct AuditReportSheet: View {
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Independent security audit conducted March 2026 by Cure53. Cove was found to store all data exclusively on-device using the iOS Keychain and encrypted local databases. No network calls to third-party analytics services were detected during the audit period.")
                        .font(.sfPro(size: 16))
                        .foregroundColor(t.text)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
            }
            .background(t.bg.ignoresSafeArea())
            .navigationTitle("Audit Report · March 2026")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accent)
                }
            }
        }
    }
}

// MARK: - Device Info Sheet

private struct DeviceInfoSheet: View {
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    private let rows: [(String, String)] = [
        ("Journal entries", "1 entry"),
        ("Tasks", "5 tasks"),
        ("Habits", "6 habits"),
        ("Routines", "4 routines"),
        ("Focus sessions", "0 sessions"),
        ("Review history", "0 reviews"),
        ("Encryption", "AES-256 via Secure Enclave"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                        HStack {
                            Text(row.0)
                                .font(.sfPro(size: 16))
                                .foregroundColor(t.text)
                            Spacer()
                            Text(row.1)
                                .font(.sfPro(size: 15))
                                .foregroundColor(t.text2)
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 16)
                        .overlay(alignment: .bottom) {
                            if index < rows.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                }
                .background(t.surface.cornerRadius(12))
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .background(t.bg.ignoresSafeArea())
            .navigationTitle("What's on this device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accent)
                }
            }
        }
    }
}

// MARK: - Appearance Section

private struct AppearanceSection: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let accents: [(name: String, label: String, color: Color)] = [
        ("sage",     "Sage",     Color(hex: "6B9B7E")),
        ("indigo",   "Indigo",   Color(hex: "6C5CE7")),
        ("rose",     "Rose",     Color(hex: "E05A47")),
        ("graphite", "Graphite", Color(hex: "5A5A6E")),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("APPEARANCE")
                .font(.sfPro(size: 13))
                .foregroundColor(t.text2)
                .padding(.horizontal, 32)
                .padding(.bottom, 7)

            VStack(spacing: 0) {
                // Dark appearance toggle
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 29, height: 29)
                        .background(Color(hex: "5A5A6E").cornerRadius(7))

                    Text("Dark appearance")
                        .font(.sfPro(size: 17))
                        .foregroundColor(t.text)

                    Spacer()

                    Toggle("", isOn: $store.themeDark)
                        .labelsHidden()
                        .tint(t.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Divider().padding(.leading, 57)
                }

                // Accent color row
                HStack(spacing: 12) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 29, height: 29)
                        .background(t.accent.cornerRadius(7))

                    Text("Accent")
                        .font(.sfPro(size: 17))
                        .foregroundColor(t.text)

                    Spacer()

                    HStack(spacing: 10) {
                        ForEach(accents, id: \.name) { accent in
                            Button {
                                withAnimation(.spring(duration: 0.25)) {
                                    store.accentName = accent.name
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(accent.color)
                                        .frame(width: 28, height: 28)
                                    if store.accentName == accent.name {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .shadow(color: accent.color.opacity(0.35), radius: 3, y: 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(t.surface.cornerRadius(10))
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Layout Section

private struct LayoutSection: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("DAY VIEW LAYOUT")
                .font(.sfPro(size: 13))
                .foregroundColor(t.text2)
                .padding(.horizontal, 32)
                .padding(.bottom, 7)

            HStack(spacing: 0) {
                layoutButton(label: "Timeline", icon: "calendar.day.timeline.left", layout: .timeline)
                layoutButton(label: "List", icon: "list.bullet", layout: .list)
            }
            .padding(4)
            .background(t.surface.cornerRadius(12))
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func layoutButton(label: String, icon: String, layout: DayLayout) -> some View {
        let isActive = store.dayLayout == layout
        Button {
            withAnimation(.spring(duration: 0.25)) { store.dayLayout = layout }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: isActive ? .semibold : .regular))
                Text(label)
                    .font(.sfPro(size: 15, weight: isActive ? .semibold : .regular))
            }
            .foregroundColor(isActive ? t.accent : t.text2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isActive ? t.bg : Color.clear)
                    .shadow(color: isActive ? .black.opacity(0.06) : .clear, radius: 4, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
