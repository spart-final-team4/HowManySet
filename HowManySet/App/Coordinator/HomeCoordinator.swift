//
//  MainViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
    
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let homeVC = container.makeHomeViewController(coordinator: self)
        
        navigationController.pushViewController(homeVC, animated: true)
    }
    
    func presentWorkoutOptionView() {
        
    }
    
    func navigateToEditRoutineView() {
        
    }
    
    func navigateToRoutineCompleteView() {
        
    }
}
