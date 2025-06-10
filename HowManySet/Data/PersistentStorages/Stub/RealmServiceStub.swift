//
//  RealmServiceStub.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation
import RealmSwift

class RealmServiceStub: RealmServiceProtocol {
    
    private let realm: Realm
    
    init() {
        do {
            realm = try Realm()
        } catch {
            print("RealmManager Realm Init Failed: \(error.localizedDescription)")
            fatalError()
        }
    }
    
    func create<T: Object>(item: T) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("create Failed: \(error.localizedDescription)")
        }
    }
    
    func read<T: Object>(type: RealmDataType<T>) -> Results<T>? {
        return realm.objects(type.type)
    }
    
    func read<T>(at index: Int, type: RealmDataType<T>) -> Object? {
        if index >= realm.objects(type.type).count {
            return nil
        }
        return realm.objects(type.type)[index]
    }
    
    func update<T: Object>(item: T, completion: @escaping (T) -> Void) {
        do {
            try realm.write {
                completion(item)
            }
        } catch {
            print("update failed: \(error.localizedDescription)")
        }
    }
    
    func delete<T: Object>(item: T) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("delete Failed: \(error.localizedDescription)")
        }
        
    }
    
    func deleteAll<T: Object>(type: RealmDataType<T>) {
        do {
            try realm.write {
                if let datas = read(type: type) {
                    realm.delete(datas)
                }
            }
        } catch {
            print("delete specific data All Failed: \(error.localizedDescription) ")
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("delete All Failed: \(error.localizedDescription)")
        }
    }
    
}
