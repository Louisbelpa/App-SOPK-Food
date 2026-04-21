import XCTest
@testable import SOPK

// MARK: - Phase calculation tests
//
// CycleStore.phaseFor(day:length:) is a static function so we can test it
// without any network or storage dependencies.

@MainActor
final class CycleStoreTests: XCTestCase {

    // MARK: - phaseFor(day:length:) — standard 28-day cycle

    func testDay1IsMenstruelle() {
        XCTAssertEqual(CycleStore.phaseFor(day: 1, length: 28), "Menstruelle")
    }

    func testDay5IsMenstruelle() {
        XCTAssertEqual(CycleStore.phaseFor(day: 5, length: 28), "Menstruelle")
    }

    func testDay6IsFolliculaire() {
        // day 6 > 5 && <= Int(28 * 0.46) = 12
        XCTAssertEqual(CycleStore.phaseFor(day: 6, length: 28), "Folliculaire")
    }

    func testDay12IsFolliculaire() {
        XCTAssertEqual(CycleStore.phaseFor(day: 12, length: 28), "Folliculaire")
    }

    func testDay13IsOvulatoire() {
        // Int(28 * 0.46) = 12, Int(28 * 0.53) = 14 — day 13 falls in ovulatory window
        XCTAssertEqual(CycleStore.phaseFor(day: 13, length: 28), "Ovulatoire")
    }

    func testDay14IsOvulatoire() {
        XCTAssertEqual(CycleStore.phaseFor(day: 14, length: 28), "Ovulatoire")
    }

    func testDay15IsLuteale() {
        XCTAssertEqual(CycleStore.phaseFor(day: 15, length: 28), "Lutéale")
    }

    func testDay28IsLuteale() {
        XCTAssertEqual(CycleStore.phaseFor(day: 28, length: 28), "Lutéale")
    }

    // MARK: - phaseFor(day:length:) — shorter 21-day cycle

    func testShorterCycle21Day1IsMenstruelle() {
        XCTAssertEqual(CycleStore.phaseFor(day: 1, length: 21), "Menstruelle")
    }

    func testShorterCycle21Day5IsMenstruelle() {
        XCTAssertEqual(CycleStore.phaseFor(day: 5, length: 21), "Menstruelle")
    }

    func testShorterCycle21Day6IsFolliculaire() {
        // Int(21 * 0.46) = 9
        XCTAssertEqual(CycleStore.phaseFor(day: 6, length: 21), "Folliculaire")
    }

    func testShorterCycle21Day11IsLuteale() {
        // Int(21 * 0.53) = 11 → day 12 is luteal
        XCTAssertEqual(CycleStore.phaseFor(day: 12, length: 21), "Lutéale")
    }

    // MARK: - phaseFor(day:length:) — longer 35-day cycle

    func testLongerCycle35Day1IsMenstruelle() {
        XCTAssertEqual(CycleStore.phaseFor(day: 1, length: 35), "Menstruelle")
    }

    func testLongerCycle35Day20IsLuteale() {
        // Int(35 * 0.53) = 18 → day 20 is luteal
        XCTAssertEqual(CycleStore.phaseFor(day: 20, length: 35), "Lutéale")
    }

    // MARK: - currentDay wraps correctly within cycleLength

    func testCurrentDayIsAtLeastOne() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 28)
        XCTAssertGreaterThanOrEqual(store.currentDay, 1)
    }

    func testCurrentDayDoesNotExceedCycleLength() {
        let store = CycleStore()
        // Set last period to far in the past so the day wraps
        let oldDate = Calendar.current.date(byAdding: .day, value: -60, to: Date())!
        store.save(lastPeriod: oldDate, length: 28)
        XCTAssertLessThanOrEqual(store.currentDay, store.cycleLength)
    }

    // MARK: - save() clamps cycleLength to [21, 45]

    func testSaveClampsCycleLengthAboveMinimum() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 10) // below minimum 21
        XCTAssertEqual(store.cycleLength, 21)
    }

    func testSaveClampsCycleLengthBelowMaximum() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 100) // above maximum 45
        XCTAssertEqual(store.cycleLength, 45)
    }

    func testSaveAcceptsValidCycleLength() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 30)
        XCTAssertEqual(store.cycleLength, 30)
    }

    // MARK: - isConfigured

    func testIsConfiguredFalseWithoutLastPeriod() {
        let store = CycleStore()
        store.clear()
        XCTAssertFalse(store.isConfigured)
    }

    func testIsConfiguredTrueAfterSave() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 28)
        XCTAssertTrue(store.isConfigured)
    }

    // MARK: - clear()

    func testClearResetsStore() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 28)
        store.clear()
        XCTAssertNil(store.lastPeriodDate)
        XCTAssertEqual(store.cycleLength, 28)
        XCTAssertFalse(store.isConfigured)
    }

    // MARK: - currentPhase uses currentDay

    func testCurrentPhaseIsConsistentWithCurrentDay() {
        let store = CycleStore()
        store.save(lastPeriod: Date(), length: 28)
        let expectedPhase = CycleStore.phaseFor(day: store.currentDay, length: store.cycleLength)
        XCTAssertEqual(store.currentPhase, expectedPhase)
    }
}
