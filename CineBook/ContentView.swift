import CoreData
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $appState.moviesPath) {
                HomeView()
            }
            .tabItem { Label("Movies", systemImage: "film") }
            .tag(0)

            NavigationStack {
                MyBookingsView()
            }
            .tabItem { Label("My Bookings", systemImage: "ticket") }
            .tag(1)
        }
        .environmentObject(appState)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
