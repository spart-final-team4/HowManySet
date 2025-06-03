//
//  MyPageCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol MyPageCoordinatorProtocol: Coordinator {
    
}

final class MyPageCoordinator: MyPageCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let myPageVC = container.makeMyPageViewController(coordinator: self)
        
        navigationController.pushViewController(myPageVC, animated: true)
    }
}
