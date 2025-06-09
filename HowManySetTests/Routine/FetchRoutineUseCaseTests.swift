//
//  FetchRoutineUseCaseTests.swift
//  HowManySetTests
//
//  Created by MJ Dev on 6/2/25.
//

import XCTest
@testable import HowManySet
@testable import RxSwift

final class FetchRoutineUseCaseTests: XCTestCase {
    
    var repository: RoutineRepository!
    var usecase: FetchRoutineUseCase!
    var disposeBag: DisposeBag!
    let realmServiceStub = RealmServiceStub()
    
    override func setUpWithError() throws {
        repository = RoutineRepositoryImpl(realmService: realmServiceStub)
        usecase = FetchRoutineUseCase(repository: repository)
        disposeBag = DisposeBag()
    }
    
    func test_저장된루틴이_정상적으로불러와지는가() {
        // given
        let routine = WorkoutRoutine(name: "test", workouts: [])
        realmServiceStub.create(item: WorkoutRoutineDTO(entity: routine))
        
        // when
        let routines = realmServiceStub.read(type: .workoutRoutine)
        
        // then
        XCTAssertTrue(!routines!.isEmpty)
    }
    
    override func tearDownWithError() throws {
        repository = nil
        usecase = nil
        realmServiceStub.deleteAll()
    }
}
