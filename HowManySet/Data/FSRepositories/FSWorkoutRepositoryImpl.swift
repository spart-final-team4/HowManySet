//
//  FSWorkoutRepositoryImpl.swift
//  HowManySet
//
//  Created by GO on 6/18/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore를 사용한 WorkoutRepository의 구현체입니다.
///
/// Clean Architecture의 Infrastructure Layer에서 실제 데이터 저장소와의 상호작용을 담당합니다.
/// Firestore의 async/await API를 활용하여 비동기 데이터 처리를 수행합니다.
final class FSWorkoutRepositoryImpl: WorkoutRepository {
    
    /// Firestore 데이터베이스 인스턴스
    private let db = Firestore.firestore()

    // MARK: - Routine Operations

    /// 새로운 운동 루틴을 Firestore에 생성합니다.
    ///
    /// - Parameters:
    ///   - routine: 생성할 운동 루틴 도메인 모델
    ///   - userId: 루틴을 소유할 사용자 식별자
    /// - Returns: 생성된 루틴의 Firestore 문서 ID
    /// - Throws: Firestore 저장 실패 시 관련 에러
    func createRoutine(_ routine: WorkoutRoutine, userId: String) async throws -> String {
        var dto = routine.toFSDTO(userId: userId)
        let ref = db.collection("workoutRoutines").document()
        dto.id = ref.documentID
        
        do {
            try await ref.setData(from: dto)
            return ref.documentID
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    /// 특정 사용자의 모든 운동 루틴을 Firestore에서 조회합니다.
    ///
    /// - Parameter userId: 루틴을 조회할 사용자 식별자
    /// - Returns: 루틴 ID를 키로 하는 루틴 딕셔너리
    /// - Throws: Firestore 조회 실패 시 관련 에러
    func fetchRoutines(for userId: String) async throws -> [String: WorkoutRoutine] {
        do {
            let snapshot = try await db.collection("workoutRoutines")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            var result = [String: WorkoutRoutine]()
            for doc in snapshot.documents {
                let dto = try doc.data(as: FSWorkoutRoutineDTO.self)
                if let id = dto.id {
                    result[id] = dto.toDomain()
                }
            }
            return result
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    /// 기존 운동 루틴을 Firestore에서 수정합니다.
    ///
    /// - Parameters:
    ///   - routine: 수정할 운동 루틴 도메인 모델
    ///   - routineId: 수정할 루틴의 고유 식별자
    ///   - userId: 루틴을 소유한 사용자 식별자
    /// - Throws: Firestore 수정 실패 시 관련 에러
    func updateRoutine(_ routine: WorkoutRoutine, routineId: String, userId: String) async throws {
        let dto = routine.toFSDTO(userId: userId)
        
        do {
            try await db.collection("workoutRoutines").document(routineId).setData(from: dto, merge: true)
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    /// 운동 루틴을 Firestore에서 삭제합니다.
    ///
    /// - Parameters:
    ///   - routineId: 삭제할 루틴의 고유 식별자
    ///   - userId: 루틴을 소유한 사용자 식별자
    /// - Throws: Firestore 삭제 실패 시 관련 에러
    func deleteRoutine(routineId: String, userId: String) async throws {
        do {
            try await db.collection("workoutRoutines").document(routineId).delete()
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    // MARK: - Record Operations

    /// 새로운 운동 기록을 Firestore에 생성합니다.
    ///
    /// - Parameters:
    ///   - record: 생성할 운동 기록 도메인 모델
    ///   - userId: 기록을 소유할 사용자 식별자
    ///   - routineId: 기록과 연관된 루틴의 식별자
    /// - Returns: 생성된 기록의 Firestore 문서 ID
    /// - Throws: Firestore 저장 실패 시 관련 에러
    func createRecord(_ record: WorkoutRecord, userId: String, routineId: String) async throws -> String {
        var dto = record.toFSDTO(userId: userId, routineId: routineId)
        let ref = db.collection("workoutRecords").document()
        dto.id = ref.documentID
        
        do {
            try await ref.setData(from: dto)
            return ref.documentID
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    /// 특정 사용자의 모든 운동 기록을 Firestore에서 조회합니다.
    ///
    /// - Parameter userId: 기록을 조회할 사용자 식별자
    /// - Returns: ID와 기록 객체의 튜플 배열
    /// - Throws: Firestore 조회 실패 시 관련 에러
    func fetchRecords(for userId: String) async throws -> [(String, WorkoutRecord)] {
        do {
            let snapshot = try await db.collection("workoutRecords")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()

            let routines = try await fetchRoutines(for: userId)
            var result: [(String, WorkoutRecord)] = []
            
            for doc in snapshot.documents {
                let dto = try doc.data(as: FSWorkoutRecordDTO.self)
                guard let recordId = dto.id,
                      let routine = routines[dto.routineId] else { continue }
                
                let record = dto.toDomain(with: routine)
                result.append((recordId, record))
            }
            
            return result
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    // MARK: - Session Operations

    /// 새로운 운동 세션을 Firestore에 생성합니다.
    ///
    /// - Parameters:
    ///   - session: 생성할 운동 세션 도메인 모델
    ///   - userId: 세션을 소유할 사용자 식별자
    ///   - recordId: 세션과 연관된 기록의 식별자
    /// - Returns: 생성된 세션의 Firestore 문서 ID
    /// - Throws: Firestore 저장 실패 시 관련 에러
    func createSession(_ session: WorkoutSession, userId: String, recordId: String) async throws -> String {
        var dto = session.toFSDTO(userId: userId, recordId: recordId)
        let ref = db.collection("workoutSessions").document()
        dto.id = ref.documentID
        
        do {
            try await ref.setData(from: dto)
            return ref.documentID
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }

    /// 특정 사용자의 모든 운동 세션을 Firestore에서 조회합니다.
    ///
    /// - Parameter userId: 세션을 조회할 사용자 식별자
    /// - Returns: ID와 세션 객체의 튜플 배열
    /// - Throws: Firestore 조회 실패 시 관련 에러
    func fetchSessions(for userId: String) async throws -> [(String, WorkoutSession)] {
        do {
            let snapshot = try await db.collection("workoutSessions")
                .whereField("userId", isEqualTo: userId)
                .order(by: "startDate", descending: true)
                .getDocuments()

            let records = try await fetchRecords(for: userId)
            let recordsDict = Dictionary(uniqueKeysWithValues: records)
            var result: [(String, WorkoutSession)] = []
            
            for doc in snapshot.documents {
                let dto = try doc.data(as: FSWorkoutSessionDTO.self)
                guard let sessionId = dto.id,
                      let record = recordsDict[dto.recordId] else { continue }
                
                let session = dto.toDomain(with: record)
                result.append((sessionId, session))
            }
            
            return result
        } catch {
            throw WorkoutRepositoryError.databaseError
        }
    }
}
