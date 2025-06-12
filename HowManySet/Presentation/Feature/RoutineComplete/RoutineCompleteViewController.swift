//
//  CompleteViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class RoutineCompleteViewController: UIViewController, View {
    
    // MARK: - Properties
    private weak var coordinator: RoutineCompleteCoordinatorProtocol?
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    
    // MARK: - Initializer
    init(reactor: RoutineCompleteViewReactor, coordinator: RoutineCompleteCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - UI Methods
private extension RoutineCompleteViewController {
    
    func setupUI() {
        
    }
    
    func setViewHiearchy() {
        
    }
    
    func setConstraints() {
        
    }
}

// MARK: - Reactor Binding
extension RoutineCompleteViewController {
    
    func bind(reactor: RoutineCompleteViewReactor) {
        
    }
}
