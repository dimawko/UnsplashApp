//
//  Image.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation

struct Image: Codable {
    let createdAt: String?
    let urls: Urls?
    let likes: Int?
    let user: User?
    let location: Location?
    let views, downloads: Int?

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case urls, likes, user, location, views, downloads
    }

    struct Urls: Codable {
        let raw, full, regular, small: String
        let thumb: String
        let smallS3: String

        enum CodingKeys: String, CodingKey {
            case raw, full, regular, small, thumb
            case smallS3 = "small_s3"
        }
    }

    struct User: Codable {
        let username, name, firstName, lastName: String?

        enum CodingKeys: String, CodingKey {
                case username, name
                case firstName = "first_name"
                case lastName = "last_name"
            }
    }

    struct Location: Codable {
        let title, name, city, country: String?
    }
}
