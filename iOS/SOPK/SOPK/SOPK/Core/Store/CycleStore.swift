import SwiftUI
import Foundation
import Combine

@MainActor
final class CycleStore: ObservableObject {
    @Published var lastPeriodDate: Date?
    @Published var cycleLength: Int = 28

    private let lastPeriodKey  = "cycle_last_period"
    private let cycleLengthKey = "cycle_length"
    private let client = SupabaseClient.shared
    private var userId: UUID?

    init() {
        if let ts = UserDefaults.standard.object(forKey: lastPeriodKey) as? Double {
            lastPeriodDate = Date(timeIntervalSince1970: ts)
        }
        let stored = UserDefaults.standard.integer(forKey: cycleLengthKey)
        cycleLength = stored > 0 ? stored : 28
    }

    // MARK: - Sync depuis Supabase (appelé après login)
    func sync(profile: Profile) {
        userId = profile.id
        if let cl = profile.cycleLength, cl > 0 { cycleLength = cl }
        if let dateStr = profile.lastPeriodDate,
           let date = DateFormatter.isoDate.date(from: dateStr) {
            lastPeriodDate = date
        }
        persistLocally()
    }

    // MARK: - Sauvegarde (local + Supabase)
    func save(lastPeriod: Date, length: Int) {
        lastPeriodDate = lastPeriod
        cycleLength = max(21, min(45, length))
        persistLocally()
        Task { await persistRemote() }
    }

    // MARK: - Réinitialiser à la déconnexion
    func clear() {
        userId = nil
        lastPeriodDate = nil
        cycleLength = 28
        UserDefaults.standard.removeObject(forKey: lastPeriodKey)
        UserDefaults.standard.removeObject(forKey: cycleLengthKey)
    }

    // MARK: - Computed
    var currentDay: Int {
        guard let start = lastPeriodDate else { return 1 }
        let diff = Calendar.current.dateComponents([.day], from: startOfDay(start), to: startOfDay(Date())).day ?? 0
        return max(1, (diff % cycleLength) + 1)
    }

    var currentPhase: String { phaseFor(day: currentDay, length: cycleLength) }

    var phaseAdvice: String {
        switch currentPhase {
        case "Menstruelle":  return "Privilégiez le fer, la vitamine C et les oméga-3 pour réduire l'inflammation"
        case "Folliculaire": return "Boostez avec des protéines, des folates et des antioxydants"
        case "Ovulatoire":   return "Maximum d'énergie — zinc, oméga-3 et fibres"
        default:             return "Privilégiez le magnésium, les oméga-3 et les aliments anti-stress"
        }
    }

    var isConfigured: Bool { lastPeriodDate != nil }

    static func phaseFor(day: Int, length: Int) -> String {
        if day <= 5                           { return "Menstruelle" }
        if day <= Int(Double(length) * 0.46)  { return "Folliculaire" }
        if day <= Int(Double(length) * 0.53)  { return "Ovulatoire" }
        return "Lutéale"
    }

    // MARK: - Privé
    private func phaseFor(day: Int, length: Int) -> String { CycleStore.phaseFor(day: day, length: length) }
    private func startOfDay(_ date: Date) -> Date { Calendar.current.startOfDay(for: date) }

    private func persistLocally() {
        if let date = lastPeriodDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastPeriodKey)
        }
        UserDefaults.standard.set(cycleLength, forKey: cycleLengthKey)
    }

    private func persistRemote() async {
        guard let uid = userId else { return }
        struct CycleUpdate: Encodable {
            let lastPeriodDate: String?
            let cycleLength: Int
            enum CodingKeys: String, CodingKey {
                case lastPeriodDate = "last_period_date"
                case cycleLength    = "cycle_length"
            }
        }
        let dateStr = lastPeriodDate.map { DateFormatter.isoDate.string(from: $0) }
        try? await client.requestVoid(
            table: "profiles",
            method: .PATCH,
            query: [("id", "eq.\(uid.uuidString)")],
            body: CycleUpdate(lastPeriodDate: dateStr, cycleLength: cycleLength)
        )
    }
}
