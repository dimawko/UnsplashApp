//
//  NetworkManager.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import Foundation

enum Link: String {
    case randomPhoto = "https://api.unsplash.com/photos/random?count=5&client_id=jl7DJcBPGRgow1g6KiOaUQWU5ZRStIDPqXu5ZSJaJAM"
}

class NetworkManager {

    static let shared = NetworkManager()

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
        guard let imageDataUrl = imageData.urls?.regular else { return }
        guard let url = URL(string: imageDataUrl) else { return }
        URLSession.shared.downloadTask(with: url) { localUrl, _, error in
            guard let localUrl = localUrl else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            do {
                let data = try Data(contentsOf: localUrl)
                completion(.success(data))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
}
