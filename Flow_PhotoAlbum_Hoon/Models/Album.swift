//
//  AlbumModel.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/04.
//

import UIKit
import Photos

struct Album {
    let name: String
    let count: Int
    let collection: PHAssetCollection
    let thumbnail: UIImage
    
    init(name: String, count: Int, collection: PHAssetCollection, thumbnail: UIImage) {
        self.name = name
        self.count = count
        self.collection = collection
        self.thumbnail = thumbnail
    }
}
