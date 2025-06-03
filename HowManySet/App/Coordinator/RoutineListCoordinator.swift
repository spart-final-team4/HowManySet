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
    
    func start() {
        let routineListVC = container.makeRoutineListViewController(coordinator: self)
        
        navigationController.pushViewController(routineListVC, animated: true)
    }
}
