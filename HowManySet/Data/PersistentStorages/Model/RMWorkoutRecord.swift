//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

/// RoutineText 형식
/// "\(self.rmID)&\(self.documentID)&\(self.name)&\(workoutName)%\(exercise.weight)%\(exercise.reps)%\(exercise.unit)%$""
///
final class RMWorkoutRecord: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var routineRecordText: String
    @Persisted var totalTime: Int
    @Persisted var workoutTime: Int
    @Persisted var comment: String?
    @Persisted var date: Date

    convenience init(
        routineRecordText: String,
        totalTime: Int,
        workoutTime: Int,
        comment: String? = nil,
        date: Date
    ) {
        self.init()
        self.routineRecordText = routineRecordText
        self.totalTime = totalTime
        self.workoutTime = workoutTime
        self.comment = comment
        self.date = date
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RMWorkoutRecord {
    func toDTO() -> WorkoutRecordDTO {
        return WorkoutRecordDTO(
            rmID: self.id,
            documentID: "",
            workoutRoutine: RMWorkoutRecord.fromRoutineText(self.routineRecordText),
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.date
        )
    }
}

extension RMWorkoutRecord {
    convenience init(dto: WorkoutRecordDTO) {
        self.init()
        self.id = dto.rmID
        self.routineRecordText = WorkoutRoutineDTO.toRoutineText(dto.workoutRoutine ?? WorkoutRoutineDTO.mockData())
        self.totalTime = dto.totalTime
        self.workoutTime = dto.workoutTime
        self.comment = dto.comment
        self.date = dto.date
    }
}
extension RMWorkoutRecord {
    static func fromRoutineText(_ text: String) -> WorkoutRoutineDTO? {
        let sections = text.components(separatedBy: "&")
        guard sections.count >= 4 else { return nil }

        let routineID = sections[0]
        let documentID = sections[1]
        let routineName = sections[2]
        let workoutsText = sections[3]

        var workouts: [WorkoutDTO] = []

        // 여러 workout은 $로 구분
        let workoutChunks = workoutsText.components(separatedBy: "$").filter { !$0.isEmpty }

        for workoutChunk in workoutChunks {
            // workout의 헤더(3개) + 세트들(% 구분)
            let parts = workoutChunk.components(separatedBy: "%").filter { !$0.isEmpty }

            guard parts.count >= 3 else { continue }

            let workoutID = parts[0]
            let workoutName = parts[1]
            let workoutComment = parts[2].isEmpty ? nil : parts[2]

            var sets: [WorkoutSetDTO] = []

            // 이후는 weight, reps, unit 순서 반복
            let setParts = Array(parts.dropFirst(3))
            var i = 0
            while i + 2 < setParts.count {
                guard let weight = Double(setParts[i]),
                      let reps = Int(setParts[i + 1]) else {
                    break
                }
                let unit = setParts[i + 2]
                sets.append(WorkoutSetDTO(weight: weight, unit: unit, reps: reps))
                i += 3
            }

            let workout = WorkoutDTO(id: workoutID, name: workoutName, comment: workoutComment, sets: sets)
            workouts.append(workout)
        }

        return WorkoutRoutineDTO(rmID: routineID, documentID: documentID, name: routineName, workouts: workouts)
    }
}
