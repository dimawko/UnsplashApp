//
//  FavoriteTableViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit
import RealmSwift

class FavoriteTableViewController: UITableViewController {

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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteImages?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteTableViewCell.indetifier,
            for: indexPath) as? FavoriteTableViewCell else {
            return UITableViewCell()
        }

        guard let favoriteImage = favoriteImages?[indexPath.row] else { return UITableViewCell() }

        cell.nameLabel.text = favoriteImage.user?.name
        cell.photoImage.image = nil

        let representerIdentifier = favoriteImage.id
        cell.representedIdentifier = representerIdentifier

        NetworkManager.shared.fetchImage(with: favoriteImage) { result in
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
        guard let favoriteImage = favoriteImages?[indexPath.row] else { return }

        guard let cell = tableView.cellForRow(at: indexPath) as? FavoriteTableViewCell  else { return }

        let photoDetailsVC = PhotoDetailsViewController()
        photoDetailsVC.modalPresentationStyle = .currentContext
        photoDetailsVC.photoDetails = favoriteImage
        photoDetailsVC.image = cell.photoImage.image
        
        self.navigationController?.pushViewController(photoDetailsVC, animated: true)
    }

    private func setupTableView() {
        self.tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.indetifier)
        tableView.rowHeight = 100
    }
}
