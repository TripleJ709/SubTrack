/// 구독 카테고리 고정 목록. `rawValue`는 Core Data에 문자열로 저장되므로 값을 바꾸면 기존 데이터를 읽지 못한다.
enum SubscriptionCategory: String, CaseIterable {
    case video
    case music
    case shopping
    case productivity
    case cloud
    case game
    case etc
}
