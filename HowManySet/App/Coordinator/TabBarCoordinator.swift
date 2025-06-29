//
//  TabBarCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

/// 앱의 탭바 관련 코디네이터
/// 각 탭별 네비게이션 및 코디네이터 관리 담당
final class TabBarCoordinator: Coordinator {
    
    /// 완료 시 호출 클로저
    var finishFlow: (() -> Void)?
    
    let tabBarController: UITabBarController
    private let container: DIContainer
    
    /// MyPage → Auth 전환 중복 방지
    private var didRequestAuth = false
    
    // 각 탭에 대한 Coordinator
    private var homeCoordinator: HomeCoordinator?
    private var routineListCoordinator: RoutineListCoordinator?
    private var calendarCoordinator: CalendarCoordinator?
    private var myPageCoordinator: MyPageCoordinator?
    
    init(tabBarController: UITabBarController, container: DIContainer) {
        self.tabBarController = tabBarController
        self.container = container
        tabBarController.setValue(CustomTabbar(), forKey: "tabBar")
    }
    
    /// 탭바 초기화 및 각 탭의 네비게이션 및 코디네이터 시작
    func start() {
        
        // 각 탭에 대한 UINavigationController
        let homeNav = UINavigationController()
        let routineListNav = UINavigationController()
        let calendarNav = UINavigationController()
        let myPageNav = UINavigationController()
        
        // 각 탭의 코디네이터 생성
        homeCoordinator = HomeCoordinator(navigationController: homeNav, container: container)
        routineListCoordinator = RoutineListCoordinator(navigationController: routineListNav, container: container)
        calendarCoordinator = CalendarCoordinator(navigationController: calendarNav, container: container)
        myPageCoordinator = MyPageCoordinator(navigationController: myPageNav, container: container)
        
        homeCoordinator?.routineListCoordinator = routineListCoordinator
        routineListCoordinator?.homeCoordinator = homeCoordinator
        
        /// MyPageCoordinator의 finishFlow 설정 (로그아웃/계정삭제 시 호출됨)
        myPageCoordinator?.finishFlow = { [weak self] in
            /// 로그아웃/계정삭제 후 인증 화면으로 이동
            self?.navigateToAuth()
        }
        
        // 각 코디네이터 start()
        homeCoordinator?.start()
        routineListCoordinator?.start()
        calendarCoordinator?.start()
        myPageCoordinator?.start()
        
        tabBarController.viewControllers = [
            homeNav,
            routineListNav,
            calendarNav,
            myPageNav
        ]
        
        // 탭바 색 설정
        tabBarController.tabBar.backgroundColor = .tabBarBG
        tabBarController.tabBar.tintColor = .brand
        tabBarController.tabBar.unselectedItemTintColor = .gray
        
        // 탭바 아이템 설정
        homeNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: nil)
        routineListNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "list.dash"), selectedImage: nil)
        calendarNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "calendar"), selectedImage: nil)
        myPageNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), selectedImage: nil)
        
    }
    
    /// 로그아웃/계정삭제 후 인증 화면으로 이동
    private func navigateToAuth() {
        guard !didRequestAuth else { return }
        didRequestAuth = true
        finishFlow?()
    }
}

// Tabbar Height를 조정하기 위해 서브클래싱
fileprivate final class CustomTabbar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        let height = 60
        let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        size.height = 60 + safeAreaBottom
        return size
    }
}
