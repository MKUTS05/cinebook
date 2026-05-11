import Combine
import SwiftUI

/// Shared navigation state for the app's tab bar and Movies navigation stack.
/// Injected as an EnvironmentObject from ContentView so any deep view can
/// switch tabs or pop the Movies stack to root (e.g. after a booking is confirmed).
@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab = 0
    @Published var moviesPath = NavigationPath()
}
