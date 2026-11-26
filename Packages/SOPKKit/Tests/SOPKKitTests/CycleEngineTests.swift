import Testing
@testable import SOPKKit

struct CycleEngineTests {
    let engine = CycleEngine()
    let origin = LocalDate(year: 2026, month: 1, day: 1)

    /// Jours de règles : `bleedDays` jours consécutifs à partir de chaque décalage donné.
    func periodDays(startingAt offsets: [Int], bleedDays: Int = 5) -> [LocalDate] {
        offsets.flatMap { offset in (0..<bleedDays).map { origin.adding(days: offset + $0) } }
    }

    @Test func noHistoryMeansNoCycleNoEstimateNoAlert() {
        let cycles = engine.cycles(fromPeriodDays: [LocalDate]())
        #expect(cycles.isEmpty)
        #expect(engine.currentCycleDay(cycles: cycles, today: origin) == nil)
        #expect(engine.nextPeriodWindow(cycles: cycles) == nil)
        #expect(engine.alerts(cycles: cycles, today: origin).isEmpty)
    }

    @Test func groupsConsecutiveBleedingDaysIntoOneCycleStart() {
        let cycles = engine.cycles(fromPeriodDays: periodDays(startingAt: [0, 30, 58]))
        #expect(cycles.map(\.start) == [origin, origin.adding(days: 30), origin.adding(days: 58)])
        #expect(cycles.map(\.length) == [30, 28, nil])
    }

    @Test func spottingAFewDaysAfterPeriodDoesNotOpenANewCycle() {
        let days = periodDays(startingAt: [0]) + [origin.adding(days: 8)]
        #expect(engine.cycles(fromPeriodDays: days).count == 1)
    }

    @Test func ignoresDuplicatesAndOrder() {
        let days = periodDays(startingAt: [30, 0])
        #expect(engine.cycles(fromPeriodDays: days + days).map(\.length) == [30, nil])
    }

    @Test func currentCycleDayStartsAtOne() {
        let cycles = engine.cycles(fromPeriodDays: periodDays(startingAt: [0]))
        #expect(engine.currentCycleDay(cycles: cycles, today: origin) == 1)
        #expect(engine.currentCycleDay(cycles: cycles, today: origin.adding(days: 22)) == 23)
    }

    @Test func estimatesAWindowOnlyForRegularCycles() throws {
        // Cycles de 29, 31 et 33 jours : écart de 4 jours ≤ 7.
        let cycles = engine.cycles(fromPeriodDays: periodDays(startingAt: [0, 29, 60, 93]))
        let window = try #require(engine.nextPeriodWindow(cycles: cycles))
        #expect(window.earliest == origin.adding(days: 93 + 29))
        #expect(window.latest == origin.adding(days: 93 + 33))
    }

    @Test(arguments: [
        [0, 35, 95, 130],   // 35, 60, 35 jours : cycles irréguliers typiques du SOPK
        [0, 28, 56],        // seulement 2 cycles complets
        [0, 25, 50, 83]     // 25, 25, 33 : écart de 8 jours > 7
    ])
    func refusesToEstimateIrregularOrInsufficientHistory(offsets: [Int]) {
        let cycles = engine.cycles(fromPeriodDays: periodDays(startingAt: offsets))
        #expect(engine.isRegular(cycles: cycles) == false)
        #expect(engine.nextPeriodWindow(cycles: cycles) == nil)
    }

    @Test func onlyTheThreeMostRecentCyclesCount() {
        // Un vieux cycle de 60 jours, puis 3 cycles réguliers de 30 jours.
        let cycles = engine.cycles(fromPeriodDays: periodDays(startingAt: [0, 60, 90, 120, 150]))
        #expect(engine.isRegular(cycles: cycles))
    }

    @Test func alertsAfterNinetyDaysWithoutPeriod() {
        let cycles = engine.cycles(fromPeriodDays: periodDays(startingAt: [0]))
        #expect(engine.alerts(cycles: cycles, today: origin.adding(days: 89)).isEmpty)
        #expect(engine.alerts(cycles: cycles, today: origin.adding(days: 90)) == [.noPeriodSince(days: 90)])
    }
}
