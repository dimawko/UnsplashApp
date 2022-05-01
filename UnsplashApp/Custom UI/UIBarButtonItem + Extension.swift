//
//  UIBarButtonItem + Extension.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 30.04.2022.
//

import UIKit

class UIBarButtonItemExtension: UIBarButtonItem {

    convenience init(with image: String, and action: Selector) {
        self.init(image: UIImage(systemName: image), style: .plain, target: UIViewController.self, action: action)
    }
}
