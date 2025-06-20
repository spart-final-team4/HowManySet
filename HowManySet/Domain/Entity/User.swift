//
//  User.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// 사용자 정보를 나타내는 도메인 모델
/// - 앱 전체에서 사용되는 통합된 사용자 모델
public struct User {
    /// Firebase Auth에서 제공하는 고유 사용자 ID
    public let uid: String
    /// 사용자 이름 (닉네임)
    public let name: String
    /// 로그인 제공자 (kakao, google, apple, anonymous)
    public let provider: String
    /// 사용자 이메일 (선택적)
    public let email: String?

    /// User 모델 생성자
    /// - Parameters:
    ///   - uid: Firebase Auth 사용자 ID
    ///   - name: 사용자 이름
    ///   - provider: 로그인 제공자
    ///   - email: 사용자 이메일 (선택적)
    public init(uid: String, name: String, provider: String, email: String? = nil) {
        self.uid = uid
        self.name = name
        self.provider = provider
        self.email = email
    }
}
