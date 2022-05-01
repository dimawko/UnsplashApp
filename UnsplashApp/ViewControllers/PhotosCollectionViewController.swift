//
//  PhotosCollectionViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private var images: [Image] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos"
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)

        getImageData()
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        let image = images[indexPath.row]
        NetworkManager.shared.fetchImage(with: image) { result in
            switch result {
            case .success(let data):
                let cellimage = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.imageView.image = cellimage
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]

        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }

        let photoDetailsVC = PhotoDetailsViewController()
        photoDetailsVC.modalPresentationStyle = .currentContext
        photoDetailsVC.photoDetails = image
        photoDetailsVC.image = cell.imageView.image

        self.navigationController?.pushViewController(photoDetailsVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3-1, height: 150)
    }
}

// MARK: - Networking
extension PhotosCollectionViewController {
    private func getImageData() {
        NetworkManager.shared.fetchData { result in
            switch result {
            case .success(let imageData):
                self.images = imageData
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
