//
//  CalendarViewCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

protocol CalendarCoordinatorProtocol: Coordinator {
    
}

final class CalendarCoordinator: CalendarCoordinatorProtocol {
    
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let calendarVC = CalendarViewController()
        
        navigationController.pushViewController(calendarVC, animated: true)
    }
}
