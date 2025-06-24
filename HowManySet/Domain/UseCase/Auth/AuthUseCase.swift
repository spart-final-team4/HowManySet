//
//  AuthUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import RxSwift
import Foundation

/// 인증 관련 비즈니스 로직을 처리하는 UseCase 구현체
///
/// Repository를 통해 데이터를 처리하고 비즈니스 규칙을 적용하며,
/// Clean Architecture 원칙에 따라 Firebase에 직접 접근하지 않습니다.
/// Firestore 기반 닉네임 관리와 익명 사용자 로컬 저장, 완전한 계정 삭제를 지원합니다.
public final class AuthUseCase: AuthUseCaseProtocol {
    /// 인증 데이터 처리를 담당하는 Repository
    private let repository: AuthRepositoryProtocol

    /// AuthUseCase 인스턴스를 생성합니다
    /// - Parameter repository: 인증 데이터 처리를 담당하는 Repository 구현체
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    /// 카카오 계정으로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 백업 데이터를 저장하며,
    /// 기존 온보딩 상태를 유지합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func loginWithKakao() -> Observable<User> {
        return repository.signInWithKakao()
            .do(onNext: { user in
                print("🟢 카카오 로그인 성공: \(user.name) (\(user.uid))")
                UserDefaults.standard.set(user.name, forKey: "userNickname")
                UserDefaults.standard.set("kakao", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                if user.hasCompletedOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                UserDefaults.standard.synchronize()
            })
            .do(onError: { error in
                print("🔴 카카오 로그인 실패: \(error)")
            })
    }

    /// 구글 계정으로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 백업 데이터를 저장하며,
    /// 기존 온보딩 상태를 유지합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func loginWithGoogle() -> Observable<User> {
        return repository.signInWithGoogle()
            .do(onNext: { user in
                print("🟢 구글 로그인 성공: \(user.name) (\(user.uid))")
                UserDefaults.standard.set(user.name, forKey: "userNickname")
                UserDefaults.standard.set("google", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                if user.hasCompletedOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                UserDefaults.standard.synchronize()
            })
            .do(onError: { error in
                print("🔴 구글 로그인 실패: \(error)")
            })
    }

    /// Apple ID로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 백업 데이터를 저장하며,
    /// 기존 온보딩 상태를 유지합니다.
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func loginWithApple(token: String, nonce: String) -> Observable<User> {
        return repository.signInWithApple(token: token, nonce: nonce)
            .do(onNext: { user in
                print("🟢 Apple 로그인 성공: \(user.name) (\(user.uid))")
                UserDefaults.standard.set(user.name, forKey: "userNickname")
                UserDefaults.standard.set("apple", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                if user.hasCompletedOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                UserDefaults.standard.synchronize()
            })
            .do(onError: { error in
                print("🔴 Apple 로그인 실패: \(error)")
            })
    }

    /// 익명 로그인을 수행합니다
    ///
    /// 익명 사용자의 경우 모든 데이터를 로컬(UserDefaults)에만 저장합니다.
    /// - Returns: 익명 사용자 정보를 방출하는 Observable
    public func loginAnonymously() -> Observable<User> {
        return repository.signInAnonymously()
            .do(onNext: { user in
                print("🟢 익명 로그인 성공: \(user.name) (\(user.uid))")
                UserDefaults.standard.set("비회원", forKey: "userNickname")
                UserDefaults.standard.set("anonymous", forKey: "userProvider")
                UserDefaults.standard.set(user.uid, forKey: "userUID")
                UserDefaults.standard.synchronize()
            })
            .do(onError: { error in
                print("🔴 익명 로그인 실패: \(error)")
            })
    }
    
    /// 현재 사용자를 로그아웃시킵니다
    ///
    /// Firestore의 온보딩 상태는 유지하고 UserDefaults만 초기화합니다.
    /// 재로그인 시 기존 온보딩 상태를 복원할 수 있습니다.
    /// - Returns: 로그아웃 완료를 알리는 Observable
    public func logout() -> Observable<Void> {
        return repository.signOut()
            .do(onNext: { _ in
                print("🟢 로그아웃 성공 - Firestore 온보딩 상태는 유지됨")
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                UserDefaults.standard.removeObject(forKey: "hasSkippedOnboarding")
                UserDefaults.standard.removeObject(forKey: "userNickname")
                UserDefaults.standard.removeObject(forKey: "userProvider")
                UserDefaults.standard.removeObject(forKey: "userUID")
                UserDefaults.standard.removeObject(forKey: "hasSetNickname")
                UserDefaults.standard.synchronize()
            })
            .do(onError: { error in
                print("🔴 로그아웃 실패: \(error)")
            })
    }
    
    /// 현재 사용자의 계정을 완전히 삭제합니다
    ///
    /// 소셜 로그인 연결 해제, Firestore 데이터 삭제, 로컬 데이터 초기화를
    /// 모두 수행합니다.
    /// - Returns: 계정 삭제 완료를 알리는 Observable
    public func deleteAccount() -> Observable<Void> {
        return repository.deleteAccount()
            .do(onNext: { _ in
                print("🟢 계정 삭제 성공 - 모든 데이터 완전 초기화")
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
            .do(onError: { error in
                print("🔴 계정 삭제 실패: \(error)")
            })
    }

    /// 사용자의 온보딩 상태를 조회합니다
    ///
    /// 익명 사용자는 로컬 상태를, 일반 사용자는 Firestore 상태를 확인하여
    /// 온보딩 필요 여부를 판단합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 사용자 온보딩 상태를 방출하는 Observable
    public func getUserStatus(uid: String) -> Observable<UserStatus> {
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        
        if userProvider == "anonymous" {
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            let hasSetNickname = UserDefaults.standard.bool(forKey: "hasSetNickname")
            
            if !hasSetNickname || !hasCompletedOnboarding {
                print("🔴 익명 사용자 온보딩 미완료 - 로컬 확인")
                return Observable.just(.needsOnboarding)
            } else {
                print("🟢 익명 사용자 온보딩 완료 - 로컬 확인")
                return Observable.just(.complete)
            }
        } else {
            return repository.fetchUserInfo(uid: uid)
                .map { user in
                    guard let user = user else {
                        print("🔴 사용자 정보 없음 - 온보딩 필요")
                        return .needsOnboarding
                    }
                    
                    if !user.hasSetNickname || !user.hasCompletedOnboarding {
                        print("🔴 온보딩 미완료 - 닉네임: \(user.hasSetNickname), 온보딩: \(user.hasCompletedOnboarding)")
                        return .needsOnboarding
                    } else {
                        print("🟢 온보딩 완료 - 메인 화면으로")
                        UserDefaults.standard.set(user.name, forKey: "userNickname")
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        UserDefaults.standard.set(true, forKey: "hasSetNickname")
                        UserDefaults.standard.synchronize()
                        return .complete
                    }
                }
                .do(onNext: { status in
                    print("🔍 사용자 상태 조회 결과: \(status)")
                })
                .do(onError: { error in
                    print("🔴 사용자 상태 조회 실패: \(error)")
                })
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
            return Observable.error(NSError(domain: "InvalidNickname", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 닉네임입니다. (한글/영문 2~8자)"]))
        }
        
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        
        if userProvider == "anonymous" {
            return Observable.create { observer in
                UserDefaults.standard.set(nickname, forKey: "userNickname")
                UserDefaults.standard.set(true, forKey: "hasSetNickname")
                UserDefaults.standard.synchronize()
                
                print("🟢 익명 사용자 닉네임 로컬 저장: \(nickname)")
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
        } else {
            return repository.updateUserNickname(uid: uid, nickname: nickname)
                .do(onNext: { _ in
                    print("🟢 닉네임 Firestore 저장 완료: \(nickname)")
                    UserDefaults.standard.set(nickname, forKey: "userNickname")
                    UserDefaults.standard.set(true, forKey: "hasSetNickname")
                    UserDefaults.standard.synchronize()
                })
                .do(onError: { error in
                    print("🔴 닉네임 Firestore 저장 실패: \(error)")
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
                
                print("🟢 익명 사용자 온보딩 로컬 저장 완료")
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
        } else {
            return repository.updateOnboardingStatus(uid: uid, completed: true)
                .do(onNext: { _ in
                    print("🟢 온보딩 Firestore 저장 완료")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.synchronize()
                })
                .do(onError: { error in
                    print("🔴 온보딩 Firestore 저장 실패: \(error)")
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
                
                print("🟢 익명 사용자 온보딩 상태 로컬 초기화 완료")
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
        } else {
            return repository.resetUserOnboardingStatus(uid: uid)
                .do(onNext: { _ in
                    print("🟢 사용자 온보딩 상태 초기화 완료")
                    UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.removeObject(forKey: "hasSkippedOnboarding")
                    UserDefaults.standard.removeObject(forKey: "hasSetNickname")
                    UserDefaults.standard.synchronize()
                })
                .do(onError: { error in
                    print("🔴 온보딩 상태 초기화 실패: \(error)")
                })
        }
    }

    /// 닉네임의 유효성을 검사합니다
    ///
    /// 한글, 영문, 숫자 조합으로 2~8자 길이의 닉네임만 허용합니다.
    /// - Parameter nickname: 검사할 닉네임
    /// - Returns: 유효한 닉네임이면 true, 그렇지 않으면 false
    private func isValidNickname(_ nickname: String) -> Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[가-힣a-zA-Z0-9]{2,8}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }
}
