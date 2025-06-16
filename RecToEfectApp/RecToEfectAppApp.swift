import SwiftUI
import SwiftData

@main
struct RecToEfectAppApp: App {
    @MainActor
    let dataManager = DataManager.shared
    
    init() {
        // Disable idle timer (keep screen awake)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(dataManager.container)
        }
    }
}

struct ContentView: View {
    @State private var isFirstLaunch = !UserDefaults.standard.bool(forKey: "launchedBefore")
    
    var body: some View {
        Group {
            if isFirstLaunch {
                TutorialView()
                    .onDisappear {
                        UserDefaults.standard.set(true, forKey: "launchedBefore")
                        isFirstLaunch = false
                    }
            } else {
                MainView()
            }
        }
    }
}