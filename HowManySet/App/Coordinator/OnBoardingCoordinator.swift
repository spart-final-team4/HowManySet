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
        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        // Repository를 통해 현재 사용자 정보 가져오기
        authRepository.getCurrentUser()
            .flatMap { user -> Observable<Void> in
                guard let user = user else {
                    return Observable.error(NSError(domain: "NoCurrentUser", code: -1))
                }
                return authUseCase.completeNicknameSetting(uid: user.uid, nickname: nickname)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { (_: Void) in
                    print("🟢 OnBoardingCoordinator: 닉네임 설정 완료")
                },
                onError: { (error: Error) in
                    print("🔴 OnBoardingCoordinator: 닉네임 설정 실패 - \(error)")
                }
            )
            .disposed(by: disposeBag)
    }

    /// 온보딩 완료 시 호출
    func completeOnBoarding() {
        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        // Repository를 통해 현재 사용자 정보 가져오기
        authRepository.getCurrentUser()
            .flatMap { [weak self] user -> Observable<Void> in
                guard let user = user else {
                    // 사용자가 없으면 로컬 저장만 하고 완료
                    print("🟡 OnBoardingCoordinator: 현재 사용자가 없음 - 로컬 저장만 진행")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                    return Observable.empty()
                }
                return authUseCase.completeOnboarding(uid: user.uid)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (_: Void) in
                    print("🟢 OnBoardingCoordinator: 온보딩 완료")
                    // 로컬 저장도 함께 진행 (백업용)
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                },
                onError: { [weak self] (error: Error) in
                    print("🔴 OnBoardingCoordinator: 온보딩 완료 처리 실패 - \(error)")
                    // 에러가 발생해도 로컬 저장 후 다음 단계로 진행
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.finishFlow?()
                }
            )
            .disposed(by: disposeBag)
    }
}
