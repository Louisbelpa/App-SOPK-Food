import SwiftUI
import Foundation
import Combine

// MARK: - Shopping item with category grouping
struct ShoppingSection: Identifiable {
    let id: String
    var items: [ShoppingEntry]
}

struct ShoppingEntry: Identifiable {
    let id: String        // UUID or local key
    let name: String
    let qty: String
    var isChecked: Bool
    var dbId: String?     // nil = local only
}

@MainActor
final class ShoppingStore: ObservableObject {
    @Published private(set) var categories: [ShoppingSection] = []
    @Published private(set) var isLoading = false
    @Published var error: AppError?

    private let repository: any ShoppingRepository

    init(repository: any ShoppingRepository = SupabaseShoppingRepository()) {
        self.repository = repository
    }

    var totalItems: Int { categories.reduce(0) { $0 + $1.items.count } }
    var checkedItems: Int { categories.reduce(0) { $0 + $1.items.filter(\.isChecked).count } }

    // MARK: - Load
    func load(familyId: UUID?) async {
        guard let fid = familyId else { loadSample(); return }
        isLoading = true
        defer { isLoading = false }
        error = nil

        do {
            let items = try await repository.fetchItems(familyId: fid)
            categories = groupItems(items)
        } catch let appError as AppError {
            self.error = appError
            loadSample()
        } catch {
            self.error = AppError(from: error)
            loadSample()
        }
    }

    // MARK: - Toggle
    func toggle(entryId: String, familyId: UUID?) async {
        for ci in categories.indices {
            for ii in categories[ci].items.indices {
                if categories[ci].items[ii].id == entryId {
                    categories[ci].items[ii].isChecked.toggle()
                    let newVal = categories[ci].items[ii].isChecked
                    if let dbId = categories[ci].items[ii].dbId {
                        do {
                            try await repository.toggleItem(itemId: dbId, isChecked: newVal)
                        } catch let appError as AppError {
                            self.error = appError
                        } catch {
                            self.error = AppError(from: error)
                        }
                    }
                    return
                }
            }
        }
    }

    // MARK: - Add item
    func addItem(name: String, qty: String, category: String = "autre", familyId: UUID?) async {
        guard let fid = familyId else {
            insertEntry(ShoppingEntry(id: UUID().uuidString, name: name, qty: qty, isChecked: false), category: category)
            return
        }
        do {
            try await repository.addItem(familyId: fid, name: name, qty: qty, category: category)
            await load(familyId: fid)
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = AppError(from: error)
        }
    }

    // MARK: - Clear checked
    func clearChecked(familyId: UUID?) async {
        guard let fid = familyId else {
            for ci in categories.indices { categories[ci].items.removeAll(where: \.isChecked) }
            categories.removeAll { $0.items.isEmpty }
            return
        }
        do {
            try await repository.clearCheckedItems(familyId: fid)
            await load(familyId: fid)
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = AppError(from: error)
        }
    }

    // MARK: - Helpers
    private func loadSample() {
        categories = SampleData.shopping.map { sc in
            let entries = sc.items.map { item in
                ShoppingEntry(id: item.name, name: item.name, qty: item.qty, isChecked: item.checked)
            }
            return ShoppingSection(id: sc.category, items: entries)
        }
    }

    private func groupItems(_ items: [ShoppingItemDTO]) -> [ShoppingSection] {
        var dict: [String: [ShoppingEntry]] = [:]
        for item in items {
            let cat = item.category ?? "autre"
            let qtyStr: String = {
                guard let q = item.quantity, q > 0 else { return "" }
                let num = q.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(q))" : String(format: "%.1f", q)
                return item.unit.map { "\(num) \($0)" } ?? num
            }()
            let entry = ShoppingEntry(id: item.id, name: item.name, qty: qtyStr, isChecked: item.isChecked, dbId: item.id)
            dict[cat, default: []].append(entry)
        }
        return dict.sorted { $0.key < $1.key }.map { ShoppingSection(id: $0.key, items: $0.value) }
    }

    private func insertEntry(_ entry: ShoppingEntry, category: String) {
        if let idx = categories.firstIndex(where: { $0.id == category }) {
            categories[idx].items.append(entry)
        } else {
            categories.append(ShoppingSection(id: category, items: [entry]))
        }
    }
}
