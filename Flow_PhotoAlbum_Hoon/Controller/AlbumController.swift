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
    private func pushView(album: Album) {
        let vc = PhotoController(album: album)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 앨범접근 허가요청 AlertView
    private func showAlertView(completion: @escaping (UIAlertAction) -> ()) {
        let alert = UIAlertController(title: "접근을 허가해주세요.",
                                      message: "앨범을 조회하기 위해 모든 사진에 대한 접근을 허가해주세요.",
                                      preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default, handler: completion)
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

// MARK: - getAlbumsFromLocal: 로컬 사진첩으로부터 앨범 가져옴

extension AlbumController {
    /// 로컬 사진첩으로부터 앨범을 가져옴
    private func getAlbumsFromLocal() {
        PhotoService.shared.getAlbumsFromLocal { fetchedAlbums in
            self.albumList.append(fetchedAlbums)
        }
    }
}

// MARK: - checkAuthAndLoadData

extension AlbumController {
    /// 앨범접근 허가 요청
    private func checkAuthAndLoadData() {
        let photoLibraryAuthrizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibraryAuthrizationStatus {
        case .authorized:
            self.getAlbumsFromLocal()
            self.tableView.reloadData()
            
        default:
            showAlertView { _ in
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
            break
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
        pushView(album: albumList[indexPath.row])
    }
}


