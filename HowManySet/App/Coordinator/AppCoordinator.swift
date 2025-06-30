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

    /// Firebase Auth 리스너 핸들 (메모리 누수 방지)
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    /// rootViewController 교체 중복 방지
    private var isSwitchingRoot = false

    /// 최초 분기가 이미 이뤄졌는지 여부
    /// (이후 콜백은 실시간 로그인/로그아웃 이벤트)
    private var hasRouted = false

    /// 첫 콜백 nil 대기용 타이머
    private var authWaitTimer: Disposable?
    private let initialAuthWait: RxTimeInterval = .seconds(1)

    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        authWaitTimer?.dispose()
    }

    /// 앱 시작 시 호출
    func start() {
        authStateListenerHandle
            = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            // 이미 한 번 분기했으면 이후 콜백은 상태 변화 처리로 사용
            if self.hasRouted {
                self.route(using: user)
                return
            }

            // 1) user 가 즉시 존재 → 세션 유효성 검사 후 분기
            if let user {
                self.hasRouted = true
                self.authWaitTimer?.dispose()
                self.validateSession(user) { [weak self] isValid in
                    guard let self else { return }
                    if isValid {
                        self.route(using: user)
                    } else {
                        self.checkLocalUserStatus()
                    }
                }
            }
            // 2) 첫 콜백이 nil → 잠시 대기 후 여전히 nil이면 비로그인 플로우
            else {
                self.authWaitTimer?.dispose()
                self.authWaitTimer
                    = Observable<Int>.timer(self.initialAuthWait,
                                            scheduler: MainScheduler.instance)
                      .subscribe(onNext: { [weak self] _ in
                          guard let self, !self.hasRouted else { return }
                          self.hasRouted = true
                          self.route(using: nil)
                      })
            }
        }
    }

    /// ★ 토큰(세션) 유효성 검사 – 만료·삭제된 계정이면 false
    private func validateSession(_ user: FirebaseAuth.User,
                                 completion: @escaping (Bool) -> Void) {
        user.reload { error in
            if let error {
                print("🔴 token invalid:", error)
                try? Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    /// user 존재 여부에 따른 라우팅
    private func route(using user: FirebaseAuth.User?) {
        if let user {
            checkUserStatusWithFirestore(uid: user.uid)
        } else {
            checkLocalUserStatus()
        }
    }

    /// 로컬 사용자 상태 확인 (Firebase Auth 없을 때)
    private func checkLocalUserStatus() {
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if hasCompleted {
            print("🟡 로컬 온보딩 완료 상태 - 메인 화면")
            showTabBarFlow()
        } else {
            print("🔴 로컬 온보딩 미완료 - 로그인 화면")
            showAuthFlow()
        }
    }

    /// Firestore 기반 사용자 상태 확인
    private func checkUserStatusWithFirestore(uid: String) {
        let authRepo = AuthRepositoryImpl(firebaseAuthService: FirebaseAuthService())
        let authUseCase = AuthUseCase(repository: authRepo)

        authUseCase.getUserStatus(uid: uid)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] status in
                    guard let self else { return }
                    switch status {
                    case .needsOnboarding:
                        // 로컬 플래그가 true인데 서버가 false라면 유령 세션 → 로그아웃
                        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                            try? Auth.auth().signOut()
                            self.showAuthFlow()
                        } else {
                            self.showOnboardingFlow()
                        }
                    case .complete:
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        self.showTabBarFlow()
                    }
                },
                onError: { [weak self] error in
                    print("🔴 Firestore 사용자 상태 조회 실패: \(error)")
                    self?.checkLocalUserStatus()
                }
            )
            .disposed(by: disposeBag)
    }

    /// 로그인/회원가입 흐름 시작
    private func showAuthFlow() {
        guard !isSwitchingRoot else { return }
        isSwitchingRoot = true
        defer { isSwitchingRoot = false }

        print("🔑 로그인 화면 표시")
        let coord = AuthCoordinator(navigationController: UINavigationController(),
                                    container: container)
        childCoordinators.append(coord)

        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            self.childDidFinish(coord)
            if let current = Auth.auth().currentUser {
                self.checkUserStatusWithFirestore(uid: current.uid)
            } else {
                self.showAuthFlow()
            }
        }

        coord.start()
        window.rootViewController = coord.navigationController
        window.makeKeyAndVisible()
    }

    /// 온보딩 흐름 시작
    private func showOnboardingFlow() {
        guard !isSwitchingRoot else { return }
        isSwitchingRoot = true
        defer { isSwitchingRoot = false }

        print("👋 온보딩 화면 표시")
        let coord = OnBoardingCoordinator(navigationController: UINavigationController(),
                                          container: container)
        childCoordinators.append(coord)

        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self.childDidFinish(coord)
            self.showTabBarFlow()
        }

        coord.start()
        window.rootViewController = coord.navigationController
        window.makeKeyAndVisible()
    }

    /// 메인 탭바 흐름 시작
    private func showTabBarFlow() {
        guard !isSwitchingRoot else { return }
        isSwitchingRoot = true
        defer { isSwitchingRoot = false }

        print("🏠 메인 화면 표시")
        let coord = TabBarCoordinator(tabBarController: UITabBarController(),
                                      container: container)
        childCoordinators.append(coord)

        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            self.childDidFinish(coord)
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            self.showAuthFlow()
        }

        coord.start()
        window.rootViewController = coord.tabBarController
        window.makeKeyAndVisible()
    }

    private func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll {
            ObjectIdentifier($0) == ObjectIdentifier(child)
        }
    }
}
