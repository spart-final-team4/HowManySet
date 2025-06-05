//
//  CompleteRoutineCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit

protocol RoutineCompleteCoordinatorProtocol: Coordinator {
    
}

final class RoutineCompleteCoordinator: RoutineCompleteCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let routineCompleteVC = container.makeRoutineCompleteViewController(coordinator: self)
        
        navigationController.pushViewController(routineCompleteVC, animated: true)
    }
    
    /// 메인 홈 화면으로 이동
    /// 초기화 하고 push or just pop?
    func navigateToHomeView() {
        // 운동 상태 초기화 코드
        // workoutStateManager.reset()
        
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, container: container)
        let homeVC = container.makeHomeViewController(coordinator: homeCoordinator)
        
        // navigation 스택을 홈으로 초기화
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
}
