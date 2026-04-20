import Foundation
import Combine

// Lightweight Supabase Realtime listener using WebSocket
// Écoute les changements sur la table shopping_items pour la synchronisation famille
@MainActor
final class RealtimeManager: ObservableObject {
    static let shared = RealtimeManager()
    private var webSocketTask: URLSessionWebSocketTask?
    private var pingTask: Task<Void, Never>?

    private init() {}

    // MARK: - Subscribe to shopping_items changes for a family
    func subscribeToShoppingList(familyId: UUID, onChange: @escaping () -> Void) {
        // Évite les connexions WebSocket multiples si déjà abonné
        guard webSocketTask == nil else { return }

        let urlString = SupabaseConfig.url.absoluteString
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        + "/realtime/v1/websocket?apikey=\(SupabaseConfig.anonKey)&vsn=1.0.0"

        guard let url = URL(string: urlString) else { return }

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        sendJoinMessage(familyId: familyId)
        startPing()
        receiveLoop(onChange: onChange)
    }

    func unsubscribe() {
        pingTask?.cancel()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    // MARK: - Private
    private func sendJoinMessage(familyId: UUID) {
        let payload: [String: Any] = [
            "topic": "realtime:public:shopping_items:family_id=eq.\(familyId.uuidString)",
            "event": "phx_join",
            "payload": ["config": ["broadcast": ["self": true], "presence": ["key": ""]]],
            "ref": "1"
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let str = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(str)) { _ in }
    }

    private func startPing() {
        pingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                let heartbeat: [String: Any] = ["topic": "phoenix", "event": "heartbeat", "payload": [:], "ref": nil as Any? ?? NSNull()]
                if let data = try? JSONSerialization.data(withJSONObject: heartbeat),
                   let str = String(data: data, encoding: .utf8) {
                    webSocketTask?.send(.string(str)) { _ in }
                }
            }
        }
    }

    private func receiveLoop(onChange: @escaping () -> Void) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let str) = message,
                   let data = str.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let event = json["event"] as? String,
                   ["INSERT", "UPDATE", "DELETE"].contains(event) {
                    Task { @MainActor in onChange() }
                }
                self?.receiveLoop(onChange: onChange)
            case .failure:
                // Tentative de reconnexion après 2 secondes
                Task { @MainActor [weak self] in
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    self?.receiveLoop(onChange: onChange)
                }
            }
        }
    }
}
