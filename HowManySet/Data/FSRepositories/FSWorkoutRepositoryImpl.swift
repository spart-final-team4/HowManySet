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
            print("🔥 루틴 생성 성공: \(ref.documentID)")
            return ref.documentID
        } catch {
            print("🔥 루틴 생성 실패: \(error)")
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
            print("🔥 루틴 조회 시작: userId=\(userId)")
            let snapshot = try await db.collection("workoutRoutines")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            print("🔥 조회된 문서 수: \(snapshot.documents.count)")
            
            var result = [String: WorkoutRoutine]()
            for doc in snapshot.documents {
                do {
                    let dto = try doc.data(as: FSWorkoutRoutineDTO.self)
                    if let id = dto.id {
                        result[id] = dto.toDomain()
                        print("🔥 루틴 매핑 성공: \(dto.name) (ID: \(id))")
                    }
                } catch {
                    print("🔥 루틴 매핑 실패: \(error)")
                    continue
                }
            }
            
            print("🔥 루틴 조회 완료: \(result.count)개")
            return result
        } catch {
            print("🔥 루틴 조회 실패: \(error)")
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
        var dto = routine.toFSDTO(userId: userId)
        dto.id = routineId // ID 보장
        
        do {
            print("🔥 루틴 수정 시작: routineId=\(routineId)")
            try await db.collection("workoutRoutines").document(routineId).setData(from: dto, merge: true)
            print("🔥 루틴 수정 성공: \(routineId)")
        } catch {
            print("🔥 루틴 수정 실패: \(error)")
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
            print("🔥 루틴 삭제 시작: routineId=\(routineId)")
            try await db.collection("workoutRoutines").document(routineId).delete()
            print("🔥 루틴 삭제 성공: \(routineId)")
        } catch {
            print("🔥 루틴 삭제 실패: \(error)")
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
            print("🔥 기록 생성 시작: routineId=\(routineId)")
            try await ref.setData(from: dto)
            print("🔥 기록 생성 성공: \(ref.documentID)")
            return ref.documentID
        } catch {
            print("🔥 기록 생성 실패: \(error)")
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
            print("🔥 기록 조회 시작: userId=\(userId)")
            let snapshot = try await db.collection("workoutRecords")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()

            print("🔥 조회된 기록 문서 수: \(snapshot.documents.count)")

            let routines = try await fetchRoutines(for: userId)
            print("🔥 참조할 루틴 수: \(routines.count)")
            
            var result: [(String, WorkoutRecord)] = []
            
            for doc in snapshot.documents {
                do {
                    let dto = try doc.data(as: FSWorkoutRecordDTO.self)
                    guard let recordId = dto.id else {
                        print("🔥 기록 ID 누락: \(doc.documentID)")
                        continue
                    }
                    
                    // 루틴이 없어도 기록은 조회하되, 기본 루틴으로 대체
                    let routine = routines[dto.routineId] ?? WorkoutRoutine(
                        name: "삭제된 루틴 (\(dto.routineId))",
                        workouts: []
                    )
                    
                    let record = dto.toDomain(with: routine)
                    result.append((recordId, record))
                    print("🔥 기록 매핑 성공: \(recordId)")
                } catch {
                    print("🔥 기록 매핑 실패: \(error)")
                    continue
                }
            }
            
            print("🔥 기록 조회 완료: \(result.count)개")
            return result
        } catch {
            print("🔥 기록 조회 실패: \(error)")
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
            print("🔥 세션 생성 시작: recordId=\(recordId)")
            try await ref.setData(from: dto)
            print("🔥 세션 생성 성공: \(ref.documentID)")
            return ref.documentID
        } catch {
            print("🔥 세션 생성 실패: \(error)")
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
            print("🔥 세션 조회 시작: userId=\(userId)")
            let snapshot = try await db.collection("workoutSessions")
                .whereField("userId", isEqualTo: userId)
                .order(by: "startDate", descending: true)
                .getDocuments()

            print("🔥 조회된 세션 문서 수: \(snapshot.documents.count)")

            let records = try await fetchRecords(for: userId)
            print("🔥 참조할 기록 수: \(records.count)")
            
            // 기록을 딕셔너리로 변환하여 빠른 조회 가능
            let recordsDict = Dictionary(uniqueKeysWithValues: records)
            var result: [(String, WorkoutSession)] = []
            
            for doc in snapshot.documents {
                do {
                    let dto = try doc.data(as: FSWorkoutSessionDTO.self)
                    guard let sessionId = dto.id else {
                        print("🔥 세션 ID 누락: \(doc.documentID)")
                        continue
                    }
                    
                    // 기록이 없어도 세션은 조회하되, 기본 기록으로 대체
                    let record = recordsDict[dto.recordId] ?? WorkoutRecord(
                        workoutRoutine: WorkoutRoutine(name: "삭제된 루틴", workouts: []),
                        totalTime: 0,
                        workoutTime: 0,
                        comment: "삭제된 기록",
                        date: Date()
                    )
                    
                    let session = dto.toDomain(with: record)
                    result.append((sessionId, session))
                    print("🔥 세션 매핑 성공: \(sessionId)")
                } catch {
                    print("🔥 세션 매핑 실패: \(error)")
                    continue
                }
            }
            
            print("🔥 세션 조회 완료: \(result.count)개")
            return result
        } catch {
            print("🔥 세션 조회 실패: \(error)")
            throw WorkoutRepositoryError.databaseError
        }
    }
}
