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
    private let homeCoordinator: HomeCoordinator

    init(navigationController: UINavigationController, container: DIContainer, workoutSummary: WorkoutSummary, homeViewReactor: HomeViewReactor, homeCoordinator: HomeCoordinator) {
        self.navigationController = navigationController
        self.container = container
        self.workoutSummary = workoutSummary
        self.homeViewReactor = homeViewReactor
        self.homeCoordinator = homeCoordinator
    }
    
    func start() {
        let routineCompleteVC = container.makeRoutineCompleteViewController(coordinator: self, workoutSummary: workoutSummary, homeViewReactor: homeViewReactor)

        navigationController.pushViewController(routineCompleteVC, animated: true)
    }
    
    /// 메인 홈 시작화면으로 이동
    func navigateToHomeView() {
        let homeStartVC = container.makeHomeStartViewController(coordinator: homeCoordinator)
        // navigation 스택을 홈으로 초기화
        navigationController.setViewControllers([homeStartVC], animated: false)
    }
}
