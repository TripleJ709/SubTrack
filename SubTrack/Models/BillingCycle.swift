/// 결제 주기. `rawValue`는 Core Data에 문자열로 저장되므로 값을 바꾸면 기존 데이터를 읽지 못한다.
enum BillingCycle: String, CaseIterable {
    case weekly
    case monthly
    case yearly
}
