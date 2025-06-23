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
final class OnBoardingCoordinator: OnBoardingCoordinatorProtocol {
    
    /// 온보딩 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    
    /// 온보딩 흐름 navigation controller
    let navigationController: UINavigationController
    
    /// DI 컨테이너
    private let container: DIContainer
    
    /// RxSwift DisposeBag
    private let disposeBag = DisposeBag()

    /// 생성자 - 의존성 주입 및 윈도우 연결
    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    /// 온보딩 흐름 시작
    func start() {
        let onboardingVC = container.makeOnBoardingViewController(coordinator: self)
        navigationController.pushViewController(onboardingVC, animated: true)
    }

    /// 닉네임 설정 완료 시 호출
    func completeNicknameSetting(nickname: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("현재 사용자가 없음")
            return
        }

        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        authUseCase.completeNicknameSetting(uid: currentUser.uid, nickname: nickname)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { _ in
                    print("닉네임 설정 완료")
                },
                onError: { error in
                    print("닉네임 설정 실패: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }

    /// 온보딩 완료 시 호출
    func completeOnBoarding() {
        guard let currentUser = Auth.auth().currentUser else {
            print("현재 사용자가 없음")
            // 로컬 저장만 진행
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            finishFlow?()
            return
        }
        
        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        authUseCase.completeOnboarding(uid: currentUser.uid)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] in
                    print("온보딩 완료")
                    // 로컬 저장도 함께 진행 (백업용)
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                },
                onError: { [weak self] error in
                    print("온보딩 완료 처리 실패: \(error)")
                    // 에러가 발생해도 로컬 저장 후 다음 단계로 진행
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                }
            )
            .disposed(by: disposeBag)
    }
}
