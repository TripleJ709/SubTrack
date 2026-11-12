import Foundation

/// 첫 결제일과 주기로 다음 결제일을 계산한다.
/// 달력(`Calendar`)을 밖에서 받아서, 테스트에서 시간대를 고정할 수 있다.
///
/// 핵심 규칙: n번째 결제일은 항상 **첫 결제일에 n번 더해서** 구한다.
/// 직전 결제일에 1번씩 더하면 1/31 → 2/28 → 3/28처럼 결제일이 밀려 버린다.
/// 첫 결제일에서 매번 다시 더하면 1/31 → 2/28 → 3/31로 원래 날짜로 돌아온다.
struct BillingDateCalculator {
    let calendar: Calendar

    /// 기준일(포함) 이후 가장 가까운 결제일. 시각은 무시하고 날짜(0시)로 돌려준다.
    func nextBillingDate(firstBillingDate: Date, cycle: BillingCycle, from referenceDate: Date) -> Date {
        let first = calendar.startOfDay(for: firstBillingDate)
        let reference = calendar.startOfDay(for: referenceDate)
        let index = nextIndex(first: first, cycle: cycle, reference: reference)
        return billingDate(first: first, cycle: cycle, index: index)
    }

    /// 기준일(포함)부터 앞으로 `count`회의 결제일.
    func upcomingBillingDates(firstBillingDate: Date, cycle: BillingCycle, from referenceDate: Date, count: Int) -> [Date] {
        guard count > 0 else { return [] }
        let first = calendar.startOfDay(for: firstBillingDate)
        let reference = calendar.startOfDay(for: referenceDate)
        let start = nextIndex(first: first, cycle: cycle, reference: reference)
        return (0..<count).map { billingDate(first: first, cycle: cycle, index: start + $0) }
    }

    // MARK: - 내부 계산

    /// 첫 결제일에 `index`번 더한 결제일. `index`가 0이면 첫 결제일이다.
    /// 없는 날짜(예: 2월 31일)는 `Calendar`가 그 달의 마지막 날로 맞춰 준다.
    private func billingDate(first: Date, cycle: BillingCycle, index: Int) -> Date {
        calendar.date(byAdding: cycle.calendarComponent, value: index, to: first) ?? first
    }

    /// 기준일 이상이 되는 가장 작은 `index`.
    private func nextIndex(first: Date, cycle: BillingCycle, reference: Date) -> Int {
        guard reference > first else { return 0 }

        // 지난 기간으로 대략의 위치를 먼저 구해서, 몇 년 지난 구독도 한 칸씩 세지 않게 한다.
        let component = cycle.calendarComponent
        let elapsed = calendar.dateComponents([component], from: first, to: reference)
        var index = max(0, elapsed.value(for: component) ?? 0)

        // 대략의 위치는 한두 칸 틀릴 수 있으니 정확한 위치로 맞춘다.
        while index > 0, billingDate(first: first, cycle: cycle, index: index - 1) >= reference {
            index -= 1
        }
        while billingDate(first: first, cycle: cycle, index: index) < reference {
            index += 1
        }
        return index
    }
}

private extension BillingCycle {
    /// 주기 하나를 `Calendar`의 단위로 바꾼다.
    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly: .weekOfYear
        case .monthly: .month
        case .yearly: .year
        }
    }
}
