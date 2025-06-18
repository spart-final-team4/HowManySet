//
//  FSUseCaseError.swift
//  HowManySet
//
//  Created by GO on 6/18/25.
//

import Foundation

/// 운동 UseCase에서 발생할 수 있는 비즈니스 로직 에러를 정의합니다.
///
/// Clean Architecture의 Domain Layer에서 UseCase 실행 중 발생하는
/// 비즈니스 규칙 위반이나 데이터 유효성 검증 실패 등을 나타냅니다.
enum WorkoutUseCaseError: Error {
    
    // MARK: - Validation Errors
    
    /// 유효하지 않은 사용자 ID
    case invalidUserId
    
    /// 유효하지 않은 루틴 ID
    case invalidRoutineId
    
    /// 유효하지 않은 기록 ID
    case invalidRecordId
    
    /// 유효하지 않은 루틴 데이터
    case invalidRoutineData
    
    /// 유효하지 않은 기록 데이터
    case invalidRecordData
    
    /// 유효하지 않은 세션 데이터
    case invalidSessionData
    
    // MARK: - Business Logic Errors
    
    /// 중복된 루틴 이름
    case duplicateRoutineName
    
    /// 빈 운동 목록
    case emptyWorkoutList
    
    /// 루틴을 찾을 수 없음
    case routineNotFound
    
    /// 기록을 찾을 수 없음
    case recordNotFound
    
    /// 세션을 찾을 수 없음
    case sessionNotFound
    
    /// 관련 기록이 있는 루틴 (삭제 불가)
    case routineHasRelatedRecords
    
    /// 유효하지 않은 날짜 범위
    case invalidDateRange
    
    // MARK: - Permission Errors
    
    /// 권한 없음 (다른 사용자의 데이터 접근)
    case unauthorized
    
    /// 접근 거부됨
    case accessDenied
}

// MARK: - LocalizedError Extension
extension WorkoutUseCaseError: LocalizedError {
    
    /// 사용자에게 표시할 에러 메시지를 제공합니다.
    ///
    /// - Returns: 각 에러 케이스에 맞는 한국어 에러 메시지
    var errorDescription: String? {
        switch self {
        // Validation Errors
        case .invalidUserId:
            return "유효하지 않은 사용자 ID입니다."
        case .invalidRoutineId:
            return "유효하지 않은 루틴 ID입니다."
        case .invalidRecordId:
            return "유효하지 않은 기록 ID입니다."
        case .invalidRoutineData:
            return "루틴 데이터가 올바르지 않습니다."
        case .invalidRecordData:
            return "기록 데이터가 올바르지 않습니다."
        case .invalidSessionData:
            return "세션 데이터가 올바르지 않습니다."
            
        // Business Logic Errors
        case .duplicateRoutineName:
            return "이미 존재하는 루틴 이름입니다."
        case .emptyWorkoutList:
            return "루틴에는 최소 하나 이상의 운동이 포함되어야 합니다."
        case .routineNotFound:
            return "요청한 루틴을 찾을 수 없습니다."
        case .recordNotFound:
            return "요청한 기록을 찾을 수 없습니다."
        case .sessionNotFound:
            return "요청한 세션을 찾을 수 없습니다."
        case .routineHasRelatedRecords:
            return "관련된 운동 기록이 있어 루틴을 삭제할 수 없습니다."
        case .invalidDateRange:
            return "유효하지 않은 날짜 범위입니다."
            
        // Permission Errors
        case .unauthorized:
            return "접근 권한이 없습니다."
        case .accessDenied:
            return "접근이 거부되었습니다."
        }
    }
    
    /// 에러 발생 이유에 대한 상세 설명을 제공합니다.
    ///
    /// - Returns: 개발자나 디버깅용 상세 에러 설명
    var failureReason: String? {
        switch self {
        case .invalidUserId:
            return "사용자 ID가 비어있거나 3자 미만입니다."
        case .duplicateRoutineName:
            return "동일한 이름의 루틴이 이미 존재합니다."
        case .routineHasRelatedRecords:
            return "삭제하려는 루틴과 연관된 운동 기록이 존재합니다."
        case .invalidDateRange:
            return "시작 날짜가 종료 날짜보다 늦습니다."
        default:
            return nil
        }
    }
    
    /// 에러 해결을 위한 제안사항을 제공합니다.
    ///
    /// - Returns: 사용자가 문제를 해결할 수 있는 방법 제안
    var recoverySuggestion: String? {
        switch self {
        case .invalidUserId:
            return "올바른 사용자 ID를 입력해주세요."
        case .duplicateRoutineName:
            return "다른 이름으로 루틴을 생성해주세요."
        case .emptyWorkoutList:
            return "루틴에 운동을 추가한 후 다시 시도해주세요."
        case .routineHasRelatedRecords:
            return "관련된 기록을 먼저 삭제한 후 루틴을 삭제해주세요."
        case .invalidDateRange:
            return "올바른 날짜 범위를 선택해주세요."
        default:
            return "잠시 후 다시 시도해주세요."
        }
    }
}

