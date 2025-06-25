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

    /// 온보딩 플로우 종료 및 화면 전환을 담당하는 Coordinator. 약한 참조로 메모리 누수 방지.
    private weak var coordinator: OnBoardingCoordinatorProtocol?
    
    /// ReactorKit 기반 상태 관리 객체. 온보딩 화면의 상태와 액션을 처리.
    private var reactor: OnBoardingViewReactor
    
    /// 온보딩 안내 페이지(타이틀, 이미지, 인디케이터, 버튼 등)를 포함하는 뷰.
    private let onboardingView = OnboardingView()
    
    /// 닉네임 입력 및 "다음" 버튼을 포함하는 뷰.
    private let nicknameInputView = NicknameInputView()
    
    /// RxSwift DisposeBag. 바인딩 해제 및 메모리 관리에 사용.
    private var disposeBag = DisposeBag()
    
    /// OnBoardingViewController 생성자. Reactor와 Coordinator를 주입받아 초기화.
    /// - Parameters:
    ///   - reactor: 온보딩 상태 및 액션 관리를 위한 ReactorKit 객체
    ///   - coordinator: 온보딩 플로우 종료 시 호출할 Coordinator
    init(reactor: OnBoardingViewReactor, coordinator: OnBoardingCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    /// 뷰 로드 후 UI 세팅 및 닉네임 유효성 바인딩.
    /// 온보딩/닉네임 입력 뷰의 초기 표시 상태를 설정.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindNicknameValidation()
        onboardingView.isHidden = true
        nicknameInputView.isHidden = false
        
        bindUIEvents()
        setupKeyboardObserver()
    }
}

private extension OnBoardingViewController {
    /// 전체 UI Appearance, 계층, 제약조건, 액션, 델리게이트 설정을 일괄 처리.
    func setupUI() {
        setAppearance()
        setActions()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경색 및 온보딩 페이지 인디케이터의 페이지 수 등 Appearance 관련 설정.
    func setAppearance() {
        view.backgroundColor = .background
        navigationController?.setNavigationBarHidden(true, animated: false)
        onboardingView.pageIndicator.numberOfPages = onboardingPages.count
    }
    
    /// 각 버튼의 액션(Target) 연결. 닉네임 "다음", 온보딩 "다음/시작하기", 닫기(X) 버튼 등.
    func setActions() {
        nicknameInputView.nextButton.addTarget(self, action: #selector(nicknameInputViewNextButtonAction), for: .touchUpInside)
        onboardingView.nextButton.addTarget(self, action: #selector(onboardingViewNextButtonAction), for: .touchUpInside)
        onboardingView.closeButton.addTarget(self, action: #selector(onboardingViewCloseButtonAction), for: .touchUpInside)
    }
    
    /// 닉네임 입력 뷰와 온보딩 뷰를 뷰 계층에 추가.
    func setViewHierarchy() {
        view.addSubviews(nicknameInputView, onboardingView)
    }
    
    /// SnapKit을 활용한 온보딩/닉네임 입력 뷰의 오토레이아웃 제약조건 설정.
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
    /// 닉네임 입력 "다음" 버튼 클릭 시 온보딩 페이지로 전환. 첫 페이지로 초기화.
    @objc func nicknameInputViewNextButtonAction() {
        guard let nickname = nicknameInputView.nicknameTextField.text,
              !nickname.isEmpty else {
            return
        }
        
        // 닉네임 설정 완료 처리
        coordinator?.completeNicknameSetting(nickname: nickname)
        
        // 온보딩 화면으로 전환
        nicknameInputView.isHidden = true
        onboardingView.isHidden = false
        currentPageIndex = 0
        
        dismissKeyboard()
    }
    
    /// 닉네임 유효성에 따라 "다음" 버튼 활성화/비활성화 및 스타일 변경.
    /// - Parameter isEnabled: 버튼 활성화 여부
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
    /// 온보딩 "다음"/"시작하기" 버튼 클릭 시 다음 페이지로 이동하거나, 마지막 페이지면 온보딩 완료 처리.
    @objc func onboardingViewNextButtonAction() {
        goToNextPage()
    }
    
    /// 온보딩 닫기(X) 버튼 클릭 시 온보딩을 건너뛰고 바로 완료 처리.
    @objc func onboardingViewCloseButtonAction() {
        // 온보딩 건너뛰었음을 별도로 저장 (향후 재안내 등에 활용 가능)
        UserDefaults.standard.set(true, forKey: "hasSkippedOnboarding")
        
        // Coordinator를 통해 온보딩 완료 처리
        coordinator?.completeOnBoarding()
    }
}

// MARK: - 닉네임 입력 유효성 바인딩
private extension OnBoardingViewController {
    /// Rx 바인딩을 통해 닉네임 입력값이 변경될 때마다 유효성 검사 및 버튼 상태 업데이트.
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
    
    /// 닉네임 유효성 검사(한글/영문 2~8자).
    /// - Parameter nickname: 입력된 닉네임 문자열
    /// - Returns: 유효하면 true, 아니면 false
    func isValidNickname(_ nickname: String) -> Bool {
        let regex = "^[가-힣a-zA-Z]{2,8}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: nickname)
    }
}

// MARK: - 온보딩 페이지 관리
private extension OnBoardingViewController {
    /// 온보딩 각 페이지의 데이터(타이틀, 서브타이틀, 이미지명) 정의.
    struct OnboardingPageData {
        let title: String
        let subtitle: String
        let imageName: String
    }

    /// 온보딩 페이지 데이터 배열. 페이지 순서대로 정의.
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

    /// 현재 온보딩 페이지 인덱스. 변경 시 UI 업데이트.
    var currentPageIndex: Int {
        get { onboardingView.pageIndicator.currentPage }
        set {
            onboardingView.pageIndicator.currentPage = newValue
            updatePageContent(index: newValue)
        }
    }

    /// 온보딩 페이지 UI를 현재 인덱스에 맞게 업데이트.
    /// - Parameter index: 표시할 페이지 인덱스
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

    /// 다음 온보딩 페이지로 이동하거나, 마지막 페이지면 온보딩 완료 처리(coordinator 호출).
    func goToNextPage() {
        let nextIndex = currentPageIndex + 1
        if nextIndex < onboardingPages.count {
            currentPageIndex = nextIndex
        } else {
            print("goToNextPage() - else")
            coordinator?.completeOnBoarding()
        }
    }
}

private extension OnBoardingViewController {
    func setupKeyboardObserver() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// 키보드가 나타날 때 버튼 위로 이동
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        let adjustedKeyboardHeight = keyboardHeight - safeAreaBottom
        
        nicknameInputView.adjustButtonForKeyboard(keyboardHeight: adjustedKeyboardHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    /// 키보드가 사라질 때 버튼을 원래 위치로 복원
    @objc func keyboardWillHide(notification: NSNotification) {
        nicknameInputView.adjustButtonForKeyboard(keyboardHeight: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func bindUIEvents() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
