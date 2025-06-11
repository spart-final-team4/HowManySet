//
//  DIContainer.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class DIContainer {

    /// 온보딩 화면을 생성하여 반환
    func makeOnBoardingViewController(coordinator: OnBoardingCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = OnBoardingViewReactor()
        
        return OnBoardingViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 인증 화면을 생성하여 반환
    func makeAuthViewController(coordinator: AuthCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = AuthViewReactor()
        
        return AuthViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 홈 화면을 생성하여 반환
    func makeHomeViewController(coordinator: HomeCoordinator) -> UIViewController {
        let realmService: RealmServiceProtocol = RealmService()
        let recordRepository = RecordRepositoryImpl(realmService: realmService)
        
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
        
        let reactor = HomeViewReactor(
            saveRecordUseCase: saveRecordUseCase
        )
        
        return HomeViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 루틴 리스트 화면을 생성하여 반환
    func makeRoutineListViewController(coordinator: RoutineListCoordinator) -> UIViewController {
        let realmService: RealmServiceProtocol = RealmService()
        let routineRepository = RoutineRepositoryImpl(realmService: realmService)
        
        let deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository)
        let fetchRoutineUseCase = FetchRoutineUseCase(repository: routineRepository)
        let saveRoutineUseCase = SaveRoutineUseCase(repository: routineRepository)
        
        let reactor = RoutineListViewReactor(
            deleteRoutineUseCase: deleteRoutineUseCase,
            fetchRoutineUseCase: fetchRoutineUseCase,
            saveRoutineUseCase: saveRoutineUseCase
        )
        
        return RoutineListViewController(reactor: reactor, coordinator: coordinator)
    }

    /// 캘린더 화면을 생성하여 반환
    func makeCalendarViewController(coordinator: CalendarCoordinator) -> UIViewController {
        let realmService: RealmServiceProtocol = RealmService()
        let recordRepository = RecordRepositoryImpl(realmService: realmService)
        
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
        let fetchRecordUseCase = FetchRecordUseCase(repository: recordRepository)

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
        
        let reactor = MyPageViewReactor(
            fetchUserSettingUseCase: fetchUserSettingUseCase,
            saveUserSettingUseCase: saveUserSettingUseCase
        )
        
        return MyPageViewController(reactor: reactor, coordinator: coordinator)
    }
    
    /// 루틴 완료 화면을 생성하여 반환
    func makeRoutineCompleteViewController(coordinator: RoutineCompleteCoordinator) -> UIViewController {
        
        let realmService: RealmServiceProtocol = RealmService()
        let recordRepository = RecordRepositoryImpl(realmService: realmService)
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)

        let reactor = RoutineCompleteViewReactor(saveRecordUseCase: saveRecordUseCase)
        
        return RoutineCompleteViewController(reactor: reactor, coordinator: coordinator)
    }
}
