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
    
    func openRealm() throws -> Realm {
        do {
            return try Realm()
        } catch {
            throw(RealmErrorType.openRealmDatabaseFailed)
        }
    }

    /// Realm에 객체를 생성(저장)합니다.
    /// - Parameter item: 저장할 Realm 객체
    func create<T: Object>(item: T) throws {
        do {
            let realm = try openRealm()
            try realm.write {
                realm.add(item)
            }
        } catch RealmErrorType.openRealmDatabaseFailed {
            throw(RealmErrorType.openRealmDatabaseFailed)
        } catch {
            throw(RealmErrorType.databaseWriteFailed)
        }
    }

    /// Realm에서 특정 타입의 객체 목록을 조회합니다.
    /// - Parameter type: 조회할 Realm 객체 타입 (`RealmDataType`)
    /// - Returns: 조회된 객체의 리스트 (`Results<T>`), 없으면 `nil`
    func read<T: Object>(type: RealmDataType<T>) throws -> Results<T> {
        do {
            let realm = try Realm()
            return realm.objects(type.type)
        } catch {
            throw(RealmErrorType.openRealmDatabaseFailed)
        }
    }
    
    func read<T: Object>(type: RealmDataType<T>, primaryKey: String) throws -> Object {
        do {
            let realm = try Realm()
            guard let data = realm.object(ofType: type.type.self, forPrimaryKey: primaryKey) else {
                throw(RealmErrorType.objectBindingFailed)
            }
            return data
        } catch {
            throw(RealmErrorType.openRealmDatabaseFailed)
        }
    }

    /// Realm에 저장된 객체를 업데이트합니다.
    /// - Parameters:
    ///   - item: 업데이트할 Realm 객체
    ///   - completion: 변경 사항을 적용할 클로저
    func update<T: Object>(item: T, completion: @escaping (T) -> Void) throws {
        do {
            let realm = try Realm()
            try realm.write {
                if let data = item as? RMWorkoutRoutine {
                    data.workouts.forEach { workout in
                        realm.add(workout, update: .modified)
                    }
                }
                completion(item)
                realm.add(item, update: .modified)
            }
        } catch RealmErrorType.openRealmDatabaseFailed {
            throw(RealmErrorType.openRealmDatabaseFailed)
        } catch {
            throw(RealmErrorType.databaseWriteFailed)
        }
    }

    /// Realm에서 특정 객체를 삭제합니다.
    /// - Parameter item: 삭제할 Realm 객체
    func delete<T: Object>(item: T) throws {
        
        do {
            let realm = try openRealm()
            
            guard let primaryKey = T.primaryKey() else {
                print("⚠️ \(T.self)는 primaryKey가 없어서 안전한 삭제가 불가능합니다.")
                throw(RealmErrorType.nonePrimaryKey)
            }
            
            guard let keyValue = item.value(forKey: primaryKey) else {
                print("⚠️ 객체에서 primary key 값을 가져올 수 없습니다.")
                throw(RealmErrorType.incorrectPrimaryKey)
            }
            
            guard let objToDelete = realm.object(ofType: T.self, forPrimaryKey: keyValue) else {
                print("❌ Realm에 해당 객체가 존재하지 않습니다.")
                throw(RealmErrorType.dataNotFound)
            }
            
            try realm.write {
                realm.delete(objToDelete)
            }
            
        } catch RealmErrorType.openRealmDatabaseFailed {
            throw(RealmErrorType.openRealmDatabaseFailed)
        } catch {
            throw(RealmErrorType.databaseWriteFailed)
        }
    }

    /// Realm에서 특정 타입의 모든 객체를 삭제합니다.
    /// - Parameter type: 삭제할 Realm 객체 타입 (`RealmDataType`)
    func deleteAll<T: Object>(type: RealmDataType<T>) throws {
        do {
            let realm = try openRealm()
            try realm.write {
                let datas = try read(type: type)
                realm.delete(datas)
            }
        } catch RealmErrorType.openRealmDatabaseFailed {
            throw(RealmErrorType.openRealmDatabaseFailed)
        } catch RealmErrorType.databaseWriteFailed {
            throw(RealmErrorType.databaseWriteFailed)
        }
    }

    /// Realm에 저장된 모든 객체를 삭제합니다.
    func deleteAll() throws {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch RealmErrorType.openRealmDatabaseFailed {
            throw(RealmErrorType.openRealmDatabaseFailed)
        } catch RealmErrorType.databaseWriteFailed {
            throw(RealmErrorType.databaseWriteFailed)
        }
    }
}

