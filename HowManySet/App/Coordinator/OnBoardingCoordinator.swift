//
//  OnBoardingCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit
import FirebaseAuth
import RxSwift

protocol OnBoardingCoordinatorProtocol: Coordinator {
    func completeOnBoarding()
    func completeNicknameSetting(nickname: String)
}

/// 온보딩 흐름 담당 coordinator (닉네임 입력 + 온보딩)
/// - Clean Architecture 원칙에 따라 Repository를 통해서만 사용자 정보 접근
final class OnBoardingCoordinator: OnBoardingCoordinatorProtocol {
    
    /// 온보딩 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    
    /// 온보딩 흐름 navigation controller
    let navigationController: UINavigationController
    
    /// DI 컨테이너
    private let container: DIContainer
    
    /// RxSwift DisposeBag
    private let disposeBag = DisposeBag()
    
    private let firebaseAuthService = FirebaseAuthService()
    private lazy var authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
    private lazy var authUseCase = AuthUseCase(repository: authRepository)
    
    /// 완료 처리 중 플래그 (중복 호출 방지)
    private var isCompleting = false

    /// 생성자 - 의존성 주입 및 윈도우 연결
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 온보딩 흐름 시작
    func start() {
        let onboardingVC = container.makeOnBoardingViewController(coordinator: self)
        navigationController.pushViewController(onboardingVC, animated: false)
    }
    
    /// 닉네임만 입력하는 시작점
    func startWithNicknameOnly() {
        print("🔍 OnBoardingCoordinator: startWithNicknameOnly 호출")
        let onboardingVC = container.makeOnBoardingViewController(coordinator: self)
        
        navigationController.pushViewController(onboardingVC, animated: false)
        print("🔍 OnBoardingViewController 푸시 완료")
    }


    /// 온보딩만 하는 시작점
    func startWithOnboardingOnly() {
        let onboardingVC = container.makeOnBoardingViewController(coordinator: self)
        // 온보딩만 시작하도록 설정
        if let vc = onboardingVC as? OnBoardingViewController {
            vc.startWithOnboardingOnly()
        }
        navigationController.pushViewController(onboardingVC, animated: false)
    }

    
    /// 닉네임 설정 완료 시 호출
    func completeNicknameSetting(nickname: String) {
        authRepository.getCurrentUser()
            .flatMap { [weak self] user -> Observable<Void> in
                guard let self,
                      let user,
                      let uid = user.uid else {  // uid를 안전하게 언래핑
                    return Observable.error(NSError(domain: "NoCurrentUser", code: -1))
                }
                return self.authUseCase.completeNicknameSetting(uid: uid, nickname: nickname)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { _ in
                    print("🟢 닉네임 설정 완료")
                },
                onError: { error in
                    print("🔴 닉네임 설정 실패: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// 온보딩 완료 시 호출
    func completeOnBoarding() {
        guard !isCompleting else { return }
        isCompleting = true
        defer { isCompleting = false }
        
        print("🟢 OnBoardingCoordinator: 온보딩 완료 처리 시작")
        
        authRepository.getCurrentUser()
            .flatMap { [weak self] user -> Observable<Void> in
                guard let self else { return .empty() }
                guard let user,
                      let uid = user.uid else {  // uid를 안전하게 언래핑
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self.finishFlow?()
                    return .empty()
                }
                return self.authUseCase.completeOnboarding(uid: uid)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] _ in
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                },
                onError: { [weak self] error in
                    print("🔴 온보딩 완료 실패: \(error)")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                }
            )
            .disposed(by: disposeBag)
    }
}
