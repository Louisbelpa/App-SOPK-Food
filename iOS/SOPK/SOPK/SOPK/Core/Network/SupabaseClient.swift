import Foundation

// MARK: - Configuration
// Remplacer ces valeurs par vos clés Supabase (Settings > API dans le dashboard)
// Ne pas committer les vraies clés — utiliser un fichier Secrets.xcconfig exclu du git
enum SupabaseConfig {
    // Valeurs locales (supabase local). Remplacer par les vraies clés en production.
    private static let defaultURL    = "http://192.168.1.14:54321"
    private static let defaultAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

    // Priority: Scheme env vars > Info.plist injected build settings > defaults above.
    private static var resolvedURLString: String {
        if let env = ProcessInfo.processInfo.environment["SUPABASE_URL"], !env.isEmpty { return env }
        if let info = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String, !info.isEmpty { return info }
        return defaultURL
    }

    private static var resolvedAnonKey: String {
        if let env = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"], !env.isEmpty { return env }
        if let info = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String, !info.isEmpty { return info }
        return defaultAnonKey
    }

    // Fallback vers supabase.co si la chaîne est invalide (ne devrait pas arriver en pratique)
    static let url = URL(string: resolvedURLString) ?? URL(string: "https://supabase.co")!
    static var functionsURL: URL { url.appendingPathComponent("/functions/v1") }
    static let anonKey = resolvedAnonKey

    static var isConfigured: Bool { true }
}

/// Identifiants stables pour la session « hors ligne » (pas de backend).
enum LocalDemo {
    static let userId = UUID(uuidString: "00000000-0000-4000-8000-0000000000D0")!
    static let familyId = UUID(uuidString: "00000000-0000-4000-8000-0000000000F1")!
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case notAuthenticated
    case serverError(Int, String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL invalide"
        case .notAuthenticated: return "Vous devez être connecté"
        case .serverError(let code, let msg): return "Erreur serveur (\(code)): \(msg)"
        case .decodingError(let err): return "Erreur de décodage: \(err.localizedDescription)"
        case .networkError(let err): return err.localizedDescription
        }
    }
}

// MARK: - Supabase REST Client
@MainActor
final class SupabaseClient {
    static let shared = SupabaseClient()

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()

    private(set) var accessToken: String? {
        get { KeychainHelper.load(forKey: "supabase_access_token") }
        set {
            if let value = newValue {
                KeychainHelper.save(value, forKey: "supabase_access_token")
            } else {
                KeychainHelper.delete(forKey: "supabase_access_token")
            }
        }
    }

    private(set) var refreshToken: String? {
        get { KeychainHelper.load(forKey: "supabase_refresh_token") }
        set {
            if let value = newValue {
                KeychainHelper.save(value, forKey: "supabase_refresh_token")
            } else {
                KeychainHelper.delete(forKey: "supabase_refresh_token")
            }
        }
    }

    private init() {}

    // MARK: - Request builder
    func request<T: Decodable>(
        table: String? = nil,
        path: String? = nil,
        method: HTTPMethod = .GET,
        query: [(String, String)] = [],
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        var urlString: String
        if let table {
            urlString = "\(SupabaseConfig.url)/rest/v1/\(table)"
        } else if let path {
            urlString = "\(SupabaseConfig.url)\(path)"
        } else {
            throw APIError.invalidURL
        }

        guard var components = URLComponents(string: urlString) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.0, value: $0.1) }
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")

        if requiresAuth {
            guard let token = accessToken else { throw APIError.notAuthenticated }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try JSONEncoder.supabase.encode(body)
        }

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError(URLError(.badServerResponse)) }

        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(http.statusCode, msg)
        }

        do {
            return try JSONDecoder.supabase.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Void response (DELETE, etc.)
    func requestVoid(
        table: String? = nil,
        path: String? = nil,
        method: HTTPMethod,
        query: [(String, String)] = [],
        body: Encodable? = nil
    ) async throws {
        var urlString: String
        if let table { urlString = "\(SupabaseConfig.url)/rest/v1/\(table)" }
        else if let path { urlString = "\(SupabaseConfig.url)\(path)" }
        else { throw APIError.invalidURL }

        guard var components = URLComponents(string: urlString) else { throw APIError.invalidURL }
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.0, value: $0.1) }
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        if let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body { req.httpBody = try JSONEncoder.supabase.encode(body) }

        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError(0, "Requête échouée")
        }
    }

    // MARK: - Edge Function caller
    func callFunction<T: Decodable>(
        _ name: String,
        method: HTTPMethod = .GET,
        query: [(String, String)] = [],
        body: Encodable? = nil
    ) async throws -> T {
        var urlString = "\(SupabaseConfig.functionsURL)/\(name)"
        if !query.isEmpty {
            let qs = query.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
            urlString += "?\(qs)"
        }
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        if let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body { req.httpBody = try JSONEncoder.supabase.encode(body) }

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }
        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw APIError.serverError(http.statusCode, msg)
        }
        do {
            return try JSONDecoder.supabase.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func callFunctionVoid(
        _ name: String,
        method: HTTPMethod,
        body: Encodable? = nil
    ) async throws {
        let urlString = "\(SupabaseConfig.functionsURL)/\(name)"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        if let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body { req.httpBody = try JSONEncoder.supabase.encode(body) }

        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError(0, "Fonction edge échouée")
        }
    }

    // MARK: - Session helpers
    func storeSession(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearSession() {
        KeychainHelper.delete(forKey: "supabase_access_token")
        KeychainHelper.delete(forKey: "supabase_refresh_token")
    }
}

// MARK: - Codable helpers
extension JSONDecoder {
    static let supabase: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let str = try decoder.singleValueContainer().decode(String.self)
            if let date = formatter.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(), debugDescription: "Invalid date: \(str)")
        }
        return d
    }()
}

extension JSONEncoder {
    static let supabase: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()
}
