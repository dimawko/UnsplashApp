//
//  ImageCollectionSearchController.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 04.05.2022.
//

import UIKit

extension UISearchController {

    static func createSearchController(delegate: UIViewController, placeholder: String) -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = delegate as? UISearchControllerDelegate
        searchController.searchBar.delegate = delegate as? UISearchBarDelegate
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = placeholder
        return searchController
    }
}
