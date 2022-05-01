//
//  PhotoDetailsViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit
import RealmSwift
import SwiftUI

class PhotoDetailsViewController: UIViewController {

    var photoDetails: Image!
    var image: UIImage!

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupView()
        setupNavBar()
    }

    private func setupView() {
        view.addSubview(imageView)
        imageView.image = image

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func formatDate(from string: String) -> String {
        var convertedString = ""

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let dateFormatterSet = DateFormatter()
        dateFormatterSet.dateFormat = "MMM dd, yyyy"
        dateFormatterSet.locale = Locale(identifier: "en_US_POSIX")

        guard let date = dateFormatterGet.date(from: string) else { return "" }
        convertedString = dateFormatterSet.string(from: date)

        return convertedString
    }
}

// MARK: - Set up navigation bar items
extension PhotoDetailsViewController {
    private func setupNavBar() {
        navigationItem.rightBarButtonItems = createBarButtonItems()
    }

    private func createBarButtonItems() -> [UIBarButtonItem] {
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(showInfo)
        )

        let addToFavoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(addToFavorites)
        )

        let deleteFromFavoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart.fill"),
            style: .plain,
            target: self,
            action: #selector(deleteFromFavorites)
        )

//        if photoDetails.isFavorite == true {
//            return [deleteFromFavoritesButton, infoButton]
//        } else {
            return [addToFavoritesButton, deleteFromFavoritesButton]
//        }
    }

    @objc func addToFavorites() {
        StorageManager.shared.save(photoDetails)
//        navigationItem.rightBarButtonItems = createBarButtonItems()
    }

    @objc func deleteFromFavorites() {
        StorageManager.shared.delete(photoDetails)
//        navigationItem.rightBarButtonItems = createBarButtonItems()
        let addToFavoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(addToFavorites)
        )
//        navigationItem.rightBarButtonItem = addToFavoritesButton
    }

    @objc func showInfo() {
        let userName = photoDetails.user?.name ?? "Unknown"
        let creationDate = formatDate(from: photoDetails.createdAt)
        let location = photoDetails.location?.title ?? "Unknown"
        let downloads = String(photoDetails.downloads)
        let alert = UIAlertController(
            title:
                "Author: \(userName)",
            message: "Created: \(creationDate)\n Location: \(location)\n Downloads: \(downloads)",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
