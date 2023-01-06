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
    func getAlbumsFromLocal(completion: @escaping (Album) -> Void) {
        
        // 앨범에 대한 정보를 받을 fetchResult 변수
        // asset들을 가져오는 fetchAsset의 리턴 타입과 동일한 PHFetchResult<PHAsset> 타입으로 선언해준다.
        var fetchResult: PHFetchResult<PHAsset>?
            
        // albumList에 들어있는 앨범들을 순회하면서 각 앨범의 정보를 가져온다.
        AlbumVarieties().albumList.forEach {
            
            $0.enumerateObjects { album, _, _ in
                // 앨범에서 Asset들을 추출해 fetchResult에 담는다.
                fetchResult = PHAsset.fetchAssets(in: album, options: nil)
                
                // 앨범의 사진 개수, 앨범에 사진이 없다면 즉시 return 하여 메서드를 종료시킴.
                guard let albumCount = fetchResult?.count, albumCount > 0 else { return }
                
                // PHAssetCollection의 localizedTitle을 이용해 앨범 타이틀 가져오기
                let albumTitle: String = album.localizedTitle!
                
                var thumbnailAsset = PHAsset()
                print("DEBUG: title: \(albumTitle), type: \(album.assetCollectionType)")
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
                    guard let thumbnailImage = image else { return }
                    
                    // 저장
                    let fetchedAlbum = Album(name:albumTitle, count: albumCount, collection: album, thumbnail: thumbnailImage)
                    
                    completion(fetchedAlbum)
                }
            }
        }
    }
    
    /// 선택된 앨범의 사진을 가져오는 메서드
    func getImageFromAlbum(index: Int, collection: PHAssetCollection, targetSize: CGSize, completion: @escaping (UIImage) -> Void) {
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: nil)
      
        // 고품질 사진 옵션 설정
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        // 각 Cell에 표시하기 위한 asset은 fetchResult를 index로 접근해 가져온다.
        let asset: PHAsset = fetchResult.object(at: index)
        
        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFit,
                                  options: option) { image, _ in
            guard let image = image else { return }
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


