//
//  AppleWatchSyncViewReactor.swift
//  HowManySet
//
//  Created by 정근호 on 12/8/25.
//

import Foundation
import ReactorKit
import RxSwift
import FirebaseAuth

final class AppleWatchSyncViewReactor: Reactor {
    
    enum Action {
        case syncButtonTapped
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setSyncStatus(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var syncStatus: String = "버튼을 눌러 동기화를 시작하세요."
    }
    
    let initialState: State = State()
    
    private let fetchRoutineUseCase: FetchRoutineUseCase
    private let watchConnector: WatchConnector
    
    init(fetchRoutineUseCase: FetchRoutineUseCase, watchConnector: WatchConnector) {
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.watchConnector = watchConnector
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .syncButtonTapped:
            let startLoading: Observable<Mutation> = .just(.setLoading(true))
            let setSyncingStatus: Observable<Mutation> = .just(.setSyncStatus("루틴 목록을 가져오는 중..."))
            let stopLoading: Observable<Mutation> = .just(.setLoading(false))
            
            let syncProcess = fetchRoutineUseCase.execute(uid: Auth.auth().currentUser?.uid)
                .asObservable()
                .observe(on: MainScheduler.instance)
                .flatMapLatest { [weak self] routines -> Observable<Mutation> in
                    guard let self = self else { return .empty() }
                    self.watchConnector.sendRoutinesToWatch(routines)
                    return .just(.setSyncStatus("\(routines.count)개의 루틴을 Watch로 보냈습니다."))
                }
                .catch { error in
                    return .just(.setSyncStatus("오류 발생: \(error.localizedDescription)"))
                }
            
            return .concat([startLoading, setSyncingStatus, syncProcess, stopLoading])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setSyncStatus(let status):
            newState.syncStatus = status
        }
        return newState
    }
}
