//
//  ViewController.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/03.
//

import UIKit

final class PhotoController: UIViewController {
    
    // MARK: - Properties
    
    // AlbumController에서 선택된 앨범을 담을 변수
    private var album: Album
    
    // AlbumController에서 넘겨준 선택된 앨범의 사진을 담을 배열
    private var photos: [UIImage]
    
    // CollectionView 생성
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureUI()
        print("DEBUG: photos: \(photos)")
    }
    
    /// 생성자 파라미터로 Album타입과 [UIImage] 타입을 받아 멤버변수에 할당
    init(album: Album, photos: [UIImage]) {
        self.album = album
        self.photos = photos
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    /// CollectionView Delegate & DataSource 설정
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// NavigationTitle & CollectionView Constraints 설정
    private func configureUI() {
        navigationItem.title = "\(album.name)"
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor,
                              bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    /// Alert를 띄어주는 메서드
    private func showAlertView(alertTitle: String, filename: String, filesize: String) {
        let alert = UIAlertController(title: alertTitle,
                                      message: "파일명 : \(filename)\n파일크기 : \(filesize)",
                                      preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension PhotoController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier,
                                                      for: indexPath) as! PhotoCell
        
        cell.photoView.image = photos[indexPath.item]
     
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PhotoService.shared.getPhotoInfo(collection: album.collection, index: indexPath.item) { filename, filesize in
            self.showAlertView(alertTitle: "사진정보", filename: filename, filesize: filesize)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        
        // item간의 간격
        flowLayout.minimumInteritemSpacing = 4
        // 행(row)간의 간격
        flowLayout.minimumLineSpacing = 4
        
        let itemSize = CGSize(width: view.frame.width / 3 - flowLayout.minimumLineSpacing,
                              height: view.frame.width / 3 - flowLayout.minimumLineSpacing)
        
        return itemSize
    }
}



