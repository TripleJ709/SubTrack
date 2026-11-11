import Testing
import UIKit
@testable import SubTrack

/// 앱 시작 구조 확인 (foundation 요구사항 1.2)
@MainActor
struct MainTabBarControllerTests {

    @Test func 홈과_통계_두_탭을_가진다() throws {
        let tabBarController = MainTabBarController()
        tabBarController.loadViewIfNeeded()

        let tabs = try #require(tabBarController.viewControllers)
        #expect(tabs.map(\.tabBarItem.title) == ["홈", "통계"])
    }

    @Test func 각_탭은_내비게이션으로_감싼_화면이다() throws {
        let tabBarController = MainTabBarController()
        tabBarController.loadViewIfNeeded()

        let tabs = try #require(tabBarController.viewControllers)
        let roots = tabs.compactMap { ($0 as? UINavigationController)?.viewControllers.first }
        #expect(roots.count == 2)
        #expect(roots.first is HomeViewController)
        #expect(roots.last is StatsViewController)
    }
}
