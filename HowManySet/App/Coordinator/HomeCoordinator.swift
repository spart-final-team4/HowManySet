//
//  MainViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
//    func startFromEditRoutine() -> (UIViewController, HomeViewReactor)
    func pushRoutineListView() 
    func presentEditAndMemoView()
    func presentEditExerciseView(
        routineName: String,
        workoutStateForEdit: WorkoutStateForEdit,
        onDismiss: (() -> Void)?
    )
    func presentEditRoutineView(with routine: WorkoutRoutine)
    func pushRoutineCompleteView(with workoutSummary: WorkoutSummary)
    func popUpEndWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary, onCancel: @escaping () -> Void?)
    func popUpCompletedWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary, onCancel: @escaping () -> Void?)
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
    
    private var isWorkoutStarted: Bool = false
    private var currentRoutine: WorkoutRoutine?
    
    weak var routineListCoordinator: RoutineListCoordinator?
        
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
        if isWorkoutStarted, let routine = currentRoutine {
            showHomeView(with: routine)
        } else {
            showHomeStartView()
        }
    } 
    
    /// 운동 시작 후 운동 중 화면을 보여주는 메서드
    private func showHomeView(with routine: WorkoutRoutine) {
        let (homeVC, reactor) = container.makeHomeViewControllerWithWorkoutStarted(coordinator: self, routine: routine)
        homeViewReactor = reactor
        reactor.action.onNext(.routineSelected)
        homeVC.navigationItem.hidesBackButton = true
        navigationController.tabBarController?.selectedIndex = 0
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    /// 운동 시작전 HomeStartView를 보여주는 메서드
    private func showHomeStartView() {
        let homeStartVC = container.makeHomeStartViewController(coordinator: self)
        navigationController.setViewControllers([homeStartVC], animated: false)
    }

    /// 운동 시작 후 (운동 중 true, routine값 설정, 운동 중 화면 처리)
    func startWorkout(with routine: WorkoutRoutine) {
        isWorkoutStarted = true
        currentRoutine = routine
        showHomeView(with: routine)
    }

    /// 운동 시작 전 (운동 중 false, routine nil, 운동 시작 전 화면 처리)
    func beforeWorkout() {
        isWorkoutStarted = false
        currentRoutine = nil
        showHomeStartView()
    }
    
    /// 시작화면에서 운동 시작하기 버튼 클릭 시 루틴 리스트 push
    func pushRoutineListView() {
        if let routineListCoordinator {
            routineListCoordinator.startModal()
        }
    }
    
    /// 운동 종목 뷰 메뉴 버튼 클릭 시 옵션 bottom sheet present
    func presentEditAndMemoView() {
        guard let homeViewReactor else { return }
        let editAndMemoVC = EditAndMemoViewController(reactor: homeViewReactor, coordinator: self)
        
        if let sheet = editAndMemoVC.sheetPresentationController {
            sheet.detents = [.custom{ context in
                0.5 * context.maximumDetentValue
            }]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(editAndMemoVC, animated: true)
    }
    
    /// 운동 카드 가운데 회색 버튼 클릭시 해당 운동 종목 편집 화면 present
    func presentEditExerciseView(
        routineName: String,
        workoutStateForEdit: WorkoutStateForEdit,
        onDismiss: (() -> Void)? = nil
    ) {
        let routineRepository = RoutineRepositoryImpl()
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        let reactor = EditExcerciseViewReactor(
            routineName: routineName,
            saveRoutineUseCase: saveRoutineUseCase,
            workoutStateForEdit: workoutStateForEdit,
            caller: ViewCaller.fromHome
        )
        let editExerciseVC = EditExcerciseViewController(reactor: reactor)
        
        editExerciseVC.onDismiss = onDismiss
        
        if let sheet = editExerciseVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(editExerciseVC, animated: true)
    }
        
    /// EditAndMemo 모달에서 루틴 수정 버튼 클릭 시 루틴 편집 화면 present
    func presentEditRoutineView(with routine: WorkoutRoutine) {
        let editRoutineCoordinator = EditRoutineCoordinator(navigationController: navigationController, container: container, routine: routine, homeCoordinator: self)
        editRoutineCoordinator.startModal()
    }
    
    /// 운동 완료 화면으로 이동
    func pushRoutineCompleteView(with workoutSummary: WorkoutSummary) {
        guard let homeViewReactor else { return }
        let routineCompleteCoordinator = RoutineCompleteCoordinator(navigationController: navigationController, container: container, workoutSummary: workoutSummary, homeViewReactor: homeViewReactor, homeCoordinator: self)
        routineCompleteCoordinator.start()
    }
    
    /// 유저가 직접 종료 버튼을 눌러서 종료 시
    func popUpEndWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary, onCancel: @escaping () -> Void?) {
        
        let endWorkoutVC = ExercisePopupViewController(
            title: "운동을 종료할까요?",
            content: "지금까지의 기록만 저장됩니다.",
            leftButtonText: "운동종료",
            rightButtonText: "계속하기",
            nextAction: { [weak self] in
                guard let self else { return }
                
                /// 종료 버튼 누를 시에 해당 클로저(reactor.action) 즉시 실행
                let workoutSummary = onConfirm()
                
                // HomeVC 초기화
                self.navigationController.popToRootViewController(animated: false)
                let homeStartVC = self.container.makeHomeStartViewController(coordinator: self)
                self.navigationController.setViewControllers([homeStartVC], animated: false)
                
                self.pushRoutineCompleteView(with: workoutSummary)
            }, cancelAction: onCancel)
        
        navigationController.present(endWorkoutVC, animated: true)
    }
    
    /// 유저가 루틴을 모두 완료했을 시
    func popUpCompletedWorkoutAlert(onConfirm: @escaping () -> WorkoutSummary, onCancel: @escaping () -> Void?) {
        
        let endWorkoutVC = ExercisePopupViewController(
            title: "오늘의 루틴 완료!",
            content: "수고하셨어요! 운동 기록을 저장할게요.",
            leftButtonText: "결과보기",
            rightButtonText: "계속하기",
            nextAction: { [weak self] in
                guard let self else { return }
                
                let workoutSummary = onConfirm()
                
                self.navigationController.popToRootViewController(animated: false)
                let homeStartVC = self.container.makeHomeStartViewController(coordinator: self)
                self.navigationController.setViewControllers([homeStartVC], animated: false)
                
                self.pushRoutineCompleteView(with: workoutSummary)
            }, cancelAction: onCancel)
        
        navigationController.present(endWorkoutVC, animated: true)
    }
}
