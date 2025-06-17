//
//  FSWorkoutMapper.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation

// MARK: - WorkoutSet Mapper

/// FSWorkoutSetDTO를 Domain의 WorkoutSet으로 변환합니다.
/// - Returns: 변환된 WorkoutSet 도메인 객체
/// - 사용 예시:
///   ```
///   let fsSetDTO = FSWorkoutSetDTO(weight: 70.0, unit: "kg", reps: 10)
///   let domainSet = fsSetDTO.toDomain()
///   ```
extension FSWorkoutSetDTO {
    func toDomain() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}

/// Domain의 WorkoutSet을 FSWorkoutSetDTO로 변환합니다.
/// - Returns: Firestore 저장용 FSWorkoutSetDTO 객체
/// - 사용 예시:
///   ```
///   let domainSet = WorkoutSet(weight: 70.0, unit: "kg", reps: 10)
///   let fsSetDTO = domainSet.toFSDTO()
///   ```
extension WorkoutSet {
    func toFSDTO() -> FSWorkoutSetDTO {
        return FSWorkoutSetDTO(weight: self.weight,
                               unit: self.unit,
                               reps: self.reps)
    }
}

// MARK: - Workout Mapper

/// FSWorkoutDTO를 Domain의 Workout으로 변환합니다.
/// - Returns: 변환된 Workout 도메인 객체 (세트 목록 포함)
/// - 사용 예시:
///   ```
///   let fsWorkoutDTO = FSWorkoutDTO(name: "벤치프레스", sets: [...], comment: "폼 집중")
///   let domainWorkout = fsWorkoutDTO.toDomain()
///   ```
extension FSWorkoutDTO {
    func toDomain() -> Workout {
        return Workout(name: self.name,
                       sets: self.sets.map { $0.toDomain() },
                       comment: self.comment)
    }
}

/// Domain의 Workout을 FSWorkoutDTO로 변환합니다.
/// - Returns: Firestore 저장용 FSWorkoutDTO 객체 (세트 목록 포함)
/// - 사용 예시:
///   ```
///   let domainWorkout = Workout(name: "벤치프레스", sets: [...], comment: "폼 집중")
///   let fsWorkoutDTO = domainWorkout.toFSDTO()
///   ```
extension Workout {
    func toFSDTO() -> FSWorkoutDTO {
        return FSWorkoutDTO(name: self.name,
                            sets: self.sets.map { $0.toFSDTO() },
                            comment: self.comment)
    }
}

// MARK: - WorkoutRoutine Mapper

/// FSWorkoutRoutineDTO를 Domain의 WorkoutRoutine으로 변환합니다.
/// - Returns: 변환된 WorkoutRoutine 도메인 객체 (운동 목록 포함)
/// - Note: userId, id 등 Firestore 관련 정보는 제외됩니다.
/// - 사용 예시:
///   ```
///   let fsRoutineDTO = FSWorkoutRoutineDTO(id: "123", userId: "user1", name: "전신 루틴", workouts: [...])
///   let domainRoutine = fsRoutineDTO.toDomain()
///   ```
extension FSWorkoutRoutineDTO {
    func toDomain() -> WorkoutRoutine {
        return WorkoutRoutine(name: self.name,
                              workouts: self.workouts.map { $0.toDomain() })
    }
}

/// Domain의 WorkoutRoutine을 FSWorkoutRoutineDTO로 변환합니다.
/// - Parameter userId: Firestore에 저장할 사용자 ID
/// - Returns: Firestore 저장용 FSWorkoutRoutineDTO 객체 (id는 nil로 설정)
/// - 사용 예시:
///   ```
///   let domainRoutine = WorkoutRoutine(name: "전신 루틴", workouts: [...])
///   let fsRoutineDTO = domainRoutine.toFSDTO(userId: "user123")
///   ```
extension WorkoutRoutine {
    func toFSDTO(userId: String) -> FSWorkoutRoutineDTO {
        return FSWorkoutRoutineDTO(id: nil,
                                   userId: userId,
                                   name: self.name,
                                   workouts: self.workouts.map { $0.toFSDTO() })
    }
}

// MARK: - WorkoutRecord Mapper

/// FSWorkoutRecordDTO를 Domain의 WorkoutRecord로 변환합니다.
/// - Parameter routine: 연관된 WorkoutRoutine 도메인 객체
/// - Returns: 변환된 WorkoutRecord 도메인 객체
/// - Note: routineId 대신 실제 WorkoutRoutine 객체를 받아 완전한 도메인 객체를 생성합니다.
/// - 사용 예시:
///   ```
///   let fsRecordDTO = FSWorkoutRecordDTO(id: "rec1", userId: "user1", routineId: "routine1", ...)
///   let routine = WorkoutRoutine(name: "전신 루틴", workouts: [...])
///   let domainRecord = fsRecordDTO.toDomain(with: routine)
///   ```
extension FSWorkoutRecordDTO {
    func toDomain(with routine: WorkoutRoutine) -> WorkoutRecord {
        return WorkoutRecord(workoutRoutine: routine,
                             totalTime: self.totalTime,
                             workoutTime: self.workoutTime,
                             comment: self.comment,
                             date: self.date)
    }
}

/// Domain의 WorkoutRecord를 FSWorkoutRecordDTO로 변환합니다.
/// - Parameters:
///   - userId: Firestore에 저장할 사용자 ID
///   - routineId: 연관된 루틴의 Firestore 문서 ID
/// - Returns: Firestore 저장용 FSWorkoutRecordDTO 객체 (id는 nil로 설정)
/// - 사용 예시:
///   ```
///   let domainRecord = WorkoutRecord(workoutRoutine: routine, totalTime: 3600, ...)
///   let fsRecordDTO = domainRecord.toFSDTO(userId: "user123", routineId: "routine456")
///   ```
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

// MARK: - WorkoutSession Mapper

/// FSWorkoutSessionDTO를 Domain의 WorkoutSession으로 변환합니다.
/// - Parameter record: 연관된 WorkoutRecord 도메인 객체
/// - Returns: 변환된 WorkoutSession 도메인 객체
/// - Note: recordId 대신 실제 WorkoutRecord 객체를 받아 완전한 도메인 객체를 생성합니다.
/// - 사용 예시:
///   ```
///   let fsSessionDTO = FSWorkoutSessionDTO(id: "session1", userId: "user1", recordId: "record1", ...)
///   let record = WorkoutRecord(workoutRoutine: routine, totalTime: 3600, ...)
///   let domainSession = fsSessionDTO.toDomain(with: record)
///   ```
extension FSWorkoutSessionDTO {
    func toDomain(with record: WorkoutRecord) -> WorkoutSession {
        return WorkoutSession(workoutRecord: record,
                              startDate: self.startDate,
                              endDate: self.endDate)
    }
}

/// Domain의 WorkoutSession을 FSWorkoutSessionDTO로 변환합니다.
/// - Parameters:
///   - userId: Firestore에 저장할 사용자 ID
///   - recordId: 연관된 기록의 Firestore 문서 ID
/// - Returns: Firestore 저장용 FSWorkoutSessionDTO 객체 (id는 nil로 설정)
/// - 사용 예시:
///   ```
///   let domainSession = WorkoutSession(workoutRecord: record, startDate: Date(), endDate: Date())
///   let fsSessionDTO = domainSession.toFSDTO(userId: "user123", recordId: "record456")
///   ```
extension WorkoutSession {
    func toFSDTO(userId: String, recordId: String) -> FSWorkoutSessionDTO {
        return FSWorkoutSessionDTO(id: nil,
                                   userId: userId,
                                   recordId: recordId,
                                   startDate: self.startDate,
                                   endDate: self.endDate)
    }
}
