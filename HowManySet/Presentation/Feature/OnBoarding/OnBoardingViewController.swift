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
import SnapKit

final class OnBoardingViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    var reactor: OnBoardingViewReactor!
    
    private weak var coordinator: OnBoardingCoordinatorProtocol?

    private let onboardingView = OnboardingView()
    private let nicknameInputView = NicknameInputView()
    
    /// 닉네임만 입력하는 모드 설정
    private var isNicknameOnlyMode = false

    init(reactor: OnBoardingViewReactor, coordinator: OnBoardingCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        onboardingView.pageIndicator.numberOfPages = OnBoardingViewReactor.onboardingPages.count
        bind(reactor: reactor)
    }
    
    /// 닉네임만 입력하는 모드 설정 (새로 추가)
    func setNicknameOnlyMode() {
        isNicknameOnlyMode = true
    }
    
    /// 온보딩만 시작하는 메서드 (닉네임 입력 건너뛰기)
    func startWithOnboardingOnly() {
        nicknameInputView.isHidden = true
        onboardingView.isHidden = false
        onboardingView.pageIndicator.currentPage = 0
        updatePageContent(index: 0)
        
        // Reactor에 닉네임 완료 상태 설정
        reactor?.action.onNext(.setNicknameCompleted)
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubviews(onboardingView, nicknameInputView)
        onboardingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        nicknameInputView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 기본적으로 닉네임 입력부터 시작
        onboardingView.isHidden = true
        nicknameInputView.isHidden = false

        setupKeyboardObserver()
        bindUIEvents()
    }

    func bind(reactor: OnBoardingViewReactor) {
        // 닉네임 입력 바인딩
        nicknameInputView.nicknameTextField.rx.text.orEmpty
            .map(OnBoardingViewReactor.Action.inputNickname)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 닉네임 설정 완료 버튼
        nicknameInputView.nextButton.rx.tap
            .map { _ in OnBoardingViewReactor.Action.completeNicknameSetting }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 온보딩 건너뛰기 버튼
        onboardingView.closeButton.rx.tap
            .map { _ in OnBoardingViewReactor.Action.skipOnboarding }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 온보딩 다음 버튼
        onboardingView.nextButton.rx.tap
            .map { _ in OnBoardingViewReactor.Action.moveToNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 닉네임 유효성에 따른 버튼 상태 변경
        reactor.state.map { $0.isNicknameValid }
            .distinctUntilChanged()
            .bind(to: nicknameInputView.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isNicknameValid }
            .distinctUntilChanged()
            .bind { [weak self] isValid in
                self?.nicknameInputView.nextButton.backgroundColor = isValid ? .brand : .darkGray
                self?.nicknameInputView.nextButton.setTitleColor(isValid ? .black : .lightGray, for: .normal)
            }
            .disposed(by: disposeBag)

        // 닉네임 완료 시 처리 로직 (수정된 버전)
        reactor.state
            .filter { $0.isNicknameComplete && !$0.isOnboardingComplete }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self = self else { return }
                
                if self.isNicknameOnlyMode {
                    // 닉네임만 모드: 바로 완료 처리
                    self.reactor?.action.onNext(.skipOnboarding)
                } else {
                    // 일반 모드: 온보딩 화면으로 전환
                    self.nicknameInputView.isHidden = true
                    self.onboardingView.isHidden = false
                    self.onboardingView.pageIndicator.currentPage = 0
                    self.updatePageContent(index: 0)
                    self.dismissKeyboard()
                }
            }
            .disposed(by: disposeBag)

        // 온보딩 완료 시 버튼 비활성화
        reactor.state.map { $0.isOnboardingComplete }
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.onboardingView.nextButton.isEnabled = false
                self?.onboardingView.closeButton.isEnabled = false
            }
            .disposed(by: disposeBag)

        // 페이지 인덱스 변경 시 콘텐츠 업데이트
        reactor.state
            .filter { !$0.isOnboardingComplete }
            .map { $0.currentPageIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] index in
                self?.updatePageContent(index: index)
            }
            .disposed(by: disposeBag)
    }

    private func updatePageContent(index: Int) {
        guard OnBoardingViewReactor.onboardingPages.indices.contains(index) else { return }
        let page = OnBoardingViewReactor.onboardingPages[index]

        onboardingView.titleLabel.text = page.title
        onboardingView.subTitleLabel.text = page.subtitle
        onboardingView.centerImageView.image = UIImage(named: page.imageName)
        onboardingView.pageIndicator.currentPage = index

        let isLast = index == OnBoardingViewReactor.onboardingPages.count - 1
        onboardingView.nextButton.setTitle(isLast ? "시작하기" : "다음", for: .normal)
    }

    private func setupKeyboardObserver() {
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

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let height = keyboardFrame.cgRectValue.height
        let safeBottom = view.safeAreaInsets.bottom
        let adjustHeight = height - safeBottom

        nicknameInputView.adjustButtonForKeyboard(keyboardHeight: adjustHeight)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        nicknameInputView.adjustButtonForKeyboard(keyboardHeight: 0)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    private func bindUIEvents() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
