import UIKit

/// 앱의 루트 화면. [홈], [통계] 두 탭을 코드로 구성한다.
final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            makeTab(
                root: HomeViewController(),
                title: "홈",
                systemImageName: "list.bullet"
            ),
            makeTab(
                root: StatsViewController(),
                title: "통계",
                systemImageName: "chart.pie"
            ),
        ]
    }

    /// 화면을 `UINavigationController`로 감싸고 탭 아이템을 붙인다.
    private func makeTab(root: UIViewController, title: String, systemImageName: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: systemImageName),
            selectedImage: nil
        )
        return navigationController
    }
}
