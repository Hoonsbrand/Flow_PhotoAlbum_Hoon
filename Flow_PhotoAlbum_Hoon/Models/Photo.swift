//
//  Photo.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/05.
//

import UIKit

struct Photo {
    let photosWithAlbumTitle: [String: [UIImage]]

    init(photosWithAlbumTitle: [String : [UIImage]]) {
        self.photosWithAlbumTitle = photosWithAlbumTitle
    }
}
