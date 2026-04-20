import SwiftUI
import AuthenticationServices

struct NourriAuthWelcomeView: View {
    @State private var showLogin = false
    @State private var showSignup = false
    @EnvironmentObject var authViewModel: AuthViewModel
    let palette: Palette

    var body: some View {
        ZStack {
            palette.bg.ignoresSafeArea()

            // Decorative circles
            GeometryReader { geo in
                let w = geo.size.width
                Circle()
                    .fill(palette.sageWash)
                    .frame(width: w * 0.9, height: w * 0.9)
                    .offset(x: -w * 0.25, y: -w * 0.18)
                Circle()
                    .fill(palette.terracottaLight.opacity(0.6))
                    .frame(width: w * 0.55, height: w * 0.55)
                    .offset(x: w * 0.6, y: w * 0.1)
                Circle()
                    .fill(palette.sageLight.opacity(0.5))
                    .frame(width: w * 0.4, height: w * 0.4)
                    .offset(x: w * 0.05, y: geo.size.height - w * 0.3)
                Circle()
                    .fill(palette.beige)
                    .frame(width: w * 0.3, height: w * 0.3)
                    .offset(x: w * 0.75, y: geo.size.height - w * 0.22)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                NouririBowlLogo(palette: palette)
                    .padding(.bottom, 28)

                // Title
                Text("Nourrir votre cycle,\napaiser l'inflammation")
                    .font(.custom("Fraunces_9pt-Regular", size: 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(palette.ink)
                    .lineSpacing(2)
                    .padding(.horizontal, 32)

                Text("Recettes anti-inflammatoires adaptées\nau SOPK et à l'endométriose")
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(palette.inkSoft)
                    .padding(.top, 12)
                    .padding(.horizontal, 32)

                Spacer()

                // CTAs
                VStack(spacing: 12) {
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

                    // Email
                    Button(action: { showSignup = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16, weight: .medium))
                            Text("Continuer par email")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(palette.sageDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(palette.sageWash)
                        .clipShape(Capsule())
                    }

                    // Login link
                    Button(action: { showLogin = true }) {
                        Text("Déjà un compte ? ")
                            .foregroundColor(palette.inkMuted)
                        + Text("Se connecter")
                            .foregroundColor(palette.sageDeep)
                            .bold()
                    }
                    .font(.system(size: 14))
                    .padding(.top, 4)

                    // GDPR
                    Text("En continuant, vous acceptez nos Conditions d'utilisation et notre Politique de confidentialité.")
                        .font(.system(size: 11))
                        .multilineTextAlignment(.center)
                        .foregroundColor(palette.inkMuted)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            NourriAuthLoginView(palette: palette)
        }
        .fullScreenCover(isPresented: $showSignup) {
            NourriAuthSignupView(palette: palette)
        }
    }
}

// MARK: - Bowl logo
struct NouririBowlLogo: View {
    let palette: Palette
    var size: CGFloat = 100

    var body: some View {
        ZStack {
            Circle()
                .fill(palette.sageWash)
                .frame(width: size, height: size)

            NouririBowlCanvas(palette: palette)
                .frame(width: size * 0.68, height: size * 0.68)
        }
    }
}

// MARK: - Bowl canvas illustration
struct NouririBowlCanvas: View {
    let palette: Palette

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h * 0.58

            // Steam (3 wavy lines)
            let steamOffsets: [CGFloat] = [-0.22, 0, 0.22]
            for dx in steamOffsets {
                let sx = cx + dx * w
                var s = Path()
                s.move(to: CGPoint(x: sx, y: cy - h * 0.38))
                s.addCurve(
                    to: CGPoint(x: sx, y: cy - h * 0.6),
                    control1: CGPoint(x: sx + w * 0.06, y: cy - h * 0.45),
                    control2: CGPoint(x: sx - w * 0.06, y: cy - h * 0.53)
                )
                ctx.stroke(s, with: .color(palette.terracotta.opacity(0.55)), lineWidth: 2)
            }

            // Bowl arc (half-ellipse)
            var bowl = Path()
            bowl.addArc(
                center: CGPoint(x: cx, y: cy),
                radius: w * 0.42,
                startAngle: .degrees(0), endAngle: .degrees(180),
                clockwise: false
            )
            ctx.stroke(bowl, with: .color(palette.sageDeep), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            // Bowl rim (full ellipse top)
            var rim = Path()
            rim.addEllipse(in: CGRect(x: cx - w * 0.42, y: cy - h * 0.07,
                                      width: w * 0.84, height: h * 0.14))
            ctx.stroke(rim, with: .color(palette.sageDeep), lineWidth: 3)

            // Bowl base
            var base = Path()
            base.move(to: CGPoint(x: cx - w * 0.18, y: cy + h * 0.36))
            base.addLine(to: CGPoint(x: cx + w * 0.18, y: cy + h * 0.36))
            ctx.stroke(base, with: .color(palette.sageDeep), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            // Leaf on top
            var leaf = Path()
            leaf.move(to: CGPoint(x: cx + w * 0.06, y: cy - h * 0.12))
            leaf.addCurve(
                to: CGPoint(x: cx + w * 0.28, y: cy - h * 0.26),
                control1: CGPoint(x: cx + w * 0.16, y: cy - h * 0.06),
                control2: CGPoint(x: cx + w * 0.28, y: cy - h * 0.14)
            )
            leaf.addCurve(
                to: CGPoint(x: cx + w * 0.06, y: cy - h * 0.12),
                control1: CGPoint(x: cx + w * 0.22, y: cy - h * 0.36),
                control2: CGPoint(x: cx + w * 0.06, y: cy - h * 0.28)
            )
            ctx.fill(leaf, with: .color(palette.sage.opacity(0.85)))
        }
    }
}

// MARK: - Auth provider button
struct AuthProviderButton: View {
    let icon: String
    let label: String
    let bg: Color
    let fg: Color
    var border: Color = .clear
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(fg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(bg)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(border, lineWidth: 1))
        }
    }
}

