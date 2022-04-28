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
        self.setViewControllers([photosVC, favoriteVC], animated: true)

        let images = ["photo", "heart.fill"]
        guard let items = self.tabBar.items else { return }
        for x in 0..<items.count {
            items[x].image = UIImage(systemName: images[x])
        }
    }
}
