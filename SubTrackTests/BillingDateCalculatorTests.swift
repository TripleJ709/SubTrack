import Testing
import Foundation
@testable import SubTrack

// MARK: - 테스트 도우미

/// 테스트용 달력. 그레고리력 + 서울 시간대로 고정해서 실행하는 곳의 설정에 영향받지 않게 한다.
private let seoulCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    return calendar
}()

/// "2026-01-31" 같은 문자열을 그날 0시의 `Date`로 만든다.
private func day(_ text: String, hour: Int = 0, minute: Int = 0) -> Date {
    let parts = text.split(separator: "-").compactMap { Int($0) }
    let components = DateComponents(
        year: parts[0], month: parts[1], day: parts[2], hour: hour, minute: minute
    )
    return seoulCalendar.date(from: components)!
}

/// 첫 결제일 / 주기 / 기준일에 대한 기대 결과 한 건. 실패했을 때 어떤 케이스인지 바로 보이게 설명을 붙인다.
struct NextDateCase: Sendable, CustomTestStringConvertible {
    let first: String
    let cycle: BillingCycle
    let reference: String
    let expected: String

    var testDescription: String { "\(cycle) 첫 결제일 \(first), 기준일 \(reference) → \(expected)" }
}

private let calculator = BillingDateCalculator(calendar: seoulCalendar)

// MARK: - 다음 결제일

/// foundation 요구사항 4.1 ~ 4.7
struct BillingDateCalculatorTests {

    // 4.1 기준일이 첫 결제일 이전이거나 같으면 첫 결제일
    @Test(arguments: [
        NextDateCase(first: "2026-03-15", cycle: .monthly, reference: "2026-01-01", expected: "2026-03-15"),
        NextDateCase(first: "2026-03-15", cycle: .monthly, reference: "2026-03-15", expected: "2026-03-15"),
        NextDateCase(first: "2026-03-15", cycle: .weekly, reference: "2026-03-14", expected: "2026-03-15"),
        NextDateCase(first: "2026-03-15", cycle: .yearly, reference: "2025-12-31", expected: "2026-03-15"),
    ])
    func 기준일이_첫_결제일_이전이거나_같으면_첫_결제일이다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 4.2 기준일이 첫 결제일 이후면 기준일 이후 가장 가까운 결제일
    @Test(arguments: [
        NextDateCase(first: "2026-01-15", cycle: .monthly, reference: "2026-03-20", expected: "2026-04-15"),
        NextDateCase(first: "2026-01-05", cycle: .weekly, reference: "2026-01-20", expected: "2026-01-26"),
        NextDateCase(first: "2024-03-10", cycle: .yearly, reference: "2026-03-11", expected: "2027-03-10"),
        NextDateCase(first: "2026-01-15", cycle: .monthly, reference: "2026-12-16", expected: "2027-01-15"),
    ])
    func 기준일_이후_가장_가까운_결제일을_돌려준다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 4.3 결제일 당일이면 그날이 다음 결제일
    @Test(arguments: [
        NextDateCase(first: "2026-01-15", cycle: .monthly, reference: "2026-03-15", expected: "2026-03-15"),
        NextDateCase(first: "2026-01-05", cycle: .weekly, reference: "2026-01-19", expected: "2026-01-19"),
        NextDateCase(first: "2024-03-10", cycle: .yearly, reference: "2026-03-10", expected: "2026-03-10"),
    ])
    func 결제일_당일이면_그날이_다음_결제일이다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 4.4 월간 결제일이 그 달에 없으면 그 달의 마지막 날
    @Test(arguments: [
        NextDateCase(first: "2026-01-31", cycle: .monthly, reference: "2026-02-01", expected: "2026-02-28"),
        NextDateCase(first: "2024-01-31", cycle: .monthly, reference: "2024-02-01", expected: "2024-02-29"),
        NextDateCase(first: "2026-01-31", cycle: .monthly, reference: "2026-04-01", expected: "2026-04-30"),
        NextDateCase(first: "2026-01-30", cycle: .monthly, reference: "2026-02-10", expected: "2026-02-28"),
    ])
    func 월간_결제일이_그_달에_없으면_마지막_날로_맞춘다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 4.5 짧은 달을 지나면 원래 결제일(31일)로 돌아온다
    @Test(arguments: [
        NextDateCase(first: "2026-01-31", cycle: .monthly, reference: "2026-02-28", expected: "2026-02-28"),
        NextDateCase(first: "2026-01-31", cycle: .monthly, reference: "2026-03-01", expected: "2026-03-31"),
        NextDateCase(first: "2026-01-31", cycle: .monthly, reference: "2026-04-30", expected: "2026-04-30"),
        NextDateCase(first: "2026-01-31", cycle: .monthly, reference: "2026-05-01", expected: "2026-05-31"),
    ])
    func 짧은_달_다음에는_원래_결제일로_돌아온다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 4.6 연간 2월 29일은 윤년이 아닌 해에 2월 28일
    @Test(arguments: [
        NextDateCase(first: "2024-02-29", cycle: .yearly, reference: "2025-01-01", expected: "2025-02-28"),
        NextDateCase(first: "2024-02-29", cycle: .yearly, reference: "2027-03-01", expected: "2028-02-29"),
        NextDateCase(first: "2024-02-29", cycle: .yearly, reference: "2028-03-01", expected: "2029-02-28"),
    ])
    func 연간_2월_29일은_윤년이_아닌_해에_28일이다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 몇 년이 지난 구독도 같은 규칙으로 계산한다
    @Test(arguments: [
        NextDateCase(first: "2020-01-31", cycle: .monthly, reference: "2026-11-11", expected: "2026-11-30"),
        NextDateCase(first: "2020-01-01", cycle: .weekly, reference: "2026-11-11", expected: "2026-11-11"),
        NextDateCase(first: "2020-01-01", cycle: .weekly, reference: "2026-11-12", expected: "2026-11-18"),
        NextDateCase(first: "2010-06-15", cycle: .yearly, reference: "2026-11-11", expected: "2027-06-15"),
    ])
    func 몇_년이_지난_구독도_계산한다(testCase: NextDateCase) {
        let result = calculator.nextBillingDate(
            firstBillingDate: day(testCase.first), cycle: testCase.cycle, from: day(testCase.reference)
        )
        #expect(result == day(testCase.expected))
    }

    // 4.7 시각은 무시하고 날짜로만 비교한다
    @Test func 같은_날이면_시각이_달라도_그날이_결제일이다() {
        let first = day("2026-01-15")
        let lateInTheDay = day("2026-01-15", hour: 23, minute: 59)
        let result = calculator.nextBillingDate(firstBillingDate: first, cycle: .monthly, from: lateInTheDay)
        #expect(result == day("2026-01-15"))
    }

    @Test func 첫_결제일에_시각이_섞여_있어도_날짜_0시로_돌려준다() {
        let first = day("2026-01-15", hour: 18, minute: 30)
        let morning = day("2026-01-15", hour: 9)
        let result = calculator.nextBillingDate(firstBillingDate: first, cycle: .monthly, from: morning)
        #expect(result == day("2026-01-15"))
    }
}

// MARK: - 앞으로 N회의 결제일

/// foundation 요구사항 4.8
struct BillingDateCalculatorUpcomingTests {

    @Test func 월말_구독은_짧은_달을_맞추고_원래_날짜로_돌아온다() {
        let dates = calculator.upcomingBillingDates(
            firstBillingDate: day("2026-01-31"), cycle: .monthly, from: day("2026-02-01"), count: 3
        )
        #expect(dates == [day("2026-02-28"), day("2026-03-31"), day("2026-04-30")])
    }

    @Test func 기준일이_결제일_당일이면_그날부터_센다() {
        let dates = calculator.upcomingBillingDates(
            firstBillingDate: day("2026-01-05"), cycle: .weekly, from: day("2026-01-19"), count: 3
        )
        #expect(dates == [day("2026-01-19"), day("2026-01-26"), day("2026-02-02")])
    }

    @Test func 첫_결제일_전이면_첫_결제일부터_센다() {
        let dates = calculator.upcomingBillingDates(
            firstBillingDate: day("2026-03-15"), cycle: .monthly, from: day("2026-01-01"), count: 3
        )
        #expect(dates == [day("2026-03-15"), day("2026-04-15"), day("2026-05-15")])
    }

    @Test func 연간_2월_29일은_해마다_윤년_여부에_따라_맞춘다() {
        let dates = calculator.upcomingBillingDates(
            firstBillingDate: day("2024-02-29"), cycle: .yearly, from: day("2027-03-01"), count: 3
        )
        #expect(dates == [day("2028-02-29"), day("2029-02-28"), day("2030-02-28")])
    }

    @Test func 첫_번째_날짜는_다음_결제일과_같다() {
        let first = day("2026-01-31")
        let reference = day("2026-06-10")
        let next = calculator.nextBillingDate(firstBillingDate: first, cycle: .monthly, from: reference)
        let list = calculator.upcomingBillingDates(firstBillingDate: first, cycle: .monthly, from: reference, count: 3)
        #expect(list.first == next)
    }

    @Test func 개수가_영이면_빈_목록이다() {
        let dates = calculator.upcomingBillingDates(
            firstBillingDate: day("2026-01-31"), cycle: .monthly, from: day("2026-02-01"), count: 0
        )
        #expect(dates.isEmpty)
    }
}
