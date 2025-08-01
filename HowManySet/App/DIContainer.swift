//
//  DIContainer.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit
import FirebaseFirestore

/// 의존성 주입 컨테이너
final class DIContainer {
    
    /// 온보딩 화면을 생성하여 반환 (닉네임 입력 + 온보딩 통합)
    func makeOnBoardingViewController(coordinator: OnBoardingCoordinatorProtocol) -> UIViewController {
        let firebaseAuthService = FirebaseAuthService()
        let repository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: repository)
        let reactor = OnBoardingViewReactor(authUseCase: authUseCase, coordinator: coordinator)
        return OnBoardingViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 인증 화면을 생성하여 반환
    func makeAuthViewController(coordinator: AuthCoordinatorProtocol) -> UIViewController {
        let firebaseAuthService = FirebaseAuthService()
        let repository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let useCase = AuthUseCase(repository: repository)
        let reactor = AuthViewReactor(useCase: useCase, coordinator: coordinator)
        return AuthViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 루틴 리스트 화면을 생성하여 반환
    func makeRoutineListViewController(coordinator: RoutineListCoordinator, caller: ViewCaller) -> UIViewController {
        let firestoreService = FirestoreService()
        let realmService = RealmService()
        let routineRepository = RoutineRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        
        let deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository)
        let fetchRoutineUseCase = FetchRoutineUseCase(repository: routineRepository)
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        
        let reactor = RoutineListViewReactor(
            deleteRoutineUseCase: deleteRoutineUseCase,
            fetchRoutineUseCase: fetchRoutineUseCase,
            saveRoutineUseCase: saveRoutineUseCase
        )
        
        return RoutineListViewController(reactor: reactor, coordinator: coordinator, caller: caller)
    }
    
    /// 캘린더 화면을 생성하여 반환
    func makeCalendarViewController(coordinator: CalendarCoordinator) -> UIViewController {
        let firestoreService = FirestoreService()
        let realmService = RealmService()
        let recordRepository = RecordRepositoryImpl(firestoreService: firestoreService,
                                                    realmService: realmService)
        
        let deleteRecordUseCase = DeleteRecordUseCase(repository: recordRepository)
        let fetchRecordUseCase = FetchRecordUseCase(repository: recordRepository)

        let reactor = CalendarViewReactor(
            deleteRecordUseCase: deleteRecordUseCase,
            fetchRecordUseCase: fetchRecordUseCase
        )
        
        return CalendarViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 마이페이지 화면을 생성하여 반환
    func makeMyPageViewController(coordinator: MyPageCoordinator) -> UIViewController {
        let firestoreService: FirestoreServiceProtocol = FirestoreService()
        
        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        let reactor = MyPageViewReactor(authUseCase: authUseCase)
        
        return MyPageViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 루틴 완료 화면을 생성하여 반환
    func makeRoutineCompleteViewController(coordinator: RoutineCompleteCoordinator, workoutSummary: WorkoutSummary, homeViewReactor: HomeViewReactor) -> UIViewController {
        
        return RoutineCompleteViewController(coordinator: coordinator, workoutSummary: workoutSummary, homeViewReactor: homeViewReactor)
    }
    
    /// 운동 편집 뷰를 생성하여 반환
    func makeEditRoutineViewController(coordinator: EditRoutineCoordinator, with routine: WorkoutRoutine, caller: ViewCaller) -> UIViewController {
        let firestoreService = FirestoreService()
        let realmService = RealmService()
        let routineRepository = RoutineRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let workoutRepository = WorkoutRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        let deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository)
        let updateRoutineUseCase = UpdateRoutineUseCase(repository: routineRepository)
        let deleteWorkoutUseCase = DeleteWorkoutUseCase(repository: workoutRepository)
        let fetchRoutineUseCase = FetchRoutineUseCase(repository: routineRepository)
        let editRoutineViewReactor = EditRoutineViewReactor(
            with: routine,
            saveRoutineUseCase: saveRoutineUseCase,
            fetchRoutineUseCase: fetchRoutineUseCase,
            deleteRoutineUseCase: deleteRoutineUseCase,
            updateRoutineUseCase: updateRoutineUseCase,
            deleteWorkoutUseCase: deleteWorkoutUseCase
        )
        
        return EditRoutineViewController(reactor: editRoutineViewReactor, coordinator: coordinator, caller: caller)
    }
    
    /// 홈 화면을 운동중 상태와 루틴 편집 뷰에서 받아온 WorkoutRoutine으로 reactor intialState를 변경 후 생성하여 반환
    func makeHomeViewControllerWithWorkoutStarted(
        coordinator: HomeCoordinator,
        routine: WorkoutRoutine)
    -> (UIViewController, HomeViewReactor) {
        let firestoreService = FirestoreService()
        let realmService = RealmService()
        let recordRepository = RecordRepositoryImpl(firestoreService: firestoreService,
                                                    realmService: realmService)
        let routineRepository = RoutineRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let workoutRepository = WorkoutRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
        let fetchRoutineUseCase = FetchRoutineUseCase(repository: routineRepository)
        let updateWorkoutUseCase = UpdateWorkoutUseCase(repository: workoutRepository)
        let updateRecordUseCase = UpdateRecordUseCase(repository: recordRepository)
        
        let initialState = HomeViewReactor.fetchedInitialState(routine: routine)
        
        let reactor = HomeViewReactor(
            saveRecordUseCase: saveRecordUseCase,
            fetchRoutineUseCase: fetchRoutineUseCase,
            updateWorkoutUseCase: updateWorkoutUseCase,
            updateRecordUseCase: updateRecordUseCase,
            initialState: initialState
        )
        
        return (HomeViewController(reactor: reactor, coordinator: coordinator), reactor)
    }
    
    /// 홈 시작 화면(운동 전) VC 생성하여 반환
    func makeHomeStartViewController(coordinator: HomeCoordinator) -> UIViewController {
        return HomeStartViewController(coordinator: coordinator)
    }
}
