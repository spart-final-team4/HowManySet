//
//  UpdateRecordUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

protocol UpdateRecordUseCaseProtocol {
    func execute(uid: String, item: WorkoutRecord)
}

extension UpdateRecordUseCaseProtocol {
    func execute(item: WorkoutRecord) {
        execute(uid: "", item: item)
    }
}
