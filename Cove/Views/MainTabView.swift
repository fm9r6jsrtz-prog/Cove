import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area — fills the full screen
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)

            // Custom floating tab bar
            CoveTabBar()
        }
        .environment(\.coveTheme, store.theme)
        // Full-screen focus session modal
        .fullScreenCover(isPresented: $store.showFocusSession) {
            FocusSessionView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        }
        // Daily review sheet
        .sheet(isPresented: $store.showDailyReview) {
            DailyReviewView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        }
        // Weekly review sheet
        .sheet(isPresented: $store.showWeeklyReview) {
            WeeklyReviewView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        }
    }

    // MARK: - Tab content switcher

    @ViewBuilder
    private var tabContent: some View {
        switch store.selectedTab {
        case .today:
            TodayView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        case .calendar:
            CalendarView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        case .focus:
            FocusView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        case .habits:
            HabitsView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        case .journal:
            JournalView()
                .environmentObject(store)
                .environment(\.coveTheme, store.theme)
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
