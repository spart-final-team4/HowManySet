//
//  CompleteRoutineCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit

protocol RoutineCompleteCoordinatorProtocol: Coordinator {
    func navigateToHomeView()
}

/// 루틴 완료 흐름 담당 coordinator를 반환
final class RoutineCompleteCoordinator: RoutineCompleteCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    private let workoutSummary: WorkoutSummary
    private let homeViewReactor: HomeViewReactor

    init(navigationController: UINavigationController, container: DIContainer, workoutSummary: WorkoutSummary, homeViewReactor: HomeViewReactor) {
        self.navigationController = navigationController
        self.container = container
        self.workoutSummary = workoutSummary
        self.homeViewReactor = homeViewReactor
    }
    
    func start() {
        let routineCompleteVC = container.makeRoutineCompleteViewController(coordinator: self, workoutSummary: workoutSummary, homeViewReactor: homeViewReactor)

        navigationController.pushViewController(routineCompleteVC, animated: true)
    }
    
    /// 메인 홈 화면으로 이동
    /// 초기화 하고 push or just pop?
    func navigateToHomeView() {
        // TODO: 운동 상태 초기화 코드
        
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, container: container)
        let (homeVC, _) = container.makeHomeViewController(coordinator: homeCoordinator)
        
        // navigation 스택을 홈으로 초기화
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
}
