//
//  TabBarCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    
    let tabBarController: UITabBarController
    private let container: DIContainer
    
    // 각 탭에 대한 Coordinator
    private var homeCoordinator: HomeCoordinator?
    private var routineListCoordinator: RoutineListCoordinator?
    private var calendarCoordinator: CalendarCoordinator?
    private var myPageCoordinator: MyPageCoordinator?

    init(tabBarController: UITabBarController, container: DIContainer) {
        self.tabBarController = tabBarController
        self.container = container
    }
    
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
        tabBarController.tabBar.backgroundColor = .secondarySystemBackground
        tabBarController.tabBar.tintColor = .green
        tabBarController.tabBar.unselectedItemTintColor = .gray
        
        // 탭바 아이템 설정
        homeNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: nil)
        routineListNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "list.dash"), selectedImage: nil)
        calendarNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "calendar"), selectedImage: nil)
        myPageNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), selectedImage: nil)
        
    }
}
