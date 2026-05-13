import SwiftUI

// MARK: - RoutinesView

struct RoutinesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your routines run in the background, guiding your day.")
                            .font(.sfPro(size: 15))
                            .foregroundColor(t.text2)
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    VStack(spacing: 14) {
                        ForEach(store.routines) { routine in
                            RoutineCard(routine: routine)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(t.bg)
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Habits")
                                .font(.sfPro(size: 17))
                        }
                        .foregroundColor(t.accent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(t.accent)
                    }
                }
            }
        }
    }
}

// MARK: - RoutineCard

private struct RoutineCard: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    let routine: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 10) {
                    Text(routine.emoji)
                        .font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(routine.name)
                            .font(.sfPro(size: 16, weight: .semibold))
                            .foregroundColor(t.text)
                        Text("\(routine.durationMins) min · \(routine.steps.count) steps")
                            .font(.sfPro(size: 13))
                            .foregroundColor(t.text2)
                    }
                }
                Spacer()
                if routine.isRunning {
                    Text("Active")
                        .font(.sfPro(size: 12, weight: .semibold))
                        .foregroundColor(t.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(t.green.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if routine.isRunning {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(routine.steps.indices, id: \.self) { i in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(i <= routine.currentStep ? t.accent : t.systemFill)
                                .frame(width: 8, height: 8)
                            Text(routine.steps[i])
                                .font(.sfPro(size: 14, weight: i == routine.currentStep ? .semibold : .regular))
                                .foregroundColor(i == routine.currentStep ? t.text : (i < routine.currentStep ? t.text3 : t.text2))
                                .strikethrough(i < routine.currentStep, color: t.text3)
                        }
                    }
                }

                Button {
                    store.advanceRoutineStep(routine)
                } label: {
                    Text("Next step")
                        .font(.sfPro(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(t.accent)
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    store.startRoutine(routine)
                } label: {
                    Text("Start routine")
                        .font(.sfPro(size: 15, weight: .medium))
                        .foregroundColor(t.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(t.accentSoft)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(t.surface.cornerRadius(18))
    }
}

// MARK: - Preview

#Preview {
    RoutinesView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
