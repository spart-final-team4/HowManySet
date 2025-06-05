//
//  MainViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
    
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let homeVC = container.makeHomeViewController(coordinator: self)
        
        navigationController.pushViewController(homeVC, animated: true)
    }
    
    /// 초기 빈 화면에서 +버튼 클릭시 present
    func presentRoutineListView() {
        let routineListCoordinator = RoutineListCoordinator(navigationController: navigationController, container: container)
        
        routineListCoordinator.startModal()
    }
    
    /// 운동 종목 뷰의 메뉴 버튼 클릭시 present
    func presentWorkoutOptionView() {
        let reactor = WorkoutOptionViewReactor()
        let workoutOptionVC = WorkoutOptionViewController(reactor: reactor)
        
        // medium 크기의 bottomSheet로 설정
        if let sheet = workoutOptionVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(workoutOptionVC, animated: true)
    }
    
    /// presentWorkoutOptionView에서 루틴 수정 버튼 클릭 시 push or present
    func pushEditRoutineView() {
        let reactor = EditRoutinViewReactor()
        let editRoutineVC = EditRoutineViewController(reactor: reactor)
        
        // present로 할지 push로 할지 결정 필요
//        if let sheet = editRoutineVC.sheetPresentationController {
//            sheet.detents = [.large()]
//            sheet.prefersGrabberVisible = true
//        }
//        
//        navigationController.present(editRoutineVC, animated: true)
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
    
    /// 운동 완료 페이지로 이동
    func pushRoutineCompleteView() {        
        let routineCompleteCoordinator = RoutineCompleteCoordinator(navigationController: navigationController, container: container)
        
        routineCompleteCoordinator.start()
    }
}
