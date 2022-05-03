//
//  FavoriteTableViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit
import RealmSwift

class FavoriteImagesTableViewController: UITableViewController {

    private var favoriteImages: Results<Image>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorite"
        setupTableView()
        favoriteImages = StorageManager.shared.realm?.objects(Image.self)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Table view data source and delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteImages?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteImageTableViewCell.indetifier,
            for: indexPath) as? FavoriteImageTableViewCell else {
            return UITableViewCell()
        }

        guard let favoriteImage = favoriteImages?[indexPath.row] else { return UITableViewCell() }

        cell.nameLabel.text = favoriteImage.user?.name
        cell.photoImage.image = nil

        let representerIdentifier = favoriteImage.id
        cell.representedIdentifier = representerIdentifier

        NetworkManager.shared.fetchImage(imageType: .small, imageData: favoriteImage) { result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    if cell.representedIdentifier == representerIdentifier {
                        cell.photoImage.image = image
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let favoriteImageDetails = favoriteImages?[indexPath.row] else { return }

        let imageDetailsVC = ImageDetailsViewController()
        imageDetailsVC.modalPresentationStyle = .currentContext
        imageDetailsVC.imageDetails = favoriteImageDetails

        self.navigationController?.pushViewController(imageDetailsVC, animated: true)
    }
}

// MARK: - Private methods
private extension FavoriteImagesTableViewController {
    func setupTableView() {
        self.tableView.register(FavoriteImageTableViewCell.self, forCellReuseIdentifier: FavoriteImageTableViewCell.indetifier)
        tableView.rowHeight = 100
    }
}
