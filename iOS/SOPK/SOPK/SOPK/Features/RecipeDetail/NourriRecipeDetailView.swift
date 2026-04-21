import SwiftUI

struct NourriRecipeDetailView: View {
    let recipe: AppRecipe
    let palette: Palette
    let isDark: Bool
    @Environment(\.dismiss) var dismiss
    @State private var tab: DetailTab = .ingredients
    @State private var servings = 2
    @State private var showAddToPlan = false
    @EnvironmentObject private var favsStore: FavoritesStore
    @EnvironmentObject private var mealPlanStore: MealPlanStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    private var isFav: Bool { favsStore.contains(recipe.id) }

    enum DetailTab: String { case ingredients = "Ingrédients"; case steps = "Préparation" }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                hero
                contentCard
            }
            .padding(.bottom, 120)
        }
        .background(palette.bg.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) { ctaButton }
        .sheet(isPresented: $showAddToPlan) {
            AddToPlanSheet(recipe: recipe, palette: palette)
        }
    }

    // MARK: - Hero image
    private var hero: some View {
        ZStack(alignment: .top) {
            RecipePlateView(seed: recipe.seed, palette: palette)
                .aspectRatio(1, contentMode: .fill)
                .background(palette.cardAlt)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(palette.ink)
                        .frame(width: 42, height: 42)
                        .background(.white.opacity(0.88))
                        .clipShape(Circle())
                        .background(Circle().fill(.ultraThinMaterial))
                }
                Spacer()
                HStack(spacing: 8) {
                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(palette.ink)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.88))
                            .clipShape(Circle())
                    }
                    Button { favsStore.toggle(recipe.id) } label: {
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(isFav ? palette.terracottaDeep : palette.ink)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.88))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 54)
        }
    }

    // MARK: - Content card (slides up over hero)
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tags row
            HStack(spacing: 6) {
                TagPill(text: recipe.category, foreground: palette.sageDeep, background: palette.sageWash)
                PhaseChip(phase: recipe.phase, palette: palette)
            }
            .padding(.bottom, 10)

            // Title
            Text(recipe.name)
                .font(.custom("Fraunces", size: 28).weight(.medium))
                .foregroundColor(palette.ink)
                .lineSpacing(2)
                .kerning(-0.4)
                .padding(.bottom, 14)

            // Stats row
            HStack(spacing: 0) {
                StatCell(value: "\(recipe.time)", unit: "min", label: "Préparation", palette: palette)
                Divider().frame(height: 40)
                StatCell(value: "\(recipe.calories)", unit: "kcal", label: "Par portion", palette: palette)
                Divider().frame(height: 40)
                VStack(spacing: 4) {
                    AntiInflamBadge(score: recipe.antiInflam, palette: palette, size: .sm)
                    Text("Anti-inflam")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 14)
            .overlay(Rectangle().frame(height: 1).foregroundColor(palette.line), alignment: .top)
            .overlay(Rectangle().frame(height: 1).foregroundColor(palette.line), alignment: .bottom)
            .padding(.bottom, 20)

            // Benefits
            VStack(alignment: .leading, spacing: 10) {
                Text("Bénéfices nutritionnels")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(palette.inkMuted)
                    .kerning(0.5)
                    .textCase(.uppercase)

                ForEach(recipe.benefits, id: \.label) { b in
                    HStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(palette.sage)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            Text(b.label)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(palette.ink)
                            Text(b.detail)
                                .font(.system(size: 11))
                                .foregroundColor(palette.inkSoft)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(palette.sageWash)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.bottom, 20)

            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(recipe.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                            Text(tag)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(palette.terre)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(palette.beige)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.bottom, recipe.allergens.isEmpty ? 22 : 10)

            // Allergènes
            if !recipe.allergens.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Allergènes")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5)
                        .textCase(.uppercase)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(recipe.allergens, id: \.self) { allergen in
                                HStack(spacing: 4) {
                                    Text(allergenEmoji(allergen))
                                        .font(.system(size: 12))
                                    Text(allergenLabel(allergen))
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .background(Color.orange.opacity(0.85))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.bottom, 22)
            }

            // Tab switch
            HStack(spacing: 4) {
                ForEach([DetailTab.ingredients, .steps], id: \.self) { t in
                    Button { withAnimation(.easeInOut(duration: 0.15)) { tab = t } } label: {
                        Text(t.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(tab == t ? palette.ink : palette.inkSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(tab == t ? palette.surface : Color.clear)
                            .clipShape(Capsule())
                            .shadow(color: tab == t ? .black.opacity(0.06) : .clear, radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(palette.cardAlt)
            .clipShape(Capsule())
            .padding(.bottom, 16)

            if tab == .ingredients {
                ingredientsTab
            } else {
                stepsTab
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .background(palette.bg)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.top, -24)
    }

    private var ingredientsTab: some View {
        VStack(spacing: 0) {
            // Servings stepper
            HStack {
                Text("Portions")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(palette.inkSoft)
                Spacer()
                HStack(spacing: 14) {
                    Button { servings = max(1, servings - 1) } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(palette.ink)
                            .frame(width: 30, height: 30)
                            .background(palette.surface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(palette.line, lineWidth: 1))
                    }
                    Text("\(servings)")
                        .font(.custom("Fraunces", size: 18).weight(.medium))
                        .foregroundColor(palette.ink)
                        .frame(minWidth: 24)
                    Button { servings += 1 } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(palette.sageDeep)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.bottom, 14)

            // Ingredient list
            VStack(spacing: 0) {
                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { idx, ing in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(ing.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(palette.ink)
                            Spacer()
                            Text(ing.qty)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(palette.inkSoft)
                        }
                        if !ing.why.isEmpty {
                            Text("→ \(ing.why)")
                                .font(.system(size: 11))
                                .italic()
                                .foregroundColor(palette.inkMuted)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    if idx < recipe.ingredients.count - 1 {
                        Divider().foregroundColor(palette.line).padding(.horizontal, 16)
                    }
                }
            }
            .background(palette.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var stepsTab: some View {
        VStack(spacing: 14) {
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(idx + 1)")
                        .font(.custom("Fraunces", size: 14).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(palette.sageDeep)
                        .clipShape(Circle())
                        .padding(.top, 4)
                    Text(step)
                        .font(.system(size: 14))
                        .foregroundColor(palette.ink)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(palette.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private var ctaButton: some View {
        Button { showAddToPlan = true } label: {
            HStack(spacing: 8) {
                Text("Ajouter au plan de repas")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(palette.sageDeep)
            .clipShape(Capsule())
            .shadow(color: palette.sageDeep.opacity(0.35), radius: 12, y: 6)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 120)
    }
}

// MARK: - Add to plan sheet
struct AddToPlanSheet: View {
    let recipe: AppRecipe
    let palette: Palette

    @EnvironmentObject private var mealPlanStore: MealPlanStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date()
    @State private var selectedMealType = "lunch"
    @State private var isAdding = false
    @State private var added = false

    private let mealTypes = [
        ("breakfast", "Petit-déjeuner"),
        ("lunch", "Déjeuner"),
        ("dinner", "Dîner"),
        ("snack", "Collation"),
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                // Recipe preview
                HStack(spacing: 12) {
                    RecipePlateView(seed: recipe.seed, palette: palette)
                        .frame(width: 56, height: 56)
                        .background(palette.cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(recipe.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(palette.ink)
                            .lineLimit(2)
                        Text("\(recipe.time) min · \(recipe.calories) kcal")
                            .font(.system(size: 12))
                            .foregroundColor(palette.inkSoft)
                    }
                    Spacer()
                }
                .padding(16)
                .background(palette.cardAlt)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Date picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5)
                        .textCase(.uppercase)
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(palette.sageDeep)
                        .labelsHidden()
                }

                // Meal type picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Repas")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5)
                        .textCase(.uppercase)
                    HStack(spacing: 8) {
                        ForEach(mealTypes, id: \.0) { mt, label in
                            Button { selectedMealType = mt } label: {
                                Text(label)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(selectedMealType == mt ? .white : palette.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedMealType == mt ? palette.sageDeep : palette.surface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(selectedMealType == mt ? Color.clear : palette.line, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()

                // CTA
                Button {
                    guard let familyId = authViewModel.currentProfile?.familyId else { return }
                    isAdding = true
                    Task {
                        await mealPlanStore.addEntry(date: selectedDate, mealType: selectedMealType, recipeId: recipe.id, familyId: familyId)
                        isAdding = false
                        added = true
                        try? await Task.sleep(nanoseconds: 700_000_000)
                        dismiss()
                    }
                } label: {
                    Group {
                        if isAdding {
                            ProgressView().tint(.white)
                        } else if added {
                            Label("Ajouté !", systemImage: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                        } else {
                            Text("Confirmer")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(added ? palette.sageDeep.opacity(0.7) : palette.sageDeep)
                    .clipShape(Capsule())
                }
                .disabled(isAdding || added || authViewModel.currentProfile?.familyId == nil)
            }
            .padding(24)
            .background(palette.bg.ignoresSafeArea())
            .navigationTitle("Planifier cette recette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(palette.sageDeep)
                }
            }
        }
    }
}

private func allergenEmoji(_ key: String) -> String {
    switch key {
    case "gluten":         return "🌾"
    case "oeufs":          return "🥚"
    case "fruits_de_mer":  return "🦐"
    case "arachides":      return "🥜"
    case "soja":           return "🌱"
    case "lait":           return "🥛"
    case "fruits_a_coque": return "🌰"
    case "sesame":         return "🫘"
    case "poisson":        return "🐟"
    default:               return "⚠️"
    }
}

private func allergenLabel(_ key: String) -> String {
    switch key {
    case "gluten":         return "Gluten"
    case "oeufs":          return "Œufs"
    case "fruits_de_mer":  return "Fruits de mer"
    case "arachides":      return "Arachides"
    case "soja":           return "Soja"
    case "lait":           return "Lait"
    case "fruits_a_coque": return "Fruits à coque"
    case "sesame":         return "Sésame"
    case "poisson":        return "Poisson"
    default:               return key
    }
}

struct StatCell: View {
    let value: String; let unit: String; let label: String; let palette: Palette
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value).font(.custom("Fraunces", size: 18).weight(.medium)).foregroundColor(palette.ink)
                Text(unit).font(.system(size: 11)).foregroundColor(palette.inkMuted)
            }
            Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(palette.inkMuted).kerning(0.5).textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}
