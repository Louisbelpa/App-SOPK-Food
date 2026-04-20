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

// Shared decodable type for DB shopping items
private struct FetchedShoppingItem: Decodable {
    let id: String
    let name: String
    let quantity: Double?
    let unit: String?
    let category: String?
    let isChecked: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, unit, category
        case isChecked = "is_checked"
    }
}

@MainActor
final class ShoppingStore: ObservableObject {
    @Published private(set) var categories: [ShoppingSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let client = SupabaseClient.shared

    var totalItems: Int { categories.reduce(0) { $0 + $1.items.count } }
    var checkedItems: Int { categories.reduce(0) { $0 + $1.items.filter(\.isChecked).count } }

    // MARK: - Load
    func load(familyId: UUID?) async {
        guard let fid = familyId else { loadSample(); return }
        isLoading = true
        defer { isLoading = false }
        error = nil

        do {
            let items: [FetchedShoppingItem] = try await client.callFunction(
                "shopping",
                method: .GET,
                query: [("family_id", fid.uuidString)]
            )
            categories = groupItems(items)
        } catch {
            self.error = error.localizedDescription
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
                        struct ToggleBody: Encodable {
                            let item_id: String
                            let is_checked: Bool
                        }
                        try? await client.callFunctionVoid(
                            "shopping",
                            method: .PATCH,
                            body: ToggleBody(item_id: dbId, is_checked: newVal)
                        )
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
            struct NewItem: Encodable {
                let family_id: String
                let name: String
                let qty: String
                let category: String
            }
            try await client.callFunctionVoid(
                "shopping",
                method: .POST,
                body: NewItem(family_id: fid.uuidString, name: name, qty: qty, category: category)
            )
            await load(familyId: fid)
        } catch { self.error = error.localizedDescription }
    }

    // MARK: - Clear checked
    func clearChecked(familyId: UUID?) async {
        guard let fid = familyId else {
            for ci in categories.indices { categories[ci].items.removeAll(where: \.isChecked) }
            categories.removeAll { $0.items.isEmpty }
            return
        }
        do {
            try await client.callFunctionVoid(
                "shopping",
                method: .DELETE,
                body: ["family_id": fid.uuidString]
            )
            await load(familyId: fid)
        } catch { self.error = error.localizedDescription }
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

    private func groupItems(_ items: [FetchedShoppingItem]) -> [ShoppingSection] {
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
