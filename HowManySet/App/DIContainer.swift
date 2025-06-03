//
//  DIContainer.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class DIContainer {

    func makeOnBoardingViewController(coordinator: OnBoardingCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = OnBoardingViewReactor()
        
        return OnBoardingViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeAuthViewController(coordinator: AuthCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = AuthViewReactor()
        
        return AuthViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeHomeViewController(coordinator: HomeCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = HomeViewReactor()
        
        return HomeViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeRoutineListViewController(coordinator: RoutineListCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = RoutineListViewReactor()
        
        return RoutineListViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeCalendarViewController(coordinator: CalendarCoordinator) -> UIViewController {
//        let repository
//        let useCase
//        let reactor = CalendarViewReactor()
        
        return CalendarViewController()
    }
    
    func makeMyPageViewController(coordinator: MyPageCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = MyPageViewReactor()
        
        return MyPageViewController(reactor: reactor, coordinator: coordinator)
    }
}
