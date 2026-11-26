import Foundation

/// Un jour du calendrier, sans heure ni fuseau horaire.
///
/// On manipule des *jours* (« j'ai eu mes règles le 3 mars »), pas des instants :
/// stocker un `Date` ferait glisser la saisie d'un jour si l'utilisatrice change de fuseau.
public struct LocalDate: Hashable, Comparable, Codable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Le jour correspondant à `date` dans le calendrier et le fuseau donnés (par défaut : ceux de l'appareil).
    public init(_ date: Date, calendar: Calendar = .current) {
        self.init(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
    }

    /// Format ISO 8601 `AAAA-MM-JJ`.
    public init?(iso: String) {
        let parts = iso.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        let candidate = LocalDate(year: parts[0], month: parts[1], day: parts[2])
        // Rejette les dates impossibles (ex. 2026-02-30).
        guard candidate.adding(days: 0) == candidate else { return nil }
        self = candidate
    }

    public var iso: String { String(format: "%04d-%02d-%02d", year, month, day) }
    public var description: String { iso }

    /// Nombre de jours de `self` jusqu'à `other` (positif si `other` est après).
    public func days(until other: LocalDate) -> Int {
        Self.dayNumber(other) - Self.dayNumber(self)
    }

    public func adding(days: Int) -> LocalDate {
        Self.fromDayNumber(Self.dayNumber(self) + days)
    }

    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    // MARK: - Arithmétique calendaire (algorithme de Howard Hinnant, calendrier grégorien proleptique)
    // Purement entière : pas de Calendar, pas de fuseau, résultat identique sur iOS et Linux.

    private static func dayNumber(_ date: LocalDate) -> Int {
        let y = date.month <= 2 ? date.year - 1 : date.year
        let era = (y >= 0 ? y : y - 399) / 400
        let yoe = y - era * 400
        let mp = (date.month + 9) % 12
        let doy = (153 * mp + 2) / 5 + date.day - 1
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
        return era * 146_097 + doe
    }

    private static func fromDayNumber(_ number: Int) -> LocalDate {
        let era = (number >= 0 ? number : number - 146_096) / 146_097
        let doe = number - era * 146_097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146_096) / 365
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let day = doy - (153 * mp + 2) / 5 + 1
        let month = mp < 10 ? mp + 3 : mp - 9
        let year = yoe + era * 400 + (month <= 2 ? 1 : 0)
        return LocalDate(year: year, month: month, day: day)
    }
}
