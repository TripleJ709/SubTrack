import UIKit

/// 통계 화면. 지금은 빈 화면이고, `stats` spec에서 차트를 채운다.
final class StatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "통계"
        view.backgroundColor = .systemGroupedBackground
    }
}
