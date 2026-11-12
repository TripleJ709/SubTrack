import Testing
import Foundation
@testable import SubTrack

/// 입력 검증 (foundation 요구사항 3.1, 3.2)
struct SubscriptionValidatorTests {

    // MARK: 정상 값

    @Test func 이름과_금액이_올바르면_통과한다() throws {
        try SubscriptionValidator.validate(name: "Netflix", amount: 17_000)
    }

    @Test func 앞뒤_공백이_있어도_내용이_있으면_통과한다() throws {
        try SubscriptionValidator.validate(name: "  Netflix  ", amount: 17_000)
    }

    @Test func 소수_금액도_영보다_크면_통과한다() throws {
        try SubscriptionValidator.validate(name: "Netflix", amount: Decimal(string: "0.01")!)
    }

    // MARK: 이름 (요구사항 3.1)

    @Test(arguments: ["", " ", "   ", "\n", "\t ", " \n\t "])
    func 공백만_있거나_빈_이름은_emptyName이다(name: String) {
        #expect(throws: SubscriptionValidationError.emptyName) {
            try SubscriptionValidator.validate(name: name, amount: 17_000)
        }
    }

    // MARK: 금액 (요구사항 3.2)

    @Test(arguments: [Decimal(0), Decimal(-1), Decimal(string: "-0.01")!])
    func 영_이하_금액은_nonPositiveAmount이다(amount: Decimal) {
        #expect(throws: SubscriptionValidationError.nonPositiveAmount) {
            try SubscriptionValidator.validate(name: "Netflix", amount: amount)
        }
    }

    // MARK: 둘 다 잘못된 경우

    @Test func 이름과_금액이_모두_잘못이면_이름_오류를_먼저_돌려준다() {
        // 폼의 입력 순서(이름 → 금액)와 맞춘다.
        #expect(throws: SubscriptionValidationError.emptyName) {
            try SubscriptionValidator.validate(name: "", amount: 0)
        }
    }
}
