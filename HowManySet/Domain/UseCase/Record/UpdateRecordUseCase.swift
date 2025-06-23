//
//  UpdateRecordUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

final class UpdateRecordUseCase: UpdateRecordUseCaseProtocol {
    private let repository: RecordRepository
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func execute(uid: String, item: WorkoutRecord) {
        repository.updateRecord(uid: uid, item: item)
    }
}
