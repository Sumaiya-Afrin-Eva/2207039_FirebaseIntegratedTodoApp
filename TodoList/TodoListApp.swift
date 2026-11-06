
import SwiftUI
import FirebaseCore

@main
struct FirebaseTodoApp: App {

    @StateObject private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        _authViewModel = StateObject(
            wrappedValue: AuthViewModel()
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
