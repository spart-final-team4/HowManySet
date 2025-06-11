//
//  WorkoutOptionViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/5/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class WorkoutOptionViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    
    // MARK: - UI Components
    
    
    // MARK: - Initializer
    init(reactor: WorkoutOptionViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

// MARK: - UI Methods
private extension WorkoutOptionViewController {
    
    func setupUI() {
        
    }
    
    func setViewHiearchy() {
        
    }
    
    func setConstraints() {
        
    }
}

// MARK: - Reactor Binding
extension WorkoutOptionViewController {
    
    func bind(reactor: WorkoutOptionViewReactor) {
        
    }
}
