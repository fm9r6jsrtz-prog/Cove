import SwiftUI

@main
struct CoveApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.themeDark ? .dark : .light)
                .tint(store.theme.accent)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ZStack {
            if store.isLocked {
                LockView()
                    .transition(.opacity)
            } else if !store.hasOnboarded {
                OnboardingView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.45), value: store.isLocked)
        .animation(.spring(duration: 0.45), value: store.hasOnboarded)
    }
}
