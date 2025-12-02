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
import MessageUI

/// 마이페이지 화면을 담당하는 ViewController
/// - `ReactorKit`을 통해 상태 관리를 하고, `coordinator` 패턴을 통해 화면 전환을 담당함
final class MyPageViewController: UIViewController, View {
    
    /// ReactorKit에서 사용하는 Reactor 타입 정의
    typealias Reactor = MyPageViewReactor
    
    /// RxSwift의 DisposeBag (리소스 해제용)
    var disposeBag = DisposeBag()
    
    /// 화면 전환을 위한 Coordinator (약한 참조)
    private var coordinator: MyPageCoordinatorProtocol?
    
    /// 마이페이지 화면의 UI 뷰
    private let mypageView = MyPageView()
    
    /// 커스텀 이니셜라이저
    /// - Parameters:
    ///   - reactor: MyPageViewReactor 인스턴스
    ///   - coordinator: 화면 전환을 위한 코디네이터
    init(reactor: MyPageViewReactor, coordinator: MyPageCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
        self.reactor = reactor
    }
    
    /// 스토리보드 사용 금지
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 뷰 로드 시 UI 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        mypageView.headerView.usernameLabel.isHidden = true
    }
    
    /// 뷰가 나타날 때마다 사용자 이름 로드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.loadUserName)
    }
    
    /// ReactorKit 바인딩
    func bind(reactor: MyPageViewReactor) {
        
        /// 컬렉션 뷰에서 셀 선택 시 액션 전달
        mypageView.collectionView.rx.itemSelected
            .map { Reactor.Action.cellTapped(MyPageCellType(indexPath: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        /// Reactor의 상태 변화 감지 후 화면 이동 처리
        reactor.state
            .map { $0.presentTarget }
            .compactMap { $0 }
            .subscribe(with: self) { owner, cell in
                owner.handleCellTapped(cell)
            }.disposed(by: disposeBag)
        
        /// 로그아웃/계정삭제 성공 시 인증 화면으로 이동
        reactor.state
            .map { $0.shouldNavigateToAuth }
            .filter { $0 }
            .subscribe(with: self) { owner, _ in
                owner.coordinator?.navigateToAuth()
            }.disposed(by: disposeBag)
        
        /// 에러 처리
        reactor.state
            .compactMap { $0.error }
            .subscribe(with: self) { owner, error in
                print("🔴 MyPage 에러: \(error)")
            }.disposed(by: disposeBag)
        
        /// 사용자 이름 바인딩 (Firestore에서 fetch한 데이터)
        reactor.state
            .map { $0.userName }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] userName in
                guard let self else { return }
                if let userName = userName {
                    // fetch 완료 시 라벨 보이기
                    self.mypageView.headerView.usernameLabel.isHidden = false
                    if userName == "비회원" {
                        // "비회원" 문자열이 들어올 때만 다시 localized 처리
                        self.mypageView.headerView.usernameLabel.text = String(localized: "비회원")
                    } else {
                        self.mypageView.headerView.usernameLabel.text = userName
                    }
                } else {
                    // fetch 전에는 라벨 숨김
                    self.mypageView.headerView.usernameLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        
        mypageView.headerView.membershipButtonTapped
            .map { Reactor.Action.membershipButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.membershipMoved }
            .distinctUntilChanged()
            .filter{ $0 == true }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] state in
                self?.coordinator?.presentMembershipView()
                reactor.action.onNext(.resetMembershipMoved)
            }
            .disposed(by: disposeBag)
        
        
    }

    /// 선택된 셀에 따라 코디네이터로 화면 이동 처리
    private func handleCellTapped(_ cellType: MyPageCellType) {
        switch cellType {
        case .setNotification:
            coordinator?.pushAlarmSettingView()
        case .setLanguage:
            coordinator?.presentLanguageSettingAlert()
        case .showVersion:
            coordinator?.showVersionInfo()
        case .showLicense:
            coordinator?.presentLicenseView()
        case .appReview:
            coordinator?.openAppStoreReviewPage()
        case .reportProblem:
            presentReportProblemView(modelName: coordinator?.modelName ?? "알수없음")
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
    
    func presentReportProblemView(modelName: String) {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            
            let mailBodyString = """
                                \(String(localized: "문제 또는 건의사항을 여기에 작성해주세요."))
                                
                                Device Model : \(modelName)
                                Device OS : \(UIDevice.current.systemVersion)
                                App Version : \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? String(localized: "알 수 없음"))
                                """
            
            vc.setToRecipients(["HowManySet@gmail.com"])
            vc.setSubject(String(localized: "HowManySet문제 제보하기"))
            vc.setMessageBody(mailBodyString, isHTML: true)
            vc.mailComposeDelegate = self
            
            present(vc, animated: true)
        } else {
            print("MFMailComposeViewController.canSendMail() is false")
            let alert = UIAlertController(title: String(localized: "오류"),
                                          message: String(localized: "메일 앱이 설치되어 있지 않습니다.\n앱 설치 후 재시도 해주세요."),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: String(localized: "확인"), style: .default))
            present(alert, animated: true)
        }
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

private extension MyPageViewController {
    
    /// UI 구성 함수
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
    }
    /// 외형 설정 (배경색 등)
    func setAppearance() {
        view.backgroundColor = .background
    }
    /// 뷰 계층 구성
    func setViewHierarchy() {
        view.addSubviews(mypageView)
    }
    
    /// 오토레이아웃 설정 (SnapKit 사용)
    func setConstraints() {
        mypageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
