//
//  ViewController.swift
//  TMI
//
//  Created by CHOMINJI on 2018. 12. 30..
//  Copyright © 2018년 momo. All rights reserved.
//

import UIKit
import Photos
import CoreData

class AlbumGridVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBAction func mlBtn(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "theFirstRun")
    }
    
    @IBOutlet weak var albumGridCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var assetsFetchResult: PHFetchResult<PHAsset>!
    
    let imageManager: PHCachingImageManager = PHCachingImageManager() //이미지를 로드해 옴
    
    let requestOptions = PHImageRequestOptions()
    
    let options = PHImageRequestOptions()
    
    static var albumList: [AlbumModel] = []
    
    var albumDictionary: [String:[PHAsset]] = ["kakaoTalk":[], "everyTime": [], "instagram":[], "others":[]]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var recordArray = [Screenshot]()
    
    var fetchedRecordArray = [Screenshot]()
    
    var searchedLocalIdentifiers: [String] = []
    
    var searchedAssests : PHFetchResult<PHAsset>!
    
    var assetCollection: PHAssetCollection!
    
    var albumFound : Bool = false
    
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    var thumbnailSize: CGSize!
    
    var previousPreheatRect = CGRect.zero
    
    var searchController: UISearchController!
    
    var searchedAssetArray: [PHAsset] = []
    
    var searchImages: [UIImage] = []
    

    var isSearchButtonClicked = false

    var pixelBufferArray: [CVPixelBuffer] = []
    var maxIndexArray: [Int] = []
    

    fileprivate func setCollectionView() {
        DispatchQueue.main.async {
            
            self.activityIndicator.startAnimating()
            
            if UserDefaults.standard.object(forKey: "theFirstRun") != nil {
                self.retrieveAssets()
            } else {
                UserDefaults.standard.set(true, forKey: "theFirstRun")
                //앱 처음 실행
                //TODO: 인트로 부르기
                self.GetAlbums()
            }
            
            self.resetCachedAssets()
            
            self.albumGridCollectionView.reloadData()
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func authorizatePhotoState() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        //사용자가 사진첩에 접근을 허가했는지
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가됨")
            setCollectionView()
        case .denied:
            print("접근 불허됨")
        case .notDetermined: //허가하는지 안하는지 선택하지 않으면
            print("아직 응답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in //다시 허가 요청
                switch status {
                case .authorized:
                    self.setCollectionView()
                case .denied:
                    print("사용자가 불허함")
                default: break
                }
            })
        case .restricted:
            print("접근 제한")
        }
        
        /* //커스텀 앨범 추가
         let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addAlbum))
         self.navigationItem.rightBarButtonItem = addButton
         */
        
        PHPhotoLibrary.shared().register(self) //포토 라이브러리가 변화될 때마다 델리게이트가 호출됨
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumGridCollectionView.delegate = self
        albumGridCollectionView.dataSource = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        setUpSearchController()
        authorizatePhotoState()
       
        NotificationCenter.default.addObserver(self, selector: #selector(deleteItem(_:)),
                                               name: NSNotification.Name("deleteAsset"),
                                               object: nil)
    }
    
    /// - Tag: UnregisterChangeObserver
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name("deleteAsset"),
                                                  object: nil)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        albumGridCollectionView.reloadData()
        
        hideBottomToolbar()
        
        setThumNailSize()
    }
    
    private func hideBottomToolbar() {
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    private func setThumNailSize() {
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearch() {
            return fetchedRecordArray.count
        }
        return AlbumGridVC.albumList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? AlbumCollectionViewCell else {
            return .init()
        }
        
        if isSearch() {
            let fetchText: Screenshot = fetchedRecordArray[indexPath.item]
            
            let option = PHImageRequestOptions()
            
            let asset = searchedAssests.object(at: indexPath.item)
        
            activityIndicator.isHidden = false
            
            activityIndicator.startAnimating()
            
            option.resizeMode = .fast
            
            cell.representedAssetIdentifier = asset.localIdentifier
            
            print("localIdentifier: \(asset.localIdentifier)")
            imageManager.requestImage(for: asset,
                                      targetSize: thumbnailSize,
                                      contentMode: .aspectFill,
                                      options: option, resultHandler: { image, _ in
                                        // UIKit may have recycled this cell by the handler's activation time.
                                        // Set the cell's thumbnail image only if it's still showing the same asset.
                                        if cell.representedAssetIdentifier == asset.localIdentifier {
                                            cell.thumbnailImage = image
                                            cell.titleLabel.text = fetchText.albumName
                                            cell.imageCountLabel.text = nil
                                        }
            })
            activityIndicator.stopAnimating()
        } else {
            let album: AlbumModel = AlbumGridVC.albumList[indexPath.item]
            cell.thumbnailImage = album.image
            cell.titleLabel.text = album.name
            cell.imageCountLabel.text = String(album.count)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if isSearch() {
            guard let assetVC = storyBoard.instantiateViewController(withIdentifier: "AssetVC") as? AssetVC else {
                fatalError("Unexpected ViewController")
            }
            
            self.navigationController?.pushViewController(assetVC, animated: true)
            
            assetVC.asset = searchedAssests.object(at: indexPath.item)
            
        } else {
            
            guard let selectedVC = storyBoard.instantiateViewController(withIdentifier: "AssetGridVC") as? AssetGridVC else {
                fatalError("Unexpected ViewController")
            }
            
            self.navigationController?.pushViewController(selectedVC, animated: true)
            
            PopupAlbumGridVC.currentAlbumIndex = indexPath.item

            selectedVC.selectedAlbums = AlbumGridVC.albumList[indexPath.item].collection
        }
        
    }
    
    @objc func addAlbum(_ sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("New Album", comment: ""), message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Album Name", comment: "")
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default) { action in
            let textField = alertController.textFields!.first!
            if let title = textField.text, !title.isEmpty {
                // Create a new album with the entered title.
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                }, completionHandler: { success, error in
                    if !success { print("Error creating album: \(String(describing: error)).") }
                })
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func deleteItem(_ notification: Notification) {
        guard let _: String = notification.userInfo?["selectedAlbum"] as? String else {
            return
        }
        
        guard let selectedAssetIndex: [Int] = notification.userInfo?["selectedAssetIndex"] as? [Int] else {
            return
        }
        
        print("1234567890::::::::::::::::::::::::::::::::::")
        
        for i in selectedAssetIndex{
            print("-----",i)
        }
    }
}

//MARK:- CollectionViewFlowLayout
//cgImage.size = UIImage.size * UIImage.scale
extension AlbumGridVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.frame.width) / 2 - 20
        let height: CGFloat = (view.frame.width) / 2 + 28
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

extension AlbumGridVC: PHPhotoLibraryChangeObserver {
    /// - Tag: RespondToChanges
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard assetsFetchResult != nil else {
            return
        }
        
        guard let changes = changeInstance.changeDetails(for: assetsFetchResult) else {
            print("No change in fetchResultChangeDetails")
            return;
        }
        DispatchQueue.main.sync {
            
            print("Contains changes")
            assetsFetchResult = changes.fetchResultAfterChanges
            let insertedObjects = changes.insertedObjects
            if insertedObjects.count > 0 {
                print("Assets have been Inserted while TMI's running")
                for insertedAsset in insertedObjects{
                    imageManager.requestImage(for: insertedAsset,
                                              targetSize: thumbnailSize,
                                              contentMode: .aspectFill,
                                              options: requestOptions,
                                              resultHandler: { image, _ in
                                                
                                                let maxIndex =
                                                    self.screenshotPredict(image: image!)
                                                self.matchPlatform(maxIndex: maxIndex, imageAsset: insertedAsset)
                                                self.getText(screenshot: image!, localIdentifier: insertedAsset.localIdentifier, maxIndex: maxIndex)
                    })
                }//포토라이브러리에서 삽입된 이미지들 디비 저장 및 각 albums 배열에 저장완료
            }
            //삭제된 이미지 처리
            let removedObjects = changes.removedObjects
            if removedObjects.count > 0 {
                print("Assets have been Removed while TMI's running")
                let request: NSFetchRequest<Screenshot> = Screenshot.fetchRequest()
                for removedAsset in removedObjects{
                    request.predicate = NSPredicate(format: "localIdentifier = %@", removedAsset.localIdentifier )
                    do{
                        if let removedRecord:Screenshot = try context.fetch(request).last{
                            context.delete(removedRecord)
                            do{try context.save()}catch{print(error)}
                        }
                    }catch{ print("coredata fetch error when screenshot is deleted in photoLibraryDidChange")}
                }
                for (key, value) in albumDictionary {
                    albumDictionary[key] = value.filter({!(removedObjects.contains($0))})
                }
            }
            for album in AlbumGridVC.albumList {
                album.collection = albumDictionary[album.name]!
                album.count = albumDictionary[album.name]!.count
                if let titleImage = albumDictionary[album.name]!.last{
                    imageManager.requestImage(for: titleImage,
                                              targetSize: thumbnailSize,
                                              contentMode: .aspectFill,
                                              options: requestOptions,
                                              resultHandler: { image, _ in
                                                album.image = image!})
                } else {
                    album.image = UIImage(named: "LaunchScreen")!
                    
                }
            }
            //        OperationQueue.main.addOperation {
            
            self.albumGridCollectionView.reloadData()
            resetCachedAssets()
            
        }
    }
}

extension AlbumGridVC {
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: albumGridCollectionView!.contentOffset, size: albumGridCollectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in albumGridCollectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assetsFetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in albumGridCollectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assetsFetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
