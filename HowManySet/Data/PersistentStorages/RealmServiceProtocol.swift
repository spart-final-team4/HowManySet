//
//  RealmServiceProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/5/25.
//

import Foundation
import RealmSwift

/// Realm 데이터베이스의 기본 CRUD 동작을 정의하는 프로토콜입니다.
protocol RealmServiceProtocol {
    
    func openRealm() throws -> Realm
    
    /// Realm에 객체를 생성(저장)합니다.
    /// - Parameter item: 저장할 Realm 객체
    func create<T: Object>(item: T) throws
    
    /// 특정 타입의 모든 객체를 Realm에서 조회합니다.
    /// - Parameter type: 조회할 Realm 객체 타입
    /// - Returns: 조회된 객체들의 결과 리스트(`Results<T>`), 없을 경우 `nil`
    func read<T: Object>(type: RealmDataType<T>) throws -> Results<T>
    
    func read<T: Object>(type: RealmDataType<T>, primaryKey: String) throws -> Object
    /// 특정 객체를 업데이트합니다.
    /// - Parameters:
    ///   - item: 업데이트할 Realm 객체
    ///   - completion: 업데이트 후 처리할 클로저. 변경된 객체를 반환합니다.
    func update<T: Object>(item: T, completion: @escaping (T) -> Void) throws
    
    /// 특정 객체를 Realm에서 삭제합니다.
    /// - Parameter item: 삭제할 Realm 객체
    func delete<T: Object>(item: T) throws
    
    /// 특정 타입의 모든 객체를 Realm에서 삭제합니다.
    /// - Parameter type: 삭제할 Realm 객체의 타입
    func deleteAll<T: Object>(type: RealmDataType<T>) throws
    
    /// Realm에 저장된 모든 객체를 삭제합니다.
    func deleteAll() throws
}

