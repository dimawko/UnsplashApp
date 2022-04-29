//
//  FavoriteTableViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit
import RealmSwift

class FavoriteTableViewController: UITableViewController {

    private var favoriteImages: Results<Image>!

    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteImages = StorageManager.shared.realm?.objects(Image.self)

        self.tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.indetifier)
        title = "Favorite"
        tableView.rowHeight = 100
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteImages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteImage = favoriteImages[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.indetifier, for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = favoriteImage.user?.name
        NetworkManager.shared.fetchImage(with: favoriteImage) { result in
            switch result {
            case .success(let data):
                let cellimage = self.getImage(from: data)
                DispatchQueue.main.async {
                    cell.photoImage.image = cellimage
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favoriteImage = favoriteImages[indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) as? FavoriteTableViewCell  else { return }
        let photoDetailsVC = PhotoDetailsViewController()
        photoDetailsVC.modalPresentationStyle = .currentContext
        photoDetailsVC.photoDetails = favoriteImage
        photoDetailsVC.image = cell.photoImage.image
        self.navigationController?.pushViewController(photoDetailsVC, animated: true)
    }
    
    private func getImage(from data: Data?) -> UIImage? {
        guard let data = data else { return UIImage(systemName: "picture") }
        return UIImage(data: data)
    }
}
