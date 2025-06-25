//
//  EditRoutineCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/25/25.
//

import UIKit

protocol EditRoutineCoordinatorProtocol: Coordinator {
    func navigateToHomeViewWithWorkoutStarted()
}


final class EditRoutineCoordinator: EditRoutineCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    private let routine: WorkoutRoutine

    init(navigationController: UINavigationController, container: DIContainer, routine: WorkoutRoutine) {
        self.navigationController = navigationController
        self.container = container
        self.routine = routine
    }
    
    func start() {
        let editRoutineVC = container.makeEditRoutineViewController(coordinator: self, with: routine)
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
    
    /// 메인 홈 화면 운동중 상태로 이동
    func navigateToHomeViewWithWorkoutStarted() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, container: container)
        let (homeVC, homeViewReactor) = container.makeHomeViewController(coordinator: homeCoordinator)
        
        // navigation 스택을 홈으로 초기화
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
}

