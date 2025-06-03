//
//  RoutineListViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import SnapKit

final class RoutineListViewController: UIViewController {
    
    private weak var coordinator: RoutineListCoordinatorProtocol?

    private let reactor: RoutineListViewReactor
    
    init(reactor: RoutineListViewReactor, coordinator: RoutineListCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
