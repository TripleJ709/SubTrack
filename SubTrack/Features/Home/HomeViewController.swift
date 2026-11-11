import UIKit

/// 홈 화면. 지금은 빈 화면이고, `home` spec에서 총액과 구독 리스트를 채운다.
final class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "구독"
        view.backgroundColor = .systemGroupedBackground
    }
}
