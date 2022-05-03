//
//  PhotoCollectionViewCell.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    static let identifier = "PhotoCollectionViewCell"

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.style = .medium
        return spinner
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(spinner)
    }

    override func layoutSubviews() {
        imageView.frame = contentView.bounds
        spinner.center = contentView.center
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
