
import SwiftUI
import SwiftData

@main
struct FinnishMPsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                SavedMP.self,
                SavedParty.self
            ]
        )
    }
}

