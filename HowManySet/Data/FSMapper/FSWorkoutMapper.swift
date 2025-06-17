//
//  FSWorkoutMapper.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation

// MARK: - WorkoutSet Mapper
extension FSWorkoutSetDTO {
    func toDomain() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}

extension WorkoutSet {
    func toFSDTO() -> FSWorkoutSetDTO {
        return FSWorkoutSetDTO(weight: self.weight,
                               unit: self.unit,
                               reps: self.reps)
    }
}

// MARK: - Workout Mapper
extension FSWorkoutDTO {
    func toDomain() -> Workout {
        return Workout(name: self.name,
                       sets: self.sets.map { $0.toDomain() },
                       comment: self.comment)
    }
}

extension Workout {
    func toFSDTO() -> FSWorkoutDTO {
        return FSWorkoutDTO(name: self.name,
                            sets: self.sets.map { $0.toFSDTO() },
                            comment: self.comment)
    }
}

// MARK: - WorkoutRoutine Mapper
extension FSWorkoutRoutineDTO {
    func toDomain() -> WorkoutRoutine {
        return WorkoutRoutine(name: self.name,
                              workouts: self.workouts.map { $0.toDomain() })
    }
}

extension WorkoutRoutine {
    func toFSDTO(userId: String) -> FSWorkoutRoutineDTO {
        return FSWorkoutRoutineDTO(id: nil,
                                   userId: userId,
                                   name: self.name,
                                   workouts: self.workouts.map { $0.toFSDTO() })
    }
}

// MARK: - WorkoutRecord Mapper
extension FSWorkoutRecordDTO {
    func toDomain(with routine: WorkoutRoutine) -> WorkoutRecord {
        return WorkoutRecord(workoutRoutine: routine,
                             totalTime: self.totalTime,
                             workoutTime: self.workoutTime,
                             comment: self.comment,
                             date: self.date)
    }
}

extension WorkoutRecord {
    func toFSDTO(userId: String, routineId: String) -> FSWorkoutRecordDTO {
        return FSWorkoutRecordDTO(id: nil,
                                  userId: userId,
                                  routineId: routineId,
                                  totalTime: self.totalTime,
                                  workoutTime: self.workoutTime,
                                  comment: self.comment,
                                  date: self.date)
    }
}
