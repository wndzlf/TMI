//
//  ViewController.swift
//  TMI
//
//  Created by CHOMINJI on 2018. 12. 30..
//  Copyright © 2018년 momo. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager() //이미지를 로드해 옴
    let cellIdentifier: String = "cell"
    var albums: [Album] = []
//    var albumList:[AlbumModel] = [AlbumModel]()
    var albumList: [AlbumModel] = []
    
    func GetAlbums() {
        let options: PHFetchOptions = PHFetchOptions()
        let getAlbums : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        // 앨범 정보
        print(getAlbums)
        for i in 0 ..< getAlbums.count{
            guard let assetCollection:PHAssetCollection = getAlbums[i] as! PHAssetCollection else {return}
            let albumTitle = assetCollection.localizedTitle
            let albumCount = assetCollection.estimatedAssetCount
            print(assetCollection.localizedTitle)
            print(assetCollection.estimatedAssetCount)
            // 위 글에서 특정앨범의 정보를 가져오는 fetchAssetsInAssetCollection 을 사용한다
            // PHFetchResult의 타입의 상수에 값을 저장한다
            // PHFetchResult 의 result 값에 count 가 있다
            let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            // 출력 시 기존 생성된 앨범들의 사진 및 비디오 수가 나옴
            print("assetsFetchResult.count=\(assetsFetchResult.count)")
            let newAlbum = AlbumModel(name: albumTitle ?? "", count: albumCount, collection: assetCollection)
                    print(newAlbum.name)
                    print(newAlbum.count)
                    //앨범 정보 추가
                    albumList.append(newAlbum)
        }
    }
    
    func requestCollection() {
        
        let cameraRoll: PHFetchResult<PHAssetCollection> =
            PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
//        guard let album = cameraRoll.firstObject else { return }
        let lastIndex: Int = cameraRoll.count
        print(lastIndex)
//        let validIndices = Set(0..<7).subtracting([2, 4, 5])
//        print(validIndices)
        // Prints "[6, 0, 1, 3]"
        let indexSet = IndexSet(0..<lastIndex)
//        print(indexSet)
//        guard let album = cameraRoll.objects(at: indexSet) else {return}
//
//        let al = cameraRoll.
//        let albumTitle : String = album.localizedTitle!
//        // 이미지만 가져오도록 옵션 설정
//        let fetchOptions2 = PHFetchOptions()
//        fetchOptions2.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//        let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions2)
//        // PHFetchResult 의 count 을 이용해 앨범 사진 갯수 가져오기
//        let albumCount = assetsFetchResult.count
//        // 저장
//        let newAlbum = AlbumModel(name:albumTitle, count: albumCount, collection:album)
//        print(newAlbum.name)
//        print(newAlbum.count)
//        //앨범 정보 추가
//        albumList.append(newAlbum)
//
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
////        self.fetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        //사용자가 사진첩에 접근을 허가했는지
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가됨")
//            self.requestCollection() //허가되어있으면 collection 불러옴
            self.GetAlbums()
            //            self.tableView.reloadData()
            OperationQueue.main.addOperation {
                self.collectionView.reloadData()
            }
        case .denied:
            print("접근 불허됨")
        case .notDetermined: //허가하는지 안하는지 선택하지 않으면
            print("아직 응답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in //다시 허가 요청
                switch status {
                case .authorized:
                    print("사용자가 허용함")
//                    self.requestCollection()
                    self.GetAlbums()
                case .denied:
                    print("사용자가 불허함")
                default: break
                }
            })
        case .restricted:
            print("접근 제한")
        }
        
        PHPhotoLibrary.shared().register(self) //포토 라이브러리가 변화될 때마다 델리게이트가 호출됨
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return self.albums.count
//        return 5
//       return self.fetchResult?.count ?? 0
        return albumList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! AlbumCollectionViewCell

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! AlbumCollectionViewCell
        
//        cell.titleLabel.text = Data[indexPath.row]["titleLabel"]
        let album: AlbumModel = self.albumList[indexPath.item]
//        let asset: PHAsset = fetchResult.object(at: indexPath.row)
        
//        imageManager.requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil) { image, _ in
//            cell.titleImageView.image = image
//        }
        cell.titleLabel.text = album.name
        cell.imageCountLabel.text = String(album.count)
        
        //        let album: Album = self.albums[indexPath.item]
        //        cell.titleImageView.image = album.titleImage
        //        cell.titleLabel.text = album.name
        //        cell.imageCountLabel = album.
        //
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell")
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        <#code#>
    }
    
    
    
}

