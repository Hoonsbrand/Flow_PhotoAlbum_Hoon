//
//  AlbumVarieties.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/05.
//

import Foundation
import Photos

final class AlbumVarieties {
    private let Customalbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    private let SmartAlbumPanoramas = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: nil)
    private let SmartAlbumFavorites = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
    private let SmartAlbumSelfPortraits = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil)
    private let SmartAlbumScreenshots = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
    private let SmartAlbumBursts = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumBursts, options: nil)
    private let Cameraroll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)

    lazy var AlbumVarieties =  [Cameraroll, SmartAlbumSelfPortraits, SmartAlbumFavorites, SmartAlbumBursts, SmartAlbumPanoramas, SmartAlbumScreenshots, Customalbums]
}


