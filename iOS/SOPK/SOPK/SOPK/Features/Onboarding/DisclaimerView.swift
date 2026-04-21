import SwiftUI

struct DisclaimerView: View {
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    @Environment(\.colorScheme) private var colorScheme

    private var palette: Palette { colorScheme == .dark ? .dark : .light }

    var body: some View {
        ZStack {
            palette.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 52))
                        .foregroundColor(palette.sageDeep)

                    VStack(spacing: 12) {
                        Text("Informations importantes")
                            .font(.custom("Fraunces-Regular", size: 26))
                            .foregroundColor(palette.ink)
                            .multilineTextAlignment(.center)

                        Text("SOPK Food est un outil d'aide à la découverte de recettes adaptées au SOPK et à l'endométriose. Il ne remplace pas l'avis d'un professionnel de santé. Consulte ton médecin ou gynécologue pour tout conseil médical personnalisé.")
                            .font(.system(size: 15))
                            .foregroundColor(palette.inkSoft)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(32)
                .background(palette.card)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 16, y: 6)
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    hasSeenDisclaimer = true
                } label: {
                    Text("J'ai compris")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(palette.sageDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
