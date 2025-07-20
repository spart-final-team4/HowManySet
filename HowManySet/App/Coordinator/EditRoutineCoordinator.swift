//
//  EditRoutineCoordinator.swift
//  HowManySet
//
//  Created by 정근호 on 6/25/25.
//

import UIKit
import RxSwift

protocol EditRoutineCoordinatorProtocol: Coordinator {
    func navigateToHomeViewWithWorkoutStarted(updateRoutine: WorkoutRoutine)
    func presentAddExerciseView(routine: WorkoutRoutine, resultHandler: @escaping (Bool) -> Void)
    func presentEditExerciseView(workout: Workout, resultHandler: @escaping (Bool) -> Void)
}


final class EditRoutineCoordinator: EditRoutineCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let container: DIContainer
    private let routine: WorkoutRoutine
    private let homeCoordinator: HomeCoordinator

    init(navigationController: UINavigationController, container: DIContainer, routine: WorkoutRoutine, homeCoordinator: HomeCoordinator) {
        self.navigationController = navigationController
        self.container = container
        self.routine = routine
        self.homeCoordinator = homeCoordinator
    }
    
    func start() {
        let editRoutineVC = container.makeEditRoutineViewController(coordinator: self, with: routine, caller: .fromTabBar)
        navigationController.pushViewController(editRoutineVC, animated: true)
    }
    
    func startModal() {
        let editRoutineVC = container.makeEditRoutineViewController(coordinator: self, with: routine, caller: .fromHome)
        
        if let sheet = editRoutineVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(editRoutineVC, animated: true)
    }

    /// AddExercise를 present하는 메서드
    func presentAddExerciseView(routine: WorkoutRoutine,
                                resultHandler: @escaping (Bool) -> Void
    ) {
        let firestoreService = FirestoreService()
        let realmService = RealmService()
        let workoutRepository = WorkoutRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let routineRepository = RoutineRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let updateWorkoutUseCase = UpdateWorkoutUseCase(repository: workoutRepository)
        let updateRoutineUseCase = UpdateRoutineUseCase(repository: routineRepository)

        let vc = EditExerciseViewController(
            reactor: EditExerciseViewReactor(
                routine: routine,
                updateWorkoutUseCase: updateWorkoutUseCase,
                updateRoutineUseCase: updateRoutineUseCase
            )
        )
        vc.saveResultRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                resultHandler(result)
            })
            .disposed(by: vc.disposeBag)
        
        navigationController.present(vc, animated: true)
    }

    /// EditExercise를 present하는 메서드
    func presentEditExerciseView(workout: Workout, resultHandler: @escaping (Bool) -> Void) {
        let firestoreService = FirestoreService()
        let realmService = RealmService()
        let workoutRepository = WorkoutRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let routineRepository = RoutineRepositoryImpl(firestoreService: firestoreService,
                                                      realmService: realmService)
        let updateWorkoutUseCase = UpdateWorkoutUseCase(repository: workoutRepository)
        let updateRoutineUseCase = UpdateRoutineUseCase(repository: routineRepository)

        let vc = EditExerciseViewController(
            reactor: EditExerciseViewReactor(
                workout: workout,
                updateWorkoutUseCase: updateWorkoutUseCase,
                updateRoutineUseCase: updateRoutineUseCase
            )
        )

        // 화면 전환 + 결과 전달은 coordinator에서 처리
        vc.saveResultRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                resultHandler(result)
            })
            .disposed(by: vc.disposeBag)

        navigationController.present(vc, animated: true)
    }

    /// 메인 홈 화면 운동중 상태로 이동
    func navigateToHomeViewWithWorkoutStarted(updateRoutine: WorkoutRoutine) {
        homeCoordinator.startWorkout(with: updateRoutine)
    }
    
    func moveToEditExcercise(with excercise: Workout) {
        
    }
    
}
