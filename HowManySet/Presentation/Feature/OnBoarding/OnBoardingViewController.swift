//
//  OnBoardingViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class OnBoardingViewController: UIViewController {
    
    // MARK: - Properties
    
    private weak var coordinator: OnBoardingCoordinatorProtocol?
    
    private var reactor: OnBoardingViewReactor
    
    private let onboardingView = OnboardingView()
    
    private let nicknameInputView = NicknameInputView()
    
    private var disposeBag = DisposeBag()
    
    init(reactor: OnBoardingViewReactor, coordinator: OnBoardingCoordinatorProtocol) {
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
        setupUI()
        
        /// 각 UIView 초기 상태
        onboardingView.isHidden = true
        nicknameInputView.isHidden = false
    }
}

private extension OnBoardingViewController {
    func setupUI() {
        setAppearance()
        setActions()
        setDelegates()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        view.backgroundColor = UIColor(named: "Background")
        
        onboardingView.pageIndicator.numberOfPages = onboardingPages.count
    }
    
    func setActions() {
        nicknameInputView.nextButton.addTarget(self, action: #selector(nicknameInputViewNextButtonAction), for: .touchUpInside)
        onboardingView.nextButton.addTarget(self, action: #selector(onboardingViewNextButtonAction), for: .touchUpInside)
        onboardingView.closeButton.addTarget(self, action: #selector(onboardingViewCloseButtonAction), for: .touchUpInside)
    }
    
    func setDelegates() {
        // TODO: NicknameInputView.textField.delegate = self
    }
    
    func setViewHierarchy() {
        view.addSubviews(nicknameInputView, onboardingView)
    }
    
    func setConstraints() {
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nicknameInputView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

private extension OnBoardingViewController {
    @objc func nicknameInputViewNextButtonAction() {
        nicknameInputView.isHidden = true
        onboardingView.isHidden = false
        
        currentPageIndex = 0
    }
    
    // 버튼 활성화 / 비활성화 로직
    func updateNextButtonState(isEnabled: Bool) {
        nicknameInputView.nextButton.isEnabled = isEnabled
        if isEnabled {
            nicknameInputView.nextButton.backgroundColor = UIColor(named: "brand")
            nicknameInputView.nextButton.setTitleColor(.black, for: .normal)
        } else {
            nicknameInputView.nextButton.backgroundColor = .darkGray
            nicknameInputView.nextButton.setTitleColor(.lightGray, for: .normal)
        }
    }
}

private extension OnBoardingViewController {
    @objc func onboardingViewNextButtonAction() {
        goToNextPage()
    }
    
    @objc func onboardingViewCloseButtonAction() {
        // TODO: 화면 전환 로직
        
        // TODO: 온보딩 화면 종료 상태 저장
    }
}

// MARK: OnboardingView.nicknameTextField
private extension OnBoardingViewController {
    func bindNicknameValidation() {
        nicknameInputView.nicknameTextField.rx.text.orEmpty
            .map { [weak self] text in
                self?.isValidNickname(text) ?? false
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isValid in
                self?.updateNextButtonState(isEnabled: isValid)
            }
            .disposed(by: disposeBag)
    }
    
    func isValidNickname(_ nickname: String) -> Bool {
        let regex = "^[가-힣a-zA-Z]{2,8}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: nickname)
    }
}

// MARK: - OnbordingView PageIndicator
private extension OnBoardingViewController {
    
    struct OnboardingPageData {
        let title: String
        let subtitle: String
        let imageName: String
    }

    var onboardingPages: [OnboardingPageData] {
        return [
            .init(title: "운동 이름부터 세트 수까지", subtitle: " 내 루틴에 맞게 직접 설정해보세요", imageName: "Onboard_SetRoutine"),
            .init(title: "오늘은 어떤 운동할까?", subtitle: "원하는 루틴만 골라 시작하세요", imageName: "Onboard_RoutineList"),
            .init(title: "운동을 완료하면 세트 완료를 클릭하고,", subtitle: "휴식 시간을 미리 설정해보세요", imageName: "Onboard_BreakTime"),
            .init(title: "운동 중 화면에서 무게, 횟수 클릭 시", subtitle: "세트 수, 무게를 변경할 수 있어요", imageName: "Onboard_WorkOutSetting"),
            .init(title: "휴식 타이머를 확인하고,", subtitle: "물 한 잔으로 리프레시해요!", imageName: "Onboard_Water"),
            .init(title: "운동 중엔 앱을 꺼도 OK!", subtitle: "잠금화면에서 운동 완료, 휴식까지 한 번에", imageName: "Onboard_LiveActivity")
        ]
    }

    var currentPageIndex: Int {
        get { onboardingView.pageIndicator.currentPage }
        set {
            onboardingView.pageIndicator.currentPage = newValue
            updatePageContent(index: newValue)
        }
    }

    func updatePageContent(index: Int) {
        guard onboardingPages.indices.contains(index) else { return }
        let page = onboardingPages[index]
        onboardingView.titleLabel.text = page.title
        onboardingView.subTitleLabel.text = page.subtitle
        onboardingView.centerImageView.image = UIImage(named: page.imageName)

        let isLastPage = index == onboardingPages.count - 1
        let buttonTitle = isLastPage ? "시작하기" : "다음"
        onboardingView.nextButton.setTitle(buttonTitle, for: .normal)
    }

    func goToNextPage() {
        let nextIndex = currentPageIndex + 1
        if nextIndex < onboardingPages.count {
            currentPageIndex = nextIndex
        } else {
            // TODO: 마지막 페이지 도달 시 다음 화면으로 이동 로직
            
            // TODO: 온보딩 화면 종료 상태 저장
            
        }
    }
}

