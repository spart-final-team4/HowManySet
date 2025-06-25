//
//  HomeStartViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/25/25.
//

import UIKit
import SnapKit
import Then

final class HomeStartViewController: UIViewController {    
    
    // MARK: - Properties
    private weak var coordinator: HomeStartCoordinatorProtocol?

    private let homeText = "홈"
    
    // MARK: - UI Components
    private lazy var titleLabel = UILabel().then {
        $0.text = homeText
        $0.font = .systemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var routineStartCardView = HomeRoutineStartCardView().then {
        $0.layer.cornerRadius = 20
    }
        
    // MARK: - Initializer
    init(coordinator: HomeStartCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
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
private extension HomeStartViewController {
    func setupUI() {
        
    }
    
    func setViewHiearchy() {
        
    }
    
    func setConstraints() {
        
    }
}

