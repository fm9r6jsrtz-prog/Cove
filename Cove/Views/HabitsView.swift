import SwiftUI

// MARK: - HabitsView

struct HabitsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @State private var showRoutines = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("THIS WEEK")
                                .font(.sfPro(size: 12, weight: .semibold))
                                .foregroundColor(t.accent)
                                .tracking(0.5)
                            Text("Habits")
                                .font(.sfRounded(size: 30, weight: .bold))
                                .foregroundColor(t.text)
                        }

                        Spacer()

                        HStack(spacing: 10) {
                            // Routines button
                            Button {
                                showRoutines = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "list.bullet.rectangle")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Routines")
                                        .font(.sfPro(size: 14, weight: .medium))
                                }
                                .foregroundColor(t.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(t.accentSoft)
                                .clipShape(Capsule())
                            }

                            // Add habit button
                            Button {
                                // placeholder
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 34, height: 34)
                                    .background(t.accent)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .padding(.bottom, 20)

                    // Summary card
                    HabitSummaryCard()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)

                    // Habit list
                    VStack(spacing: 0) {
                        ForEach(store.habits.indices, id: \.self) { i in
                            HabitRow(habit: store.habits[i])
                                .overlay(alignment: .bottom) {
                                    if i < store.habits.count - 1 {
                                        Divider().padding(.leading, 62)
                                    }
                                }
                        }
                    }
                    .background(t.surface.cornerRadius(16))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .background(t.bg)
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showRoutines) {
            RoutinesView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
    }
}

// MARK: - HabitSummaryCard

private struct HabitSummaryCard: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    // Last 14 days mock data
    private let sparklineData: [Double] = [0.4, 0.6, 0.5, 0.8, 0.75, 0.9, 0.65, 0.7, 0.85, 0.72, 0.88, 0.9, 0.95, 0.78]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Best streak top right
            VStack(alignment: .trailing, spacing: 2) {
                Text("Best streak")
                    .font(.sfPro(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                HStack(spacing: 3) {
                    Text("31 days")
                        .font(.sfPro(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("🔥")
                        .font(.system(size: 14))
                }
            }
            .padding(18)

            VStack(alignment: .leading, spacing: 20) {
                // Completion
                VStack(alignment: .leading, spacing: 4) {
                    Text("Completion")
                        .font(.sfPro(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(store.habitCompletionPct)%")
                        .font(.sfRounded(size: 56, weight: .bold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }

                // Sparkline
                SparklineChart(values: sparklineData)
                    .frame(height: 36)
            }
            .padding(22)
        }
        .background(
            LinearGradient(
                colors: [t.accent, t.accent.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: t.accent.opacity(0.28), radius: 16, y: 6)
    }
}

// MARK: - SparklineChart

private struct SparklineChart: View {
    let values: [Double]
    @Environment(\.coveTheme) var t

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(values.indices, id: \.self) { i in
                    let v = values[i]
                    let barH = max(4, geo.size.height * v)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.white.opacity(0.55 + 0.45 * v))
                        .frame(width: (geo.size.width - CGFloat(values.count - 1) * 3) / CGFloat(values.count),
                               height: barH)
                }
            }
        }
    }
}

// MARK: - HabitRow

private struct HabitRow: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    let habit: Habit

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(spacing: 12) {
            // Emoji icon
            Text(habit.emoji)
                .font(.system(size: 20))
                .frame(width: 42, height: 42)
                .background(t.accentSoft)
                .clipShape(Circle())

            // Name + streak + history
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(habit.name)
                        .font(.sfPro(size: 15, weight: .semibold))
                        .foregroundColor(t.text)

                    if habit.streak > 0 {
                        HStack(spacing: 2) {
                            if habit.streak >= 7 {
                                Text("🔥")
                                    .font(.system(size: 12))
                            }
                            Text("\(habit.streak)")
                                .font(.sfPro(size: 12, weight: .semibold))
                                .foregroundColor(habit.streak >= 7 ? .orange : t.text2)
                        }
                    }
                }

                // Week history squares
                HStack(spacing: 4) {
                    ForEach(habit.weekHistory.indices, id: \.self) { d in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(habit.weekHistory[d] ? t.accent : t.systemFill)
                            .frame(width: 16, height: 16)
                    }
                }
            }

            Spacer()

            // Checkmark circle
            Button {
                store.toggleHabit(habit)
            } label: {
                Image(systemName: habit.completedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(habit.completedToday ? t.green : t.text3)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview {
    HabitsView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
