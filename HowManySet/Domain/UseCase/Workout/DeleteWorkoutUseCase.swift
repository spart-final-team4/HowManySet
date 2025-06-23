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
    
    func excute(uid: String, item: Workout) {
        repository.deleteWorkout(uid: uid, workout: item)
    }
}
