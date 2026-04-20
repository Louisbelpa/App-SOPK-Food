import SwiftUI
import Foundation
import Combine

// MARK: - Structured week plan
struct WeekDay: Identifiable {
    let id: String   // "2026-04-21"
    let weekday: String   // "Lun"
    let dayNumber: Int    // 21
    var meals: [MealSlot]
}

struct MealSlot: Identifiable {
    let id: String
    let label: String      // "Petit-déjeuner" etc.
    let mealType: String   // "breakfast" etc.
    var recipeId: String?
    var entryId: String?   // UUID from DB for deletion
}

private let slotOrder = ["breakfast", "lunch", "dinner", "snack"]
private let slotLabels: [String: String] = [
    "breakfast": "Petit-déjeuner",
    "lunch":     "Déjeuner",
    "dinner":    "Dîner",
    "snack":     "Collation",
]

@MainActor
final class MealPlanStore: ObservableObject {
    @Published private(set) var week: [WeekDay] = []
    @Published private(set) var isLoading = false
    @Published var error: AppError?

    private let repository: any MealPlanRepository

    init(repository: any MealPlanRepository = SupabaseMealPlanRepository()) {
        self.repository = repository
    }

    /// Load the week containing `date` (Mon–Sun). Requires familyId.
    func loadWeek(for date: Date = Date(), familyId: UUID?) async {
        week = buildEmptyWeek(for: date)
        guard let fid = familyId else {
            week = buildSampleWeek(for: date)
            return
        }
        isLoading = true
        defer { isLoading = false }
        error = nil

        do {
            let entries = try await repository.fetchEntries(familyId: fid, date: date)
            var newWeek = buildEmptyWeek(for: date)
            for entry in entries {
                guard let dayIdx = newWeek.firstIndex(where: { $0.id == entry.date }),
                      let slotIdx = newWeek[dayIdx].meals.firstIndex(where: { $0.mealType == entry.mealType })
                else { continue }
                newWeek[dayIdx].meals[slotIdx].recipeId = entry.recipeId
                newWeek[dayIdx].meals[slotIdx].entryId = entry.id
            }
            week = newWeek
        } catch let appError as AppError {
            self.error = appError
            week = buildSampleWeek(for: date)
        } catch {
            self.error = AppError(from: error)
            week = buildSampleWeek(for: date)
        }
    }

    func addEntry(date: Date, mealType: String, recipeId: String, familyId: UUID) async {
        do {
            try await repository.addEntry(familyId: familyId, recipeId: recipeId, date: date, mealType: mealType)
            await loadWeek(for: date, familyId: familyId)
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = AppError(from: error)
        }
    }

    func removeEntry(entryId: String, date: Date, familyId: UUID) async {
        do {
            try await repository.removeEntry(entryId: entryId)
            await loadWeek(for: date, familyId: familyId)
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = AppError(from: error)
        }
    }

    // MARK: - Helpers
    private func mondayOf(_ date: Date) -> Date {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps)!
    }

    private func buildEmptyWeek(for date: Date) -> [WeekDay] {
        let monday = mondayOf(date)
        let shortDays = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"]
        return (0..<7).map { offset in
            let d = Calendar.current.date(byAdding: .day, value: offset, to: monday)!
            let dayNum = Calendar.current.component(.day, from: d)
            let key = DateFormatter.isoDate.string(from: d)
            let slots = slotOrder.map { mt in
                MealSlot(id: "\(key)-\(mt)", label: slotLabels[mt]!, mealType: mt)
            }
            return WeekDay(id: key, weekday: shortDays[offset], dayNumber: dayNum, meals: slots)
        }
    }

    private func buildSampleWeek(for date: Date) -> [WeekDay] {
        // Use sample recipe IDs mapped onto the week
        var days = buildEmptyWeek(for: date)
        let sampleIds = SampleData.appRecipes.prefix(7).map(\.id)
        for (i, id) in sampleIds.enumerated() where i < days.count {
            days[i].meals[1].recipeId = id  // lunch slot
        }
        return days
    }
}

extension DateFormatter {
    static let isoDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
