//
//  FirestoreService.swift
//  HowManySet
//
//  Created by GO on 6/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Firestore 데이터 모델

/// Firestore에 저장되는 운동 세트 모델
struct FSWorkoutSet: Codable {
    let weight: Double         /// 세트의 무게
    let unit: String           /// 무게 단위 (예: "kg", "lb")
    let reps: Int              /// 반복 횟수
}

/// Firestore에 저장되는 운동 모델
struct FSWorkout: Codable {
    let name: String           /// 운동 이름
    let restTime: Int          /// 세트 간 휴식 시간(초)
    let comment: String?       /// 운동에 대한 메모 (옵션)
    let sets: [FSWorkoutSet]   /// 세트 배열
}

/// Firestore에 저장되는 운동 루틴 모델
struct FSWorkoutRoutine: Codable, Identifiable {
    @DocumentID var id: String?    /// Firestore 문서 ID
    let userId: String             /// 사용자 UID(외래키)
    var name: String               /// 루틴 이름
    let workouts: [FSWorkout]      /// 운동 목록
}

/// Firestore에 저장되는 운동 기록 모델
struct FSWorkoutRecord: Codable, Identifiable {
    @DocumentID var id: String?    /// Firestore 문서 ID
    let userId: String             /// 사용자 UID(외래키)
    let routineId: String          /// 연관된 루틴 문서 ID
    let totalTime: Int             /// 전체 운동 시간(초)
    let workoutTime: Int           /// 실제 운동 시간(초)
    let comment: String?           /// 메모 (옵션)
    let date: Date                 /// 운동 날짜
}

/// Firestore에 저장되는 운동 세션 모델
struct FSWorkoutSession: Codable, Identifiable {
    @DocumentID var id: String?    /// Firestore 문서 ID
    let userId: String             /// 사용자 UID(외래키)
    let recordId: String           /// 연관된 기록 문서 ID
    let startDate: Date            /// 세션 시작 시각
    let endDate: Date              /// 세션 종료 시각
}

// MARK: - FirestoreService (싱글톤)

/// FirestoreService
/// ---
/// Firestore에 운동 루틴, 기록, 세션을 저장/조회하는 싱글톤 서비스 클래스입니다.
///
/// - 사용자별 데이터 분리 저장 (userId 필수)
/// - Swift async/await 기반 비동기 API
/// - 타입 안전한 Codable 기반 직렬화/역직렬화
/// - 루틴, 기록, 세션 CRUD 제공
///
/// ### 사용 예시
/// ```
/// let routines = try await FirestoreService.shared.fetchRoutines(for: uid)
/// ```
final class FirestoreService {
    /// 싱글톤 인스턴스
    static let shared = FirestoreService()
    /// Firestore 데이터베이스 참조
    private let db = Firestore.firestore()
    /// 외부 인스턴스 생성을 막기 위한 private init
    private init() {}
    
    // MARK: - 루틴
    
    /// 운동 루틴 생성
    /// - Parameter routine: 저장할 FSWorkoutRoutine 객체 (id는 자동 할당)
    func createRoutine(_ routine: FSWorkoutRoutine) async throws {
        let ref = db.collection("routines").document()
        var newRoutine = routine
        newRoutine.id = ref.documentID
        try ref.setData(from: newRoutine)
    }
    
    /// 특정 사용자의 운동 루틴 목록 조회
    /// - Parameter uid: 사용자 UID
    /// - Returns: FSWorkoutRoutine 배열
    func fetchRoutines(for uid: String) async throws -> [FSWorkoutRoutine] {
        let snapshot = try await db.collection("routines")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSWorkoutRoutine.self) }
    }
    
    // MARK: - 운동 기록
    
    /// 운동 기록 생성
    /// - Parameter record: 저장할 FSWorkoutRecord 객체 (id는 자동 할당)
    func createRecord(_ record: FSWorkoutRecord) async throws {
        let ref = db.collection("records").document()
        var newRecord = record
        newRecord.id = ref.documentID
        try ref.setData(from: newRecord)
    }
    
    /// 특정 사용자의 운동 기록 목록 조회
    /// - Parameter uid: 사용자 UID
    /// - Returns: FSWorkoutRecord 배열
    func fetchRecords(for uid: String) async throws -> [FSWorkoutRecord] {
        let snapshot = try await db.collection("records")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSWorkoutRecord.self) }
    }
    
    // MARK: - 운동 세션
    
    /// 운동 세션 생성 (Create)
    /// - Parameter session: 저장할 FSWorkoutSession 객체 (id는 자동 할당)
    func createSession(_ session: FSWorkoutSession) async throws {
        let ref = db.collection("sessions").document()
        var newSession = session
        newSession.id = ref.documentID
        try ref.setData(from: newSession)
    }
    
    /// 특정 사용자의 운동 세션 목록 조회 (Read)
    /// - Parameter uid: 사용자 UID
    /// - Returns: FSWorkoutSession 배열
    func fetchSessions(for uid: String) async throws -> [FSWorkoutSession] {
        let snapshot = try await db.collection("sessions")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSWorkoutSession.self) }
    }
    
    /// 루틴 수정 (Update)
    /// 루틴 수정: 해당 문서의 userId가 내 uid와 일치할 때만 수정
    func updateRoutine(_ routine: FSWorkoutRoutine) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ [Update] 로그인된 사용자가 없습니다.")
            throw NSError(domain: "NoAuth", code: 401)
        }
        guard let routineId = routine.id else {
            print("❌ [Update] 루틴 ID가 없습니다.")
            throw NSError(domain: "NoRoutineId", code: 400)
        }
        let ref = db.collection("routines").document(routineId)
        let snapshot = try await ref.getDocument()
        
        guard let data = snapshot.data() else {
            print("❌ [Update] 문서 데이터가 없습니다.")
            throw NSError(domain: "권한 없음 또는 문서 없음", code: 403)
        }
        guard let docUserId = data["userId"] as? String else {
            print("❌ [Update] 문서에 userId 필드가 없습니다. data: \(data)")
            throw NSError(domain: "권한 없음 또는 문서 없음", code: 403)
        }
        print("현재 로그인 uid: \(uid)")
        print("문서의 userId: \(docUserId)")
        guard docUserId == uid else {
            print("❌ [Update] uid 불일치! (권한 없음)")
            throw NSError(domain: "권한 없음 또는 문서 없음", code: 403)
        }
        try ref.setData(from: routine, merge: true)
        print("✅ [Update] 루틴 수정 성공")
    }
    
    /// 루틴 삭제 (Delete)
    /// 루틴 삭제: 해당 문서의 userId가 내 uid와 일치할 때만 삭제
    func deleteRoutine(routineId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ [Delete] 로그인된 사용자가 없습니다.")
            throw NSError(domain: "NoAuth", code: 401)
        }
        let ref = db.collection("routines").document(routineId)
        let snapshot = try await ref.getDocument()
        
        guard let data = snapshot.data() else {
            print("❌ [Delete] 문서 데이터가 없습니다.")
            throw NSError(domain: "권한 없음 또는 문서 없음", code: 403)
        }
        guard let docUserId = data["userId"] as? String else {
            print("❌ [Delete] 문서에 userId 필드가 없습니다. data: \(data)")
            throw NSError(domain: "권한 없음 또는 문서 없음", code: 403)
        }
        print("현재 로그인 uid: \(uid)")
        print("문서의 userId: \(docUserId)")
        guard docUserId == uid else {
            print("❌ [Delete] uid 불일치! (권한 없음)")
            throw NSError(domain: "권한 없음 또는 문서 없음", code: 403)
        }
        try await ref.delete()
        print("✅ [Delete] 루틴 삭제 성공")
    }
}
