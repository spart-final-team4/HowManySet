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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let myPageVC = MyPageViewController(reactor: MyPageReactor())
        
        navigationController.pushViewController(myPageVC, animated: true)
    }
}
