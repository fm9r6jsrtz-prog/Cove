import SwiftUI

// MARK: - DailyReviewView

struct DailyReviewView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient header
                DailyReviewHeader()

                VStack(spacing: 28) {
                    // Stats strip
                    HStack(spacing: 10) {
                        StatCard(value: "6/8",    label: "Tasks",     tint: t.accent)
                        StatCard(value: "4h 12m", label: "Focus",     tint: t.blue)
                        StatCard(value: "3",      label: "Habits",    tint: t.green)
                        StatCard(value: "2",      label: "Overrides", tint: t.orange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Energy section
                    EnergySection()

                    // Daily win section
                    DailyWinSection()

                    // Tomorrow's top 3
                    TomorrowTop3Section()

                    // Primary CTA
                    Button {
                        dismiss()
                    } label: {
                        Text("Plan tomorrow & wind down")
                            .font(.sfPro(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(t.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(t.bg.ignoresSafeArea())
    }
}

// MARK: - DailyReviewHeader

private struct DailyReviewHeader: View {
    @Environment(\.coveTheme) var t

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EVENING · 21:14")
                .font(.sfPro(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .kerning(1.0)

            Text("How was today?")
                .font(.sfRounded(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("A few questions to close the day with intention.")
                .font(.sfPro(size: 15))
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 28)
        .background(
            LinearGradient(
                colors: [t.accent, t.accent.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - EnergySection

private struct EnergySection: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let energyEmojis = ["😴", "😕", "🙂", "😌", "⚡️"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How did your energy land?")
                .font(.sfPro(size: 17, weight: .semibold))
                .foregroundColor(t.text)
                .padding(.horizontal, 16)

            HStack(spacing: 10) {
                ForEach(Array(energyEmojis.enumerated()), id: \.offset) { index, emoji in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            store.dailyReviewEnergy = index
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(store.dailyReviewEnergy == index
                                          ? t.accentSoft
                                          : t.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(store.dailyReviewEnergy == index
                                                    ? t.accent.opacity(0.4)
                                                    : Color.clear,
                                                    lineWidth: 1.5)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)

            Text("Calm · matched your morning check-in.")
                .font(.sfPro(size: 13))
                .foregroundColor(t.text2)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - DailyWinSection

private struct DailyWinSection: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("One thing that went well")
                .font(.sfPro(size: 17, weight: .semibold))
                .foregroundColor(t.text)
                .padding(.horizontal, 16)

            ZStack(alignment: .topLeading) {
                if store.dailyWin.isEmpty {
                    Text("Got through the spec without checking my phone. Closed the laptop at 5 sharp for once.")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundColor(t.text3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $store.dailyWin)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(t.text)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 110)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .tint(t.accent)
            }
            .background(t.surface.cornerRadius(14))
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - TomorrowTop3Section

private struct TomorrowTop3Section: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let rowColors: [Color] = [
        Color(hex: "6B9B7E"),
        Color(hex: "3478F6"),
        Color(hex: "9B59B6"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tomorrow's top 3")
                    .font(.sfPro(size: 17, weight: .semibold))
                    .foregroundColor(t.text)

                Spacer()

                Button {
                    store.tomorrowTop3 = [
                        "Finish Locket spec · sections 6–8",
                        "Send Q3 plan to Jordan",
                        "Sign lease addendum",
                    ]
                } label: {
                    Text("Suggest")
                        .font(.sfPro(size: 14, weight: .medium))
                        .foregroundColor(t.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(t.accentSoft))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Top3Row(
                        index: index,
                        color: rowColors[index],
                        text: index < store.tomorrowTop3.count ? store.tomorrowTop3[index] : ""
                    ) { newText in
                        if index < store.tomorrowTop3.count {
                            store.tomorrowTop3[index] = newText
                        } else {
                            while store.tomorrowTop3.count <= index {
                                store.tomorrowTop3.append("")
                            }
                            store.tomorrowTop3[index] = newText
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct Top3Row: View {
    @Environment(\.coveTheme) var t
    let index: Int
    let color: Color
    let text: String
    let onEdit: (String) -> Void

    @State private var localText: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // Number circle
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)
                Text("\(index + 1)")
                    .font(.sfPro(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            TextField("Priority \(index + 1)…", text: $localText)
                .font(.sfPro(size: 16))
                .foregroundColor(t.text)
                .tint(t.accent)
                .onChange(of: localText) { _, new in onEdit(new) }

            Spacer()

            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(t.text3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(t.surface.cornerRadius(14))
        .onAppear { localText = text }
        .onChange(of: text) { _, new in
            if localText != new { localText = new }
        }
    }
}

// MARK: - WeeklyReviewView

struct WeeklyReviewView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    @State private var showShareSheet = false

    private let focusHours: [Double] = [3.2, 4.1, 4.2, 2.8, 3.6, 1.2, 0.5]
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    private let moodEmojis = ["😴", "😌", "😌", "😕", "🙂", "😌", "😌"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Date + title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SUN, MAY 17 · WEEK 20")
                            .font(.sfPro(size: 12, weight: .semibold))
                            .foregroundColor(t.accent)
                            .kerning(0.8)

                        Text("Weekly review")
                            .font(.sfRounded(size: 30, weight: .bold))
                            .foregroundColor(t.text)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                    // Focus card
                    FocusWeekCard(hours: focusHours, dayLabels: dayLabels)

                    // 2×2 Highlights grid
                    HighlightsGrid(moodEmojis: moodEmojis)

                    // Reflection card
                    ReflectionCard()

                    // CTA
                    Button {
                    } label: {
                        Text("Set a theme for next week")
                            .font(.sfPro(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(t.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .padding(.top, 12)
            }
            .background(t.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Today") { dismiss() }
                        .foregroundColor(t.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share PDF", systemImage: "square.and.arrow.up")
                            .font(.sfPro(size: 15, weight: .medium))
                            .foregroundColor(t.accent)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: ["Weekly review — Week 20, May 2026\n\nFocus: 19h 36m (+2h 14m vs last)\nHabits: 83%\nMood: Calm"])
            }
        }
    }
}

// MARK: - FocusWeekCard

private struct FocusWeekCard: View {
    @Environment(\.coveTheme) var t
    let hours: [Double]
    let dayLabels: [String]

    private var maxHours: Double { hours.max() ?? 1 }
    private var totalFormatted: String { "19h 36m" }
    private var deltaFormatted: String { "+ 2h 14m vs last" }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus this week")
                .font(.sfPro(size: 15, weight: .semibold))
                .foregroundColor(t.text2)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(totalFormatted)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(t.text)
                    .monospacedDigit()

                Text(deltaFormatted)
                    .font(.sfPro(size: 14, weight: .semibold))
                    .foregroundColor(t.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(t.green.opacity(0.12))
                    .clipShape(Capsule())
            }

            // 7-bar chart
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(hours.enumerated()), id: \.offset) { index, h in
                    let isToday = index == hours.count - 1
                    let barHeight = max(4, (h / maxHours) * 80)

                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(isToday ? t.accent : t.accent.opacity(0.35))
                            .frame(height: barHeight)

                        Text(dayLabels[index])
                            .font(.sfPro(size: 11, weight: .medium))
                            .foregroundColor(isToday ? t.accent : t.text2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .padding(20)
        .background(t.surface.cornerRadius(18))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - HighlightsGrid

private struct HighlightsGrid: View {
    @Environment(\.coveTheme) var t
    let moodEmojis: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            // Deep work card
            HighlightCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Top tag")
                        .font(.sfPro(size: 12, weight: .medium))
                        .foregroundColor(t.text2)

                    Text("Deep work")
                        .font(.sfPro(size: 16, weight: .semibold))
                        .foregroundColor(t.text)

                    // Proportion bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(t.accent.opacity(0.15))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(t.accent)
                                .frame(width: geo.size.width * 0.56, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("56%")
                        .font(.sfPro(size: 13))
                        .foregroundColor(t.accent)
                }
            }

            // Habits card
            HighlightCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Habits")
                        .font(.sfPro(size: 12, weight: .medium))
                        .foregroundColor(t.text2)

                    Text("83%")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(t.green)
                        .monospacedDigit()

                    Text("↑ best week this month")
                        .font(.sfPro(size: 12, weight: .medium))
                        .foregroundColor(t.green)
                }
            }

            // Mood card
            HighlightCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mood")
                        .font(.sfPro(size: 12, weight: .medium))
                        .foregroundColor(t.text2)

                    HStack(spacing: 4) {
                        Text("😌")
                            .font(.system(size: 22))
                        Text("Calm")
                            .font(.sfPro(size: 15, weight: .semibold))
                            .foregroundColor(t.text)
                    }

                    // 7-emoji week row
                    HStack(spacing: 2) {
                        ForEach(Array(moodEmojis.enumerated()), id: \.offset) { _, emoji in
                            Text(emoji)
                                .font(.system(size: 13))
                        }
                    }
                }
            }

            // Overrides card
            HighlightCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Overrides")
                        .font(.sfPro(size: 12, weight: .medium))
                        .foregroundColor(t.text2)

                    Text("4 times")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(t.orange)

                    Text("Mostly Wed evening")
                        .font(.sfPro(size: 12))
                        .foregroundColor(t.text2)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct HighlightCard<Content: View>: View {
    @Environment(\.coveTheme) var t
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .background(t.surface.cornerRadius(16))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }
}

// MARK: - ReflectionCard

private struct ReflectionCard: View {
    @Environment(\.coveTheme) var t

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(t.accent)

                Text("Reflection")
                    .font(.sfPro(size: 15, weight: .semibold))
                    .foregroundColor(t.text)
            }

            Text("What's one habit or boundary you held this week that you want to carry into next week?")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundColor(t.text)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(t.accentTint)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(t.accent.opacity(0.15), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Daily Review") {
    DailyReviewView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}

#Preview("Weekly Review") {
    WeeklyReviewView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
