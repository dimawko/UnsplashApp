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
            let copy = realm?.create(Image.self, value: image, update: .all)
            guard let copy = copy else { return }
            realm?.add(copy)
        }
    }

    func delete(_ image: Image) {
        if let deleteUrls = realm?.object(ofType: Urls.self, forPrimaryKey: image.urls?.regular) {
            write {
                realm?.delete(deleteUrls)
            }
        }
        if let deleteUser = realm?.object(ofType: User.self, forPrimaryKey: image.user?.name) {
            write {
                realm?.delete(deleteUser)
            }
        }
        if let deleteLocation  = realm?.object(ofType: Location.self, forPrimaryKey: image.location?.title) {
            write {
                realm?.delete(deleteLocation)
            }
        }
        if let deleteData = realm?.object(ofType: Image.self, forPrimaryKey: image.id) {
            write {
                realm?.delete(deleteData)
            }
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
