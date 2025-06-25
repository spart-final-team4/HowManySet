//
//  HomeStartCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/25/25.
//

import UIKit

protocol HomeStartCoordinatorProtocol: Coordinator {
    func pushRoutineListView()
}

/// 홈 시작화면 흐름 담당 coordinator
/// 홈 시작화면 진입 및 관련 화면 present/push 처리
final class HomeStartCoordinator: HomeStartCoordinatorProtocol {
    
    /// 홈 시작 흐름 navigation controller
    private let navigationController: UINavigationController
    
    /// DI 컨테이너
    private let container: DIContainer
        
    /// coordinator 생성자
    /// - Parameters:
    ///   - navigationController: 홈 시작 흐름용 navigation
    ///   - container: DI 컨테이너
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    /// 홈 시작뷰 시작
    func start() {
        let homeStartVC = container.makeHomeStartViewController(coordinator: self)
        navigationController.pushViewController(homeStartVC, animated: true)
    }
    
    /// 빈 화면에서 +버튼 클릭 시 루틴 리스트 push
    func pushRoutineListView() {
        let routineListCoordinator = RoutineListCoordinator(navigationController: navigationController, container: container)
        routineListCoordinator.start()
    }
}
