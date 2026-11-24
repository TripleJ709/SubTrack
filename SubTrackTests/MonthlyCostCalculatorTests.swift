import Testing
import Foundation
@testable import SubTrack

/// 금액 / 주기에 대한 기대 결과 한 건. 실패했을 때 어떤 케이스인지 바로 보이게 설명을 붙인다.
struct MonthlyCostCase: Sendable, CustomTestStringConvertible {
    let amount: Decimal
    let cycle: BillingCycle
    let expected: Decimal

    var testDescription: String { "\(cycle) \(amount) → 월 \(expected)" }
}

/// 나누어떨어지지 않는 값을 비교할 때 허용하는 차이. (Decimal도 1/3은 끝자리가 잘린다)
private let tolerance = Decimal(string: "0.0000000001")!

/// 원 단위로 반올림한다. 화면에 표시할 때의 반올림을 흉내 낸다.
private func roundedToWon(_ value: Decimal) -> Decimal {
    var source = value
    var result = Decimal()
    NSDecimalRound(&result, &source, 0, .plain)
    return result
}

/// 월 환산 금액 (foundation 요구사항 5.1 ~ 5.3)
struct MonthlyCostCalculatorTests {

    // MARK: 주기별 환산 (요구사항 5.1)

    @Test(arguments: [
        MonthlyCostCase(amount: 17_000, cycle: .monthly, expected: 17_000),
        MonthlyCostCase(amount: 120_000, cycle: .yearly, expected: 10_000),
        MonthlyCostCase(amount: 3_000, cycle: .weekly, expected: 13_000),
    ])
    func 주기에_맞게_월_금액으로_환산한다(testCase: MonthlyCostCase) {
        let result = MonthlyCostCalculator.monthlyCost(amount: testCase.amount, cycle: testCase.cycle)
        #expect(result == testCase.expected)
    }

    @Test(arguments: BillingCycle.allCases)
    func 금액이_영이면_주기와_상관없이_영이다(cycle: BillingCycle) {
        #expect(MonthlyCostCalculator.monthlyCost(amount: 0, cycle: cycle) == 0)
    }

    // MARK: 합계 (요구사항 5.2)

    @Test func 빈_목록의_합계는_영이다() {
        #expect(MonthlyCostCalculator.total([]) == 0)
    }

    @Test func 주기가_섞여_있어도_월_환산_금액으로_더한다() {
        let total = MonthlyCostCalculator.total([
            (amount: 17_000, cycle: .monthly),
            (amount: 120_000, cycle: .yearly),
            (amount: 3_000, cycle: .weekly),
        ])
        #expect(total == 40_000)
    }

    // MARK: Decimal, 반올림 안 함 (요구사항 5.3)

    @Test func 소수_금액을_더해도_오차가_없다() {
        // Double이면 0.1 + 0.2가 0.30000000000000004가 된다.
        let total = MonthlyCostCalculator.total([
            (amount: Decimal(string: "0.1")!, cycle: .monthly),
            (amount: Decimal(string: "0.2")!, cycle: .monthly),
        ])
        #expect(total == Decimal(string: "0.3")!)
    }

    @Test func 연간_금액이_나누어떨어지지_않아도_반올림하지_않는다() {
        // 10,000 ÷ 12 = 833.333...
        let result = MonthlyCostCalculator.monthlyCost(amount: 10_000, cycle: .yearly)
        #expect(result != roundedToWon(result))
        #expect(abs(result * 12 - 10_000) < tolerance)
    }

    @Test func 주간_금액이_나누어떨어지지_않아도_반올림하지_않는다() {
        // 1,000 × 52 ÷ 12 = 4,333.333...
        let result = MonthlyCostCalculator.monthlyCost(amount: 1_000, cycle: .weekly)
        #expect(result != roundedToWon(result))
        #expect(abs(result * 12 - 52_000) < tolerance)
    }

    @Test func 합계는_각각_반올림하지_않고_더한다() {
        // 833.333... × 3 = 2,500. 먼저 반올림하면 833 × 3 = 2,499가 되어 1원이 모자란다.
        let total = MonthlyCostCalculator.total(Array(repeating: (amount: 10_000, cycle: .yearly), count: 3))
        #expect(roundedToWon(total) == 2_500)
    }
}
