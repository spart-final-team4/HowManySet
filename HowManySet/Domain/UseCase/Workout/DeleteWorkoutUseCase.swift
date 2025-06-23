//
//  DeleteWorkoutUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

final class DeleteWorkoutUseCase: DeleteWorkoutUseCaseProtocol {
    
    private let repository: WorkoutRepository
    
    init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    func execute(item: Workout) {
        repository.deleteWorkout(workout: item)
    }
}
