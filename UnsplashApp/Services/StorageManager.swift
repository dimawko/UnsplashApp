//
//  StorageManager.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation
import RealmSwift

final class StorageManager {

    static let shared = StorageManager()

    var realm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch let error as NSError {
            print(error)
        }
        return nil
    }

    private init() {}

    func save(_ image: Image) {
        write {
            realm?.create(Image.self, value: image, update: .all)
        }
    }

    func delete(_ image: Image) {
        write {
            if let urls = image.urls, let user = image.user, let location = image.location {
                realm?.delete(urls)
                realm?.delete(user)
                realm?.delete(location)
            }
            realm?.delete(image)
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
