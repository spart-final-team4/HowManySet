//
//  DIContainer.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class DIContainer {

    func makeOnBoardingViewController(coordinator: OnBoardingCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = OnBoardingViewReactor()
        
        return OnBoardingViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeAuthViewController(coordinator: AuthCoordinator) -> UIViewController {
//        let repository
//        let useCase
        let reactor = AuthViewReactor()
        
        return AuthViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeHomeViewController(coordinator: HomeCoordinator) -> UIViewController {
        let recordRepository = RecordRepositoryImpl()
        
        let saveRecordUseCase = SaveRecordUseCase(repository: recordRepository)
        
        let reactor = HomeViewReactor(
            saveRecordUseCase: saveRecordUseCase
        )
        
        return HomeViewController(reactor: reactor, coordinator: coordinator)
    }
    
    func makeRoutineListViewController(coordinator: RoutineListCoordinator) -> UIViewController {

        let routineRepository = RoutineRepositoryImpl()
        
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
    
    func makeCalendarViewController(coordinator: CalendarCoordinator) -> UIViewController {
        
        let recordRepository = RecordRepositoryImpl()
        
        let fetchRecordUseCase = FetchRecordUseCase(repository: recordRepository)
//        let useCase
//        let reactor = CalendarViewReactor()
        
        return CalendarViewController()
    }
    
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
}
