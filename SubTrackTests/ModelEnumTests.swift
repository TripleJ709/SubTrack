import Testing
@testable import SubTrack

/// 열거형의 저장 값 확인 (foundation 요구사항 2.2, 2.3)
/// 문자열 값은 Core Data에 그대로 저장되므로, 실수로 바꾸면 이 테스트가 실패해서 알려 준다.
struct ModelEnumTests {

    @Test func 결제_주기는_주간_월간_연간이다() {
        #expect(BillingCycle.allCases.map(\.rawValue) == ["weekly", "monthly", "yearly"])
    }

    @Test func 카테고리는_고정_목록_일곱_개다() {
        #expect(SubscriptionCategory.allCases.map(\.rawValue) == [
            "video", "music", "shopping", "productivity", "cloud", "game", "etc",
        ])
    }

    @Test func 알_수_없는_문자열은_열거형으로_만들어지지_않는다() {
        // Core Data에서 읽을 때 월간 / 기타로 대체하는 것은 엔티티(3.1)가 맡는다.
        #expect(BillingCycle(rawValue: "daily") == nil)
        #expect(SubscriptionCategory(rawValue: "unknown") == nil)
    }
}
