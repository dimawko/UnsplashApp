//
//  TabBarViewController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    private func setupTabBar() {
        let photosVC = UINavigationController(rootViewController: PhotosCollectionViewController())
        let favoriteVC = UINavigationController(rootViewController: FavoriteTableViewController())
        photosVC.title = "Photos"
        favoriteVC.title = "Favorite"
        setViewControllers([photosVC, favoriteVC], animated: true)

        let images = ["photo", "heart.fill"]
        guard let items = tabBar.items else { return }
        for index in 0..<items.count {
            items[index].image = UIImage(systemName: images[index])
        }
    }
}
