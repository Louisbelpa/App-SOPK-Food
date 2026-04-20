import SwiftUI

struct NourriPlanView: View {
    let palette: Palette
    let isDark: Bool
    let onRecipeTap: (String) -> Void
    @EnvironmentObject private var recipeStore: RecipeStore
    @EnvironmentObject private var mealPlanStore: MealPlanStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var cycleStore: CycleStore
    @State private var selectedDay = 0
    @State private var referenceDate = Date()
    @State private var addSlotDate: Date? = nil
    @State private var addSlotMealType = "lunch"

    private var weekLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "fr_FR")
        let cal = Calendar.current
        let week = cal.component(.weekOfYear, from: referenceDate)
        return "\(f.string(from: referenceDate).capitalized) · Semaine \(week)"
    }

    private var selectedWeekDay: WeekDay? {
        guard !mealPlanStore.week.isEmpty, selectedDay < mealPlanStore.week.count else { return nil }
        return mealPlanStore.week[selectedDay]
    }

    private var dailyStats: (kcal: Int, antiInflam: Int) {
        guard let day = selectedWeekDay else { return (0, 0) }
        let recipes = day.meals.compactMap { slot -> AppRecipe? in
            guard let rid = slot.recipeId else { return nil }
            return recipeStore.recipe(id: rid)
        }
        let kcal = recipes.reduce(0) { $0 + $1.calories }
        let ai = recipes.isEmpty ? 0 : recipes.reduce(0) { $0 + $1.antiInflam } / recipes.count
        return (kcal, ai)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weekLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)
                        Text("Plan de repas")
                            .font(.custom("Fraunces", size: 30))
                            .foregroundColor(palette.ink)
                            .kerning(-0.5)
                    }
                    Spacer()
                    // Week navigation
                    HStack(spacing: 8) {
                        Button {
                            referenceDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: referenceDate)!
                            Task { await mealPlanStore.loadWeek(for: referenceDate, familyId: authViewModel.currentProfile?.familyId) }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(palette.ink)
                                .frame(width: 36, height: 36)
                                .background(palette.surface)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(palette.line, lineWidth: 1))
                        }
                        Button {
                            referenceDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: referenceDate)!
                            Task { await mealPlanStore.loadWeek(for: referenceDate, familyId: authViewModel.currentProfile?.familyId) }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(palette.ink)
                                .frame(width: 36, height: 36)
                                .background(palette.surface)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(palette.line, lineWidth: 1))
                        }
                    }
                }
                .padding(.top, 62)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Day picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(mealPlanStore.week.enumerated()), id: \.offset) { idx, day in
                            let on = selectedDay == idx
                            Button { selectedDay = idx } label: {
                                VStack(spacing: 2) {
                                    Text(day.weekday)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(on ? .white.opacity(0.75) : palette.inkMuted)
                                        .kerning(0.5)
                                        .textCase(.uppercase)
                                    Text("\(day.dayNumber)")
                                        .font(.custom("Fraunces", size: 20).weight(.medium))
                                        .foregroundColor(on ? .white : palette.ink)
                                }
                                .frame(width: 54)
                                .padding(.vertical, 10)
                                .background(on ? palette.sageDeep : palette.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(on ? Color.clear : palette.line, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 18)

                // Daily summary
                let stats = dailyStats
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total du jour")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)
                        if stats.kcal > 0 {
                            Text("\(stats.kcal) kcal")
                                .font(.custom("Fraunces", size: 20).weight(.medium))
                                .foregroundColor(palette.ink)
                        } else {
                            Text("Aucune recette planifiée")
                                .font(.custom("Fraunces", size: 16))
                                .foregroundColor(palette.inkSoft)
                        }
                    }
                    Spacer()
                    if stats.antiInflam > 0 {
                        AntiInflamBadge(score: stats.antiInflam, palette: palette, size: .md)
                    }
                }
                .padding(16)
                .background(palette.cardAlt)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .padding(.bottom, 18)

                // Meal slots
                if let day = selectedWeekDay {
                    let dayDate = DateFormatter.isoDate.date(from: day.id) ?? Date()
                    VStack(spacing: 14) {
                        ForEach(day.meals) { slot in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(slot.label)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(palette.inkMuted)
                                        .kerning(0.5)
                                        .textCase(.uppercase)
                                    Spacer()
                                    if let rid = slot.recipeId, let recipe = recipeStore.recipe(id: rid) {
                                        Text("\(recipe.time) min")
                                            .font(.system(size: 11))
                                            .foregroundColor(palette.inkMuted)
                                    }
                                }

                                if let rid = slot.recipeId, let recipe = recipeStore.recipe(id: rid) {
                                    ZStack(alignment: .topTrailing) {
                                        Button { onRecipeTap(recipe.id) } label: {
                                            HStack(spacing: 12) {
                                                RecipePlateView(seed: recipe.seed, palette: palette)
                                                    .frame(width: 64, height: 64)
                                                    .background(palette.cardAlt)
                                                    .clipShape(RoundedRectangle(cornerRadius: 14))

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(recipe.name)
                                                        .font(.custom("Fraunces", size: 15).weight(.medium))
                                                        .foregroundColor(palette.ink)
                                                        .lineLimit(2)
                                                    HStack(spacing: 8) {
                                                        PhaseChip(phase: recipe.phase, palette: palette, small: true)
                                                        Text("\(recipe.calories) kcal")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(palette.inkSoft)
                                                    }
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(palette.inkMuted)
                                            }
                                            .padding(12)
                                            .background(palette.card)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            Task {
                                                if let entryId = slot.entryId,
                                                   let familyId = authViewModel.currentProfile?.familyId {
                                                    await mealPlanStore.removeEntry(entryId: entryId, date: dayDate, familyId: familyId)
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(palette.inkMuted)
                                        }
                                        .padding(8)
                                    }
                                } else {
                                    // Empty slot — tap to add
                                    Button {
                                        if let day = selectedWeekDay,
                                           let date = DateFormatter.isoDate.date(from: day.id) {
                                            addSlotDate = date
                                            addSlotMealType = slot.mealType
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16))
                                                .foregroundColor(palette.inkMuted)
                                            Text("Ajouter une recette")
                                                .font(.system(size: 14))
                                                .foregroundColor(palette.inkMuted)
                                            Spacer()
                                        }
                                        .padding(16)
                                        .background(palette.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(palette.line, style: StrokeStyle(lineWidth: 1, dash: [6]))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Generate CTA
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundColor(palette.sageDeep)
                        Text("Générer la semaine")
                            .font(.custom("Fraunces", size: 15).weight(.medium))
                            .foregroundColor(palette.ink)
                    }
                    Text("Adapté à votre phase \(cycleStore.currentPhase.lowercased()) et à vos préférences.")
                        .font(.system(size: 12))
                        .foregroundColor(palette.inkSoft)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(
                    LinearGradient(colors: [palette.sageWash, palette.beige], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(palette.sage.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6])))
                .padding(.horizontal, 20)
                .padding(.top, 22)
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
        .task {
            await mealPlanStore.loadWeek(for: referenceDate, familyId: authViewModel.currentProfile?.familyId)
            // Set selected day to today
            let todayKey = DateFormatter.isoDate.string(from: Date())
            if let idx = mealPlanStore.week.firstIndex(where: { $0.id == todayKey }) {
                selectedDay = idx
            }
        }
        .sheet(isPresented: Binding(
            get: { addSlotDate != nil },
            set: { if !$0 { addSlotDate = nil } }
        )) {
            if let date = addSlotDate {
                PlanRecipePickerSheet(date: date, mealType: addSlotMealType, palette: palette)
            }
        }
    }
}

// MARK: - Recipe picker sheet for meal plan
private struct PlanRecipePickerSheet: View {
    let date: Date
    let mealType: String
    let palette: Palette

    @EnvironmentObject private var recipeStore: RecipeStore
    @EnvironmentObject private var mealPlanStore: MealPlanStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    private var filtered: [AppRecipe] {
        let base = recipeStore.recipes.filter { $0.mealType == mealType }
        guard !query.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    private var mealLabel: String {
        switch mealType {
        case "breakfast": return "Petit-déjeuner"
        case "lunch": return "Déjeuner"
        case "dinner": return "Dîner"
        default: return "Collation"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(palette.inkMuted)
                    TextField("Rechercher une recette…", text: $query)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(palette.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                if filtered.isEmpty {
                    Spacer()
                    Text("Aucune recette pour ce repas")
                        .foregroundColor(palette.inkSoft)
                    Spacer()
                } else {
                    List(filtered) { recipe in
                        Button {
                            guard let fid = authViewModel.currentProfile?.familyId else { return }
                            Task {
                                await mealPlanStore.addEntry(date: date, mealType: mealType, recipeId: recipe.id, familyId: fid)
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                RecipePlateView(seed: recipe.seed, palette: palette)
                                    .frame(width: 48, height: 48)
                                    .background(palette.cardAlt)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(recipe.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(palette.ink)
                                        .lineLimit(2)
                                    Text("\(recipe.time) min · \(recipe.calories) kcal")
                                        .font(.system(size: 11))
                                        .foregroundColor(palette.inkSoft)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(palette.bg)
                    }
                    .listStyle(.plain)
                    .background(palette.bg)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(palette.bg.ignoresSafeArea())
            .navigationTitle("Choisir pour \(mealLabel)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }
}
