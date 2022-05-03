//
//  NetworkManager.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation

enum LinkString {
    static let randomPhoto = "https://api.unsplash.com/photos/random?"
    static let searchPhoto = "https://api.unsplash.com/search/photos?"
    static let apiKey = "&client_id=jl7DJcBPGRgow1g6KiOaUQWU5ZRStIDPqXu5ZSJaJAM"
}

final class NetworkManager {

    static let shared = NetworkManager()
    var images = NSCache<NSString, NSData>()

    private init() {}

    func fetchImage(with imageData: Image, completion: @escaping(Result<Data, Error>) -> Void) {
        // MARK: - Checking if the image is already in a cache
        guard let imageUrl = imageData.urls?.regular else { return }
        if let imageData = images.object(forKey: imageUrl as NSString) {
            completion(.success(imageData as Data))
            return
        }

        // MARK: - Download image, If its not in the cache
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.downloadTask(with: url) { localUrl, _, error in
            guard let localUrl = localUrl else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            do {
                let data = try Data(contentsOf: localUrl)
                self.images.setObject(data as NSData, forKey: imageUrl as NSString)
                completion(.success(data))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchImageData<T: Decodable>(dataType: T.Type, url: String, query: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: url + query + LinkString.apiKey ) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            do {
                let imageData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(imageData))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
}
