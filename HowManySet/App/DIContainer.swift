//
//  DIContainer.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit
import FirebaseFirestore

/// 의존성 주입 컨테이너
/// - 출시 수준의 완전한 DI 구현
final class DIContainer {
    
    /// 온보딩 화면을 생성하여 반환 (닉네임 입력 + 온보딩 통합)
    func makeOnBoardingViewController(coordinator: OnBoardingCoordinatorProtocol) -> UIViewController {
        let reactor = OnBoardingViewReactor()
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
    
    /// 홈 화면을 생성하여 반환
    func makeHomeViewController(coordinator: HomeCoordinator) -> (UIViewController, HomeViewReactor) {
        let recordRepository = RecordRepositoryImpl()
        let routineRepository = RoutineRepositoryImpl()
        let workoutRepository = WorkoutRepositoryImpl()
        
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
//        let deleteRecordUseCase = DeleteRecordUseCase(repository: recordRepository)
        let fetchRoutineUseCase = FetchRoutineUseCase(repository: routineRepository)
        let updateWorkoutUseCase = UpdateWorkoutUseCase(repository: workoutRepository)
        
        // Firestore 로직 추가
        let firestoreService: FirestoreServiceProtocol = FirestoreService()
        
        let fsRecordRepository = FSRecordRepositoryImpl(firestoreService: firestoreService)
        let fsSaveRecordUseCase = FSSaveRecordUseCase(repository: fsRecordRepository)
//        let fsDeleteRecordUseCase = FSDeleteRecordUseCase(repository: fsRecordRepository)
        
        let fsRoutineRepository = FSRoutineRepositoryImpl(firestoreService: firestoreService)
        let fsFetchRoutineUseCase = FSFetchRoutineUseCase(repository: fsRoutineRepository)
        let fsUpdateRoutineUseCase = FSUpdateRoutineUseCase(repository: routineRepository)
        
//        let restoredState = loadCurrentWorkoutState()
        let initialState = HomeViewReactor.defaultInitialState()
        
        let reactor = HomeViewReactor(
            saveRecordUseCase: saveRecordUseCase,
            fsSaveRecordUseCase: fsSaveRecordUseCase,
            fetchRoutineUseCase: fetchRoutineUseCase,
            fsFetchRoutineUseCase: fsFetchRoutineUseCase,
            updateWorkoutUseCase: updateWorkoutUseCase,
            fsUpdateRoutineUseCase: fsUpdateRoutineUseCase,
            initialState: initialState
        )
        
        return (HomeViewController(reactor: reactor, coordinator: coordinator), reactor)
    }
    
    /// 루틴 리스트 화면을 생성하여 반환
    func makeRoutineListViewController(coordinator: RoutineListCoordinator) -> UIViewController {
        let routineRepository = RoutineRepositoryImpl()
        
        let deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository)
        let fetchRoutineUseCase = FetchRoutineUseCase(repository: routineRepository)
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        
        // Firestore 로직 추가
        let firestoreService: FirestoreServiceProtocol = FirestoreService()
        let fsRoutineRepository = FSRoutineRepositoryImpl(firestoreService: firestoreService)
        let fsFetchRoutineUseCase = FSFetchRoutineUseCase(repository: fsRoutineRepository)
        let fsSaveRoutineUseCase = FSSaveRoutineUseCase(repository: fsRoutineRepository)
        let fsDeleteRoutineUseCase = FSDeleteRoutineUseCase(repository: fsRoutineRepository)
        
        let reactor = RoutineListViewReactor(
            deleteRoutineUseCase: deleteRoutineUseCase,
            fetchRoutineUseCase: fetchRoutineUseCase,
            saveRoutineUseCase: saveRoutineUseCase
        )
        
        return RoutineListViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 캘린더 화면을 생성하여 반환
    func makeCalendarViewController(coordinator: CalendarCoordinator) -> UIViewController {
        let recordRepository = RecordRepositoryImpl()
        
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
        let fetchRecordUseCase = FetchRecordUseCase(repository: recordRepository)

        // Firestore 로직 추가
        let firestoreService: FirestoreServiceProtocol = FirestoreService()
        let fsRecordRepository = FSRecordRepositoryImpl(firestoreService: firestoreService)
        let fsSaveRecordUseCase = FSSaveRecordUseCase(repository: fsRecordRepository)
        let fsFetchRecordUseCase = FSFetchRecordUseCase(repository: fsRecordRepository)

        let reactor = CalendarViewReactor(
            saveRecordUseCase: saveRecordUseCase,
            fetchRecordUseCase: fetchRecordUseCase
        )
        
        return CalendarViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 마이페이지 화면을 생성하여 반환
    func makeMyPageViewController(coordinator: MyPageCoordinator) -> UIViewController {
        let userSettingRepository = UserSettingRepositoryImpl()
        let fetchUserSettingUseCase = FetchUserSettingUseCase(repository: userSettingRepository)
        let saveUserSettingUseCase = SaveUserSettingUseCase(repository: userSettingRepository)
        
        let firestoreService: FirestoreServiceProtocol = FirestoreService()
        let fsUserSettingRespository = FSUserSettingRepositoryImpl(
            firestoreService: firestoreService
        )
        
        let fsFetchUserSettingUseCase = FSFetchUserSettingUseCase(
            repository: fsUserSettingRespository
        )
        let fsSaveUserSettingUseCase = FSSaveUserSettingUseCase(
            repository: fsUserSettingRespository
        )
        
        let firebaseAuthService = FirebaseAuthService()
        let authRepository = AuthRepositoryImpl(firebaseAuthService: firebaseAuthService)
        let authUseCase = AuthUseCase(repository: authRepository)
        
        let reactor = MyPageViewReactor(
            fetchUserSettingUseCase: fetchUserSettingUseCase,
            saveUserSettingUseCase: saveUserSettingUseCase,
            authUseCase: authUseCase
        )
        
        return MyPageViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 루틴 완료 화면을 생성하여 반환
    func makeRoutineCompleteViewController(coordinator: RoutineCompleteCoordinator, workoutSummary: WorkoutSummary, homeViewReactor: HomeViewReactor) -> UIViewController {
        
        return RoutineCompleteViewController(coordinator: coordinator, workoutSummary: workoutSummary, homeViewReactor: homeViewReactor)
    }
}
