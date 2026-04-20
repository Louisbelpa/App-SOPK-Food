import SwiftUI
import AuthenticationServices

struct NourriAuthLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    let palette: Palette

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showSignup = false
    @State private var showResetPassword = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            palette.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Nav
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(palette.ink)
                                .frame(width: 42, height: 42)
                                .background(palette.surface)
                                .clipShape(Circle())
                                .shadow(color: palette.ink.opacity(0.06), radius: 4, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)

                    // Heading
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Heureux de vous ")
                            .font(.custom("Fraunces_9pt-Regular", size: 30))
                            .foregroundColor(palette.ink)
                        + Text("revoir")
                            .font(.custom("Fraunces_9pt-Italic", size: 30))
                            .foregroundColor(palette.sageDeep)

                        Text("Connectez-vous pour retrouver vos recettes et votre plan personnalisé.")
                            .font(.system(size: 14))
                            .foregroundColor(palette.inkSoft)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // Error
                    if let err = authViewModel.error {
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(palette.danger)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                    }

                    // Form
                    VStack(spacing: 12) {
                        AuthTextField(
                            icon: "envelope",
                            placeholder: "Adresse email",
                            text: $email,
                            palette: palette,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        ZStack(alignment: .trailing) {
                            if showPassword {
                                AuthTextField(
                                    icon: "lock",
                                    placeholder: "Mot de passe",
                                    text: $password,
                                    palette: palette,
                                    isSecure: false
                                )
                                .focused($focusedField, equals: .password)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil }
                            } else {
                                AuthTextField(
                                    icon: "lock",
                                    placeholder: "Mot de passe",
                                    text: $password,
                                    palette: palette,
                                    isSecure: true
                                )
                                .focused($focusedField, equals: .password)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil }
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .font(.system(size: 15))
                                    .foregroundColor(palette.inkMuted)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // Forgot password
                    Button("Mot de passe oublié ?") { showResetPassword = true }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(palette.sageDeep)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    // Login CTA
                    Button(action: {
                        Task { await authViewModel.login(email: email, password: password) }
                    }) {
                        ZStack {
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Se connecter")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            email.isEmpty || password.isEmpty
                                ? palette.sageDeep.opacity(0.4)
                                : palette.sageDeep
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Divider
                    HStack(spacing: 12) {
                        Rectangle().fill(palette.line).frame(height: 1)
                        Text("ou")
                            .font(.system(size: 12))
                            .foregroundColor(palette.inkMuted)
                        Rectangle().fill(palette.line).frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)

                    // SSO
                    VStack(spacing: 10) {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                      let tokenData = credential.identityToken,
                                      let idToken = String(data: tokenData, encoding: .utf8)
                                else {
                                    authViewModel.error = "Token Apple invalide"
                                    return
                                }

                                let given = credential.fullName?.givenName ?? ""
                                let family = credential.fullName?.familyName ?? ""
                                let hint = "\(given) \(family)".trimmingCharacters(in: .whitespacesAndNewlines)

                                Task {
                                    await authViewModel.signInWithApple(
                                        idToken: idToken,
                                        displayNameHint: hint.isEmpty ? nil : hint
                                    )
                                }
                            case .failure(let err):
                                authViewModel.error = err.localizedDescription
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 54)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)

                    // Signup link
                    HStack(spacing: 0) {
                        Spacer()
                        Button(action: { showSignup = true }) {
                            Text("Pas encore de compte ? ")
                                .foregroundColor(palette.inkMuted)
                            + Text("S'inscrire")
                                .foregroundColor(palette.sageDeep)
                                .bold()
                        }
                        .font(.system(size: 14))
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 48)
                }
            }
        }
        .fullScreenCover(isPresented: $showSignup) {
            NourriAuthSignupView(palette: palette)
        }
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordSheet(palette: palette)
                .environmentObject(authViewModel)
        }
    }
}

private struct ResetPasswordSheet: View {
    let palette: Palette
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Mot de passe oublié")
                .font(.custom("Fraunces_9pt-Regular", size: 24))
                .foregroundColor(palette.ink)
                .padding(.top, 32)

            Text("Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe.")
                .font(.system(size: 14))
                .foregroundColor(palette.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            AuthTextField(
                icon: "envelope",
                placeholder: "Adresse email",
                text: $email,
                palette: palette,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            .padding(.horizontal, 24)

            if let msg = authViewModel.error {
                Text(msg)
                    .font(.system(size: 13))
                    .foregroundColor(msg.contains("✓") ? palette.sageDeep : palette.danger)
                    .padding(.horizontal, 24)
            }

            Button {
                Task {
                    await authViewModel.resetPassword(email: email)
                    if authViewModel.error?.contains("✓") == true {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        dismiss()
                    }
                }
            } label: {
                Text("Envoyer le lien")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(email.isEmpty ? palette.sageDeep.opacity(0.4) : palette.sageDeep)
                    .clipShape(Capsule())
            }
            .disabled(email.isEmpty || authViewModel.isLoading)
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(palette.bg.ignoresSafeArea())
        .onDisappear { authViewModel.error = nil }
    }
}

// MARK: - Reusable text field
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let palette: Palette
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(palette.inkMuted)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(palette.ink)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(palette.ink)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(palette.line, lineWidth: 1)
        )
    }
}
