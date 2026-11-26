import Foundation

/// Accès au contenu éditorial embarqué dans l'app (fichiers JSON de `Resources/Content`).
public enum ContentLibrary {
    public enum LoadingError: Error {
        case missingResource(String)
    }

    public static func recipes() throws -> [Recipe] {
        try decode([Recipe].self, resource: "recipes")
    }

    public static func workouts() throws -> WorkoutCatalog {
        try decode(WorkoutCatalog.self, resource: "workouts")
    }

    static func decode<T: Decodable>(_ type: T.Type, resource: String) throws -> T {
        guard let url = Bundle.module.url(forResource: resource, withExtension: "json")
            ?? Bundle.module.url(forResource: resource, withExtension: "json", subdirectory: "Content")
        else {
            throw LoadingError.missingResource(resource)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: Data(contentsOf: url))
    }
}
