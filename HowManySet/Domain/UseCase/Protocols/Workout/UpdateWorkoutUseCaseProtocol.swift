//
//  UpdateWorkoutUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

protocol UpdateWorkoutUseCaseProtocol {
    func execute(uid: String, item: Workout)
}

extension UpdateWorkoutUseCaseProtocol {
    func execute(item: Workout) {
        execute(uid: "", item: item)
    }
}
