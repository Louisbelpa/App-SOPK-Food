import SwiftUI

// MARK: - Data
private let symptoms = [
    "Fatigue chronique", "Règles douloureuses", "Ballonnements", "Prise de poids",
    "Acné hormonale", "Troubles du sommeil", "Anxiété", "Douleurs pelviennes"
]

private let avoidTags = [
    "Gluten", "Lactose", "Sucre raffiné", "Alcool",
    "Caféine", "Viande rouge", "Soja non-fermenté (modération)"
]

// MARK: - Main View
struct NourriOnboardingView: View {
    let palette: Palette
    var onDone: () -> Void

    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var step = 0
    @State private var selectedCondition: String? = nil
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedAvoid: Set<String> = []

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal, 24)
                .padding(.top, 16)

            Group {
                switch step {
                case 0: welcomeStep
                case 1: conditionStep
                case 2: symptomsStep
                case 3: avoidStep
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.3), value: step)

            bottomCTA
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .background(palette.bg.ignoresSafeArea())
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(i <= step ? palette.sageDeep : palette.sageWash)
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Steps
    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 56))
                .foregroundColor(palette.sageDeep)

            VStack(spacing: 12) {
                Text("Une cuisine")
                    .font(.custom("Fraunces-Regular", size: 34))
                    .foregroundColor(palette.ink)
                + Text(" qui vous écoute")
                    .font(.custom("Fraunces-Italic", size: 34))
                    .foregroundColor(palette.sageDeep)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            Text("Recettes pensées pour le SOPK, l'endométriose et votre cycle hormonal. Personnalisées pour vous.")
                .font(.system(size: 17))
                .foregroundColor(palette.ink.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("Cette application fournit des informations nutritionnelles générales. Elle ne remplace pas l'avis d'un médecin ou d'une diététicienne.")
                .font(.system(size: 12))
                .foregroundColor(palette.ink.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var conditionStep: some View {
        VStack(alignment: .leading, spacing: 28) {
            stepHeader(title: "Votre situation", subtitle: "Nous adapterons les recettes à votre profil hormonale.")

            let options = ["SOPK", "Endométriose", "Les deux", "Je m'informe"]
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selectedCondition = option
                    } label: {
                        HStack {
                            Text(option)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(selectedCondition == option ? palette.sageDeep : palette.ink)
                            Spacer()
                            if selectedCondition == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(palette.sageDeep)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedCondition == option ? palette.sageWash : palette.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedCondition == option ? palette.sageDeep : Color.clear, lineWidth: 1.5)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundColor(palette.inkMuted)
                Text("Tes données de santé sont stockées de façon sécurisée et ne sont jamais partagées. Tu peux les supprimer à tout moment dans les Réglages.")
                    .font(.system(size: 12))
                    .foregroundColor(palette.inkMuted)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 32)
    }

    private var symptomsStep: some View {
        VStack(alignment: .leading, spacing: 28) {
            stepHeader(title: "Symptômes à apaiser", subtitle: "Sélectionnez tout ce qui vous concerne. Vous pourrez modifier cela plus tard.")

            WrappingChips(items: symptoms, selected: $selectedSymptoms, palette: palette)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 32)
    }

    private var avoidStep: some View {
        VStack(alignment: .leading, spacing: 28) {
            stepHeader(title: "Ce que vous évitez", subtitle: "Nous pourrons filtrer les recettes contenant ces aliments.")

            VStack(spacing: 0) {
                ForEach(avoidTags, id: \.self) { tag in
                    Button {
                        if selectedAvoid.contains(tag) {
                            selectedAvoid.remove(tag)
                        } else {
                            selectedAvoid.insert(tag)
                        }
                    } label: {
                        HStack {
                            Text(tag)
                                .font(.system(size: 17))
                                .foregroundColor(palette.ink)
                            Spacer()
                            Image(systemName: selectedAvoid.contains(tag) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedAvoid.contains(tag) ? palette.sageDeep : palette.ink.opacity(0.3))
                                .font(.system(size: 22))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    Divider()
                        .padding(.leading, 24)
                }
            }

            Spacer()
        }
        .padding(.top, 32)
    }

    // MARK: - Helpers
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Fraunces-Regular", size: 28))
                .foregroundColor(palette.ink)
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(palette.ink.opacity(0.6))
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom CTA
    private var bottomCTA: some View {
        HStack(spacing: 16) {
            if step > 0 {
                Button {
                    step -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(palette.ink)
                        .frame(width: 52, height: 52)
                        .background(palette.card)
                        .clipShape(Circle())
                }
            }

            Button {
                if step < totalSteps - 1 {
                    step += 1
                } else {
                    saveAndFinish()
                }
            } label: {
                Text(buttonLabel)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(palette.sageDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
            }
        }
    }

    private var buttonLabel: String {
        switch step {
        case 0: return "Commencer"
        case totalSteps - 1: return "Découvrir mes recettes"
        default: return "Continuer"
        }
    }

    // MARK: - Persistence
    private func saveAndFinish() {
        UserDefaults.standard.set(true, forKey: "onboarding_completed")
        if let condition = selectedCondition {
            UserDefaults.standard.set(condition, forKey: "onboarding_condition")
        }
        UserDefaults.standard.set(Array(selectedSymptoms), forKey: "onboarding_symptoms")
        UserDefaults.standard.set(Array(selectedAvoid), forKey: "onboarding_avoid")

        if let userId = authViewModel.currentUser?.id {
            Task { await persistToSupabase(userId: userId) }
        }
        onDone()
    }

    private func persistToSupabase(userId: UUID) async {
        struct OnboardingUpdate: Encodable {
            let symptoms: [String]
            let avoidTags: [String]
            let condition: String?
            enum CodingKeys: String, CodingKey {
                case symptoms
                case avoidTags  = "avoid_tags"
                case condition
            }
        }
        let mappedCondition: String? = {
            switch selectedCondition {
            case "SOPK":          return "sopk"
            case "Endométriose":  return "endometriose"
            case "Les deux":      return "both"
            default:              return nil   // "Je m'informe" ou nil
            }
        }()
        let client = SupabaseClient.shared
        try? await client.requestVoid(
            table: "profiles",
            method: .PATCH,
            query: [("id", "eq.\(userId.uuidString)")],
            body: OnboardingUpdate(
                symptoms: Array(selectedSymptoms),
                avoidTags: Array(selectedAvoid),
                condition: mappedCondition
            )
        )
    }
}

// MARK: - Wrapping Chips
private struct WrappingChips: View {
    let items: [String]
    @Binding var selected: Set<String>
    let palette: Palette

    var body: some View {
        _WrappingLayout(spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button {
                    if selected.contains(item) { selected.remove(item) } else { selected.insert(item) }
                } label: {
                    Text(item)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selected.contains(item) ? palette.sageDeep : palette.ink.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selected.contains(item) ? palette.sageWash : palette.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selected.contains(item) ? palette.sageDeep : Color.clear, lineWidth: 1.5)
                                )
                        )
                }
            }
        }
    }
}

// MARK: - Custom wrapping layout
private struct _WrappingLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layoutRows(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layoutRows(proposal: ProposedViewSize(bounds.size), subviews: subviews)
        for (subview, origin) in zip(subviews, result.origins) {
            subview.place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private struct LayoutResult {
        var size: CGSize
        var origins: [CGPoint]
    }

    private func layoutRows(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return LayoutResult(size: CGSize(width: maxWidth, height: y + rowHeight), origins: origins)
    }
}
