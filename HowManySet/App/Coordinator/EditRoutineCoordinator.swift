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
    private let homeNavigationController: UINavigationController

    init(navigationController: UINavigationController, container: DIContainer, routine: WorkoutRoutine, homeNavigationController: UINavigationController) {
        self.navigationController = navigationController
        self.container = container
        self.routine = routine
        self.homeNavigationController = homeNavigationController
    }
    
    func start() {
        let editRoutineVC = container.makeEditRoutineViewController(coordinator: self, with: routine)
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
    
    func startModal() {
        let editRoutineVC = container.makeEditRoutineViewController(coordinator: self, with: routine)
        
        if let sheet = editRoutineVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(editRoutineVC, animated: true)
    }
    
    /// 메인 홈 화면 운동중 상태로 이동
    func navigateToHomeViewWithWorkoutStarted() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, container: container)
        let (homeVC, homeViewReactor) = container.makeHomeViewControllerWithWorkoutStarted(coordinator: homeCoordinator, routine: routine)
        
        // 여기서 바로 routineSelected 실행하여 운동 시작
        homeViewReactor.action.onNext(.routineSelected)
        let home = homeVC as? HomeViewController
        if let home {
            home.bindLiveActivityEvents(reactor: homeViewReactor)
        }
        
        homeVC.navigationItem.hidesBackButton = true
        homeNavigationController.setViewControllers([homeVC], animated: false)
        homeNavigationController.tabBarController?.selectedIndex = 0
    }
    
}

