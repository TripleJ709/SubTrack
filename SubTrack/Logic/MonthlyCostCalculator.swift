import Foundation

/// 구독 금액을 월 기준으로 환산한다.
/// 반올림하지 않은 값을 돌려준다. 먼저 반올림하고 더하면 합계가 어긋나므로, 반올림은 화면에 표시할 때 한 번만 한다.
enum MonthlyCostCalculator {

    /// 구독 하나의 월 환산 금액. 1년을 52주, 12개월로 본다.
    static func monthlyCost(amount: Decimal, cycle: BillingCycle) -> Decimal {
        switch cycle {
        case .weekly: amount * 52 / 12
        case .monthly: amount
        case .yearly: amount / 12
        }
    }

    /// 여러 구독의 월 환산 금액 합계. 빈 목록이면 0이다.
    static func total(_ items: [(amount: Decimal, cycle: BillingCycle)]) -> Decimal {
        items.reduce(0) { $0 + monthlyCost(amount: $1.amount, cycle: $1.cycle) }
    }
}
