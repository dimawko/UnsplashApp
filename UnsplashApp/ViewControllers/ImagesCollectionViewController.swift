//
//  PhotosCollectionViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

class ImagesCollectionViewController: UICollectionViewController {

    private var randomImages: [Image] = []
    private var searchImages: [Image] = []
    private var isSearching = false
    private var loadMoreRandomImages = false

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
        return CGSize(width: view.frame.size.width / 3-1, height: 150)
    }
}

// MARK: - Networking
extension ImagesCollectionViewController {
    private func getRandomImages() {
        NetworkManager.shared.fetchImageData(
            dataType: [Image].self,
            url: LinkString.randomPhoto,
            query: "count=30"
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
        if loadMoreRandomImages == true {
            NetworkManager.shared.fetchImageData(
                dataType: [Image].self,
                url: LinkString.randomPhoto,
                query: "count=30"
            ) { result in
                switch result {
                case .success(let randomImages):
                    DispatchQueue.main.async {
                        let newIndexPaths = self.setupNewIndexPaths(for: randomImages)
                        self.randomImages.append(contentsOf: randomImages)
                        self.collectionView.insertItems(at: newIndexPaths)
                        self.loadMoreRandomImages = false
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    private func getSearchImages(searchText: String, searchPage: Int = 1) {
        NetworkManager.shared.fetchImageData(
            dataType: SearchResults.self,
            url: LinkString.searchPhoto,
            query: "query=\(searchText.lowercased())&per_page=30&page=\(searchPage)"
        ) { result in
            switch result {
            case .success(let searchResults):
                DispatchQueue.main.async {
                    if searchPage == 1 {
                        self.searchImages = searchResults.results
                        self.collectionView.reloadData()
                    } else {
                        let newIndexPaths = self.setupNewIndexPaths(for: searchResults.results)
                        self.searchImages.append(contentsOf: searchResults.results)
                        self.collectionView.insertItems(at: newIndexPaths)
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
        getSearchImages(searchText: searchText)
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
                print("will Display cell")
                loadMoreRandomImages = true
                getMoreRandomImages()
            }
        } else {
            guard let searchText = searchController.searchBar.text else { return }
            indexForLastVisibleCell = searchImages.count - 1
            if indexPath.row == indexForLastVisibleCell {
                var nextPage = 2
                print("will display Search cell")
                getSearchImages(searchText: searchText, searchPage: nextPage)
                nextPage += 1
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
