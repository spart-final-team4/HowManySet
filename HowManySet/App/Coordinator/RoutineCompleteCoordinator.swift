//
//  CompleteRoutineCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit

protocol RoutineCompleteCoordinatorProtocol: Coordinator {
    
}

final class RoutineCompleteCoordinator: RoutineCompleteCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let routineCompleteVC = container.makeRoutineCompleteViewController(coordinator: self)
        
        navigationController.pushViewController(routineCompleteVC, animated: true)
    }
    
    func navigateToHomeView() {
        
    }
    
}
