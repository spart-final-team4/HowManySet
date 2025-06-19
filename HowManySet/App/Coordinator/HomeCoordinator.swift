//
//  MainViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
    func presentRoutineListView()
    func presentEditAndMemoView()
    func presentEditExerciseView(routineName: String)
    func presentEditRoutineView(with routine: WorkoutRoutine)
    func pushRoutineCompleteView(with workoutSummary: WorkoutSummary)
    func popUpEndWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary)
    func popUpCompletedWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary)
}

/// 홈 흐름 담당 coordinator
/// 홈 화면 진입 및 관련 화면 present/push 처리
final class HomeCoordinator: HomeCoordinatorProtocol {
    
    /// 홈 흐름 navigation controller
    private let navigationController: UINavigationController
    
    /// DI 컨테이너
    private let container: DIContainer
    
    // EditAndMemoView에 동일한 reactor 주입 위해 보관
    private var homeViewReactor: HomeViewReactor?
    
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
        let (homeVC, reactor) = container.makeHomeViewController(coordinator: self)
        navigationController.pushViewController(homeVC, animated: true)
        homeViewReactor = reactor
    }
    
    /// 빈 화면에서 +버튼 클릭 시 루틴 리스트 present
    func presentRoutineListView() {
        let routineListCoordinator = RoutineListCoordinator(navigationController: navigationController, container: container)
        routineListCoordinator.startModal()
    }
    
    /// 운동 종목 뷰 메뉴 버튼 클릭 시 옵션 bottom sheet present
    func presentEditAndMemoView() {
        guard let homeViewReactor else { return }
        let editAndMemoVC = EditAndMemoViewController(reactor: homeViewReactor, coordinator: self)
        
        if let sheet = editAndMemoVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
                
        navigationController.present(editAndMemoVC, animated: true)
    }
    
    /// 운동 카드 가운데 회색 버튼 클릭시 해당 운동 종목 편집 화면 present
    func presentEditExerciseView(routineName: String) {
        let routineRepository = RoutineRepositoryImpl()
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        let reactor = EditExcerciseViewReactor(routineName: routineName, saveRoutineUseCase: saveRoutineUseCase)
        let editExerciseVC = EditExcerciseViewController(reactor: reactor)
        
        if let sheet = editExerciseVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(editExerciseVC, animated: true)
    }
        
    /// EditAndMemo 모달에서 루틴 수정 버튼 클릭 시 루틴 편집 화면 present
    func presentEditRoutineView(with routine: WorkoutRoutine) {
        let routineRepository = RoutineRepositoryImpl()
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        let deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository)
        let reactor = EditRoutineViewReactor(with: routine,
                                             saveRoutineUseCase: saveRoutineUseCase,
                                             deleteRoutineUseCase: deleteRoutineUseCase)
        let editRoutineVC = EditRoutineViewController(reactor: reactor)
        
        if let sheet = editRoutineVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(editRoutineVC, animated: true)
    }
    
    /// 운동 완료 화면으로 이동
    func pushRoutineCompleteView(with workoutSummary: WorkoutSummary) {
        let routineCompleteCoordinator = RoutineCompleteCoordinator(navigationController: navigationController, container: container, workoutSummary: workoutSummary)
        routineCompleteCoordinator.start()
    }
    
    /// 유저가 직접 종료 버튼을 눌러서 종료 시
    func popUpEndWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary) {
        
        let endWorkoutVC = DefaultPopupViewController(
            title: "운동 종료",
            titleTextColor: .error,
            content: "현재 운동을 종료하시겠습니까?",
            okButtonText: "종료",
            okButtonBackgroundColor: .error,
            okAction: { [weak self] in
                guard let self else { return }
                
                /// 종료 버튼 누를 시에 해당 클로저(reactor.action) 즉시 실행
                let workoutSummary = onConfirm()
                
                // HomeVC 초기화
                self.navigationController.popToRootViewController(animated: false)
                let (newHomeVC, _) = self.container.makeHomeViewController(coordinator: self)
                self.navigationController.setViewControllers([newHomeVC], animated: false)
                
                self.pushRoutineCompleteView(with: workoutSummary)
            })
        
        navigationController.present(endWorkoutVC, animated: true)
    }
    
    /// 유저가 루틴을 모두 완료했을 시
    func popUpCompletedWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary) {
        
        let endWorkoutVC = DefaultPopupViewController(
            title: "오늘의 모든 운동 완료!",
            titleTextColor: .error,
            content: "모든 운동을 완료했습니다. 운동을 종료하시겠습니까?",
            okButtonText: "종료",
            okButtonBackgroundColor: .error,
            okAction: { [weak self] in
                guard let self else { return }
                
                let workoutSummary = onConfirm()
                
                self.navigationController.popToRootViewController(animated: false)
                let (newHomeVC, _) = self.container.makeHomeViewController(coordinator: self)
                self.navigationController.setViewControllers([newHomeVC], animated: false)
                
                self.pushRoutineCompleteView(with: workoutSummary)
            })
        
        navigationController.present(endWorkoutVC, animated: true)
    }
    
}
