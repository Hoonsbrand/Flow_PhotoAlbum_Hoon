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
                
                // UIImage로 가져오기
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
        
        // UIImage로 가져오기
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
        // 선택한 사진이 속해있는 앨범
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: nil)
                
        // 사진을 클릭하여 선택된 에셋
        let asset: PHAsset = fetchResult.object(at: index)
        print("DEBUG: asset: \(asset)")
        
        // 에섯의 정보가 담겨있는 resources
        let resources: [PHAssetResource] = PHAssetResource.assetResources(for: asset)
        print("DEBUG: resources: \(resources)")
        
        guard let resource = resources.first else { return }
        
        // 파일 이름
        guard let filename = resource.originalFilename as? String else { return }
        print("DEBUG: originalFilename's type: \(type(of: resources.first?.originalFilename))")
        
        // 파일 크기
        var filesize = ""
       
        guard let byte = resource.value(forKey: "fileSize") as? UInt64 else { return }
        print("DEBUG: byte: \(byte)")
        
        // MB로 변환한 String 값 할당
        filesize = String(format: "%.2f", Double(byte) / (1024.0*1024.0)) + " MB"
        
        completion(filename, filesize)
    }
}




