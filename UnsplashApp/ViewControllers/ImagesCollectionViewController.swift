//
//  PhotosCollectionViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

class ImagesCollectionViewController: UICollectionViewController {

    // MARK: - Private properties
    private var images: [Image] = []
    private var searchImages: [Image] = []
    private var isSearching = false
    private var isLoadNeeded = false

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search photos"
        return searchController
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        getImageData()
    }
}

// MARK: - Collection view data source and delegate methods
extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isSearching ? searchImages.count : images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        let image = isSearching ? searchImages[indexPath.row] : images[indexPath.row]
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
        searchController.searchBar.endEditing(true)
        let imageDetails = isSearching ? searchImages[indexPath.row] : images[indexPath.row]

        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }

        let imageDetailsVC = ImageDetailsViewController()
        imageDetailsVC.modalPresentationStyle = .currentContext
        imageDetailsVC.imageDetails = imageDetails
        imageDetailsVC.image = cell.imageView.image

        self.navigationController?.pushViewController(imageDetailsVC, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = images.count - 5
        if indexPath.row == lastElement {
            isLoadNeeded = true
            DispatchQueue.main.async {
                self.getImageData()
                self.collectionView.reloadData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3-1, height: 150)
    }
}

// MARK: - Networking
extension ImagesCollectionViewController {
    private func getImageData() {
        NetworkManager.shared.fetchImageData(dataType: [Image].self, url: LinkString.randomPhoto, query: "count=30") { result in
            switch result {
            case .success(let imageData):
                if self.isLoadNeeded == false {
                    DispatchQueue.main.async {
                        self.images = imageData
                        self.collectionView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.images.append(contentsOf: imageData)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Search bar methods
extension ImagesCollectionViewController: UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }

        isSearching = true
        NetworkManager.shared.fetchImageData(dataType: SearchResults.self, url: LinkString.searchPhoto, query: "query=\(searchText)") { result in
            switch result {
            case .success(let searchResults):
                DispatchQueue.main.async {
                    self.searchImages = searchResults.results
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchController.searchBar.text else { return }
        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.isSearching = false
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - Private methods
private extension ImagesCollectionViewController {
    func setupNavBar() {
        title = "Photos"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
