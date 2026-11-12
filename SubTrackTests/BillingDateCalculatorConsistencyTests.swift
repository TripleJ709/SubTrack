import Testing
import Foundation
@testable import SubTrack

/// 빠른 계산(지난 기간으로 위치를 짐작)이 "하나씩 세는 느린 방식"과 같은 답을 내는지 확인한다.
/// 월말·윤일 같은 까다로운 첫 결제일로 기준일을 하루씩 옮겨 가며 모두 비교한다.
struct BillingDateCalculatorConsistencyTests {

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()

    /// 느린 방식: 첫 결제일에 0, 1, 2...번 더해 보면서 기준일 이상이 되는 첫 날짜를 찾는다.
    private func slowNext(first: Date, cycle: BillingCycle, reference: Date) -> Date {
        let component: Calendar.Component = switch cycle {
        case .weekly: .weekOfYear
        case .monthly: .month
        case .yearly: .year
        }
        var index = 0
        while true {
            let candidate = calendar.date(byAdding: component, value: index, to: first)!
            if candidate >= reference { return candidate }
            index += 1
        }
    }

    @Test(arguments: BillingCycle.allCases)
    func 빠른_계산은_하나씩_세는_계산과_같다(cycle: BillingCycle) {
        let calculator = BillingDateCalculator(calendar: calendar)
        let firstDates = [(2024, 1, 31), (2024, 2, 29), (2026, 1, 15), (2020, 3, 31), (2023, 12, 31)]

        for (year, month, dayOfMonth) in firstDates {
            let first = calendar.date(from: DateComponents(year: year, month: month, day: dayOfMonth))!
            // 첫 결제일 10일 전부터 약 3년 뒤까지 하루씩 옮긴다.
            for offset in -10...1100 {
                let reference = calendar.date(byAdding: .day, value: offset, to: first)!
                let expected = slowNext(first: first, cycle: cycle, reference: reference)
                let actual = calculator.nextBillingDate(firstBillingDate: first, cycle: cycle, from: reference)
                #expect(actual == expected, "\(cycle) 첫 결제일 \(first), 기준일 +\(offset)일")
            }
        }
    }
}
