//
//  DataModelDebugger.swift
//  HowManySet
//
//  Created by MJ on 12/3/25.
//

import Foundation

/// WorkoutRecord, WorkoutRoutine을 보기좋게 Print해주는 구조체
struct DataModelDebugger {
    
    func printRecord(_ record: WorkoutRecord, _ depth: Int = 0) {
        let hSpace = String(repeating: "\t", count: depth)
        print("\(hSpace)기록 날짜: \(record.date)")
        print("\(hSpace)기록 ID: (rmID: \(record.rmID)) (documentID: \(record.documentID)) (uuid: \(record.uuid))")
        print("\(hSpace)기록내 저장된 총 소요시간 / 운동 시간: \(record.totalTime) / \(record.workoutTime)")
        print("\(hSpace)기록에 저장된 메모: \(record.comment)")
        print("\(hSpace)기록의 운동 정보: ")
        printRoutine(record.workoutRoutine, depth + 1)
        
    }
    
    func printRoutine(_ routine: WorkoutRoutine, _ depth: Int = 0) {
        let hSpace = String(repeating: "\t", count: depth)
        print("\(hSpace)루틴명: \(routine.name)")
        print("\(hSpace)루틴 ID (rmID:\(routine.rmID)), (documentID: \(routine.documentID))")
        print("\(hSpace)루틴내 운동 리스트 (\(routine.workouts.count))")
        routine.workouts.forEach { workout in
            printWorkout(workout, depth + 1)
        }
    }
    
    func printWorkout(_ workout: Workout, _ depth: Int = 0) {
        let hSpace = String(repeating: "\t", count: depth)
        print("\(hSpace)- 운동이름: \(workout.name)")
        print("\(hSpace)- 운동ID (rmID: \(workout.id)), (documentID:\(workout.documentID))")
        workout.sets.forEach { set in
            printSets(set, depth + 1)
        }
    }
    
    func printSets(_ set: WorkoutSet, _ depth: Int = 0) {
        let hSpace = String(repeating: "\t", count: depth)
        print("\(hSpace)- 세트 단위 / 무게 / 횟수: \(set.unit) / \(set.weight) / \(set.reps)")
    }
    
    func printAllRoutines(_ model: [WorkoutRoutine], _ startDepth: Int = 0) {
        model.forEach { routine in
            print("⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼")
            printRoutine(routine, startDepth)
            routine.workouts.forEach { workout in
                printWorkout(workout, startDepth + 1)
                workout.sets.forEach { set in
                    printSets(set, startDepth + 2)
                }
            }
        }
    }
    
    func printRecords(_ model: [WorkoutRecord], _ startDepth: Int = 0) {
        model.forEach { record in
            print("⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼⎼")
            printRecord(record, startDepth)
        }
    }
}
