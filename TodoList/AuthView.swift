
import SwiftUI

struct AuthView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 65))
                    .foregroundColor(.blue)

                Text("My Todo App")
                    .font(.largeTitle)
                    .bold()

                Text(
                    isRegistering
                    ? "Create your account"
                    : "Login to your account"
                )
                .font(.headline)
                .foregroundColor(.secondary)

                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(10)

                Button {
                    if isRegistering {
                        authViewModel.signUp(
                            email: email.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            password: password
                        )
                    } else {
                        authViewModel.login(
                            email: email.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            password: password
                        )
                    }
                } label: {
                    Text(isRegistering ? "Register" : "Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(
                    email.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty || password.isEmpty
                )

                Button {
                    isRegistering.toggle()
                    authViewModel.errorMessage = ""
                } label: {
                    Text(
                        isRegistering
                        ? "Already have an account? Login"
                        : "Don't have an account? Register"
                    )
                    .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding(25)
            .alert(
                "Authentication Error",
                isPresented: $authViewModel.showError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authViewModel.errorMessage)
            }
        }
    }
}
