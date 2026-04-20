import SwiftUI

struct NourriAuthSignupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    let palette: Palette

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var rgpdAccepted = false
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password }

    // Password strength: 0–4
    var passwordStrength: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { score += 1 }
        return score
    }

    var strengthLabel: String {
        switch passwordStrength {
        case 0: return password.isEmpty ? "" : "Trop court"
        case 1: return "Faible"
        case 2: return "Correct"
        case 3: return "Bon"
        default: return "Excellent"
        }
    }

    var strengthColor: Color {
        switch passwordStrength {
        case 0: return palette.danger
        case 1: return palette.danger
        case 2: return palette.warn
        case 3: return palette.sage
        default: return palette.sageDeep
        }
    }

    var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 8 && rgpdAccepted
    }

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
                        Text("Créons ")
                            .font(.custom("Fraunces_9pt-Regular", size: 30))
                            .foregroundColor(palette.ink)
                        + Text("votre compte")
                            .font(.custom("Fraunces_9pt-Italic", size: 30))
                            .foregroundColor(palette.sageDeep)

                        Text("Rejoignez la communauté Nourrir et commencez votre parcours santé personnalisé.")
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
                            icon: "person",
                            placeholder: "Prénom",
                            text: $name,
                            palette: palette
                        )
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }

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

                        // Password + eye toggle
                        ZStack(alignment: .trailing) {
                            AuthTextField(
                                icon: "lock",
                                placeholder: "Mot de passe",
                                text: $password,
                                palette: palette,
                                isSecure: !showPassword
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .font(.system(size: 15))
                                    .foregroundColor(palette.inkMuted)
                                    .padding(.trailing, 16)
                            }
                        }

                        // Password strength
                        if !password.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 4) {
                                    ForEach(0..<4) { i in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(i < passwordStrength ? strengthColor : palette.line)
                                            .frame(height: 4)
                                            .animation(.spring(duration: 0.25), value: passwordStrength)
                                    }
                                }
                                Text(strengthLabel)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(strengthColor)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    // RGPD consent
                    Button(action: { withAnimation(.spring(duration: 0.2)) { rgpdAccepted.toggle() } }) {
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(rgpdAccepted ? palette.sageDeep : palette.surface)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(rgpdAccepted ? Color.clear : palette.line, lineWidth: 1.5)
                                    )
                                if rgpdAccepted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            Text("J'accepte les ")
                                .foregroundColor(palette.inkSoft)
                            + Text("Conditions d'utilisation")
                                .foregroundColor(palette.sageDeep)
                                .underline()
                            + Text(" et la ")
                                .foregroundColor(palette.inkSoft)
                            + Text("Politique de confidentialité")
                                .foregroundColor(palette.sageDeep)
                                .underline()
                            + Text(". Mes données sont traitées conformément au RGPD.")
                                .foregroundColor(palette.inkSoft)
                        }
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // CTA
                    Button(action: {
                        Task {
                            await authViewModel.register(
                                email: email,
                                password: password,
                                displayName: name,
                                condition: nil
                            )
                        }
                    }) {
                        ZStack {
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Créer mon compte")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? palette.sageDeep : palette.sageDeep.opacity(0.35))
                        .clipShape(Capsule())
                    }
                    .disabled(!canSubmit || authViewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .animation(.spring(duration: 0.2), value: canSubmit)

                    // Already have account
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Text("Déjà un compte ? ")
                                .foregroundColor(palette.inkMuted)
                            + Text("Se connecter")
                                .foregroundColor(palette.sageDeep)
                                .bold()
                        }
                        .font(.system(size: 14))
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}
