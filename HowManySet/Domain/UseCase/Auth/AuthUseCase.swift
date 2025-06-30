//
//  AuthUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import RxSwift
import Foundation

/// 인증 관련 비즈니스 로직을 담당하는 UseCase
///
/// 다양한 소셜 로그인 제공자를 지원하며, 사용자 인증과 온보딩 프로세스의
/// 비즈니스 규칙을 구현합니다. Repository 계층과 Presentation 계층 사이의
/// 중간 역할을 담당합니다.
public final class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    /// AuthUseCase 초기화
    ///
    /// - Parameter repository: 인증 관련 데이터 처리를 위한 Repository
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    /// 카카오 계정으로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 사용자 정보를 저장합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func loginWithKakao() -> Observable<User> {
        return repository.signInWithKakao()
            .do(onNext: { user in
                UserDefaults.standard.set(user.name, forKey: "userNickname")
                UserDefaults.standard.set("kakao", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                if user.hasCompletedOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                UserDefaults.standard.synchronize()
            })
    }
    
    /// 구글 계정으로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 사용자 정보를 저장합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func loginWithGoogle() -> Observable<User> {
        return repository.signInWithGoogle()
            .do(onNext: { user in
                UserDefaults.standard.set(user.name, forKey: "userNickname")
                UserDefaults.standard.set("google", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                if user.hasCompletedOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                UserDefaults.standard.synchronize()
            })
    }
    
    /// Apple ID로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 사용자 정보를 저장합니다.
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func loginWithApple(token: String, nonce: String) -> Observable<User> {
        return repository.signInWithApple(token: token, nonce: nonce)
            .do(onNext: { user in
                UserDefaults.standard.set(user.name, forKey: "userNickname")
                UserDefaults.standard.set("apple", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                if user.hasCompletedOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                UserDefaults.standard.synchronize()
            })
    }
    
    /// 익명 로그인을 수행합니다
    ///
    /// 익명 사용자의 경우 모든 데이터를 로컬(UserDefaults)에만 저장합니다.
    /// - Returns: 익명 사용자 정보를 방출하는 Observable
    public func loginAnonymously() -> Observable<User> {
        return repository.signInAnonymously()
            .do(onNext: { user in
                UserDefaults.standard.set("비회원", forKey: "userNickname")
                UserDefaults.standard.set("anonymous", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                UserDefaults.standard.synchronize()
            })
    }
    
    /// 현재 사용자를 로그아웃시킵니다
    ///
    /// UserDefaults의 사용자 정보를 초기화합니다.
    /// - Returns: 로그아웃 완료를 알리는 Observable
    public func logout() -> Observable<Void> {
        return repository.signOut()
            .do(onNext: { _ in
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                UserDefaults.standard.removeObject(forKey: "hasSkippedOnboarding")
                UserDefaults.standard.removeObject(forKey: "userNickname")
                UserDefaults.standard.removeObject(forKey: "userProvider")
                UserDefaults.standard.removeObject(forKey: "userUID")
                UserDefaults.standard.removeObject(forKey: "hasSetNickname")
                UserDefaults.standard.synchronize()
            })
    }
    
    /// 현재 사용자의 계정을 완전히 삭제합니다
    ///
    /// UserDefaults의 사용자 정보를 초기화합니다.
    /// - Returns: 계정 삭제 완료를 알리는 Observable
    public func deleteAccount() -> Observable<Void> {
        return repository.deleteAccount()
            .do(onNext: { _ in
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
            })
    }
    
    /// 사용자의 온보딩 상태를 조회합니다
    ///
    /// 익명 사용자는 로컬 상태를, 일반 사용자는 Firestore 상태를 확인합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 사용자 온보딩 상태를 방출하는 Observable
    /// 사용자의 온보딩 상태를 조회
    public func getUserStatus(uid: String) -> Observable<UserStatus> {
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        if userProvider == "anonymous" {
            let hasSetNickname = UserDefaults.standard.bool(forKey: "hasSetNickname")
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            
            if !hasSetNickname {
                return Observable.just(.needsNickname)
            } else if !hasCompletedOnboarding {
                return Observable.just(.needsOnboarding)
            } else {
                return Observable.just(.complete)
            }
        } else {
            return repository.fetchUserInfo(uid: uid)
                .map { user in
                    guard let user = user else { return .needsNickname }
                    
                    if !user.hasSetNickname {
                        return .needsNickname
                    } else if !user.hasCompletedOnboarding {
                        return .needsOnboarding
                    } else {
                        // 서버 데이터를 로컬에 동기화
                        UserDefaults.standard.set(user.name, forKey: "userNickname")
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        UserDefaults.standard.set(true, forKey: "hasSetNickname")
                        UserDefaults.standard.synchronize()
                        return .complete
                    }
                }
        }
    }
    
    /// 사용자의 닉네임 설정을 완료합니다
    ///
    /// 닉네임 유효성 검사를 수행하며, 익명 사용자는 로컬에,
    /// 일반 사용자는 Firestore에 저장합니다.
    /// - Parameters:
    ///   - uid: 사용자 고유 식별자
    ///   - nickname: 설정할 닉네임 (한글/영문/숫자 2~8자)
    /// - Returns: 닉네임 설정 완료를 알리는 Observable
    public func completeNicknameSetting(uid: String, nickname: String) -> Observable<Void> {
        guard isValidNickname(nickname) else {
            return Observable.error(NSError(domain: "InvalidNickname", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 닉네임입니다. (한글/영문/숫자 2~8자)"]))
        }
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        if userProvider == "anonymous" {
            return Observable.create { observer in
                UserDefaults.standard.set(nickname, forKey: "userNickname")
                UserDefaults.standard.set(true, forKey: "hasSetNickname")
                UserDefaults.standard.synchronize()
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
        } else {
            return repository.updateUserNickname(uid: uid, nickname: nickname)
                .do(onNext: { _ in
                    UserDefaults.standard.set(nickname, forKey: "userNickname")
                    UserDefaults.standard.set(true, forKey: "hasSetNickname")
                    UserDefaults.standard.synchronize()
                })
        }
    }
    
    /// 사용자의 온보딩 프로세스를 완료합니다
    ///
    /// 익명 사용자는 로컬에, 일반 사용자는 Firestore에 완료 상태를 저장합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 온보딩 완료를 알리는 Observable
    public func completeOnboarding(uid: String) -> Observable<Void> {
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        if userProvider == "anonymous" {
            return Observable.create { observer in
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.synchronize()
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
        } else {
            return repository.updateOnboardingStatus(uid: uid, completed: true)
                .do(onNext: { _ in
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                })
        }
    }
    
    /// 사용자의 온보딩 상태를 초기화합니다
    ///
    /// 개발 및 테스트 목적으로 사용되며, 온보딩을 처음부터 다시 진행할 수 있도록 합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 온보딩 상태 초기화 완료를 알리는 Observable
    public func resetUserOnboardingStatus(uid: String) -> Observable<Void> {
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        if userProvider == "anonymous" {
            return Observable.create { observer in
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                UserDefaults.standard.removeObject(forKey: "hasSetNickname")
                UserDefaults.standard.set("비회원", forKey: "userNickname")
                UserDefaults.standard.synchronize()
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
        } else {
            return repository.resetUserOnboardingStatus(uid: uid)
                .do(onNext: { _ in
                    UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.removeObject(forKey: "hasSkippedOnboarding")
                    UserDefaults.standard.removeObject(forKey: "hasSetNickname")
                    UserDefaults.standard.synchronize()
                })
        }
    }
    
    /// 닉네임 유효성 검사
    ///
    /// 한글, 영문, 숫자 2~8자만 허용합니다.
    /// - Parameter nickname: 검사할 닉네임
    /// - Returns: 유효한 닉네임이면 true, 아니면 false
    private func isValidNickname(_ nickname: String) -> Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[가-힣a-zA-Z0-9]{2,8}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }
    
    /// 닉네임 유효성 검사 결과를 Observable로 반환합니다
    ///
    /// - Parameter nickname: 검사할 닉네임
    /// - Returns: 유효성 결과를 방출하는 Observable
    public func checkNicknameValid(_ nickname: String) -> Observable<Bool> {
        return Observable.just(isValidNickname(nickname))
    }
    
    /// 온보딩 프로세스를 완료합니다 (uid 없이 내부에서 처리)
    ///
    /// 현재 로그인된 사용자의 uid를 내부적으로 관리하여,
    /// Presentation 계층에서는 uid를 직접 전달하지 않습니다.
    /// - Returns: 온보딩 완료를 알리는 Observable
    public func completeOnboarding() -> Observable<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "userUID") else {
            return Observable.error(NSError(domain: "NoUser", code: -1))
        }
        return completeOnboarding(uid: uid)
    }
    
    /// 닉네임 설정을 완료합니다 (uid 없이 내부에서 처리)
    ///
    /// 현재 로그인된 사용자의 uid를 내부적으로 관리하여,
    /// Presentation 계층에서는 uid를 직접 전달하지 않습니다.
    /// - Parameter nickname: 설정할 닉네임
    /// - Returns: 닉네임 설정 완료를 알리는 Observable
    public func completeNicknameSetting(nickname: String) -> Observable<Void> {
        guard let uid = UserDefaults.standard.string(forKey: "userUID") else {
            return Observable.error(NSError(domain: "NoUser", code: -1))
        }
        return completeNicknameSetting(uid: uid, nickname: nickname)
    }
}
