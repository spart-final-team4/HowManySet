//
//  WorkoutRepository.swift
//  HowManySet
//
//  Created by GO on 6/18/25.
//

import Foundation

/// 운동 관련 데이터의 저장, 조회, 수정, 삭제 기능을 정의하는 Repository 프로토콜입니다.
///
/// Clean Architecture의 Domain Layer에서 데이터 접근 계층의 인터페이스를 정의합니다.
/// 구체적인 구현체(Realm, Firestore 등)와 독립적으로 비즈니스 로직을 작성할 수 있습니다.
protocol WorkoutRepository {
    
    // MARK: - Routine Operations
    
    /// 새로운 운동 루틴을 생성합니다.
    ///
    /// - Parameters:
    ///   - routine: 생성할 운동 루틴 도메인 모델
    ///   - userId: 루틴을 소유할 사용자 식별자
    /// - Returns: 생성된 루틴의 고유 식별자
    /// - Throws: 생성 실패 시 관련 에러
    /// - Note: 비동기 처리를 위해 async/await 패턴을 사용합니다.
    func createRoutine(_ routine: WorkoutRoutine, userId: String) async throws -> String
    
    /// 특정 사용자의 모든 운동 루틴을 조회합니다.
    ///
    /// - Parameter userId: 루틴을 조회할 사용자 식별자
    /// - Returns: 루틴 ID를 키로, 루틴 객체를 값으로 하는 딕셔너리
    /// - Throws: 조회 실패 시 관련 에러
    /// - Note: 딕셔너리 형태로 반환하여 ID 기반 빠른 접근을 지원합니다.
    func fetchRoutines(for userId: String) async throws -> [String: WorkoutRoutine]
    
    /// 기존 운동 루틴을 수정합니다.
    ///
    /// - Parameters:
    ///   - routine: 수정할 운동 루틴 도메인 모델
    ///   - routineId: 수정할 루틴의 고유 식별자
    ///   - userId: 루틴을 소유한 사용자 식별자
    /// - Throws: 수정 실패 시 관련 에러
    /// - Important: 루틴 ID와 사용자 ID가 모두 일치해야 수정이 가능합니다.
    func updateRoutine(_ routine: WorkoutRoutine, routineId: String, userId: String) async throws
    
    /// 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - routineId: 삭제할 루틴의 고유 식별자
    ///   - userId: 루틴을 소유한 사용자 식별자
    /// - Throws: 삭제 실패 시 관련 에러
    /// - Warning: 삭제된 루틴은 복구할 수 없으므로 신중하게 사용해야 합니다.
    func deleteRoutine(routineId: String, userId: String) async throws

    // MARK: - Record Operations
    
    /// 새로운 운동 기록을 생성합니다.
    ///
    /// - Parameters:
    ///   - record: 생성할 운동 기록 도메인 모델
    ///   - userId: 기록을 소유할 사용자 식별자
    ///   - routineId: 기록과 연관된 루틴의 식별자
    /// - Returns: 생성된 기록의 고유 식별자
    /// - Throws: 생성 실패 시 관련 에러
    /// - Note: 루틴 ID를 통해 기록과 루틴 간의 관계를 설정합니다.
    func createRecord(_ record: WorkoutRecord, userId: String, routineId: String) async throws -> String
    
    /// 특정 사용자의 모든 운동 기록을 조회합니다.
    ///
    /// - Parameter userId: 기록을 조회할 사용자 식별자
    /// - Returns: ID와 기록 객체의 튜플 배열
    /// - Throws: 조회 실패 시 관련 에러
    /// - Note: 최신 기록부터 내림차순으로 정렬되어 반환됩니다.
    func fetchRecords(for userId: String) async throws -> [(String, WorkoutRecord)]

    // MARK: - Session Operations
    
    /// 새로운 운동 세션을 생성합니다.
    ///
    /// - Parameters:
    ///   - session: 생성할 운동 세션 도메인 모델
    ///   - userId: 세션을 소유할 사용자 식별자
    ///   - recordId: 세션과 연관된 기록의 식별자
    /// - Returns: 생성된 세션의 고유 식별자
    /// - Throws: 생성 실패 시 관련 에러
    /// - Note: 기록 ID를 통해 세션과 기록 간의 관계를 설정합니다.
    func createSession(_ session: WorkoutSession, userId: String, recordId: String) async throws -> String
    
    /// 특정 사용자의 모든 운동 세션을 조회합니다.
    ///
    /// - Parameter userId: 세션을 조회할 사용자 식별자
    /// - Returns: ID와 세션 객체의 튜플 배열
    /// - Throws: 조회 실패 시 관련 에러
    /// - Note: 최신 세션부터 내림차순으로 정렬되어 반환됩니다.
    func fetchSessions(for userId: String) async throws -> [(String, WorkoutSession)]
}

// MARK: - Repository Error Types
/// Repository 계층에서 발생할 수 있는 에러 타입을 정의합니다.
///
/// - Note: 구체적인 에러 타입을 통해 상위 계층에서 적절한 에러 처리가 가능합니다.
enum WorkoutRepositoryError: Error, LocalizedError {
    
    /// 데이터를 찾을 수 없는 경우
    case dataNotFound
    
    /// 잘못된 사용자 ID
    case invalidUserId
    
    /// 잘못된 루틴 ID
    case invalidRoutineId
    
    /// 잘못된 기록 ID
    case invalidRecordId
    
    /// 권한 없음 (다른 사용자의 데이터 접근 시도)
    case unauthorized
    
    /// 네트워크 연결 오류
    case networkError
    
    /// 데이터베이스 오류
    case databaseError
    
    /// 사용자에게 표시할 에러 메시지
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "요청한 데이터를 찾을 수 없습니다."
        case .invalidUserId:
            return "유효하지 않은 사용자 ID입니다."
        case .invalidRoutineId:
            return "유효하지 않은 루틴 ID입니다."
        case .invalidRecordId:
            return "유효하지 않은 기록 ID입니다."
        case .unauthorized:
            return "접근 권한이 없습니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .databaseError:
            return "데이터베이스 오류가 발생했습니다."
        }
    }
}
