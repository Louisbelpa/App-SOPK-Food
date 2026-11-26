import Testing
@testable import SOPKKit

struct LocalDateTests {
    @Test func parsesIsoAndRoundTrips() throws {
        let date = try #require(LocalDate(iso: "2026-11-26"))
        #expect(date == LocalDate(year: 2026, month: 11, day: 26))
        #expect(date.iso == "2026-11-26")
    }

    @Test(arguments: ["2026-02-30", "2026-13-01", "pas-une-date", "2026-11"])
    func rejectsInvalidDates(_ raw: String) {
        #expect(LocalDate(iso: raw) == nil)
    }

    @Test func countsDaysAcrossMonthsYearsAndLeapDays() {
        let start = LocalDate(year: 2024, month: 2, day: 28)
        #expect(start.adding(days: 1) == LocalDate(year: 2024, month: 2, day: 29))
        #expect(start.adding(days: 2) == LocalDate(year: 2024, month: 3, day: 1))
        #expect(LocalDate(year: 2025, month: 12, day: 31).adding(days: 1) == LocalDate(year: 2026, month: 1, day: 1))
        #expect(LocalDate(year: 2026, month: 1, day: 1).days(until: LocalDate(year: 2027, month: 1, day: 1)) == 365)
        #expect(start.adding(days: 400).adding(days: -400) == start)
    }
}
