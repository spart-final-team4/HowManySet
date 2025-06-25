//
//  HomeStartViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/25/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class HomeStartViewController: UIViewController {    
    
    // MARK: - Properties
    private weak var coordinator: HomeStartCoordinatorProtocol?
    
    private var disposeBag = DisposeBag()

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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUIEvents()
    }
    
}
    
// MARK: - UI Methods
private extension HomeStartViewController {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        view.addSubviews(
            titleLabel,
            routineStartCardView
        )
    }
    
    func setConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        routineStartCardView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }

    }
}

// MARK: - UI Events
private extension HomeStartViewController {
    
    func bindUIEvents() {
        
        routineStartCardView.todayDateLabel.text = Date().toDateLabel()
        
        routineStartCardView.routineSelectButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                    self.routineStartCardView.routineSelectButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                        self.routineStartCardView.routineSelectButton.transform = .identity
                    }, completion: { _ in
                        self.coordinator?.pushRoutineListView()
                    })
                })
            })
            .disposed(by: disposeBag)
    }
}
