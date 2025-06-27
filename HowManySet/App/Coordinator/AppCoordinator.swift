//
//  AppCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import FirebaseAuth
import RxSwift

/// 앱의 전체 흐름을 관리하는 Coordinator
/// - 로그인 여부, 온보딩 여부를 체크하고 적절한 흐름으로 분기
final class AppCoordinator: Coordinator {
    
    /// 앱의 최상위 UIWindow
    var window: UIWindow
    
    /// 현재 자식 Coordinator들을 보관
    private var childCoordinators: [Coordinator] = []
    
    /// 의존성 주입 컨테이너
    private let container: DIContainer
    
    /// RxSwift DisposeBag
    private let disposeBag = DisposeBag()
    
    /// 흐름 완료 시 호출될 클로저
    var finishFlow: (() -> Void)?
    
    /// 생성자 - 의존성 주입 및 윈도우 연결
    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }
    
    /// 앱 시작 시 호출됨 - 출시 수준의 완전한 플로우
    func start() {
        print("🚀 앱 시작 - 사용자 상태 확인")
        
        // Firebase Auth 상태 변화 감지
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                if let user = user {
                    print("🟢 Firebase Auth 사용자 발견: \(user.uid)")
                    self?.checkUserStatusWithFirestore(uid: user.uid)
                } else {
                    print("🔴 Firebase Auth 사용자 없음")
                    self?.checkLocalUserStatus()
                }
            }
        }
    }
    
    /// 로컬 사용자 상태 확인 (Firebase Auth 없을 때)
    private func checkLocalUserStatus() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            print("🟡 로컬 온보딩 완료 상태 - 메인 화면으로 (Firebase Auth 재연결 필요)")
            showTabBarFlow()
        } else {
            print("🔴 로컬 온보딩 미완료 - 로그인 화면으로")
            showAuthFlow()
        }
    }
    
    /// Firestore 기반 사용자 상태 확인
    private func checkUserStatusWithFirestore(uid: String) {
        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        authUseCase.getUserStatus(uid: uid)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] userStatus in
                    switch userStatus {
                    case .needsOnboarding:
                        print("🔴 Firestore: 온보딩 필요 - 온보딩 화면으로")
                        self?.showOnboardingFlow()
                    case .complete:
                        print("🟢 Firestore: 온보딩 완료 - 메인 화면으로")
                        // UserDefaults 동기화
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        self?.showTabBarFlow()
                    }
                },
                onError: { [weak self] error in
                    print("🔴 Firestore 사용자 상태 조회 실패: \(error)")
                    // 에러 시 로컬 상태 확인
                    self?.checkLocalUserStatus()
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// 로그인/회원가입 흐름 시작
    private func showAuthFlow() {
        print("🔑 로그인 화면 표시")
        let authCoordinator = AuthCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(authCoordinator)
        
        authCoordinator.finishFlow = { [weak self, weak authCoordinator] in
            guard let self, let authCoordinator else { return }
            self.childDidFinish(authCoordinator)
            
            print("🟢 로그인 완료 - 사용자 상태 재확인")
            // 로그인 완료 후 사용자 상태 확인
            if let currentUser = Auth.auth().currentUser {
                self.checkUserStatusWithFirestore(uid: currentUser.uid)
            } else {
                print("🔴 로그인 완료 후 사용자 정보 없음")
                self.showAuthFlow()
            }
        }
        
        authCoordinator.start()
        window.rootViewController = authCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 온보딩 흐름 시작 (닉네임 입력 + 온보딩)
    private func showOnboardingFlow() {
        print("👋 온보딩 화면 표시")
        let onboardingCoordinator = OnBoardingCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(onboardingCoordinator)
        
        onboardingCoordinator.finishFlow = { [weak self, weak onboardingCoordinator] in
            guard let self, let onboardingCoordinator else { return }
            
            print("🟢 온보딩 완료 - 메인 화면으로 이동")
            // UserDefaults에 온보딩 완료 저장
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self.showTabBarFlow()
            self.childDidFinish(onboardingCoordinator)
        }
        
        onboardingCoordinator.start()
        window.rootViewController = onboardingCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 메인 탭바 흐름 시작
    private func showTabBarFlow() {
        print("🏠 메인 화면 표시")
        let tabBarCoordinator = TabBarCoordinator(tabBarController: UITabBarController(), container: container)
        
        tabBarCoordinator.finishFlow = { [weak self, weak tabBarCoordinator] in
            guard let self, let tabBarCoordinator else { return }
            self.childDidFinish(tabBarCoordinator)
            print("🔑 메인 화면 종료 - 로그인 화면으로")
            // 로그아웃/계정삭제 후 인증 화면으로 이동
            self.showAuthFlow()
        }
        
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
    
    /// 자식 Coordinator가 완료되었을 때 배열에서 제거
    /// - 메모리 누수 방지 및 흐름 정리를 위함
    private func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if ObjectIdentifier(coordinator) == ObjectIdentifier(child) {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
