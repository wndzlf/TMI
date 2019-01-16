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
        
        let fetchOptions = PHFetchOptions()
        print(getAlbums)
        for i in 0 ..< getAlbums.count{
            guard let assetCollection:PHAssetCollection = getAlbums[i] else {return}
            let albumTitle = assetCollection.localizedTitle
            let albumCount = assetCollection.estimatedAssetCount
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            print(assetCollection.localizedTitle)
            print(assetCollection.estimatedAssetCount)
            
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let manager = PHImageManager.default()
            let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            if assetsFetchResult.count > 0 {
                // 가져온 사진중 마지막 사진을 선택하고
                if let imageAsset = assetsFetchResult.lastObject {
                    // 불러올 사진의 이미지 옵션값을 넣은 다음
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = false
                    requestOptions.deliveryMode = .highQualityFormat
                    //requestImageForAsset 을 이용해 이미지를 불러온다
                    manager.requestImage(for: imageAsset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: requestOptions, resultHandler:
                        { image, _ in
                            let newAlbum = AlbumModel(name: albumTitle ?? "", count: albumCount, image: image!, collection: assetCollection)
                            print(newAlbum.name)
                            print(newAlbum.count)
                            //앨범 정보 추가
                            self.albumList.append(newAlbum)
                    })
                }
            
//            albumTitleImage = PHAsset.fetchAssets(in: thumbnailImage, options: fetchOptions)
                
            
            // 위 글에서 특정앨범의 정보를 가져오는 fetchAssetsInAssetCollection 을 사용한다
            // PHFetchResult의 타입의 상수에 값을 저장한다
            // PHFetchResult 의 result 값에 count 가 있다
            let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            // 출력 시 기존 생성된 앨범들의 사진 및 비디오 수가 나옴
            print("assetsFetchResult.count=\(assetsFetchResult.count)")
           
            }
        }
    }
    
    func requestCollection() {
        
        let cameraRoll: PHFetchResult<PHAssetCollection> =
            PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        guard let thumbnailImage = cameraRoll.firstObject else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(in: thumbnailImage, options: fetchOptions)
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! AlbumCollectionViewCell
        
//        cell.titleLabel.text = Data[indexPath.row]["titleLabel"]
        let album: AlbumModel = self.albumList[indexPath.item]
        cell.titleImageView.image = album.image
        cell.titleLabel.text = album.name
        cell.imageCountLabel.text = String(album.count)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell")
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        <#code#>
    }
    
    
    
}

