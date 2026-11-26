import Foundation

// Modèle des séances d'activité. Le format est décrit dans `docs/kickoff/06-sport.md` (clés en anglais, snake_case).

public struct WorkoutCatalog: Codable, Hashable, Sendable {
    public let version: Int
    public let locale: String
    public let disclaimer: String
    public let exercises: [Exercise]
    public let sessions: [WorkoutSession]

    public func exercise(id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }
}

public struct Exercise: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let category: String
    public let muscles: [String]
    public let equipment: [String]
    public let impact: String
    public let instructions: [String]
    public let breathing: String?
    public let commonMistakes: [String]
    public let easierVariant: String?
    public let harderVariant: String?
    public let contraindications: [String]
}

public struct WorkoutSession: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let durationMin: Int
    public let level: Int
    public let intensity: String
    public let rpeTarget: String?
    public let type: String
    public let equipment: [String]
    /// États du check-in du jour pour lesquels la séance convient (ex. `energy_low`).
    public let goodFor: [String]
    public let avoidIf: [String]
    public let instructions: [String]
    public let contraindications: [String]
    public let blocks: [Block]

    public struct Block: Codable, Hashable, Sendable {
        public let name: String
        public let kind: String
        public let rounds: Int
        public let restBetweenRoundsSec: Int
        public let items: [Item]
    }

    public struct Item: Codable, Hashable, Sendable {
        public let exerciseId: String
        public let durationSec: Int?
        public let reps: Int?
        public let restSec: Int?
        public let perSide: Bool?
        public let note: String?
    }
}
