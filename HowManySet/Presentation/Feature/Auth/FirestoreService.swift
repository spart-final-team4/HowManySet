//
//  FirestoreService.swift
//  HowManySet
//
//  Created by GO on 6/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth // ✅ 테스트를 위한 import ✅

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
    let name: String               /// 루틴 이름
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

    /// 운동 세션 생성
    /// - Parameter session: 저장할 FSWorkoutSession 객체 (id는 자동 할당)
    func createSession(_ session: FSWorkoutSession) async throws {
        let ref = db.collection("sessions").document()
        var newSession = session
        newSession.id = ref.documentID
        try ref.setData(from: newSession)
    }

    /// 특정 사용자의 운동 세션 목록 조회
    /// - Parameter uid: 사용자 UID
    /// - Returns: FSWorkoutSession 배열
    func fetchSessions(for uid: String) async throws -> [FSWorkoutSession] {
        let snapshot = try await db.collection("sessions")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSWorkoutSession.self) }
    }
}

// MARK: - 테스트 코드입니다.
extension FirestoreService {
    /// FirestoreService 기능 테스트용 메서드
    /// - 인증된 상태에서만 정상 동작합니다.
    func testFirestoreService() async {
        // 1. 현재 로그인된 사용자 UID 가져오기
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ [테스트] 인증된 사용자가 없습니다. 먼저 Firebase 인증을 진행하세요.")
            return
        }
        print("✅ [테스트] 현재 사용자 UID: \(uid)")

        // 2. 테스트용 운동 세트/운동/루틴 생성
        let testSet = FSWorkoutSet(weight: 50, unit: "kg", reps: 12)
        let testWorkout = FSWorkout(name: "스쿼트", restTime: 90, comment: "무릎 조심", sets: [testSet])
        let testRoutine = FSWorkoutRoutine(id: nil, userId: uid, name: "하체 루틴", workouts: [testWorkout])

        // 3. 루틴 저장 테스트
        do {
            try await createRoutine(testRoutine)
            print("✅ [테스트] 루틴 저장 성공")
        } catch {
            print("❌ [테스트] 루틴 저장 실패: \(error)")
        }

        // 4. 루틴 목록 조회 테스트
        do {
            let routines = try await fetchRoutines(for: uid)
            print("✅ [테스트] 루틴 목록 조회 성공: 총 \(routines.count)개")
            for routine in routines {
                print("   - 루틴 이름: \(routine.name), 운동 개수: \(routine.workouts.count)")
            }
        } catch {
            print("❌ [테스트] 루틴 목록 조회 실패: \(error)")
        }

        // 5. 운동 기록 저장 테스트
        if let firstRoutine = try? await fetchRoutines(for: uid).first {
            let testRecord = FSWorkoutRecord(
                id: nil,
                userId: uid,
                routineId: firstRoutine.id ?? "",
                totalTime: 3600,
                workoutTime: 3200,
                comment: "기록 테스트",
                date: Date()
            )
            do {
                try await createRecord(testRecord)
                print("✅ [테스트] 운동 기록 저장 성공")
            } catch {
                print("❌ [테스트] 운동 기록 저장 실패: \(error)")
            }
        }

        // 6. 운동 기록 목록 조회 테스트
        do {
            let records = try await fetchRecords(for: uid)
            print("✅ [테스트] 운동 기록 목록 조회 성공: 총 \(records.count)개")
            for record in records {
                print("   - 기록 날짜: \(record.date), 루틴ID: \(record.routineId)")
            }
        } catch {
            print("❌ [테스트] 운동 기록 목록 조회 실패: \(error)")
        }

        // 7. 운동 세션 저장 테스트
        if let firstRecord = try? await fetchRecords(for: uid).first {
            let testSession = FSWorkoutSession(
                id: nil,
                userId: uid,
                recordId: firstRecord.id ?? "",
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600)
            )
            do {
                try await createSession(testSession)
                print("✅ [테스트] 운동 세션 저장 성공")
            } catch {
                print("❌ [테스트] 운동 세션 저장 실패: \(error)")
            }
        }

        // 8. 운동 세션 목록 조회 테스트
        do {
            let sessions = try await fetchSessions(for: uid)
            print("✅ [테스트] 운동 세션 목록 조회 성공: 총 \(sessions.count)개")
            for session in sessions {
                print("   - 세션 시작: \(session.startDate), 종료: \(session.endDate)")
            }
        } catch {
            print("❌ [테스트] 운동 세션 목록 조회 실패: \(error)")
        }
    }
}
