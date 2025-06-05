//
//  RoutineListCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol RoutineListCoordinatorProtocol: Coordinator {
    
}

final class RoutineListCoordinator: RoutineListCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    /// 탭바에서 호출 시
    func start() {
        let routineListVC = container.makeRoutineListViewController(coordinator: self)
        
        navigationController.pushViewController(routineListVC, animated: true)
    }
    
    /// 초기 홈 화면 + 버튼으로 호출 시
    func startModal() {
        let routineListVC = container.makeRoutineListViewController(coordinator: self)
        
        if let sheet = routineListVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(routineListVC, animated: true)
    }
    
    func pushEditRoutineView() {
        let reactor = EditRoutinViewReactor()
        let editRoutineVC = EditRoutineViewController(reactor: reactor)
        
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
    
    func presentEditExcerciseView() {
        let reactor = EditExcerciseViewReactor()
        let editExcerciseVC = EditExcerciseViewController(reactor: reactor)
        
        if let sheet = editExcerciseVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(editExcerciseVC, animated: true)
    }
}
