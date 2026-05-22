//
//  MembershipViewReactor.swift
//  HowManySet
//
//  Created by MJ on 12/2/25.
//

import Foundation
import ReactorKit
import RxSwift

final class MembershipViewReactor: Reactor {
    
    private let fetchRecordUseCase: FetchRecordUseCaseProtocol
    private let saveRecordUseCase: SaveRecordUseCaseProtocol
    private let deleteRecordUseCase: DeleteRecordUseCaseProtocol
    private let fetchRoutineUseCase: FetchRoutineUseCaseProtocol
    private let saveRoutineUseCase: SaveRoutineUseCaseProtocol
    private let deleteRoutineUseCase: DeleteRoutineUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    
    let initialState: State
    
    enum Action {
        case dismiss
        case signUpWithKakao
        case signUpWithGoogle
    }

    enum Mutation {
        case dismissView(Bool)
        case setLoading(Bool)
    }

    struct State {
        var dismiss: Bool = false
        var isLoading: Bool = false
    }
    
    init(fetchRecordUseCase: FetchRecordUseCaseProtocol,
         deleteRecordUseCase: DeleteRecordUseCaseProtocol,
         saveRecordUseCase: SaveRecordUseCaseProtocol,
         fetchRoutineUseCase: FetchRoutineUseCaseProtocol,
         deleteRoutineUseCase: DeleteRoutineUseCaseProtocol,
         saveRoutineUseCase: SaveRoutineUseCaseProtocol,
         authUseCase: AuthUseCaseProtocol
    ) {
        self.fetchRecordUseCase = fetchRecordUseCase
        self.deleteRecordUseCase = deleteRecordUseCase
        self.saveRecordUseCase = saveRecordUseCase
        self.fetchRoutineUseCase = fetchRoutineUseCase
        self.deleteRoutineUseCase = deleteRoutineUseCase
        self.saveRoutineUseCase = saveRoutineUseCase
        self.authUseCase = authUseCase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .dismiss:
            return .just(.dismissView(true))

        case .signUpWithKakao:
            return Observable.concat([
                .just(.setLoading(true)),
                authUseCase.loginWithKakao()
                    .do(onNext: { [weak self] user in
                        guard let uid = user.uid else { return }
                        self?.migration(uid: uid)
                    })
                    .map { _ in Mutation.dismissView(true) }
                    .catch { _ in .just(.setLoading(false)) },
                .just(.setLoading(false))
            ])

        case .signUpWithGoogle:
            return Observable.concat([
                .just(.setLoading(true)),
                authUseCase.loginWithGoogle()
                    .do(onNext: { [weak self] user in
                        guard let uid = user.uid else { return }
                        self?.migration(uid: uid)
                    })
                    .map { _ in Mutation.dismissView(true) }
                    .catch { _ in .just(.setLoading(false)) },
                .just(.setLoading(false))
            ])
            
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .dismissView(let value):
            newState.dismiss = value
        case .setLoading(let value):
            newState.isLoading = value
        }
        return newState
    }
    
}

extension MembershipViewReactor {
    func migration(uid: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                print("⎯⎯⎯⎯⎯⎯⎯⎯⎯Migration START⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯/")
                let localRoutines = try await fetchRoutineUseCase.execute(uid: nil).value
                let localRecords = try await fetchRecordUseCase.execute(uid: nil).value

                DataModelDebugger().printAllRoutines(localRoutines)
                DataModelDebugger().printRecords(localRecords)

                // MARK: - Step 1. Realm 데이터를 Firebase에 저장 (완료 후 Step 2 진행)
                for routine in localRoutines {
                    try await saveRoutineUseCase.executeAsync(uid: uid, item: routine)
                }
                for record in localRecords {
                    try await saveRecordUseCase.executeAsync(uid: uid, item: record)
                }

                // MARK: - Step 2. Realm 로컬 데이터 삭제 (Step 1 완료 보장 후 실행)
                localRoutines.forEach { deleteRoutineUseCase.execute(uid: nil, item: $0) }
                localRecords.forEach { deleteRecordUseCase.execute(uid: nil, item: $0) }

                print("⎯⎯⎯⎯⎯⎯⎯⎯⎯Migration DONE⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯/")
                print("루틴 \(localRoutines.count)개, 기록 \(localRecords.count)개 마이그레이션 완료")

            } catch {
                // Firestore 저장 실패 시 Realm 삭제를 진행하지 않음
                print("Migration FAILED: \(error.localizedDescription)")
            }
        }
    }
}


