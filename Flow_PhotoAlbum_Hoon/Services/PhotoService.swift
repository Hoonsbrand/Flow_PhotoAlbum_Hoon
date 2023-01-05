//
//  PhotoService.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/05.
//

import UIKit
import Photos

struct PhotoService {
    
    // MARK: - Properties
    
    static let shared = PhotoService()
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    // MARK: - Helpers
    
    /// 로컬 사진첩에 저장된 앨범들을 가져오는 메서드
    func getAlbumsFromLocal(completion: @escaping (Album) -> ()) {
        
        var fetchResult: PHFetchResult<PHAsset>?
    
        // 각 앨범의 사진 타이틀이름, 수 가져오기
        AlbumVarieties().AlbumVarieties.forEach {
            $0.enumerateObjects { album, index, stop in

                // PHAssetCollection의 localizedTitle을 이용해 앨범 타이틀 가져오기
                let albumTitle: String = album.localizedTitle!
                
                fetchResult = PHAsset.fetchAssets(in: album, options: nil)
                
                // 앨범의 사진 개수
                guard let albumCount = fetchResult?.count, albumCount > 0 else { return }
                
                var thumbnailAsset = PHAsset()
                
                // 썸네일 사진 가져오기
                switch album.assetCollectionType {
                    
                // 사용자 커스텀 앨범은 생성날짜 오름차순으로 정렬이 되기 때문에 첫번째 사진을 thumbnail로 사용한다.
                case PHAssetCollectionType(rawValue: 1) : thumbnailAsset = (fetchResult?.firstObject)!
                    
                default: thumbnailAsset = (fetchResult?.lastObject)!
                }
                
                // 고품질 사진 옵션 설정
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                
                imageManager.requestImage(for: thumbnailAsset,
                                               targetSize: CGSize(width: 70, height: 70),
                                               contentMode: .aspectFit,
                                               options: option) { image, _ in
                    guard let image = image else { return }
                    
                    // 저장
                    let fetchedAlbum = Album(name:albumTitle, count: albumCount, collection: album, thumbnail: image)
                    
                    completion(fetchedAlbum)
                }
            }
        }
    }
    
    /// 선택된 앨범의 사진을 가져오는 메서드
    func getImageFromAlbum(index: Int, collection: PHAssetCollection, targetSize: CGSize, completion: @escaping (UIImage) -> Void) {
        let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
      
        // 고품질 사진 옵션 설정
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        let asset: PHAsset = fetchResult.object(at: index)
        
        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFit,
                                  options: option) { image, _ in
            guard let image = image else { return }
            print(image)
            completion(image)
        }
    }
    
    /// 사진의 파일명, 파일크기를 가져오는 메서드
    func getPhotoInfo(collection: PHAssetCollection, index: Int, completion: @escaping(String, String) -> Void) {
        let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                
        let asset: PHAsset = fetchResult.object(at: index)

        let resources = PHAssetResource.assetResources(for: asset)
        guard let filename = resources.first?.originalFilename as? String else { return }
        
        var filesize = ""
        var sizeOnDisk: Int64 = 0
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            filesize = String(format: "%.2f", Double(sizeOnDisk) / (1024.0*1024.0)) + " MB"
        }
        
        completion(filename, filesize)
    }
}
