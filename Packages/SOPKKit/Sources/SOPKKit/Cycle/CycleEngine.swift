import Foundation

/// Un cycle reconstitué à partir des jours de règles saisis.
public struct Cycle: Hashable, Sendable {
    /// Premier jour des règles.
    public let start: LocalDate
    /// Durée en jours jusqu'au cycle suivant ; `nil` pour le cycle en cours.
    public let length: Int?
}

/// Fourchette indicative pour les prochaines règles.
public struct PeriodWindow: Hashable, Sendable {
    public let earliest: LocalDate
    public let latest: LocalDate
}

/// Signal factuel qui doit amener à proposer une consultation (voir `docs/kickoff/04-medical.md`).
public enum CycleAlert: Hashable, Sendable {
    /// Pas de règles depuis `days` jours (seuil : 90 jours).
    case noPeriodSince(days: Int)
}

/// Calculs sur l'historique des règles.
///
/// Règles produit (arbitrage médical, `docs/kickoff/07-synthese-decisions.md`) :
/// - **jamais** de prédiction d'ovulation, de fenêtre fertile ni de phase du cycle ;
/// - estimation des prochaines règles **uniquement** si les cycles sont réguliers
///   (3 derniers cycles complets qui varient de 7 jours au plus), et toujours sous forme de fourchette.
///   L'app la garde désactivée par défaut : c'est un réglage que l'utilisatrice active.
public struct CycleEngine: Sendable {
    /// Deux jours de règles séparés d'au moins ce nombre de jours sans saignement ouvrent un nouveau cycle.
    public static let minimumGapBetweenPeriods = 10
    /// Seuil d'aménorrhée à partir duquel on conseille de consulter.
    public static let amenorrheaThresholdDays = 90
    /// Variation maximale entre les cycles retenus pour accepter d'afficher une estimation.
    public static let regularityToleranceDays = 7
    /// Nombre de cycles complets nécessaires pour une estimation.
    public static let cyclesNeededForEstimate = 3

    public init() {}

    /// Reconstitue les cycles à partir des jours où l'utilisatrice a noté des saignements (règles).
    public func cycles(fromPeriodDays periodDays: some Collection<LocalDate>) -> [Cycle] {
        let sorted = Set(periodDays).sorted()
        guard var previous = sorted.first else { return [] }

        var starts = [previous]
        for day in sorted.dropFirst() {
            if previous.days(until: day) >= Self.minimumGapBetweenPeriods {
                starts.append(day)
            }
            previous = day
        }

        return starts.enumerated().map { index, start in
            let next = index + 1 < starts.count ? starts[index + 1] : nil
            return Cycle(start: start, length: next.map { start.days(until: $0) })
        }
    }

    /// Jour du cycle en cours (1 = premier jour des règles), ou `nil` sans historique.
    public func currentCycleDay(cycles: [Cycle], today: LocalDate) -> Int? {
        guard let last = cycles.last, last.start <= today else { return nil }
        return last.start.days(until: today) + 1
    }

    /// Alertes factuelles à afficher (avec un renvoi vers un professionnel de santé).
    public func alerts(cycles: [Cycle], today: LocalDate) -> [CycleAlert] {
        guard let last = cycles.last else { return [] }
        let days = last.start.days(until: today)
        return days >= Self.amenorrheaThresholdDays ? [.noPeriodSince(days: days)] : []
    }

    /// Les cycles récents sont-ils assez réguliers pour qu'une estimation ait un sens ?
    public func isRegular(cycles: [Cycle]) -> Bool {
        let lengths = cycles.compactMap(\.length).suffix(Self.cyclesNeededForEstimate)
        guard lengths.count == Self.cyclesNeededForEstimate,
              let min = lengths.min(), let max = lengths.max() else { return false }
        return max - min <= Self.regularityToleranceDays
    }

    /// Fourchette indicative des prochaines règles, ou `nil` si les cycles ne sont pas réguliers.
    public func nextPeriodWindow(cycles: [Cycle]) -> PeriodWindow? {
        guard isRegular(cycles: cycles), let last = cycles.last else { return nil }
        let lengths = cycles.compactMap(\.length).suffix(Self.cyclesNeededForEstimate)
        guard let min = lengths.min(), let max = lengths.max() else { return nil }
        return PeriodWindow(earliest: last.start.adding(days: min), latest: last.start.adding(days: max))
    }
}
