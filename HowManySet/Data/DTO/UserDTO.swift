//
//  UserDTO.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

/// 사용자 정보 데이터 전송 객체
///
/// Firestore와 Domain Layer 간의 데이터 변환을 담당하며,
/// 다양한 소셜 로그인 제공자의 고유 식별자를 포함합니다.
public struct UserDTO {
    /// Firebase Auth 사용자 고유 식별자
    public let uid: String
    
    /// 사용자 닉네임
    public let name: String
    
    /// 로그인 제공자 식별자
    public let provider: String
    
    /// 사용자 이메일 주소 (선택적)
    public let email: String?
    
    /// 닉네임 설정 완료 여부
    public let hasSetNickname: Bool
    
    /// 온보딩 프로세스 완료 여부
    public let hasCompletedOnboarding: Bool
    
    /// 카카오 사용자 고유 식별자 (선택적)
    public let kakaoId: Int64?
    
    /// 구글 사용자 고유 식별자 (선택적)
    public let googleId: String?
    
    /// Apple 사용자 고유 식별자 (선택적)
    public let appleId: String?

    /// UserDTO 인스턴스를 생성합니다
    /// - Parameters:
    ///   - uid: Firebase Auth 사용자 ID
    ///   - name: 사용자 닉네임
    ///   - provider: 로그인 제공자 식별자
    ///   - email: 사용자 이메일 (선택적)
    ///   - hasSetNickname: 닉네임 설정 완료 여부 (기본값: false)
    ///   - hasCompletedOnboarding: 온보딩 완료 여부 (기본값: false)
    ///   - kakaoId: 카카오 사용자 ID (선택적)
    ///   - googleId: 구글 사용자 ID (선택적)
    ///   - appleId: Apple 사용자 ID (선택적)
    public init(
        uid: String,
        name: String,
        provider: String,
        email: String? = nil,
        hasSetNickname: Bool = false,
        hasCompletedOnboarding: Bool = false,
        kakaoId: Int64? = nil,
        googleId: String? = nil,
        appleId: String? = nil
    ) {
        self.uid = uid
        self.name = name
        self.provider = provider
        self.email = email
        self.hasSetNickname = hasSetNickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.kakaoId = kakaoId
        self.googleId = googleId
        self.appleId = appleId
    }

    /// UserDTO를 User 도메인 모델로 변환합니다
    /// - Returns: User 도메인 모델 인스턴스
    public func toEntity() -> User {
        return User(
            uid: uid,
            name: name,
            provider: provider,
            email: email,
            hasSetNickname: hasSetNickname,
            hasCompletedOnboarding: hasCompletedOnboarding
        )
    }

    /// Firestore 문서 데이터로부터 UserDTO를 생성합니다
    /// - Parameters:
    ///   - uid: Firebase Auth 사용자 ID
    ///   - data: Firestore 문서 데이터
    /// - Returns: 생성된 UserDTO 인스턴스 또는 nil (필수 필드 누락 시)
    public static func from(uid: String, data: [String: Any]) -> UserDTO? {
        guard let name = data["name"] as? String,
              let provider = data["provider"] as? String else {
            return nil
        }
        
        let email = data["email"] as? String
        let hasSetNickname = data["hasSetNickname"] as? Bool ?? false
        let hasCompletedOnboarding = data["hasCompletedOnboarding"] as? Bool ?? false
        let kakaoId = data["kakaoId"] as? Int64
        let googleId = data["googleId"] as? String
        let appleId = data["appleId"] as? String
        
        return UserDTO(
            uid: uid,
            name: name,
            provider: provider,
            email: email,
            hasSetNickname: hasSetNickname,
            hasCompletedOnboarding: hasCompletedOnboarding,
            kakaoId: kakaoId,
            googleId: googleId,
            appleId: appleId
        )
    }

    /// UserDTO를 Firestore 저장용 데이터로 변환합니다
    /// - Returns: Firestore에 저장할 수 있는 딕셔너리 형태의 데이터
    public func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "uid": uid,
            "name": name,
            "provider": provider,
            "hasSetNickname": hasSetNickname,
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp()
        ]
        
        if let email = email {
            data["email"] = email
        }
        if let kakaoId = kakaoId {
            data["kakaoId"] = kakaoId
        }
        if let googleId = googleId {
            data["googleId"] = googleId
        }
        if let appleId = appleId {
            data["appleId"] = appleId
        }
        
        return data
    }
}
