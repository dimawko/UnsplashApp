//
//  PhotosCollectionViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

private enum RandomImageQuery {
    static let count = "count=30"
}

private enum SearchImageQuery {
    static let query = "query="
    static let perPage = "&per_page=30"
    static let page = "&page="
}

class ImagesCollectionViewController: UICollectionViewController {

    private var randomImages: [Image] = []
    private var searchImages: [Image] = []

    private var isLoadMoreImagesNeeded = false

    private var isSearching = false
    private var nextSearchingPage = 0

    private lazy var searchController = UISearchController.createSearchController(delegate: self, placeholder: "Search images")

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
        getRandomImages()
    }
}

// MARK: - Collection view data source and delegate methods
extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isSearching ? searchImages.count : randomImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }

        let image = isSearching ? searchImages[indexPath.row] : randomImages[indexPath.row]
        cell.photoView.spinner.startAnimating()

        NetworkManager.shared.fetchImage(imageType: .small, imageData: image) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let cellimage = UIImage(data: data)
                    cell.photoView.imageView.image = cellimage
                    cell.photoView.spinner.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchController.searchBar.endEditing(true)
        let imageDetails = isSearching ? searchImages[indexPath.row] : randomImages[indexPath.row]

        let imageDetailsVC = ImageDetailsViewController()
        imageDetailsVC.modalPresentationStyle = .currentContext
        imageDetailsVC.imageDetails = imageDetails

        self.navigationController?.pushViewController(imageDetailsVC, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setupNextCells(indexPath: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        return CGSize(
            width: (view.frame.size.width / 3) - 1,
            height: (frame.height / 4) - 1
        )
    }
}

// MARK: - Set up next cells
private extension ImagesCollectionViewController {
    func setupNewIndexPaths(for loadedImages: [Image]) -> [IndexPath] {
        var newIndexPaths = [IndexPath]()
        var newIndexPath = IndexPath()
        for loadedImage in 0..<loadedImages.count {
            if isSearching == false {
                newIndexPath = IndexPath(row: loadedImage + self.randomImages.count, section: 0)
            } else {
                newIndexPath = IndexPath(row: loadedImage + self.searchImages.count, section: 0)
            }
            newIndexPaths.append(newIndexPath)
        }
        return newIndexPaths
    }

    func setupNextCells(indexPath: IndexPath) {
        var indexForLastVisibleCell = 0
        if isSearching == false {
            indexForLastVisibleCell = randomImages.count - 1
            if indexPath.row == indexForLastVisibleCell {
                isLoadMoreImagesNeeded = true
                getMoreRandomImages()
            }
        } else {
            guard let searchText = searchController.searchBar.text else { return }
            indexForLastVisibleCell = searchImages.count - 1
            if indexPath.row == indexForLastVisibleCell {
                nextSearchingPage += 1
                getSearchImages(searchText: searchText, searchPage: nextSearchingPage)
            }
        }
    }
}

// MARK: - Networking
extension ImagesCollectionViewController {
    private func getRandomImages() {
        NetworkManager.shared.fetchImageData(
            dataType: [Image].self,
            url: LinkString.randomPhoto,
            query: RandomImageQuery.count
        ) { result in
            switch result {
            case .success(let imageData):
                DispatchQueue.main.async {
                    self.randomImages = imageData
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func getMoreRandomImages() {
        if isLoadMoreImagesNeeded == true {
            NetworkManager.shared.fetchImageData(
                dataType: [Image].self,
                url: LinkString.randomPhoto,
                query: RandomImageQuery.count
            ) { result in
                switch result {
                case .success(let randomImages):
                    DispatchQueue.main.async {
                        let newIndexPaths = self.setupNewIndexPaths(for: randomImages)
                        self.randomImages.append(contentsOf: randomImages)
                        self.collectionView.insertItems(at: newIndexPaths)
                        self.isLoadMoreImagesNeeded = false
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    private func getSearchImages(searchText: String, searchPage: Int = 0) {
        NetworkManager.shared.fetchImageData(
            dataType: SearchResults.self,
            url: LinkString.searchPhoto,
            query: SearchImageQuery.query + searchText.lowercased() + SearchImageQuery.perPage + SearchImageQuery.page + "\(searchPage)"
        ) { result in
            switch result {
            case .success(let searchImageData):
                DispatchQueue.main.async {
                    if searchPage == 0 {
                        self.searchImages = searchImageData.results
                        self.collectionView.reloadData()
                    } else {
                        let newIndexPaths = self.setupNewIndexPaths(for: searchImageData.results)
                        self.searchImages.append(contentsOf: searchImageData.results)
                        self.collectionView.insertItems(at: newIndexPaths)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Search bar delegate methods
extension ImagesCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }
        isSearching = true
        getSearchImages(searchText: searchText)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchController.searchBar.text else { return }
        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.isSearching = false
                self.nextSearchingPage = 0
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - Private methods
private extension ImagesCollectionViewController {
    func setupNavBar() {
        navigationItem.title = "Photos"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}
