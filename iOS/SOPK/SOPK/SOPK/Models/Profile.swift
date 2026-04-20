import Foundation

struct Profile: Decodable, Equatable {
    let id: UUID
    let displayName: String?
    let condition: String?
    let familyId: UUID?
    let role: String?
    let lastPeriodDate: String?  // "yyyy-MM-dd"
    let cycleLength: Int?
    let symptoms: [String]?
    let avoidTags: [String]?

    var conditionEnum: Condition? {
        guard let condition else { return nil }
        return Condition(rawValue: condition)
    }

    var isAdmin: Bool { role == "admin" }

    enum CodingKeys: String, CodingKey {
        case id, condition, role, symptoms
        case displayName     = "display_name"
        case familyId        = "family_id"
        case lastPeriodDate  = "last_period_date"
        case cycleLength     = "cycle_length"
        case avoidTags       = "avoid_tags"
    }

    init(id: UUID, displayName: String?, condition: String?, familyId: UUID?, role: String?,
         lastPeriodDate: String? = nil, cycleLength: Int? = nil,
         symptoms: [String]? = nil, avoidTags: [String]? = nil) {
        self.id = id
        self.displayName = displayName
        self.condition = condition
        self.familyId = familyId
        self.role = role
        self.lastPeriodDate = lastPeriodDate
        self.cycleLength = cycleLength
        self.symptoms = symptoms
        self.avoidTags = avoidTags
    }
}

struct Family: Decodable, Identifiable {
    let id: UUID
    let name: String
    let inviteCode: String
    let createdBy: UUID?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name
        case inviteCode = "invite_code"
        case createdBy  = "created_by"
        case createdAt  = "created_at"
    }
}
