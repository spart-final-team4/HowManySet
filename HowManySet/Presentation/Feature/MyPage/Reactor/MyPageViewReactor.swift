//
//  MyPageViewModel.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import Foundation
import RxSwift
import ReactorKit
import FirebaseAuth
import FirebaseFirestore

/// 마이페이지 화면의 Reactor (ViewModel 역할)
/// - 사용자 액션을 받아 상태 변화를 처리하고 뷰에 반영할 상태를 관리함
/// - Firestore 기반 닉네임 fetch 추가
final class MyPageViewReactor: Reactor {
    
    private let authUseCase: AuthUseCaseProtocol
    
    /// 사용자 액션 (뷰에서 발생하는 이벤트)
    enum Action {
        /// 셀 탭 이벤트, 탭된 셀 타입을 전달
        case cellTapped(MyPageCellType)
        /// 로그아웃
        case confirmLogout
        /// 계정 삭제(회원 탈퇴)
        case confirmDeleteAccount
        /// 사용자 이름 로드 (Firestore에서 fetch)
        case loadUserName
        case membershipButtonTapped
        case resetMembershipMoved
    }
    
    /// 상태 변화를 나타내는 Mutation (내부 상태 조작용)
    enum Mutation {
        /// 특정 셀 타입에 대한 화면 전환 지시
        case presentTo(MyPageCellType?)
        /// 로그아웃 성공
        case logoutSuccess
        /// 계정 삭제 성공
        case deleteAccountSuccess
        /// 에러 발생
        case setError(Error)
        /// 사용자 이름 설정
        case setUserName(String)
        case presentMembershipView(Bool)
    }
    
    /// 현재 뷰 상태를 담는 구조체
    struct State {
        /// 현재 화면 전환 대상 셀 타입 (없으면 nil)
        var presentTarget: MyPageCellType?
        /// 로그아웃/계정삭제 성공 여부
        var shouldNavigateToAuth: Bool = false
        /// 에러 정보
        var error: Error?
        /// 사용자 이름 (Firestore에서 fetch)
        var userName: String? = nil
        var membershipMoved: Bool = false
    }
    
    /// 초기 상태
    let initialState: State
    
    /// 생성자
    /// - Parameters:
    ///   - authUseCase: 인증 관련 유스케이스
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.initialState = State(presentTarget: nil)
    }
    
    /// Action을 Mutation으로 변환하는 메서드
    /// - Parameter action: 뷰에서 전달된 액션
    /// - Returns: 상태 변화를 위한 Mutation Observable
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cellTapped(let cell):
            return Observable.concat([
                .just(.presentTo(cell)),
                .just(.presentTo(nil)) // nil로 초기화(자동 재방출 방지)
            ])

        case .loadUserName:
            // Firestore에서 사용자 정보 fetch
            return fetchUserNameFromFirestore()
                .map { .setUserName($0) }
                .catch { error in
                    print("🔴 사용자 이름 로드 실패: \(error)")
                    // 실패 시 로컬 백업 사용
                    let localName = UserDefaults.standard.string(forKey: "userNickname") ?? String(localized: "비회원")
                    return .just(.setUserName(localName))
                }
            
        case .confirmLogout:
            return authUseCase.logout()
                .map { _ in .logoutSuccess }
                .catch { error in .just(.setError(error)) }

        case .confirmDeleteAccount:
            return authUseCase.deleteAccount()
                .map { _ in .deleteAccountSuccess }
                .catch { error in .just(.setError(error)) }
        case .membershipButtonTapped:
            return .just(.presentMembershipView(true))
        case .resetMembershipMoved:
            return .just(.presentMembershipView(false))
        }
    }
    
    /// Mutation을 State에 반영하는 메서드
    /// - Parameters:
    ///   - state: 현재 상태
    ///   - mutation: 적용할 변화
    /// - Returns: 새로운 상태
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .presentTo(let cellType):
            newState.presentTarget = cellType
        case .logoutSuccess, .deleteAccountSuccess:
            newState.shouldNavigateToAuth = true
        case .setError(let error):
            newState.error = error
        case .setUserName(let name):
            newState.userName = name
        case .presentMembershipView(let value):
            newState.membershipMoved = value
        }
        return newState
    }
    
    /// Firestore에서 사용자 이름을 가져오는 메서드
    /// - Returns: 사용자 이름을 방출하는 Observable
    private func fetchUserNameFromFirestore() -> Observable<String> {
        return Observable.create { observer in
            guard let currentUser = Auth.auth().currentUser else {
                // Firebase Auth 사용자가 없으면 로컬 백업 사용
                let localName = UserDefaults.standard.string(forKey: "userNickname") ?? String(localized: "비회원")
                observer.onNext(localName)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
                if let error = error {
                    print("🔴 Firestore 사용자 정보 조회 실패: \(error)")
                    observer.onError(error)
                    return
                }
                
                guard let document = snapshot, document.exists,
                      let data = document.data(),
                      let name = data["name"] as? String else {
                    print("🔴 Firestore 문서 없음 - 로컬 백업 사용")
                    let localName = UserDefaults.standard.string(forKey: "userNickname") ?? String(localized: "비회원")
                    observer.onNext(localName)
                    observer.onCompleted()
                    return
                }
                
                print("🟢 Firestore에서 사용자 이름 로드 성공: \(name)")
                observer.onNext(name)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}


extension MyPageViewReactor {
    
    func getLocalDatas() {
        
    }
    
    func migration() {
        
    }
}
