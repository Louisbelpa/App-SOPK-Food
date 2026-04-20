import Foundation

// MARK: - Unified application error type
enum AppError: Error, LocalizedError, Equatable {
    case network(String)
    case auth(String)
    case notFound(String)
    case decoding(String)
    case unknown(String)

    // MARK: - Convenience initialisers from existing error types
    init(from apiError: APIError) {
        switch apiError {
        case .notAuthenticated:
            self = .auth(apiError.errorDescription ?? "Non authentifié")
        case .invalidURL:
            self = .network("URL invalide")
        case .serverError(let code, let msg):
            if code == 404 {
                self = .notFound(msg)
            } else {
                self = .network("Erreur serveur (\(code)): \(msg)")
            }
        case .decodingError(let err):
            self = .decoding(err.localizedDescription)
        case .networkError(let err):
            self = .network(err.localizedDescription)
        }
    }

    init(from error: Error) {
        if let apiError = error as? APIError {
            self.init(from: apiError)
        } else {
            self = .unknown(error.localizedDescription)
        }
    }

    // MARK: - LocalizedError
    var errorDescription: String? {
        switch self {
        case .network(let msg):   return "Erreur réseau : \(msg)"
        case .auth(let msg):      return "Erreur d'authentification : \(msg)"
        case .notFound(let msg):  return "Introuvable : \(msg)"
        case .decoding(let msg):  return "Erreur de décodage : \(msg)"
        case .unknown(let msg):   return "Erreur inconnue : \(msg)"
        }
    }

    // MARK: - Equatable
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
