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
    private var deleteNeeded = false

    // MARK: - Private properties
    private lazy var photoView: PhotoView = {
        let photoView = PhotoView()
        photoView.imageView.contentMode = .scaleAspectFit
        return photoView
    }()

    private lazy var showImageDetailsButton = UIBarButtonItem(
        image: UIImage(systemName: "info.circle"),
        style: .plain,
        target: self,
        action: #selector(showImageDetailsAlert)
    )

    private lazy var deleteFromFavoritesButton = UIBarButtonItem(
        image: UIImage(systemName: "heart.fill"),
        style: .plain,
        target: self,
        action: #selector(deleteFromFavorites)
    )

    private lazy var addToFavoritesButton = UIBarButtonItem(
        image: UIImage(systemName: "heart"),
        style: .plain,
        target: self,
        action: #selector(addToFavorites)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getImageWithHighResolution()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureBarButtonItems()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteFromFavoritesIfNeeded()
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

    private func configureBarButtonItems() {
        if isImageFavorite() == true {
            navigationItem.rightBarButtonItems = [deleteFromFavoritesButton, showImageDetailsButton]
        } else {
            navigationItem.rightBarButtonItems = [addToFavoritesButton, showImageDetailsButton]
        }
    }

    private func deleteFromFavoritesIfNeeded() {
        if deleteNeeded == true {
            StorageManager.shared.delete(imageDetails)
        }
    }

    @objc func addToFavorites() {
        deleteNeeded = false
        StorageManager.shared.save(imageDetails)
        navigationItem.rightBarButtonItem = deleteFromFavoritesButton
    }

    @objc func deleteFromFavorites() {
        deleteNeeded = true
        navigationItem.rightBarButtonItem = addToFavoritesButton
    }

    @objc func showImageDetailsAlert() {
        let userName = imageDetails.user?.name ?? "Unknown"
        let creationDate = formatDate(from: imageDetails.createdAt ?? "Unknown")
        let location = imageDetails.location?.title ?? "Unknown"
        let likesOrDownloadsText = getLikesOrDownloadsText()

        let alert = UIAlertController(
            title: "Author: \(userName)",
            message: "Created: \(String(describing: creationDate))\n Location: \(location)\n \(likesOrDownloadsText)",
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
        view.addSubview(photoView)

        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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

    func getLikesOrDownloadsText() -> String {
        var text = ""
        let downloads = "Downloads: \(String(imageDetails.downloads ?? 0))"
        let likes = "Likes: \(imageDetails.likes)"
        if imageDetails.downloads == nil {
            text = likes
        } else {
            text = downloads
        }
        return text
    }

    func getImageWithHighResolution() {
        photoView.spinner.startAnimating()
        NetworkManager.shared.fetchImage(imageType: .regular, imageData: imageDetails) { result in
            switch result {
            case .success(let imageData):
                DispatchQueue.main.async {
                    self.photoView.imageView.image = UIImage(data: imageData)
                    self.photoView.spinner.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
