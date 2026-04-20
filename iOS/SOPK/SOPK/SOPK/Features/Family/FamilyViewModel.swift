import Foundation
import Combine

@MainActor
final class FamilyViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?

    private let client = SupabaseClient.shared

    // MARK: - Créer une famille
    func createFamily(name: String, userId: UUID) async throws -> Family {
        let inviteCode = generateInviteCode()
        struct FamilyInsert: Encodable {
            let name: String
            let inviteCode: String
            let createdBy: UUID
        }
        let families: [Family] = try await client.request(
            table: "families",
            method: .POST,
            body: FamilyInsert(name: name, inviteCode: inviteCode, createdBy: userId)
        )
        guard let family = families.first else { throw APIError.serverError(0, "Famille non créée") }
        try await joinFamily(familyId: family.id, userId: userId, role: "admin")
        return family
    }

    // MARK: - Rejoindre une famille par code
    func joinFamilyByCode(code: String, userId: UUID) async throws -> Family {
        let families: [Family] = try await client.request(
            table: "families",
            query: [("invite_code", "eq.\(code.uppercased())"), ("select", "*")]
        )
        guard let family = families.first else {
            throw APIError.serverError(404, "Code d'invitation invalide")
        }
        try await joinFamily(familyId: family.id, userId: userId, role: "member")
        return family
    }

    // MARK: - Private
    private func joinFamily(familyId: UUID, userId: UUID, role: String) async throws {
        struct ProfileUpdate: Encodable { let familyId: UUID; let role: String }
        try await client.requestVoid(
            table: "profiles",
            method: .PATCH,
            query: [("id", "eq.\(userId.uuidString)")],
            body: ProfileUpdate(familyId: familyId, role: role)
        )
    }

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).compactMap { _ in chars.randomElement() })
    }
}
