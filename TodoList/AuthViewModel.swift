
import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {

    @Published var user: User?
    @Published var errorMessage = ""
    @Published var showError = false

    private var authStateListener:
        AuthStateDidChangeListenerHandle?

    init() {
        authStateListener =
            Auth.auth().addStateDidChangeListener {
                [weak self] _, user in

                DispatchQueue.main.async {
                    self?.user = user
                }
            }
    }

    // Register a new user
    func signUp(email: String, password: String) {

        errorMessage = ""

        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { [weak self] _, error in

            if let error = error {
                self?.handleError(error)
            }
        }
    }

    // Login an existing user
    func login(email: String, password: String) {

        errorMessage = ""

        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { [weak self] _, error in

            if let error = error {
                self?.handleError(error)
            }
        }
    }

    // Logout
    func logout() {

        do {
            try Auth.auth().signOut()
        } catch {
            handleError(error)
        }
    }

    // Handle authentication errors
    private func handleError(_ error: Error) {

        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
