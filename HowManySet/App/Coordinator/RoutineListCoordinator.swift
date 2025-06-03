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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let routineListVC = RoutineListViewController(reactor: RoutineListReactor())
        
        navigationController.pushViewController(routineListVC, animated: true)
    }
}
