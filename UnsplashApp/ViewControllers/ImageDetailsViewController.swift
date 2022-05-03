//
//  PhotoDetailsViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit
import RealmSwift

class ImageDetailsViewController: UIViewController {

    // MARK: - Public properties
    var imageDetails: Image!
    var image: UIImage!

    // MARK: - Private properties
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var showImageDetailsButton = UIBarButtonItem(
        image: UIImage(systemName: "info.circle"),
        style: .plain,
        target: self,
        action: #selector(showImageDetailsAlert)
    )

    private lazy var addToFavoritesButton = UIBarButtonItem(
        image: UIImage(systemName: "heart"),
        style: .plain,
        target: self,
        action: #selector(addToFavorites)
    )

    private lazy var deleteFromFavoritesButton = UIBarButtonItem(
        image: UIImage(systemName: "heart.fill"),
        style: .plain,
        target: self,
        action: #selector(deleteFromFavorites)
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavBar()
    }
}

// MARK: - Set up navigation bar items
extension ImageDetailsViewController {

    private func isImageFavorite() -> Bool {
        var isFavorite = false
        let realmImage = StorageManager.shared.realm?.object(ofType: Image.self, forPrimaryKey: imageDetails.id)
        if realmImage != nil {
            isFavorite = true
        }
        return isFavorite
    }

    private func configureBarButtonItems() -> [UIBarButtonItem] {
        if isImageFavorite() == true {
            return [deleteFromFavoritesButton, showImageDetailsButton]
        } else {
            return [addToFavoritesButton, showImageDetailsButton]
        }
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItems = configureBarButtonItems()
    }

    @objc func addToFavorites() {
        StorageManager.shared.save(imageDetails)
        navigationItem.rightBarButtonItem = deleteFromFavoritesButton
    }

    @objc func deleteFromFavorites() {
        StorageManager.shared.delete(imageDetails)
        navigationItem.rightBarButtonItem = addToFavoritesButton
    }

    @objc func showImageDetailsAlert() {
        let userName = imageDetails.user?.name ?? "Unknown"
        let creationDate = formatDate(from: imageDetails.createdAt ?? "Unknown")
        let location = imageDetails.location?.title ?? "Unknown"
        let downloads = String(imageDetails.downloads ?? 0)

        let alert = UIAlertController(
            title: "Author: \(userName)",
            message: "Created: \(String(describing: creationDate))\n Location: \(location)\n Downloads: \(downloads)",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)

        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - Private methods
private extension ImageDetailsViewController {
    func setupView() {
        view.addSubview(imageView)
        imageView.image = image

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func formatDate(from string: String) -> String {
        var convertedString = ""

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let dateFormatterSet = DateFormatter()
        dateFormatterSet.dateFormat = "MMM dd, yyyy"
        dateFormatterSet.locale = Locale(identifier: "en_US_POSIX")

        if let date = dateFormatterGet.date(from: string) {
            convertedString = dateFormatterSet.string(from: date)
        }

        return convertedString
    }
}
