//
//  AppleWatchSyncViewController.swift
//  HowManySet
//
//  Created by 정근호 on 12/8/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class AppleWatchSyncViewController: UIViewController, View {
    
    // MARK: - Localized Texts
    private let navigationTitleText = String(localized: "Apple Watch 연동")
    private let syncRoutineText = String(localized: "루틴 목록 동기화")
    private let tapSyncButtonText = String(localized: "버튼을 눌러 동기화를 시작하세요")
    private let syncingText = String(localized: "동기화 중...")
    
    var disposeBag = DisposeBag()
    
    private lazy var syncButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(syncRoutineText, for: .normal)
        button.setTitleColor(.background, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .brand
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = tapSyncButtonText
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(reactor: AppleWatchSyncViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func bind(reactor: AppleWatchSyncViewReactor) {
        // Action
        syncButton.rx.tap
            .map { Reactor.Action.syncButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: syncButton.rx.isEnabled)
            .disposed(by: disposeBag)
            
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isLoading in
                self?.syncButton.backgroundColor = isLoading ? .systemGray : .brand
                let title = isLoading ? self?.syncingText : self?.syncRoutineText
                self?.syncButton.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)
            
        reactor.state.map { $0.syncStatus }
            .distinctUntilChanged()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .background
        self.title = navigationTitleText

        view.addSubview(syncButton)
        view.addSubview(statusLabel)

        syncButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().inset(40)
            $0.height.equalTo(50)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(syncButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(syncButton)
        }
    }
}
