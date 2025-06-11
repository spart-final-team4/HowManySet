//
//  MyPageViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import ReactorKit
import SnapKit
import RxCocoa
import RxSwift

final class MyPageViewController: UIViewController, View {
    
    typealias Reactor = MyPageViewReactor
    
    var disposeBag = DisposeBag()
    
    private weak var coordinator: MyPageCoordinatorProtocol?
    private let mypageView = MyPageView()
    
    init(reactor: MyPageViewReactor, coordinator: MyPageCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func bind(reactor: MyPageViewReactor) {
        mypageView.collectionView.rx.itemSelected
            .map { Reactor.Action.cellTapped(MyPageCellType(indexPath: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.presentTarget }
            .compactMap{ $0 }
            .subscribe(with: self) { owner, cell in
                owner.handleCellTapped(cell)
            }.disposed(by: disposeBag)
    }

    private func handleCellTapped(_ cellType: MyPageCellType) {
        switch cellType {
        case .setNotification:
            coordinator?.pushAlarmSettingView()
        case .setLanguage:
            coordinator?.presentLanguageSettingAlert()
        case .showVersion:
            coordinator?.showVersionInfo()
        case .appReview:
            coordinator?.openAppStoreReviewPage()
        case .reportProblem:
            coordinator?.presentReportProblemView()
        case .privacyPolicy:
            coordinator?.presentPrivacyPolicyView()
        case .logout:
            coordinator?.alertLogout()
        case .deleteAccount:
            coordinator?.pushAccountWithdrawalView()
        case .none:
            print("none case tapped")
        }
    }
}

private extension MyPageViewController {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        view.addSubviews(mypageView)
    }
    
    func setConstraints() {
        mypageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
