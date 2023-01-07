//
//  AlbumController.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/03.
//

import UIKit
import Photos

final class AlbumController: UIViewController {
    
    // MARK: - Properties
    
    // 앨범 리스트를 받을 변수
    private var albumList = [Album]()
    
    // 전체 사진을 받을 변수
    private var photos = [[UIImage]]()
    
    // TableView 생성 & Cell 등록
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(AlbumListCell.self, forCellReuseIdentifier: AlbumListCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthAndLoadData()
        configureTableView()
        configureUI()
    }
    
    /// 다음 화면(PhotoController)의 뒤로가기 버튼에 제목을 없애기 위해
    /// View가 사라질 때 title을 없앰
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = ""
    }
    
    /// 다시 AlbumController로 돌아올 때 title을 설정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "앨범"
    }
    
    // MARK: - Helpers
    
    /// TableView Delegate&DataSource, rowHeight 설정
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 85
    }
    
    /// TableView Constraints 설정
    private func configureUI() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// PhotoController에 album을 넘겨주며 pushView로 화면 전환
    private func pushView(album: Album, index: Int) {
        let vc = PhotoController(album: album, photos: photos[index])
        
//        print("DEBUG: photosWithAlbumTitle: \(photosWithAlbumTitle[album.name]!)")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 앨범접근 허가요청 AlertView
    private func showAlertView() {
        let alert = UIAlertController(title: "접근을 허가해주세요.",
                                      message: "앨범을 조회하기 위해 설정 앱에서 모든 사진에 대한 접근을 허가해주세요.",
                                      preferredStyle: .alert)
        
        // 모든 사진에 대해 승인을 하지 않으면 "이동", "취소" 두개의 버튼 선택지가 있다.
        // 1. 이동을 누르게 되면 설정창으로 이동을 한다.
        // 설정창에서 승인 범위를 모든 사진으로 하고 앱으로 돌아오면 정상적으로 작동을 한다.
        let getAuthAction = UIAlertAction(title: "이동", style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings,options: [:],completionHandler: nil)
            }
        })
        
        // 2. 취소를 누르게 되면 앱을 종료시킨다.
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
        
        alert.addAction(getAuthAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

// MARK: - getAlbumsFromLocal: 로컬 사진첩으로부터 앨범 가져옴

extension AlbumController {
    /// 로컬 사진첩으로부터 앨범을 가져옴
    private func getAlbumsFromLocal() {
        PhotoService.shared.getAlbumsFromLocal { fetchedAlbums, photos in
            self.albumList.append(fetchedAlbums)
            self.photos = photos

            print("DEBUG: ----------\(fetchedAlbums.name)-----------")
            print("DEBUG: photos: \(photos)")
        }
    }
}

// MARK: - checkAuthAndLoadData

extension AlbumController {
    /// 앨범 접근권한 승인요청
    private func checkAuthAndLoadData() {
        let photoLibraryAuthrizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorizationStatus in
            switch photoLibraryAuthrizationStatus {
                
            // 앱 첫 진입 시 권한 승인에 대한 case는 .notDetermined에서 이루어진다.
            // 밑에있는 .authorized와 default는 첫 승인 요청 후 앱 내에 적용되어 있는 승인 여부에 따라 호출이 된다.
            case .notDetermined:
                print("권한에 대한 승인 보류")
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorizationStatus in
                    switch authorizationStatus {
                        
                    // 모든 사진에 대해 승인 되었을 때
                    case .authorized:
                        print("권한이 승인됨.")
                        self.getAlbumsFromLocal()
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    // 모든 사진에 대한 승인 외 나머지
                    default:
                        self.showAlertView()
                    }
                }
                
            // 모든 사진에 대해 승인 되었을 때
            case .authorized:
                print("권한이 승인됨.")
                self.getAlbumsFromLocal()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            
            // 모든 사진에 대한 승인 외 나머지
            default:
                self.showAlertView()
            }
        }
    }
}


// MARK: - UITableViewDelegate/DataSource

extension AlbumController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumListCell.reuseIdentifier, for: indexPath) as! AlbumListCell
        
        cell.selectionStyle = .none
        cell.album = albumList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushView(album: albumList[indexPath.row], index: indexPath.row)
    }
}



