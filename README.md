<aside> 💡  `아키텍쳐 패턴`:  **MVVM**  `UI`:  **Code Base(No Storyboard)**  `외부 라이브러리 사용 여부`: ❌  

</aside>

# ⭐️ main branch

<aside> 💡 현재 노션에서 기재되어있는 코드는  **main**  **branch**  의 코드이다. main branch 의 앨범과 사진을 가져오는 로직은  **AlbumController**  에서 앨범 정보를  **PhotoController**  로 전달 후  **PhotoController**  에서 해당 앨범의 정보로 사진들을  **UIImage**  로 요청을 한다.

</aside>

# develop branch

<aside> 💡 기존의 방식과는 다르게  **AlbumController**  에서 앨범 정보를 받을 때 모든 사진에 대한 정보도 같이 받아온다. 그 후  **PhotoController**  로 데이터를 전달할 때 앨범의 정보가 아닌 이미 받아놓은  **UIImage**  배열을 전달하여 화면에 표시하는 방식이다. 개인적으로  **main branch**  의 방식이 더 안정적이라고 생각한다.

</aside>

# `프로젝트 구조`

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a507f4d5-23af-44f8-92ea-a6284cdbf0e5/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032329Z&X-Amz-Expires=86400&X-Amz-Signature=08aedb7e2a706142fa1b0a62c2cb2134a55e2e4a1e8f424ac37208a3d380a229&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%22Untitled.png%22&x-id=GetObject)

-   `Models`
    -   **Album**
        -   로컬에 저장된 앨범을 받아 저장하기 위한 모델 struct 로 구현했으며 생성자를 통해 총 4개의 멤버 변수에 할당
    -   **AlbumVarieties**
        -   앨범의 종류를 정의해놓은 class 앨범을 가져오려는 쪽에서 사용하게 된다.
-   `Services`
    -   **PhotoService**
        -   로컬 사진첩에 저장된 앨범들을 가져오는 메서드, 선택된 앨범의 사진을 가져오는 메서드, 선택된 사질의 파일명, 파일크기를 가져오는 메서드 총 3개로 구성이 되어있다. 앨범과 사진 Fetching에 관련된 메서드를 모아놓은 struct
-   `Utils`
    -   **UIView+Extension**
        -   UIView의 extension으로 Constraint를 구성할 때 더 편리하게 도와주는 메서드들이 있다.
    -   **Protocols**
        -   Reusable Cell Identifier를 보다 안전한 방법으로 사용하기 위한 프로토콜이 선언되어 있다.
-   `Controllers`
    -   **AlbumController**
        -   PhotoService의 메서드를 통해 앨범들을 가져와 UITableView에 보여주는 Controller
    -   **PhotoController**
        -   AlbumController로 부터 전달받은 앨범을 PhotoService 메서드의 파라미터로 사용해 해당 앨범의 사진을 가져와 UICollectionView에 보여주는 Controller
-   `ViewModels`
    -   **AlbumViewModel**
        -   AlbumListCell에서 사용할 String과 UIImage를 반환
-   `Views`
    -   **AlbumListCell**
        -   AlbumController에서 사용하는 Cell 이며, Cell의 UI를 구성하고 ViewModel과 통신하여 각 UI 요소에 알맞은 데이터를 할당하여 표시한다. 총 3개의 UI 요소가 있다.
    -   **PhotoCell**
        -   PhotoController에서 사용하는 Cell 이며, Cell의 UI를 구성하며 단 하나만의 요소가 존재하며 데이터 할당을 AlbumController에서 직접 하기 때문에 ViewModel이 없다.

----------

<aside> 💡 앨범, 특정 앨범의 사진, 사진의 정보를 가져오는 메서드는  **PhotoService**  내에 정의되어 있다.  `앨범, 사진, 사진 정보`  순으로 설명

</aside>

`앨범 접근권한 승인에 대한 내용까지 기재하면 더 길어질거같아 따로 첨부`

[**앨범 접근권한 승인요청**](https://www.notion.so/d46f8bf3b91c4eeea335aa02de2129a2)

# 앨범을 가져온 방법

# `1) 앨범정보와 썸네일을 가져오는 메서드 생성`

### PhotoService -  **`getAlbumsFromLocal()`**

```swift
func getAlbumsFromLocal(completion: @escaping (Album) -> Void) { }

```

> 로컬 사진첩으로부터 앨범들을 가지고 오는 동작을 수행하여 getAlbumsFromLocal 이라 작명함. completion 으로 Album 타입을 넘겨주어 AlbumController 내의 멤버 변수에 할당하게 해준다.

```swift
// 앨범에 대한 정보를 받을 fetchResult 변수
// asset들을 가져오는 fetchAsset의 리턴 타입과 동일한 PHFetchResult<PHAsset> 타입으로 선언
var fetchResult: PHFetchResult<PHAsset>?

// albumList에 들어있는 앨범들을 순회하면서 각 앨범의 정보를 가져온다.
AlbumVarieties().albumList.forEach {
    $0.enumerateObjects { album, _, _ in
  
        fetchResult = PHAsset.fetchAssets(in: album, options: nil)
        
        // 앨범의 사진 개수, 앨범에 사진이 없다면 즉시 return 하여 메서드를 종료시킴
        guard let albumCount = fetchResult?.count, albumCount > 0 else 
				{ return }

				// PHAssetCollection의 localizedTitle을 이용해 앨범 타이틀 가져오기
        let albumTitle: String = album.localizedTitle!
        
        var thumbnailAsset = PHAsset()
        
        // 썸네일 사진 가져오기
        switch album.assetCollectionType {
            
        // 사용자 커스텀 앨범은 생성날짜 오름차순으로 정렬이 되기 때문에 첫번째 사진을 thumbnail로 사용한다.
        case PHAssetCollectionType(rawValue: 1) : thumbnailAsset = (fetchResult?.firstObject)!
            
        default: thumbnailAsset = (fetchResult?.lastObject)!
}

```

> 앨범을 가져오는 메서드에서는 총 3가지의 작업을 한다.

`1. 앨범 썸네일 가져오기 2. 앨범의 사진 수 가져오기 3. 앨범을 completion 으로 전달하기`

`AlbumVarieties().albumList.forEach`

-   **albumList**를 순회하면서 각 앨범의 정보를 가져온다.

`$0.enumerateObjects { album, … }`

-   **forEach**를 통해 나오는  **$0**은  **PHFetchResult**  이다.  **PHFetchResults**를  **enumerate**로 접근을 하게 되면  **PHAssetCollection**  타입을 넘겨 받을 수 있고, 이를  **album**이라 작명하였다. 이제 이  **album**을 통해  **asset**들을 추출할 수 있게 된다.

`fetchResult`

-   받아온  **album**을  **fetchAssets**  메서드를 사용하여  **PHAssetCollection**에서  **asset**들을 가져온 결과를 받을 수 있다. 해당 변수를 이용하여  **asset**에 접근할 수 있다.

`guard let albumCount = …`

-   **guard-let**  구문은 앨범에 사진이 없으면 메서드를 종료 시키기 위해 작성하였다. 개발 초기에 해당 조건을 걸지 않았더니 사진이  **0**개인 앨범들도 콘솔에 표시가 되는걸 발견하고 작성하였다.

`albumTitle`

-   **PHAssetCollection**  에서 제공하는 프로퍼티이며, 앨범의 제목을 가져올 수 있다.

`thumbnailAsset`

-   썸네일을 담기 위한  **PHAsset**  타입의 변수,  **fetchResult**에서 썸네일로 사용할  **asset**을 담아준다.

`switch album.assetCollectionType`

-   사용자가 직접 만든 앨범의 순서 때문에 만든  **switch**문 직접 내 아이폰으로 사진첩 앱을 보던 중, 사용자가 직접 만든 앨범은 날짜순이 아닌 “앨범에 추가한 순”으로 정렬이 되고 가장 처음 앨범에 넣은 사진이 썸네일 사진으로 쓰이는 걸 발견하였다! 그래서 앨범의 타입이 다를것이다라고 생각하여 콘솔에 앨범 이름과 타입을 출력해보았다.

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/c32e0e74-6f99-41b9-847d-f4e567e23dd2/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032423Z&X-Amz-Expires=86400&X-Amz-Signature=7aff906a5162df6e7613e642d3384201256d765328c40805fa98eccd03618c10&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%22Untitled.png%22&x-id=GetObject)

> 3번째에는 제가 직접 시뮬레이터에서 만든 앨범 정보가 출력되어있다.  **rawValue**가  **1**로 나타나며 공식문서에 따라  **1**은  **album**,  **2**는  **smartAlbum**이라는 것을 알았다.
> 
> **`case** PHAssetCollectionType(rawValue: 1) :`
> 
> -   그리하여 사용자가 직접 만든 앨범**(rawValue: 1)**은  **fetchResult**의  `첫번째 오브젝트`  즉, 첫번째 사진이 되어야 하고, 나머지  **smartAlbum**은 최신순으로 정렬이 되서 결과가 나오니  `마지막 오브젝트`를 썸네일로 설정하게 하였다.

```swift
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

```

> 이제 썸네일  **asset**을 가져왔으니 실제로 화면에 표시하기 위해  **UIImage**로 받아오는 작업을 하면 해당 메서드의 역할은 끝이난다.

`option.isSynchronous = true`

-   이미지를 받아오는 작업을 동기적으로 실행하여 고화질 이미지를 받아올 때 까지 모든 동작을 멈춘다.

`let fetchedAlbum = Album(…)`

-   **requestImage**를 통해 이미지를  **UIImage**로 받아오고 나면 이제  **Album**  구조체를 완성시킬 수 있다. 위에서 이미 받아온  **name, count, collection**에 이어서  **UIImage**로 받은  **thumbnailImage**를 생성자에 할당하여  **Album**  구조체를 생성한다.

`completion(fetchedAlbum)`

-   **completion**에 위에서 생성한  **Album**구조체를 담아 내보내준다.  **escaping**  클로저로 해당 메서드가 끝나도 외부에서 해당  **Album**  구조체를 사용할 수 있다.

# `2) 받아온 앨범정보와 썸네일을 화면에 표시하기`

### AlbumController

```swift
private var albumList = [Album]()

private func getAlbumsFromLocal() {
    PhotoService.shared.getAlbumsFromLocal { fetchedAlbums in
        self.albumList.append(fetchedAlbums)
    }
}

```

> `albumList`

-   **AlbumController**의  **[Album]**  타입의 멤버변수 앨범 리스트를 받아 화면에 표시해야하므로  **albumList**를  **Album**  구조체들을 가지게 만들었다.

`getAlbumsFromLocal()`

-   **PhotoService**의  **getAlbumsFromLocal**  메서드를 호출해  **completion**  으로 넘어온  **fetchedAlbums**를 멤버변수인  **albumList**에 추가해준다.

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
 -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: 
AlbumListCell.reuseIdentifier, for: indexPath) as! AlbumListCell
    
    cell.selectionStyle = .none
    cell.album = albumList[indexPath.row]
    
    return cell
}

```

> **albumList**를 각 행으로 접근하여 해당  **index**에 해당하는 앨범을  **AlbumListCell**의 멤버변수  **album**에 할당해준다.

### AlbumListCell

```swift
var album: Album? {
    didSet { configureUI() }
}

private func configureUI() {
    guard let album = album else { return }
    let viewModel = AlbumViewModel(album: album)
    
    thumbnailImage.image = viewModel.thumbnailImage
    titleLabel.text = viewModel.albumTitle
    imageCountLabel.text = viewModel.imageCount
}

```

> **AlbumListCell**의  **album**  변수에 값이 할당이 되면 **configureUI()**를 호출한다. 그 후  **AlbumViewModel**  을 생성하여 프로퍼티를 이용해 각  **UI**  요소에 알맞은 값을 할당한다.

### AlbumViewModel

```swift
struct AlbumViewModel {
    
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
    
    init(album: Album) {
        self.album = album
    }
}

```

# ▶️ 실행 결과

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/e5e8b99a-aa95-4072-83f2-ff1e808a936d/12.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032441Z&X-Amz-Expires=86400&X-Amz-Signature=b03b27a6f483d10285d9bed9d5b46cb6a2a04fee600e6f5c40ca8b1b80156642&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%2212.gif%22&x-id=GetObject)

# `실제 앨범과의 비교`

### 프로젝트
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/afca97d3-28d9-4e97-81c8-c65e9057e597/simulator_screenshot_2569C199-792C-429A-8C05-7970D5A41475.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032451Z&X-Amz-Expires=86400&X-Amz-Signature=f4eaac847f798890d9a354cd29c8dde393a2e06c8fccb91975e6952bd50369af&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%22simulator_screenshot_2569C199-792C-429A-8C05-7970D5A41475.png%22&x-id=GetObject)



---
### 아이폰 사진첩
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/7585d9e0-a86a-412e-9155-25624104f4d3/simulator_screenshot_93B0F421-940B-4AE5-8A1E-0A0E6022D48D.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032506Z&X-Amz-Expires=86400&X-Amz-Signature=ea57073b8253128f1b6f9c724ab7f3320c85719c1bee9d39213e65209e62281f&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%22simulator_screenshot_93B0F421-940B-4AE5-8A1E-0A0E6022D48D.png%22&x-id=GetObject)



----------

# 💡선택된 앨범으로부터 사진을 가져온 방법💡

# `1) 어떤 앨범이 선택됐는지 받아오기`

### AlbumController (선택된 앨범을  `보내는 쪽`)

```swift
private func pushView(album: Album) {
    let vc = PhotoController(album: album)
    
    self.navigationController?.pushViewController(vc, animated: true)
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    pushView(album: albumList[indexPath.row])
}

```

### PhotoController (선택된 앨범을  `받는 쪽`)

```swift
private var album: Album

init(album: Album) {
    self.album = album
    super.init(nibName: nil, bundle: nil)
}

```

> **AlbumController**  의  **TableView**  각 행을 클릭하면  **PhotoController**  로 넘어가는데 이때  **PhotoController**  의 생성자 파라미터로 클릭한 행의  **Album**  을 넘겨준다.

# `2) 선택된 앨범의 사진을 가져오는 메서드 생성`

### PhotoService -  `getImageFromAlbum()`

```swift
func getImageFromAlbum(index: Int, collection: PHAssetCollection, 
											targetSize: CGSize = PHImageManagerMaximumSize, 
											completion: @escaping (UIImage) -> Void) {

    let fetchResult: PHFetchResult<PHAsset>
		 = PHAsset.fetchAssets(in: collection, options: nil)
  
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

```

> **—————————[파라미터]—————————**  `index`:  **CollectionView**의  **item**들에 사진을 표시할 것이기 때문에 각  **item**들의  **indexPath**를 받아 해당  **index**를 이용해  **fetchResult**에 접근해  **asset**을 받아온다.

`collection`: 어떤 앨범에서  **asset**을 가져올것인지는 사용자가 클릭을 할 때 까지는 모른다. 그러므로  **PHAssetCollection**  타입의 파라미터를 받아 앨범을 클릭할 때 어떤 앨범인지  **getImageFromAlbum**  메서드 측에서 알 수 있다.

`targetSize`: 이미지 사이즈를 받을 파라미터. 기본값으로 최대 해상도인  **PHImageManagerMaximumSize**  을 사용합다.

`completion`:  **UIImage**를 넘겨  **Cell**에 표시할 수 있게 한다.  **—————————[파라미터]—————————**

`fetchResult`

-   파라미터로 받은  **PHAssetCollection**  타입의  **collection**을  **fetchAssets**  메서드의 파라미터로 사용해 해당 앨범(**collection**)의  **asset**들을 받아온다.

`asset`

-   앨범의  **asset**들을 받은  **fetchResult**의 타입은  **PHFetchResult<PHAsset>**  그러므로  **PHFetchResult**의 메서드인  **object**  로 접근을 하면 특정  **index**의  **PHAsset**을 받아올 수 있고, 이를 이용해 파라미터로 받은  **index**를 사용해 각  **Cell**에 알맞은 사진을 표시하게 해준다.

그 후 **requestImage()**를 이용해  **UIImage**를 받아  **completion**으로 넘겨준다.

# `3) 받아온 사진을 화면에 표시하기`

### PhotoController -  `collectionView(…, cellForItemAt: …)`

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell
(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
    
    let targetSize = cell.photoView.frame.size
    
    PhotoService.shared.getImageFromAlbum(index: indexPath.item,
                                          collection: album.collection) 
		{ image in
        cell.photoView.image = image
    }
 
    return cell
}

```

> **PhotoService**의  **getImageFromAlbum**  메서드를 호출하여 각 파라미터에 알맞은 값을 넣어준 후**completion**  으로 전달받은 **image(UIImage)**를  **cell.photoView**의 이미지로 할당을 해준다.**targetSize**  는 따로 값을 전달하지 않아 최대 해상도를 사용한다 그 후  **cell**을 반환해주면 각  **Cell**에 이미지들이 표시가 된다.

# ▶️ 실행 결과

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/c2b2d5d9-d0eb-4b30-a72b-912450c4ffd4/12.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032540Z&X-Amz-Expires=86400&X-Amz-Signature=ab65b5ef07711d0c7490534499cbccd95b7452085759919f2ef8e0a5b1ad20c5&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%2212.gif%22&x-id=GetObject)




----------

# 💡사진 정보를 가져온 방법💡

# `1) 사진의 파일명, 파일크기를 가져오는 메서드 생성`

### PhotoService -  `getPhotoInfo()`

```swift
func getPhotoInfo(collection: PHAssetCollection, index: Int, completion: 
		@escaping(String, String) -> Void) {

    // 선택한 사진이 속해있는 앨범
    let fetchResult: PHFetchResult<PHAsset> = 
				PHAsset.fetchAssets(in: collection, options: nil)
            
    // 사진을 클릭하여 선택된 에셋
    let asset: PHAsset = fetchResult.object(at: index)
    print("DEBUG: asset: \\(asset)")
    
    // 에섯의 정보가 담겨있는 resources
    let resources: [PHAssetResource] = 
				PHAssetResource.assetResources(for: asset)
    print("DEBUG: resources: \\(resources)")
    
    guard let resource = resources.first else { return }
    
    // 파일 이름
    guard let filename = resource.originalFilename as? String else { return }
    print("DEBUG: originalFilename's type: \\(type(of: resources.first?.originalFilename))")
    
    // 파일 크기
    var filesize = ""
   
    guard let byte = resource.value(forKey: "fileSize") as? UInt64 else 
		{ return }
    print("DEBUG: byte: \\(byte)")
    
    // MB로 변환한 String 값 할당
    filesize = String(format: "%.2f", Double(byte) / (1024.0*1024.0)) + " MB"
    
    completion(filename, filesize)
}

```

> **—————————[파라미터]—————————**  `collection`:  **PHAssetCollection**  타입으로 즉, 앨범을 파라미터로 받는다.

`index`:  **Int**  타입으로 사용자가 앨범에서 사진을 클릭할 때  **collection**에서  **object(at:)**  으로 접근하는데, 이 때, 몇번째 사진인지 전달해주기 위한 파라미터이다.

`completion`: 파일의 이름과 사이즈를 넘겨주기위한 두개의  **String**  인자로 구성되어있다.  **—————————[파라미터]—————————**

`fetchResult`

-   파라미터로 받은 **collection(앨범)**을  **fetchAssets**의 인자로 할당한다.

`asset`

-   앨범의  **asset**들을 받은  **fetchResult**의 타입은  **PHFetchResult<PHAsset>**  그러므로  **PHFetchResult**의 메서드인  **object**  로 접근을 하면 클릭한 사진의  **index**에 해당하는  **PHAsset**을 받아올 수 있다.

`resources`

-   **assetResources**  의 인자로  **asset**을 할당하면 그의 결과로 해당  **asset**의 정보를 가져온다.

`guard let resource = resources.first`

-   **resources**에서 이번 프로젝트에서 필요한 정보가 들어있는 첫번째 배열을 옵셔널 바인딩 하였다.

`**파일** **이름**: guard let filename`

-   **PHAssetResource**에서 제공하는  **originalFilename**  프로퍼티에 접근해 파일 이름을 가져올 수 있다.

`**파일 사이즈**: filesize`

-   **“fileSize”**  키를 이용해 값을 확인하면 바이트로 나오는 걸 볼 수 있다.  **UInt64**로 캐스팅을 해준 이유는 정상적인 파일의 사이즈는 양수로 나오기 때문에 양수만 사용하는  **UInt**를 사용하였고, 파일의 크기가 매우 클 수도 있기 때문에  **64비트**를 사용하였다.

그 후 소수점 2자리수까지 표현하며  **MegaByte**로 변환하는 공식을 사용하였다.

`completion`

-   모든 작업이 끝난 후  **filename**과  **filesize**를  **completion**으로 넘겨준다.

# `2) 받아온사진의 파일명, 파일크기를 Alert에 표시`

### PhotoController

```swift
private func showAlertView(alertTitle: String, filename: String, 
													 filesize: String) {
    let alert = UIAlertController(title: alertTitle, 
		message: "파일명 : \\(filename)\\n파일크기 : \\(filesize)", preferredStyle: .alert)                         
    
    let okButton = UIAlertAction(title: "확인", style: .default)
    
    alert.addAction(okButton)
    present(alert, animated: true)
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    PhotoService.shared.getPhotoInfo(collection: album.collection, 
																index: indexPath.item) { filename, filesize in

        self.showAlertView(alertTitle: "사진정보", filename: filename,
													 filesize: filesize)
    }
}

```

> **didSelectItemAt**  에서  **PhotoService**  의  **getPhotoInfo**를 호출한다.  **collection**  인자로는  **AlbumController**넘겨받아 저장한 멤버변수인 album의 collection을,  **index**  인자로는 각  **item**을 클릭하면 제공되는 indexPath.item을 넘겨준다.

**getPhotoInfo**  를 호출하면  **completion**  으로  **filename**과  **filesize**를 받는데 이를 Alert알림을 띄어주는 메서드인  **showAlertView**의 인자로 넣는다.

# `실행 결과`

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/bf77af29-aa59-4997-80cc-0aeab36f1b7b/12.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032917Z&X-Amz-Expires=86400&X-Amz-Signature=fcefad00149656dedc00acda8cf50fd2e6cfae4ee3f36a1e3b34c961250cd72e&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%2212.gif%22&x-id=GetObject)

----------

# 문제점 해결

# `문제`

<aside> 💡 해상도가 높은 사진이 포함되어있는 앨범을 선택하여 조회하면 사진들을 가져오는 시간이 오래걸리고 그만큼 메모리를 많이 사용한다는 문제를 발견하였다.  **Recents**  앨범은  **11**장의 사진을 가지며 높은 해상도를 가진 사진들을 다수 포함하고 있는데,  **11**장을 넘어 수십장, 수천장이 된다면 더 큰 문제가 될거라 생각했다.

</aside>

# `기존코드`

### PhotoService -  `getImageFromAlbum()`

```swift
func getImageFromAlbum(..., targetSize: CGSize = PHImageManagerMaximumSize, ...)

```

> 기존 사진을  **UIImage**  로 바꾸는 메서드의  **targetSize**  파라미터는  **최대해상도**  사이즈가 기본값으로 설정이 되어있다.

### PhotoController -  `collectionView(…, cellForItemAt: …)`

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell
(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
    
    let targetSize = cell.photoView.frame.size
    
    PhotoService.shared.getImageFromAlbum(index: indexPath.item,
                                          collection: album.collection) 
		{ image in
        cell.photoView.image = image
    }
 
    return cell
}

```

> **getImageFromAlbum()**  을 호출하는  **PhotoController**  에서  **targetSize**  파라미터에 값을 전달하지 않아 기본값(**최대해상도**)을 사용한다.

### 이미지 요청 동기처리 (isSynchronous = true)

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/078fb728-a22e-41fa-b52f-4bf9df4f5ed8/1.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032936Z&X-Amz-Expires=86400&X-Amz-Signature=86cffc48edefd186ec8d325e4b762de2f4ac29d486385c3cb141fe8c232c847e&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%221.gif%22&x-id=GetObject)

### 이미지 요청 비동기처리 (isSynchronous = false)
  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/08f2a829-afb4-4c28-89a1-66aa88aa1dca/2.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T032950Z&X-Amz-Expires=86400&X-Amz-Signature=7f7371ba2deedcf25ce285c7e8331a7493f6d8b8145609be29f3352c0268bce4&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%222.gif%22&x-id=GetObject)

### 메모리 사용량

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/dbf94549-78a9-4cac-b4b9-b34e4ecb63e1/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T033001Z&X-Amz-Expires=86400&X-Amz-Signature=251cf06e32b054afac67383b6aa83f073fc5ee536d3992327b77da0e87f22a97&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%22Untitled.png%22&x-id=GetObject)

----------

# `해결방법`

<aside> 💡  **Asset**  에서  **UIImage**  를 받는 메서드인  **requestImage**  에서  **targetSize**  를 설정할 때, 사이즈에 대한 제한을 두었다.

</aside>

# `바꾼코드`

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
    
    PhotoService.shared.getImageFromAlbum(index: indexPath.item,
                        collection: album.collection,
                        targetSize: CGSize(width: 300, height: 300)) { image in
        cell.photoView.image = image
    }
    return cell
}

```

> **targetSize**  파라미터에  **width**,  **height**  값을  **300**으로 주며 더이상 기본값을 사용하지 않고 제한된 사이즈로 이미지를 받아온다.

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/94ac8e71-e270-4543-ae52-a0898b763a36/3.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T033017Z&X-Amz-Expires=86400&X-Amz-Signature=00793764e0fba929493cf3206871aff849a2186c941d235a984b4bc0009e2cf5&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%223.gif%22&x-id=GetObject)

> **gif**  로 확인을 하면 최고해상도의 이미지처리를 비동기로 했을 때와 비슷해보이지만, 실제로 실행을 해보면 확실히 더 부드러운 것을 확인하실 수 있다.

### 메모리 사용량

  
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a404ff92-f285-4a89-a7de-b729c37fb15f/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230210%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230210T033026Z&X-Amz-Expires=86400&X-Amz-Signature=3c07d03bca010cae539cd5304fa7069afb7141e78d87d58b263f31e2a8e629f8&X-Amz-SignedHeaders=host&response-content-disposition=filename%3D%22Untitled.png%22&x-id=GetObject)

> 메모리 사용량도 현저하게 줄어들며 사진의 개수가 현재보다 많아져도 기존의 방식보다는 훨씬 더 효율적인 메모리 관리를 할 수 있을것으로 예상이 된다.
