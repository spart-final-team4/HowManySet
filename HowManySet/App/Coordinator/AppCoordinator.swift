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
        // 🟢 비회원 사용자 체크 - Firebase Auth 리스너 없이 바로 처리
        let provider = UserDefaults.standard.string(forKey: "userProvider") ?? "none"
        if provider == "anonymous" {
            print("🟢 비회원 사용자 감지 - Firebase Auth 리스너 없이 로컬 상태만 확인")
            checkLocalUserStatus()
            return
        }
        
        // 🟢 앱 시작 시 온보딩 완료 여부 먼저 체크 (일반 사용자)
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if hasCompletedOnboarding {
            print("🟢 온보딩 완료 상태 - 메인 화면으로 바로 이동")
            showTabBarFlow()
            return
        }
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
                self.authWaitTimer = Observable<Int>.timer(self.initialAuthWait, scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        guard let self, !self.hasRouted else { return }
                        self.hasRouted = true
                        self.route(using: nil)
                    })
            }
        }
    }
    
    /// 토큰(세션) 유효성 검사 – 만료·삭제된 계정이면 false
    private func validateSession(_ user: FirebaseAuth.User, completion: @escaping (Bool) -> Void) {
        user.reload { error in
            if let error {
                print("🔴 token invalid:", error)
                try? Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                UserDefaults.standard.removeObject(forKey: "hasSetNickname")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    /// user 존재 여부에 따른 라우팅
    private func route(using user: FirebaseAuth.User?) {
        validateUserState() // 디버깅용 로그
        
        if let user {
            print("🟢 Firebase 사용자 존재: \(user.uid)")
            checkUserStatusWithFirestore(uid: user.uid)
        } else {
            print("🔴 Firebase 사용자 없음 - 비회원 로그인 플로우 시작")
            // 🟢 수정: uid가 nil이면 무조건 비회원 플로우
            handleAnonymousUserFlow()
        }
    }
    
    /// 비회원 사용자 플로우 처리
    private func handleAnonymousUserFlow() {
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let provider = UserDefaults.standard.string(forKey: "userProvider") ?? "none"
        
        print("🔍 비회원 사용자 플로우")
        print("   - Provider: \(provider)")
        print("   - hasCompleted: \(hasCompleted)")
        
        // provider가 없으면 아직 로그인하지 않은 상태
        if provider == "none" || provider.isEmpty {
            print("🔴 로그인 필요 - 로그인 화면으로 이동")
            showAuthFlow()
            return
        }
        
        // 비회원 로그인 완료된 상태에서는 바로 메인 화면으로
        if provider == "anonymous" {
            print("🟡 비회원 로그인 완료 - 바로 메인 화면으로 이동")
            // 온보딩 완료 상태로 설정하고 메인 화면으로
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            showTabBarFlow()
        } else {
            // 다른 provider인데 Firebase uid가 없는 경우 (세션 만료 등)
            print("🔴 세션 만료 가능성 - 로그인 화면으로 이동")
            showAuthFlow()
        }
    }
    
    /// 로컬 사용자 상태 확인 (Firebase Auth 없을 때) - 이제 사용하지 않음
    private func checkLocalUserStatus() {
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let hasSetNickname = UserDefaults.standard.bool(forKey: "hasSetNickname")
        let provider = UserDefaults.standard.string(forKey: "userProvider") ?? "none"
        
        print("🔍 checkLocalUserStatus 호출")
        print("   - Provider: \(provider)")
        print("   - hasSetNickname: \(hasSetNickname)")
        print("   - hasCompleted: \(hasCompleted)")
        
        // 🟢 수정: provider가 "none"이면서 다른 상태도 없으면 로그인 화면으로
        if provider == "none" || provider.isEmpty {
            // 혹시 이미 온보딩이 완료된 상태라면 메인으로
            if hasCompleted {
                print("🟡 Provider 없지만 온보딩 완료 - 메인 화면")
                showTabBarFlow()
            } else {
                print("🔴 Provider 없음 - 로그인 화면으로 이동")
                showAuthFlow()
            }
            return
        }
        
        // 🟢 익명 사용자 전용 로직
        if provider == "anonymous" {
            if !hasCompleted {
                print("🔴 익명 사용자 온보딩 미완료 - 온보딩 화면으로 직행")
                showOnboardingFlow()
            } else {
                print("🟡 익명 사용자 온보딩 완료 - 메인 화면")
                showTabBarFlow()
            }
            return
        }
        
        // 기존 소셜 로그인 사용자 로직 유지
        if !hasSetNickname {
            print("🔴 로컬 닉네임 미설정 - 닉네임 입력 화면")
            showNicknameFlow()
        } else if !hasCompleted {
            print("🔴 로컬 온보딩 미완료 - 온보딩 화면")
            showOnboardingFlow()
        } else {
            print("🟡 로컬 온보딩 완료 상태 - 메인 화면")
            showTabBarFlow()
        }
    }
    
    /// Firestore 기반 사용자 상태 확인 (수정된 버전)
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
                    case .needsNickname:
                        print("🔴 서버: 닉네임 설정 필요")
                        self.showNicknameFlow()
                    case .needsOnboarding:
                        print("🔴 서버: 온보딩 필요")
                        self.showOnboardingFlow()
                    case .complete:
                        print("🟢 서버: 온보딩 완료")
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        UserDefaults.standard.set(true, forKey: "hasSetNickname")
                        self.showTabBarFlow()
                    }
                },
                onError: { [weak self] error in
                    print("🔴 Firestore 사용자 상태 조회 실패: \(error)")
                    // Firebase 사용자가 있는데 Firestore 조회 실패 시에만 로컬 상태 확인
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
        let coord = AuthCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(coord)
        
        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            self.childDidFinish(coord)
            // 🟢 수정: Auth 완료 후 다시 라우팅 (Firebase user 상태에 따라)
            if let currentUser = Auth.auth().currentUser {
                self.checkUserStatusWithFirestore(uid: currentUser.uid)
            } else {
                self.handleAnonymousUserFlow()
            }
        }
        
        coord.start()
        window.rootViewController = coord.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 닉네임 입력만 하는 플로우
    private func showNicknameFlow() {
        guard !isSwitchingRoot else { return }
        isSwitchingRoot = true
        defer { isSwitchingRoot = false }
        
        print("✏️ 닉네임 입력 화면 표시")
        let coord = OnBoardingCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(coord)
        
        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            self.childDidFinish(coord)
            // 닉네임 완료 후 바로 메인으로 이동 (온보딩은 ViewController 내부에서 처리)
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self.showTabBarFlow()
        }
        
        coord.startWithNicknameOnly()
        window.rootViewController = coord.navigationController
        window.makeKeyAndVisible()
    }
    
    /// 온보딩만 하는 플로우
    private func showOnboardingFlow() {
        guard !isSwitchingRoot else { return }
        isSwitchingRoot = true
        defer { isSwitchingRoot = false }
        
        print("👋 온보딩 화면 표시")
        let coord = OnBoardingCoordinator(navigationController: UINavigationController(), container: container)
        childCoordinators.append(coord)
        
        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self.childDidFinish(coord)
            self.showTabBarFlow()
        }
        
        coord.startWithOnboardingOnly()
        window.rootViewController = coord.navigationController
        window.makeKeyAndVisible()
    }
    
    
    /// 메인 탭바 흐름 시작 (수정된 버전)
    private func showTabBarFlow() {
        guard !isSwitchingRoot else { return }
        isSwitchingRoot = true
        defer { isSwitchingRoot = false }
        
        print("🏠 메인 화면 표시")
        let coord = TabBarCoordinator(tabBarController: UITabBarController(), container: container)
        childCoordinators.append(coord)
        
        coord.finishFlow = { [weak self, weak coord] in
            guard let self, let coord else { return }
            self.childDidFinish(coord)
            
            // 🟢 uid 체크로 분기하여 UserDefaults 삭제
            let uid = UserDefaults.standard.string(forKey: "userUID")
            
            if uid == nil {
                // 비회원 사용자 - Bundle identifier로 완전 삭제
                if let bundleIdentifier = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
                    UserDefaults.standard.synchronize()
                    print("🟢 비회원 로그아웃 - Bundle 전체 UserDefaults 삭제 완료")
                }
            } else {
                // 기존 일반 사용자 로직 유지
                let keysToRemove = [
                    "hasCompletedOnboarding",
                    "hasSkippedOnboarding",
                    "userNickname",
                    "userProvider",
                    "userUID",
                    "hasSetNickname"
                ]
                for key in keysToRemove {
                    UserDefaults.standard.removeObject(forKey: key)
                }
                UserDefaults.standard.synchronize()
                print("🟢 일반 사용자 로그아웃 - 개별 키 UserDefaults 삭제 완료")
            }
            
            self.showAuthFlow()
        }
        
        coord.start()
        window.rootViewController = coord.tabBarController
        window.makeKeyAndVisible()
    }
    
    
    /// 디버깅을 위한 상태 검증 메서드
    private func validateUserState() {
        let hasNickname = UserDefaults.standard.bool(forKey: "hasSetNickname")
        let hasOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let provider = UserDefaults.standard.string(forKey: "userProvider") ?? "none"
        let nickname = UserDefaults.standard.string(forKey: "userNickname") ?? "없음"
        let uid = UserDefaults.standard.string(forKey: "userUID") ?? "없음"
        
        print("🔍 현재 사용자 상태:")
        print("   - Provider: \(provider)")
        print("   - UID: \(uid)")
        print("   - 닉네임: \(nickname)")
        print("   - 닉네임 설정: \(hasNickname)")
        print("   - 온보딩 완료: \(hasOnboarding)")
    }
    
    private func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll {
            ObjectIdentifier($0) == ObjectIdentifier(child)
        }
    }
}
