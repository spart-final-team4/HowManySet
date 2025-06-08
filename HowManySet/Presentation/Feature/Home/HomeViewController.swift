//
//  MainViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import SnapKit
import Then

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private weak var coordinator: HomeCoordinatorProtocol?

    private let reactor: HomeViewReactor
    
    // MARK: - UI Components
    private lazy var routineStartView = HomeRoutineStartView().then {
        $0.layer.cornerRadius = 20
    }
    
    // MARK: - Initializer
    init(reactor: HomeViewReactor, coordinator: HomeCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setupUI()
    }
}

// MARK: - UI Methods
private extension HomeViewController {
    func setupUI() {
        navigationItem.title = "홈"
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        view.addSubview(routineStartView)
    }
    
    func setConstraints() {
        routineStartView.snp.makeConstraints {
            // 시스템 inset = 16, navigationTitle과 맞추기 위함.
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.height.equalToSuperview().multipliedBy(0.47)
        }
    }
}

