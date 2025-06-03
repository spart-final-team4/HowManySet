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
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let calendarVC = container.makeCalendarViewController(coordinator: self)
        
        navigationController.pushViewController(calendarVC, animated: true)
    }
}
