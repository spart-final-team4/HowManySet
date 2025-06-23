//
//  DeleteWorkoutUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

protocol DeleteWorkoutUseCaseProtocol {
    func execute(uid: String, item: Workout)
}

extension DeleteWorkoutUseCaseProtocol {
    func execute(item: Workout) {
        execute(uid: "", item: item)
    }
}
