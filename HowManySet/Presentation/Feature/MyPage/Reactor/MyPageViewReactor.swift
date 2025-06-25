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
    
    private let fetchUserSettingUseCase: FetchUserSettingUseCase
    private let saveUserSettingUseCase: SaveUserSettingUseCase
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
        var userName: String?
    }
    
    /// 초기 상태
    let initialState: State
    
    /// 생성자
    /// - Parameters:
    ///   - fetchUserSettingUseCase: 사용자 설정 조회용 유스케이스
    ///   - saveUserSettingUseCase: 사용자 설정 저장용 유스케이스
    ///   - authUseCase: 인증 관련 유스케이스
    init(fetchUserSettingUseCase: FetchUserSettingUseCase, saveUserSettingUseCase: SaveUserSettingUseCase, authUseCase: AuthUseCaseProtocol) {
        self.fetchUserSettingUseCase = fetchUserSettingUseCase
        self.saveUserSettingUseCase = saveUserSettingUseCase
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
            // 🟢 Firestore에서 사용자 정보 fetch
            return fetchUserNameFromFirestore()
                .map { .setUserName($0) }
                .catch { error in
                    print("🔴 사용자 이름 로드 실패: \(error)")
                    // 실패 시 로컬 백업 사용
                    let localName = UserDefaults.standard.string(forKey: "userNickname") ?? "비회원"
                    return .just(.setUserName(localName))
                }
            
        case .confirmLogout:
            print("🔥 로그아웃 액션 시작")
            return authUseCase.logout()
                .map { .logoutSuccess }
                .catch { error in
                    print("🔥 로그아웃 실패: \(error)")
                    return .just(.setError(error))
                }
            
        case .confirmDeleteAccount:
            print("🔥 계정삭제 액션 시작")
            return authUseCase.deleteAccount()
                .map { .deleteAccountSuccess }
                .catch { error in
                    print("🔥 계정삭제 실패: \(error)")
                    return .just(.setError(error))
                }
        }
    }
    
    /// Mutation을 받아 새로운 상태로 변환하는 메서드
    /// - Parameters:
    ///   - state: 현재 상태
    ///   - mutation: 수행할 상태 변화
    /// - Returns: 변경된 새 상태
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .presentTo(let myPageCellType):
            newState.presentTarget = myPageCellType
        case .logoutSuccess, .deleteAccountSuccess:
            newState.shouldNavigateToAuth = true
        case .setError(let error):
            newState.error = error
        case .setUserName(let userName):
            newState.userName = userName
        }
        return newState
    }
    
    /// Firestore에서 사용자 이름 가져오기
    /// - Returns: 사용자 이름 Observable
    func fetchUserNameFromFirestore() -> Observable<String> {
        return Observable.create { observer in
            // 익명 사용자는 로컬에서만
            let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
            if userProvider == "anonymous" {
                let localName = UserDefaults.standard.string(forKey: "userNickname") ?? "비회원"
                print("🟡 익명 사용자 닉네임 로컬 로드: \(localName)")
                observer.onNext(localName)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 일반 사용자는 Firestore에서 fetch
            guard let currentUser = Auth.auth().currentUser else {
                print("🔴 현재 사용자 없음 - 기본값 사용")
                observer.onNext("비회원")
                observer.onCompleted()
                return Disposables.create()
            }
            
            print("🟢 Firestore에서 사용자 이름 fetch 시작: \(currentUser.uid)")
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
                    print("🔴 Firestore 사용자 문서 없음 - 기본값 사용")
                    observer.onNext("사용자")
                    observer.onCompleted()
                    return
                }
                
                print("🟢 Firestore에서 닉네임 로드 성공: \(name)")
                // 🟢 Firestore에서 가져온 닉네임을 로컬에도 백업 저장
                UserDefaults.standard.set(name, forKey: "userNickname")
                UserDefaults.standard.synchronize()
                
                observer.onNext(name)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
