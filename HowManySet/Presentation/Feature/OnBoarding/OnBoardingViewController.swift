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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // 🟢 익명 사용자는 닉네임 입력 스킵하고 바로 온보딩으로
        let provider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        if provider == "anonymous" {
            print("🟢 익명 사용자 - 닉네임 입력 스킵하고 온보딩 시작")
            // 온보딩 화면으로 바로 이동하는 로직 추가
            startWithOnboardingOnly()
        } else {
            setupOnboardingPages()
        }
        
        bind(reactor: reactor)
    }
    
    func setNicknameOnlyMode() {
        isNicknameOnlyMode = true
    }
    
    /// 온보딩만 시작하는 메서드 (닉네임 입력 건너뛰기)
    func startWithOnboardingOnly() {
        setupOnboardingPages()
        nicknameInputView.isHidden = true
        onboardingView.isHidden = false
        reactor?.action.onNext(.setNicknameCompleted)
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubviews(onboardingView, nicknameInputView)
        onboardingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        nicknameInputView.snp.makeConstraints { $0.edges.equalToSuperview() }

        onboardingView.isHidden = true
        nicknameInputView.isHidden = false

        onboardingView.scrollView.delegate = self
        
        setupKeyboardObserver()
        bindUIEvents()
    }
    
    private func setupOnboardingPages() {
        let pageViews = OnBoardingViewReactor.onboardingPages.map { pageData in
            OnboardingPageControlView(pageData: pageData)
        }
        onboardingView.addPageContentViews(pageViews)
        onboardingView.pageIndicator.numberOfPages = pageViews.count
    }

    func bind(reactor: OnBoardingViewReactor) {
        // 닉네임 관련 바인딩
        nicknameInputView.nicknameTextField.rx.text.orEmpty
            .map(OnBoardingViewReactor.Action.inputNickname)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        nicknameInputView.nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.nicknameInputView.nextButton.animateTap {
                    reactor.action.onNext(.completeNicknameSetting)
                }
            })
            .disposed(by: disposeBag)

        // 온보딩 관련 바인딩
        onboardingView.closeButton.rx.tap
            .map { _ in OnBoardingViewReactor.Action.skipOnboarding }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        onboardingView.nextButton.rx.tap
            .map { _ in OnBoardingViewReactor.Action.moveToNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 상태(State) 바인딩
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
            
        reactor.state
            .filter { $0.isNicknameComplete && !$0.isOnboardingComplete }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self = self else { return }
                
                if self.isNicknameOnlyMode {
                    self.reactor?.action.onNext(.skipOnboarding)
                } else {
                    self.nicknameInputView.isHidden = true
                    self.onboardingView.isHidden = false
                    self.dismissKeyboard()
                    let xOffset = 0.0
                    self.onboardingView.scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
                    self.onboardingView.pageIndicator.currentPage = 0
                }
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isOnboardingComplete }
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.onboardingView.nextButton.isEnabled = false
                self?.onboardingView.closeButton.isEnabled = false
            }
            .disposed(by: disposeBag)

        reactor.state
            .filter { !$0.isOnboardingComplete }
            .map { $0.currentPageIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] index in
                guard let self = self else { return }
                
                let pageWidth = self.onboardingView.scrollView.frame.width
                guard pageWidth > 0 else { return }
                let xOffset = pageWidth * CGFloat(index)
                self.onboardingView.scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
                
                self.onboardingView.pageIndicator.currentPage = index
                
                let isLast = index == OnBoardingViewReactor.onboardingPages.count - 1
                self.onboardingView.nextButton.setTitle(isLast ? String(localized: "시작하기") : String(localized: "다음"), for: .normal)
            }
            .disposed(by: disposeBag)
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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

// MARK: - UIScrollViewDelegate
extension OnBoardingViewController: UIScrollViewDelegate {
    
    /// 스크롤이 멈췄을 때 현재 페이지를 계산하여 Reactor에 전달합니다.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        guard pageWidth > 0 else { return }
        
        let currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
        
        // Reactor에 페이지가 스와이프로 변경되었음을 알립니다.
        reactor.action.onNext(.pageSwiped(to: currentPage))
    }
}
