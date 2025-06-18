//
//  WorkoutUseCase.swift
//  HowManySet
//
//  Created by GO on 6/18/25.
//

import Foundation

/// 운동 관련 비즈니스 로직을 처리하는 UseCase 클래스입니다.
///
/// Clean Architecture의 Domain Layer에서 애플리케이션의 핵심 비즈니스 규칙을 구현합니다.
/// Repository를 통해 데이터에 접근하고, 도메인 규칙을 적용하여 결과를 반환합니다.
final class WorkoutUseCase {
    
    /// 데이터 접근을 위한 Repository 인스턴스
    ///
    /// - Note: 의존성 주입을 통해 구체적인 구현체와 분리됩니다.
    private let repository: WorkoutRepository
    
    /// UseCase 초기화
    ///
    /// - Parameter repository: 데이터 접근을 위한 Repository 프로토콜 구현체
    /// - Note: 의존성 역전 원칙(DIP)을 적용하여 추상화에 의존합니다.
    init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    // MARK: - Routine Business Logic
    
    /// 새로운 운동 루틴을 생성합니다.
    ///
    /// - Parameters:
    ///   - routine: 생성할 운동 루틴
    ///   - userId: 루틴을 소유할 사용자 ID
    /// - Returns: 생성된 루틴의 고유 식별자
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    /// - Note: 비즈니스 규칙 검증 후 Repository를 통해 데이터를 저장합니다.
    func createRoutine(_ routine: WorkoutRoutine, userId: String) async throws -> String {
        // 비즈니스 규칙 검증
        try validateUserId(userId)
        try validateRoutine(routine)
        
        // 중복 루틴 이름 검증
        let existingRoutines = try await repository.fetchRoutines(for: userId)
        if existingRoutines.values.contains(where: { $0.name == routine.name }) {
            throw WorkoutUseCaseError.duplicateRoutineName
        }
        
        // Repository를 통한 데이터 저장
        return try await repository.createRoutine(routine, userId: userId)
    }
    
    /// 사용자의 모든 운동 루틴을 조회합니다.
    ///
    /// - Parameter userId: 루틴을 조회할 사용자 ID
    /// - Returns: 루틴 ID를 키로 하는 루틴 딕셔너리
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func loadRoutines(userId: String) async throws -> [String: WorkoutRoutine] {
        try validateUserId(userId)
        return try await repository.fetchRoutines(for: userId)
    }
    
    /// 기존 운동 루틴을 수정합니다.
    ///
    /// - Parameters:
    ///   - routine: 수정할 루틴 데이터
    ///   - routineId: 수정할 루틴의 ID
    ///   - userId: 루틴을 소유한 사용자 ID
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func updateRoutine(_ routine: WorkoutRoutine, routineId: String, userId: String) async throws {
        try validateUserId(userId)
        try validateRoutineId(routineId)
        try validateRoutine(routine)
        
        // 소유권 검증
        let existingRoutines = try await repository.fetchRoutines(for: userId)
        guard existingRoutines[routineId] != nil else {
            throw WorkoutUseCaseError.routineNotFound
        }
        
        try await repository.updateRoutine(routine, routineId: routineId, userId: userId)
    }
    
    /// 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - routineId: 삭제할 루틴의 ID
    ///   - userId: 루틴을 소유한 사용자 ID
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    /// - Warning: 관련된 기록과 세션도 함께 삭제될 수 있습니다.
    func deleteRoutine(routineId: String, userId: String) async throws {
        try validateUserId(userId)
        try validateRoutineId(routineId)
        
        // 소유권 검증
        let existingRoutines = try await repository.fetchRoutines(for: userId)
        guard existingRoutines[routineId] != nil else {
            throw WorkoutUseCaseError.routineNotFound
        }
        
        // 관련 기록 존재 여부 확인 (비즈니스 규칙)
        let records = try await repository.fetchRecords(for: userId)
        let hasRelatedRecords = records.contains { _, record in
            record.workoutRoutine.name == existingRoutines[routineId]?.name
        }
        
        if hasRelatedRecords {
            throw WorkoutUseCaseError.routineHasRelatedRecords
        }
        
        try await repository.deleteRoutine(routineId: routineId, userId: userId)
    }
    
    // MARK: - Record Business Logic
    
    /// 새로운 운동 기록을 생성합니다.
    ///
    /// - Parameters:
    ///   - record: 생성할 운동 기록
    ///   - userId: 기록을 소유할 사용자 ID
    ///   - routineId: 기록과 연관된 루틴 ID
    /// - Returns: 생성된 기록의 고유 식별자
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func createRecord(_ record: WorkoutRecord, userId: String, routineId: String) async throws -> String {
        try validateUserId(userId)
        try validateRoutineId(routineId)
        try validateRecord(record)
        
        // 루틴 존재 여부 확인
        let existingRoutines = try await repository.fetchRoutines(for: userId)
        guard existingRoutines[routineId] != nil else {
            throw WorkoutUseCaseError.routineNotFound
        }
        
        return try await repository.createRecord(record, userId: userId, routineId: routineId)
    }
    
    /// 사용자의 모든 운동 기록을 조회합니다.
    ///
    /// - Parameter userId: 기록을 조회할 사용자 ID
    /// - Returns: ID와 기록 객체의 튜플 배열
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func loadRecords(userId: String) async throws -> [(String, WorkoutRecord)] {
        try validateUserId(userId)
        return try await repository.fetchRecords(for: userId)
    }
    
    /// 특정 기간의 운동 기록을 조회합니다.
    ///
    /// - Parameters:
    ///   - userId: 기록을 조회할 사용자 ID
    ///   - startDate: 조회 시작 날짜
    ///   - endDate: 조회 종료 날짜
    /// - Returns: 해당 기간의 기록 배열
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func loadRecords(userId: String, from startDate: Date, to endDate: Date) async throws -> [(String, WorkoutRecord)] {
        try validateUserId(userId)
        try validateDateRange(startDate: startDate, endDate: endDate)
        
        let allRecords = try await repository.fetchRecords(for: userId)
        return allRecords.filter { _, record in
            record.date >= startDate && record.date <= endDate
        }
    }
    
    // MARK: - Session Business Logic
    
    /// 새로운 운동 세션을 생성합니다.
    ///
    /// - Parameters:
    ///   - session: 생성할 운동 세션
    ///   - userId: 세션을 소유할 사용자 ID
    ///   - recordId: 세션과 연관된 기록 ID
    /// - Returns: 생성된 세션의 고유 식별자
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func createSession(_ session: WorkoutSession, userId: String, recordId: String) async throws -> String {
        try validateUserId(userId)
        try validateRecordId(recordId)
        try validateSession(session)
        
        // 기록 존재 여부 확인
        let existingRecords = try await repository.fetchRecords(for: userId)
        guard existingRecords.contains(where: { $0.0 == recordId }) else {
            throw WorkoutUseCaseError.recordNotFound
        }
        
        return try await repository.createSession(session, userId: userId, recordId: recordId)
    }
    
    /// 사용자의 모든 운동 세션을 조회합니다.
    ///
    /// - Parameter userId: 세션을 조회할 사용자 ID
    /// - Returns: ID와 세션 객체의 튜플 배열
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func loadSessions(userId: String) async throws -> [(String, WorkoutSession)] {
        try validateUserId(userId)
        return try await repository.fetchSessions(for: userId)
    }
    
    // MARK: - Analytics Business Logic
    
    /// 사용자의 운동 통계를 계산합니다.
    ///
    /// - Parameter userId: 통계를 계산할 사용자 ID
    /// - Returns: 운동 통계 정보
    /// - Throws: 유효성 검증 실패 또는 Repository 에러
    func calculateWorkoutStatistics(userId: String) async throws -> WorkoutStatistics {
        try validateUserId(userId)
        
        let records = try await repository.fetchRecords(for: userId)
        let sessions = try await repository.fetchSessions(for: userId)
        
        return WorkoutStatistics(
            totalWorkouts: records.count,
            totalSessions: sessions.count,
            totalWorkoutTime: records.reduce(0) { $0 + $1.1.workoutTime },
            totalVolume: records.reduce(0) { $0 + $1.1.workoutRoutine.totalVolume },
            averageWorkoutDuration: records.isEmpty ? 0 : records.reduce(0) { $0 + $1.1.workoutTime } / records.count,
            mostUsedRoutine: findMostUsedRoutine(from: records)
        )
    }
    
    /// 가장 많이 사용된 루틴을 찾습니다.
    ///
    /// - Parameter records: 분석할 운동 기록 배열
    /// - Returns: 가장 많이 사용된 루틴 이름
    private func findMostUsedRoutine(from records: [(String, WorkoutRecord)]) -> String? {
        let routineNames = records.map { $0.1.workoutRoutine.name }
        let routineCounts = Dictionary(grouping: routineNames) { $0 }
            .mapValues { $0.count }
        
        return routineCounts.max { $0.value < $1.value }?.key
    }
}

// MARK: - Validation Methods
private extension WorkoutUseCase {
    
    /// 사용자 ID 유효성을 검증합니다.
    ///
    /// - Parameter userId: 검증할 사용자 ID
    /// - Throws: 유효하지 않은 경우 `WorkoutUseCaseError.invalidUserId`
    func validateUserId(_ userId: String) throws {
        guard !userId.isEmpty, userId.count >= 3 else {
            throw WorkoutUseCaseError.invalidUserId
        }
    }
    
    /// 루틴 ID 유효성을 검증합니다.
    ///
    /// - Parameter routineId: 검증할 루틴 ID
    /// - Throws: 유효하지 않은 경우 `WorkoutUseCaseError.invalidRoutineId`
    func validateRoutineId(_ routineId: String) throws {
        guard !routineId.isEmpty else {
            throw WorkoutUseCaseError.invalidRoutineId
        }
    }
    
    /// 기록 ID 유효성을 검증합니다.
    ///
    /// - Parameter recordId: 검증할 기록 ID
    /// - Throws: 유효하지 않은 경우 `WorkoutUseCaseError.invalidRecordId`
    func validateRecordId(_ recordId: String) throws {
        guard !recordId.isEmpty else {
            throw WorkoutUseCaseError.invalidRecordId
        }
    }
    
    /// 운동 루틴 유효성을 검증합니다.
    ///
    /// - Parameter routine: 검증할 운동 루틴
    /// - Throws: 유효하지 않은 경우 관련 에러
    func validateRoutine(_ routine: WorkoutRoutine) throws {
        guard routine.isValid else {
            throw WorkoutUseCaseError.invalidRoutineData
        }
        
        guard !routine.workouts.isEmpty else {
            throw WorkoutUseCaseError.emptyWorkoutList
        }
    }
    
    /// 운동 기록 유효성을 검증합니다.
    ///
    /// - Parameter record: 검증할 운동 기록
    /// - Throws: 유효하지 않은 경우 관련 에러
    func validateRecord(_ record: WorkoutRecord) throws {
        guard record.isValid else {
            throw WorkoutUseCaseError.invalidRecordData
        }
    }
    
    /// 운동 세션 유효성을 검증합니다.
    ///
    /// - Parameter session: 검증할 운동 세션
    /// - Throws: 유효하지 않은 경우 관련 에러
    func validateSession(_ session: WorkoutSession) throws {
        guard session.isValid else {
            throw WorkoutUseCaseError.invalidSessionData
        }
    }
    
    /// 날짜 범위 유효성을 검증합니다.
    ///
    /// - Parameters:
    ///   - startDate: 시작 날짜
    ///   - endDate: 종료 날짜
    /// - Throws: 유효하지 않은 경우 `WorkoutUseCaseError.invalidDateRange`
    func validateDateRange(startDate: Date, endDate: Date) throws {
        guard startDate <= endDate else {
            throw WorkoutUseCaseError.invalidDateRange
        }
    }
}

// MARK: - Domain Model Extensions
/// Entity 파일 수정 없이 필요한 검증 로직을 확장으로 추가합니다.
extension WorkoutRoutine {
    /// 루틴 데이터의 유효성을 검증합니다.
    var isValid: Bool {
        return !name.isEmpty && workouts.allSatisfy { $0.isValid }
    }
    
    /// 루틴의 총 볼륨을 계산합니다.
    var totalVolume: Double {
        return workouts.reduce(0) { $0 + $1.totalVolume }
    }
}

extension Workout {
    /// 운동 데이터의 유효성을 검증합니다.
    var isValid: Bool {
        return !name.isEmpty && sets.allSatisfy { $0.isValid }
    }
    
    /// 운동의 총 볼륨을 계산합니다.
    var totalVolume: Double {
        return sets.reduce(0) { $0 + $1.totalVolume }
    }
}

extension WorkoutSet {
    /// 세트 데이터의 유효성을 검증합니다.
    var isValid: Bool {
        return weight >= 0 && reps > 0 && !unit.isEmpty
    }
    
    /// 세트의 총 볼륨을 계산합니다.
    var totalVolume: Double {
        return weight * Double(reps)
    }
}

extension WorkoutRecord {
    /// 기록 데이터의 유효성을 검증합니다.
    var isValid: Bool {
        return totalTime >= 0 &&
               workoutTime >= 0 &&
               workoutTime <= totalTime &&
               workoutRoutine.isValid
    }
}

extension WorkoutSession {
    /// 세션 데이터의 유효성을 검증합니다.
    var isValid: Bool {
        return startDate < endDate && workoutRecord.isValid
    }
}
