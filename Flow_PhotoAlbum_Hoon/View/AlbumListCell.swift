//
//  AlbumListCell.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/03.
//

import UIKit

final class AlbumListCell: UITableViewCell {
    
    // MARK: - Properties
    
    var album: Album? {
        didSet { configureUI() }
    }
    
    private let thumbnailImage: UIImageView = {
        let iv = UIImageView()
        iv.anchor(width: 70, height: 70)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private let imageCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(thumbnailImage)
        thumbnailImage.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 20)
        
        let albumInfoStack = UIStackView(arrangedSubviews: [titleLabel, imageCountLabel])
        addSubview(albumInfoStack)
        albumInfoStack.centerY(inView: self, leftAnchor: thumbnailImage.rightAnchor, paddingLeft: 20)
        albumInfoStack.axis = .vertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers

    private func configureUI() {
        guard let album = album else { return }
        let viewModel = AlbumViewModel(album: album)
        
        thumbnailImage.image = viewModel.thumbnailImage
        titleLabel.text = viewModel.albumTitle
        imageCountLabel.text = viewModel.imageCount
    }
}

// MARK: - ReuseIdentifier

extension AlbumListCell: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
