import Foundation

/// 첫 결제일과 주기로 다음 결제일을 계산한다.
/// 달력(`Calendar`)을 밖에서 받아서, 테스트에서 시간대를 고정할 수 있다.
struct BillingDateCalculator {
    let calendar: Calendar

    /// 기준일(포함) 이후 가장 가까운 결제일.
    func nextBillingDate(firstBillingDate: Date, cycle: BillingCycle, from referenceDate: Date) -> Date {
        // TODO(2.4): 구현한다. 지금은 테스트가 컴파일되고 "실패"하도록 일부러 틀린 값을 돌려준다.
        .distantPast
    }

    /// 기준일(포함)부터 앞으로 `count`회의 결제일.
    func upcomingBillingDates(firstBillingDate: Date, cycle: BillingCycle, from referenceDate: Date, count: Int) -> [Date] {
        // TODO(2.4): 구현한다.
        []
    }
}
