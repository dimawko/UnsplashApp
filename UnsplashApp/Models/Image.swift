//
//  Image.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation
import RealmSwift

class Image: Object, Codable {
    @Persisted var createdAt = ""
    @Persisted var urls: Urls? = nil
    @Persisted var likes = 0
    @Persisted var user: User? = nil
    @Persisted var location: Location? = nil
    @Persisted var downloads = 0

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case urls, likes, user, location, downloads
    }


}

class Urls: Object, Codable {
    let raw, full, small: String
    @Persisted var regular = ""
    let thumb: String
    let smallS3: String

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

class User: Object, Codable {
    @Persisted var name = ""
    let username, firstName, lastName: String?

    enum CodingKeys: String, CodingKey {
        case username, name
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

class Location: Object, Codable {
    @Persisted var title: String? = nil
    let name, city, country: String?
}
