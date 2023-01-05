//
//  AlbumViewModel.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/04.
//

import UIKit

struct AlbumViewModel {
    
    // MARK: - Properties
    
    let album: Album
    
    var albumTitle: String {
        return album.name
    }
    
    var imageCount: String {
        return String(album.count)
    }
    
    var thumbnailImage: UIImage {
        return album.thumbnail
    }
    
    // MARK: - Lifecycle
    
    init(album: Album) {
        self.album = album
    }
}
