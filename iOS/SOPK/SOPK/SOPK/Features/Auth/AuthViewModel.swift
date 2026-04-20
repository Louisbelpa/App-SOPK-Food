import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var currentProfile: Profile?
    @Published var isLoading = true
    @Published var error: String?

    private let client = SupabaseClient.shared

    /// Session factice sans backend (aucune clé Supabase).
    func enterLocalDemoMode() {
        error = nil
        currentUser = AuthUser(id: LocalDemo.userId, email: "demo@local.app")
        currentProfile = Profile(
            id: LocalDemo.userId,
            displayName: "Mode local",
            condition: Condition.endometriose.rawValue,
            familyId: LocalDemo.familyId,
            role: "admin"
        )
    }

    // MARK: - Session restore
    func restoreSession() async {
        defer { isLoading = false }
        guard SupabaseConfig.isConfigured else {
            currentUser = nil
            currentProfile = nil
            error = "Configuration Supabase manquante"
            return
        }
        guard client.accessToken != nil else { return }
        do {
            try await refreshSession()
            await loadProfile()
        } catch {
            client.clearSession()
        }
    }

    // MARK: - Register
    func register(email: String, password: String, displayName: String, condition: String?) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        guard SupabaseConfig.isConfigured else {
            self.error = "Connexion base de donnees non configuree"
            return
        }
        do {
            let response: AuthResponse = try await client.request(
                path: "/auth/v1/signup",
                method: .POST,
                body: ["email": email, "password": password],
                requiresAuth: false
            )
            do {
                client.storeSession(accessToken: response.accessToken, refreshToken: response.refreshToken)
                currentUser = response.user

                // Créer le profil
                try await createProfile(userId: response.user.id, displayName: displayName, condition: condition)
                await loadProfile()
            } catch {
                // Prevent navigating into app with a half-created account state.
                client.clearSession()
                currentUser = nil
                currentProfile = nil
                throw error
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        guard SupabaseConfig.isConfigured else {
            self.error = "Connexion base de donnees non configuree"
            return
        }
        do {
            let response: AuthResponse = try await client.request(
                path: "/auth/v1/token?grant_type=password",
                method: .POST,
                body: ["email": email, "password": password],
                requiresAuth: false
            )
            client.storeSession(accessToken: response.accessToken, refreshToken: response.refreshToken)
            currentUser = response.user
            await loadProfile()
        } catch {
            self.error = "Email ou mot de passe incorrect"
        }
    }

    // MARK: - Logout
    func logout() async {
        if SupabaseConfig.isConfigured {
            try? await client.requestVoid(path: "/auth/v1/logout", method: .POST)
            client.clearSession()
        }
        currentUser = nil
        currentProfile = nil
    }

    // MARK: - Reset Password
    func resetPassword(email: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        guard SupabaseConfig.isConfigured else { return }
        do {
            try await client.requestVoid(
                path: "/auth/v1/recover",
                method: .POST,
                body: ["email": email]
            )
            self.error = "Email de réinitialisation envoyé ✓"
        } catch {
            self.error = "Impossible d'envoyer l'email"
        }
    }

    // MARK: - Delete Account
    func deleteAccount() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        guard SupabaseConfig.isConfigured else { return }
        do {
            try await client.requestVoid(path: "/auth/v1/user", method: .DELETE)
            client.clearSession()
            currentUser = nil
            currentProfile = nil
        } catch {
            self.error = "Impossible de supprimer le compte"
        }
    }

    // MARK: - Apple Sign In
    func signInWithApple(idToken: String, displayNameHint: String?) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        guard SupabaseConfig.isConfigured else {
            self.error = "Connexion base de donnees non configuree"
            return
        }
        do {
            struct AppleTokenBody: Encodable {
                let provider = "apple"
                let id_token: String
            }

            let response: AuthResponse = try await client.request(
                path: "/auth/v1/token?grant_type=id_token",
                method: .POST,
                body: AppleTokenBody(id_token: idToken),
                requiresAuth: false
            )

            client.storeSession(accessToken: response.accessToken, refreshToken: response.refreshToken)
            currentUser = response.user
            await loadProfile()

            // First Apple login can arrive without an existing profile row.
            if currentProfile == nil {
                let cleanedHint = displayNameHint?.trimmingCharacters(in: .whitespacesAndNewlines)
                let fallbackName = response.user.email?.split(separator: "@").first.map(String.init) ?? "Nouvelle utilisatrice"
                let displayName = (cleanedHint?.isEmpty == false) ? cleanedHint! : fallbackName
                try await createProfile(userId: response.user.id, displayName: displayName, condition: nil)
                await loadProfile()
            }
        } catch {
            self.error = "Connexion Apple impossible"
        }
    }

    // MARK: - Private helpers
    private func refreshSession() async throws {
        guard let refreshToken = client.refreshToken else { throw APIError.notAuthenticated }
        let response: AuthResponse = try await client.request(
            path: "/auth/v1/token?grant_type=refresh_token",
            method: .POST,
            body: ["refresh_token": refreshToken],
            requiresAuth: false
        )
        client.storeSession(accessToken: response.accessToken, refreshToken: response.refreshToken)
        currentUser = response.user
    }

    private func createProfile(userId: UUID, displayName: String, condition: String?) async throws {
        struct ProfileUpdate: Encodable {
            let displayName: String
            let condition: String?
        }
        try await client.requestVoid(
            table: "profiles",
            method: .PATCH,
            query: [("id", "eq.\(userId.uuidString)")],
            body: ProfileUpdate(displayName: displayName, condition: condition)
        )
    }

    private func loadProfile() async {
        guard let userId = currentUser?.id else { return }
        do {
            let profiles: [Profile] = try await client.request(
                table: "profiles",
                query: [("id", "eq.\(userId.uuidString)"), ("select", "*")]
            )
            currentProfile = profiles.first
        } catch {
            self.error = error.localizedDescription
        }
    }

    func refreshProfile() async {
        await loadProfile()
    }
}

// MARK: - Auth response models
struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct AuthUser: Decodable {
    let id: UUID
    let email: String?

    init(id: UUID, email: String?) {
        self.id = id
        self.email = email
    }
}
