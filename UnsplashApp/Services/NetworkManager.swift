//
//  NetworkManager.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation

enum Link: String {
    case randomPhoto = "https://api.unsplash.com/photos/random?count=30&client_id=jl7DJcBPGRgow1g6KiOaUQWU5ZRStIDPqXu5ZSJaJAM"
    case searchPhoto = "https://api.unsplash.com/search/photos?query=space&&client_id=jl7DJcBPGRgow1g6KiOaUQWU5ZRStIDPqXu5ZSJaJAM"
}

class NetworkManager {

    static let shared = NetworkManager()

    var images = NSCache<NSString, NSData>()

    private init() {}

    func fetchData(completion: @escaping (Result<[Image], Error>) -> Void) {
        guard let url = URL(string: Link.randomPhoto.rawValue) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            do {
                let imageData = try JSONDecoder().decode([Image].self, from: data)
                completion(.success(imageData))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchImage(with imageData: Image, completion: @escaping(Result<Data, Error>) -> Void) {
        guard let imageUrl = imageData.urls?.regular else { return }
        if let imageData = images.object(forKey: imageUrl as NSString) {
            completion(.success(imageData as Data))
            return
        }

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

    func fetchSearchResults(with query: String, completion: @escaping (Result<SearchResults, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?query=\(query)&client_id=jl7DJcBPGRgow1g6KiOaUQWU5ZRStIDPqXu5ZSJaJAM") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            do {
                let searchData = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(.success(searchData))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchDatas<T: Decodable>(url: String, query: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?query=\(query)&client_id=jl7DJcBPGRgow1g6KiOaUQWU5ZRStIDPqXu5ZSJaJAM") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            do {
                let searchData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(searchData))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
}
