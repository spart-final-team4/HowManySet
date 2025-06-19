//
//  RoutineListCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol RoutineListCoordinatorProtocol: Coordinator {
    func presentRoutineNameView()
    func pushEditExcerciseView(routineName: String)
    func pushEditRoutineView(with: WorkoutRoutine)
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
    
    /// 루틴명 편집 화면으로 모달 표시
    func presentRoutineNameView() {
        // RoutineListVC에 있는 saveRoutineUseCase를 재사용하기 위해 인스턴스를 찾고 없으면 리턴
        guard let routineListVC = navigationController.viewControllers.first(
            where: { $0 is RoutineListViewController }
        ) as? RoutineListViewController else { return }
        
        let reactor = RoutineNameReactor()
        let routineNameVC = RoutineNameViewController(reactor: reactor, coordinator: self)

        if let sheet = routineNameVC.sheetPresentationController {
            let fixedHeight: CGFloat = UIScreen.main.bounds.height * 0.27

            sheet.detents = [.custom(resolver: { _ in
                fixedHeight
            })]
            sheet.prefersGrabberVisible = true

            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true // iPhone에서 전체화면 방지
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        navigationController.present(routineNameVC, animated: true)
    }
    
    /// 운동 편집 화면 전체 화면으로 push
    func pushEditExcerciseView(routineName: String) {
        let routineRepository = RoutineRepositoryImpl()
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        
        let reactor = EditExcerciseViewReactor(routineName: routineName, saveRoutineUseCase: saveRoutineUseCase)
        let editExcerciseVC = EditExcerciseViewController(reactor: reactor)
        
        navigationController.pushViewController(editExcerciseVC, animated: true)
    }

    /// 루틴 리스트 화면에서 셀 클릭 시 루틴 내 운동 리스트 화면으로 push
    func pushEditRoutineView(with routine: WorkoutRoutine) {
        let routineRepository = RoutineRepositoryImpl()
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        let deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository)
        let reactor = EditRoutineViewReactor(with: routine,
                                             saveRoutineUseCase: saveRoutineUseCase,
                                             deleteRoutineUseCase: deleteRoutineUseCase)
        let editRoutineVC = EditRoutineViewController(reactor: reactor)
        
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
}
