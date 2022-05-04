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
    private var shouldLoadMoreImageData = false

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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let image = isSearching ? searchImages[indexPath.row] : images[indexPath.row]
        cell.spinner.startAnimating()

        NetworkManager.shared.fetchImage(imageType: .small, imageData: image) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let cellimage = UIImage(data: data)
                    cell.imageView.image = cellimage
                    cell.spinner.stopAnimating()
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

        let imageDetailsVC = ImageDetailsViewController()
        imageDetailsVC.modalPresentationStyle = .currentContext
        imageDetailsVC.imageDetails = imageDetails

        self.navigationController?.pushViewController(imageDetailsVC, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = images.count - 1
        if indexPath.row == lastElement {
            print("will Display cell")
            shouldLoadMoreImageData = true
            getMoreImageData()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.size.width / 3-1, height: 150)
    }
}

// MARK: - Networking
extension ImagesCollectionViewController {
    private func getImageData() {
        NetworkManager.shared.fetchImageData(
            dataType: [Image].self,
            url: LinkString.randomPhoto,
            query: "count=30"
        ) { result in
            switch result {
            case .success(let imageData):
                DispatchQueue.main.async {
                    self.images = imageData
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func getMoreImageData() {
        if self.shouldLoadMoreImageData == true {
            NetworkManager.shared.fetchImageData(
                dataType: [Image].self,
                url: LinkString.randomPhoto,
                query: "count=30"
            ) { result in
                switch result {
                case .success(let imageData):
                    DispatchQueue.main.async {
                        let newIndexPaths = self.setupNewIndexPaths(imageData: imageData)
                        self.images.append(contentsOf: imageData)
                        self.collectionView.insertItems(at: newIndexPaths)
                        self.shouldLoadMoreImageData = false
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    private func setupNewIndexPaths(imageData: [Image]) -> [IndexPath] {
        var newIndexPaths = [IndexPath]()
        for image in 0..<imageData.count {
            let indexPath = IndexPath(row: image + self.images.count, section: 0)
            newIndexPaths.append(indexPath)
        }
        return newIndexPaths
    }
}

// MARK: - Search bar methods
extension ImagesCollectionViewController: UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }

        isSearching = true
        NetworkManager.shared.fetchImageData(
            dataType: SearchResults.self,
            url: LinkString.searchPhoto,
            query: "query=\(searchText)"
        ) { result in
            switch result {
            case .success(let searchResults):
                DispatchQueue.main.async {
                    self.searchImages = searchResults.results
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
