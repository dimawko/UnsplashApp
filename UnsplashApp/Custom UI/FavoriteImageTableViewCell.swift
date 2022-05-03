//
//  FavoriteTableViewCell.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 29.04.2022.
//

import UIKit

class FavoriteImageTableViewCell: UITableViewCell {

    static let indetifier = "FavoriteTableViewCell"

    var representedIdentifier = ""

    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center

        return label
    }()

    var photoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return imageView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    private func setupCell() {
        addSubview(nameLabel)
        addSubview(photoImage)

        NSLayoutConstraint.activate([
            photoImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImage.topAnchor.constraint(equalTo: topAnchor),
            photoImage.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            photoImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            photoImage.widthAnchor.constraint(equalToConstant: 100),

            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
