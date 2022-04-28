//
//  StorageManager.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()

    private init() {}

    var realm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch let error as NSError {
            print(error)
        }
        return nil
    }

    func save(_ image: Image) {
        write {
            realm?.add(image)
        }
    }

    private func write(completion: () -> Void) {
        do {
            try realm?.write {
                completion()
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
