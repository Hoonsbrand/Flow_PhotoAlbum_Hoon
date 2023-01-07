//
//  AlbumListCell.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/03.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
 
    // MARK: - Properties
    
    // 사진 View
    var photoView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers

    private func configureUI() {
        self.addSubview(photoView)
        photoView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}

// MARK: - ReuseIdentifier

extension PhotoCell: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
