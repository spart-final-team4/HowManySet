//
//  UpdateWorkoutUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

final class UpdateWorkoutUseCase: UpdateWorkoutUseCaseProtocol {
    
    private let repository: WorkoutRepository
    
    init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    func execute(uid: String, item: Workout) {
        repository.updateWorkout(uid: uid, workout: item)
    }
}
