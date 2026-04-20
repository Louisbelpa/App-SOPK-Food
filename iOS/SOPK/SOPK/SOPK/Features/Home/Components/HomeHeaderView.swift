import SwiftUI

/// Top section of the home screen: greeting, date, and cycle phase banner.
struct HomeHeaderView: View {
    let palette: Palette
    let firstName: String
    let todayString: String
    let phase: (name: String, day: Int, of: Int)
    let phaseAdvice: String
    let isCycleConfigured: Bool
    let onProfileTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(todayString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.3)
                        .textCase(.uppercase)
                    Text("Bonjour ") + Text(firstName.isEmpty ? "" : firstName).italic().foregroundColor(palette.sageDeep) + Text("")
                }
                .font(.custom("Fraunces", size: 30).weight(.regular))
                .foregroundColor(palette.ink)

                Spacer()

                Button(action: onProfileTap) {
                    Image(systemName: "person")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(palette.ink)
                        .frame(width: 42, height: 42)
                        .background(palette.surface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(palette.line, lineWidth: 1))
                }
            }

            // Cycle phase banner
            HStack(spacing: 14) {
                CycleDial(day: phase.day, of: phase.of, palette: palette)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Phase \(phase.name.lowercased()) · J\(phase.day)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.4)
                        .textCase(.uppercase)
                    Text(isCycleConfigured ? phaseAdvice : "Configurez votre cycle pour des recommandations personnalisées")
                        .font(.custom("Fraunces", size: 17))
                        .foregroundColor(palette.ink)
                        .lineSpacing(2)
                }
                Spacer()
            }
            .padding(16)
            .background(palette.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .padding(.top, 70)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}
