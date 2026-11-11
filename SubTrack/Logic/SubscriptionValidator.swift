import Foundation

/// 구독 입력 검증 오류. 화면에서 어떤 문구로 보일지는 ViewModel이 정한다.
enum SubscriptionValidationError: Error, Equatable {
    case emptyName
    case nonPositiveAmount
}

/// 구독을 저장하기 전에 입력값을 검사한다.
enum SubscriptionValidator {

    /// 이름이 비었거나 금액이 0 이하이면 오류를 던진다. 둘 다 잘못이면 이름 오류를 먼저 던진다.
    static func validate(name: String, amount: Decimal) throws(SubscriptionValidationError) {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw .emptyName
        }
        if amount <= 0 {
            throw .nonPositiveAmount
        }
    }
}
