//
//  FavoriteTableViewCell.swift
//  UnsplashApp
//
//  Created by Dinmukhammed Sagyntkan on 29.04.2022.
//

import UIKit

final class FavoriteImageTableViewCell: UITableViewCell {

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

    var photoView: PhotoView = {
        let photoView = PhotoView()
        photoView.imageView.layer.cornerRadius = 10
        return photoView
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
        addSubview(photoView)

        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            photoView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            photoView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            photoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            photoView.widthAnchor.constraint(equalToConstant: 100),

            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
