//
//  RealmService.swift
//  HowManySet
//
//  Created by MJ Dev on 6/5/25.
//

import Foundation
import RealmSwift

/// Realm 데이터베이스에 대한 기본적인 CRUD 기능을 제공하는 클래스입니다.
/// `RealmServiceProtocol`을 구현하며, Realm 객체를 생성, 조회, 수정, 삭제할 수 있습니다.
final class RealmService: RealmServiceProtocol {
    
    static let shared = RealmService()
    
    private init() { }

    /// Realm에 객체를 생성(저장)합니다.
    /// - Parameter item: 저장할 Realm 객체
    func create<T: Object>(item: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("create Failed: \(error.localizedDescription)")
        }
    }

    /// Realm에서 특정 타입의 객체 목록을 조회합니다.
    /// - Parameter type: 조회할 Realm 객체 타입 (`RealmDataType`)
    /// - Returns: 조회된 객체의 리스트 (`Results<T>`), 없으면 `nil`
    func read<T: Object>(type: RealmDataType<T>) -> Results<T>? {
        let realm = try? Realm()
        return realm?.objects(type.type)
    }

    /// Realm에서 특정 인덱스에 해당하는 객체를 조회합니다.
    /// - Parameters:
    ///   - index: 조회할 객체의 인덱스
    ///   - type: 조회할 Realm 객체 타입 (`RealmDataType`)
    /// - Returns: 조회된 객체가 존재하면 반환, 없으면 `nil`
    func read<T>(at index: Int, type: RealmDataType<T>) -> Object? {
        let realm = try? Realm()
        if index >= realm?.objects(type.type).count ?? 0 {
            return nil
        }
        return realm?.objects(type.type)[index]
    }

    /// Realm에 저장된 객체를 업데이트합니다.
    /// - Parameters:
    ///   - item: 업데이트할 Realm 객체
    ///   - completion: 변경 사항을 적용할 클로저
    func update<T: Object>(item: T, completion: @escaping (T) -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                completion(item)
            }
        } catch {
            print("update failed: \(error.localizedDescription)")
        }
    }

    /// Realm에서 특정 객체를 삭제합니다.
    /// - Parameter item: 삭제할 Realm 객체
    func delete<T: Object>(item: T) {
        let realm = try? Realm()
        guard let primaryKey = T.primaryKey() else {
            print("⚠️ \(T.self)는 primaryKey가 없어서 안전한 삭제가 불가능합니다.")
            return
        }
        
        // 2. item에서 primary key 값을 안전하게 꺼냄
        guard let keyValue = item.value(forKey: primaryKey) else {
            print("⚠️ 객체에서 primary key 값을 가져올 수 없습니다.")
            return
        }
        guard let objToDelete = realm?.object(ofType: T.self, forPrimaryKey: keyValue) else {
            print("❌ Realm에 해당 객체가 존재하지 않습니다.")
            return
        }
        do {
            try realm?.write {
                realm?.delete(objToDelete)
            }
        } catch {
            print("delete Failed: \(error.localizedDescription)")
        }
    }

    /// Realm에서 특정 타입의 모든 객체를 삭제합니다.
    /// - Parameter type: 삭제할 Realm 객체 타입 (`RealmDataType`)
    func deleteAll<T: Object>(type: RealmDataType<T>) {
        do {
            let realm = try Realm()
            try realm.write {
                if let datas = read(type: type) {
                    realm.delete(datas)
                }
            }
        } catch {
            print("delete specific data All Failed: \(error.localizedDescription) ")
        }
    }

    /// Realm에 저장된 모든 객체를 삭제합니다.
    func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("delete All Failed: \(error.localizedDescription)")
        }
    }
}

