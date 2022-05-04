//
//  PhotoCollectionViewCell.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 28.04.2022.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    static let identifier = "PhotoCollectionViewCell"

    var photoView: PhotoView = {
        let view = PhotoView()
        view.imageView.contentMode = .scaleAspectFill
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.imageView.image = nil
    }

    private func setupCell() {
        addSubview(photoView)

        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoView.topAnchor.constraint(equalTo: topAnchor),
            photoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
