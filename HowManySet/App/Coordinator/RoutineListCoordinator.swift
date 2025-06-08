//
//  RoutineListCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol RoutineListCoordinatorProtocol: Coordinator {
    
}

/// 루틴 리스트 화면 관련 coordinator
/// 루틴 리스트 화면 진입 및 모달, 편집 화면 호출 담당
final class RoutineListCoordinator: RoutineListCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    /// 루틴 리스트 화면 시작
    /// 탭바에서 루틴 리스트 화면 진입 시 호출
    func start() {
        let routineListVC = container.makeRoutineListViewController(coordinator: self)
        
        navigationController.pushViewController(routineListVC, animated: true)
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    /// 루틴 리스트 화면 모달 시작
    /// 홈 화면에서 버튼 눌러 모달로 루틴 리스트 화면 호출 시
    func startModal() {
        let routineListVC = container.makeRoutineListViewController(coordinator: self)
        
        if let sheet = routineListVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(routineListVC, animated: true)
    }
    
    /// 루틴 편집 화면으로 푸시
    func pushEditRoutineView() {
        let reactor = EditRoutinViewReactor()
        let editRoutineVC = EditRoutineViewController(reactor: reactor)
        
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
    
    /// 운동 편집 화면 모달 표시
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
