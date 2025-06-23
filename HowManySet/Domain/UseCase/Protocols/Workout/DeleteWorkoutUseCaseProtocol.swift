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
