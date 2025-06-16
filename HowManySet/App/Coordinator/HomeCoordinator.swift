//
//  MainViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
    func presentWorkoutOptionView()
    func presentEditRoutineView()
    func pushRoutineCompleteView()
    func popUpEndWorkoutAlert() -> Bool
    func popUpCompletedWorkoutAlert() -> Bool
}

/// 홈 흐름 담당 coordinator
/// 홈 화면 진입 및 관련 화면 present/push 처리
final class HomeCoordinator: HomeCoordinatorProtocol {
    
    /// 홈 흐름 navigation controller
    private let navigationController: UINavigationController
    
    /// DI 컨테이너
    private let container: DIContainer

    /// coordinator 생성자
    /// - Parameters:
    ///   - navigationController: 홈 흐름용 navigation
    ///   - container: DI 컨테이너
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 홈 뷰 시작
    func start() {
        let homeVC = container.makeHomeViewController(coordinator: self)
        navigationController.pushViewController(homeVC, animated: true)
    }

    /// 빈 화면에서 버튼 클릭 시 루틴 편집 창 present
    func presentRoutineListView() {
        let routineListCoordinator = RoutineListCoordinator(navigationController: navigationController, container: container)
        routineListCoordinator.startModal()
    }

    /// 운동 종목 뷰 메뉴 버튼 클릭 시 옵션 bottom sheet present
    func presentWorkoutOptionView() {
        let workoutOptionVC = WorkoutOptionViewController(coordinator: self)
        
        if let sheet = workoutOptionVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
                
        navigationController.present(workoutOptionVC, animated: true)
    }

    /// 옵션 bottom sheet에서 루틴 수정 버튼 클릭 시 루틴 편집 화면 push
    func presentEditRoutineView() {
        let reactor = EditRoutinViewReactor()
        let editRoutineVC = EditRoutineViewController(reactor: reactor)
        
        if let sheet = editRoutineVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(editRoutineVC, animated: true)
    }

    /// 운동 완료 화면으로 이동
    func pushRoutineCompleteView() {
        let routineCompleteCoordinator = RoutineCompleteCoordinator(navigationController: navigationController, container: container)
        routineCompleteCoordinator.start()
    }
    
    func popUpEndWorkoutAlert() -> Bool {
        
        var workoutEnded = false
        
        let endWorkoutVC = DefaultPopupViewController(
            title: "운동 종료",
            titleTextColor: .error,
            content: "현재 운동을 종료하시겠습니까?",
            okButtonText: "종료",
            okButtonBackgroundColor: .error,
            okAction: { [weak self] in
                guard let self else { return }
                
                // HomeVC 초기화
                self.navigationController.popToRootViewController(animated: false)
                let newHomeVC = self.container.makeHomeViewController(coordinator: self)
                self.navigationController.setViewControllers([newHomeVC], animated: false)
                
                workoutEnded = true
                
                self.pushRoutineCompleteView()
                
            })
        
        navigationController.present(endWorkoutVC, animated: true)
        
        return workoutEnded
    }
    
    
    func popUpCompletedWorkoutAlert() -> Bool {
        
        var workoutEnded = false
        
        let endWorkoutVC = DefaultPopupViewController(
            title: "오늘의 모든 운동 완료!",
            titleTextColor: .error,
            content: "모든 운동을 완료했습니다. 운동을 종료하시겠습니까?",
            okButtonText: "종료",
            okButtonBackgroundColor: .error,
            okAction: { [weak self] in
                guard let self else { return }
                
                // HomeVC 초기화
                self.navigationController.popToRootViewController(animated: false)
                let newHomeVC = self.container.makeHomeViewController(coordinator: self)
                self.navigationController.setViewControllers([newHomeVC], animated: false)
                
                workoutEnded = true
                
                self.pushRoutineCompleteView()
                
            })
        
        navigationController.present(endWorkoutVC, animated: true)
        
        return workoutEnded
    }

}
