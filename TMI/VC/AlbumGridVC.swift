//
//  ViewController.swift
//  TMI
//
//  Created by CHOMINJI on 2018. 12. 30..
//  Copyright © 2018년 momo. All rights reserved.
//

import UIKit
import Photos
import CoreGraphics
import CoreML
import CoreData
import Accelerate
import FirebaseMLVision
//import FirebaseDatabase


class AlbumGridVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var albumGridCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var assetsFetchResult: PHFetchResult<PHAsset>!
    private let imageManager: PHCachingImageManager = PHCachingImageManager() //이미지를 로드해 옴
    private let manager = PHImageManager.default()
    private let requestOptions = PHImageRequestOptions()
    private let availableWidth = UIScreen.main.bounds.size.width
    private let availableHeight = UIScreen.main.bounds.size.height
    
    static var albumList: [AlbumModel] = []
    private var albums: [String:[PHAsset]] = ["kakaoTalk":[], "daumCafe": [], "instagram":[], "others":[]]
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var textArray = [Text]()
    private var fetchedTextArray = [Text]()
    private var searchedLocalIdentifier: [String] = []
    
    private var smartAlbums: PHFetchResult<PHAssetCollection>!
    private var userCollections: PHFetchResult<PHCollection>!
    
    
    private var image: UIImage!
    private var assetCollection: PHAssetCollection!
    private var albumFound : Bool = false
    private var photosAsset: PHFetchResult<PHAsset>!
    private var assetThumbnailSize: CGSize!
    private var collection: PHAssetCollection!
    private var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumGridCollectionView.delegate = self
        albumGridCollectionView.dataSource = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        //사용자가 사진첩에 접근을 허가했는지
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가됨")
            OperationQueue.main.addOperation {
                self.activityIndicator.startAnimating()
                self.GetAlbums()
                self.albumGridCollectionView.reloadData()
                self.activityIndicator.stopAnimating()
                
            }
        case .denied:
            print("접근 불허됨")
        case .notDetermined: //허가하는지 안하는지 선택하지 않으면
            print("아직 응답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in //다시 허가 요청
                switch status {
                case .authorized:
                    print("사용자가 허용함")
                    OperationQueue.main.addOperation {
                        //                    self.requestCollection()
                        self.activityIndicator.startAnimating()
                        self.GetAlbums()
                        self.albumGridCollectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        albumGridCollectionView.reloadData()
        
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnTap = false
    }
    
    
    
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AlbumGridVC.albumList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        let album: AlbumModel = AlbumGridVC.albumList[indexPath.item]
        cell.titleImageView.image = album.image
        cell.titleLabel.text = album.name
        cell.imageCountLabel.text = String(album.count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell")
        //goto SelectedAlbumImageVC
        //self.performSegue(withIdentifier: "ToDetailAlbum", sender: self)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let selectedVC = storyBoard.instantiateViewController(withIdentifier: "AssetGridVC") as! AssetGridVC
        self.navigationController?.pushViewController(selectedVC, animated: true)
//        if self.albumList[indexPath.item].name == "daumCafe" {
//            print("goto DaumCafe")
//        } else if self.albumList[indexPath.item].name == "kakaoTalk" {
//            print("goto kakaoTalk")
//        } else if self.albumList[indexPath.item].name == "instagram" {
//            print("goto instagram")
//        } else if self.albumList[indexPath.item].name == "others" {
//            print("goto others")
//        }
        PopupAlbumGridVC.currentAlbumIndex = indexPath.item
        selectedVC.selectedAlbums = AlbumGridVC.albumList[indexPath.item].collection
    }
    
    @objc
    func addAlbum(_ sender: AnyObject) {
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
}


extension AlbumGridVC {
    func retrieveAssets() {
    }
    func GetAlbums() {
        let options: PHFetchOptions = PHFetchOptions()
        // 스크린샷 앨범만 가져온다.
        let getAlbums : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: options)
        
        if getAlbums.count > 0 {
            guard let assetCollection: PHAssetCollection = getAlbums.firstObject else {return}
            let fetchOptions = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            if assetsFetchResult.count > 0 {
                requestOptions.isSynchronous = true
                //순차적으로 진행되게 하기위해 true!
                requestOptions.deliveryMode = .highQualityFormat
                for i in 0..<assetsFetchResult.count {
                    //스크린샷 앨범에서 가져온 사진 오브젝트 하나하나 반복
                    let imageAsset = assetsFetchResult.object(at: i)
                    //requestImageForAsset 을 이용해 이미지를 불러온다
                    manager.requestImage(for: imageAsset,
                                         targetSize: PHImageManagerMaximumSize,
                                         //원래의 이미지 사이즈로 가져온다.
                        contentMode: .aspectFill,
                        options: requestOptions,
                        resultHandler: { image, _ in
                            self.getText(screenshot: image!,localIdentifier: imageAsset.localIdentifier )
                            let maxIndex = self.screenshotPredict(image: image!)
                            //테스트
                            self.matchPlatform(maxIndex: maxIndex, imageAsset: imageAsset)
                            //inceptionV3 모델에 가져온 이미지를 넣고 결과를 maxIndex에 저장한다.
                    })//리퀘스트 완료
                }//for문 끝
                makeAlbumModel(albumTitle: "kakaoTalk")
                makeAlbumModel(albumTitle: "daumCafe")
                makeAlbumModel(albumTitle: "instagram")
                makeAlbumModel(albumTitle: "others")
                //각각 어레이를 collection으로 해서 앨범모델을 만들고 albumList에 추가한다.
                //                screenshotSearch(keyword: "둘러보기")
                //                deleteAllCDRecords() //디비 비우는 메소드
            }//if문 끝
        }
    }//GetAlbums 메소드 끝
    
    func makeAlbumModel(albumTitle: String){
        requestOptions.isSynchronous = true
        //순차적으로 진행되게하기위해 true로 설정
        requestOptions.deliveryMode = .highQualityFormat
        if var album = albums[albumTitle]{
            if let titleImage = album.last{
                //타이틀이미지를 따로 저장하기위해 한 번 더 리퀘스트한다.
                let albumCount = album.count
                manager.requestImage(for: titleImage,
                                     targetSize: PHImageManagerMaximumSize,
                                     contentMode: .aspectFill,
                                     options: requestOptions,
                                     resultHandler: { image, _ in
                                        let newAlbum = AlbumModel(name: albumTitle ,
                                                                  count: albumCount,
                                                                  image: image!,
                                                                  collection: album)
                                        AlbumGridVC.albumList.append(newAlbum)
                })
            }
        }
//        createAlbum(albumTitle: albumTitle) //앨범 추가(shared)
    }
    
    
    func matchPlatform(maxIndex: Int, imageAsset: PHAsset){
        switch maxIndex{
        //결과에 따라 각각의 어레이에 imageAsset자체를 넣는다(UIImage 타입 아님)
        case 0:
            albums["kakaoTalk"]?.append(imageAsset)
        case 1:
            albums["daumCafe"]?.append(imageAsset)
        case 2:
            albums["instagram"]?.append(imageAsset)
        case 3:
            albums["others"]?.append(imageAsset)
        default:
            print("추론 에러 발생")
            
        }
    }
    
    func createAlbum(albumTitle: String) {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                self.albumFound = success
                
                if (success) {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                    print(collectionFetchResult)
                    self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
                }
            })
        }
    }
    
  
        //    func updateAlbumModel(albumModel: AlbumModel){
        //       var  albumModel.collection = album[albumModel.name]
        //    }
        
        // insert 경우 이미지 리퀘스트=> 프레딕트 => album[""]에 추가 => 앨범모델 업데이트(다시 어펜드): 이 떄 해당 앨범모델이 이미 생성되어 있다면 updateAlbum , 아니라면 makeAlbum메소드 부르기
        // remove의 경우 => 해당 album['']에서 제거하고 updateAlbju
        func argmax(_ array: UnsafePointer<Double>, count: Int) -> (Int, Double) {
            //tensorflow의 argmax구현
            var maxValue: Double = 0
            var maxIndex: vDSP_Length = 0
            vDSP_maxviD(array, 1, &maxValue, &maxIndex, vDSP_Length(count))
            if(maxValue > 0.6){ return (Int(maxIndex), maxValue)}
            else{ return (3, maxValue)}
            
        }
        
        func resize(image: UIImage, newSize: CGSize) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
        
        func screenshotPredict(image: UIImage) -> Int {
            let model = inception_v3()
            let newSize = CGSize(width: 149.5, height: 149.5) //size 299..?
            //        let newSize = CGSize(width: availableWidth, height: availableHeight)
            let image = resize(image: image, newSize: newSize)
            if let pixelBuffer = ImageProcessor.pixelBuffer(forImage: image.cgImage!) {
                //이미지의 사이즈와 타입을 바꾸기위한 전처리과정 후 추론
                guard let inception_v3Output = try? model.prediction(Mul__0: pixelBuffer) else {
                    fatalError("Unexpected runtime error.")}
                let featurePointer = UnsafePointer<Double>(OpaquePointer(inception_v3Output.final_result__0.dataPointer))
                print(inception_v3Output.final_result__0)
                let (maxIndex, maxValue) = argmax(featurePointer, count: 3)
                print("이름은 " + String(maxIndex) + ", 값은 " + String(maxValue))
                return maxIndex
                //추론 성공
            }
            return -1
            //추론 실패
        }
    }

//MARK:- OCR
extension AlbumGridVC {
    //ocr로 텍스트 추출하고 디비에 localIdentifier와 함께 저장하는 메소드
    func getText(screenshot: UIImage, localIdentifier: String){
        //MLvision instance 생성
        let vision = Vision.vision()
        // https://cloud.google.com/vision/docs/languages => 언어 약자 확인하는 사이트
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ko", "en"] //ocr에게 어떤 언어인지 미리 힌트 주는거
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        //위의 힌트옵션 추가해서 textRecognizer 생성
        let visionImage = VisionImage(image: screenshot)
        textRecognizer.process(visionImage) { result, error in
            //textRecognizer Run!
            guard error == nil, let result = result else {
                print("OCR textRecognizer error")
                return
            }
            //result가 nil일때 어떻게 할 지 고민해보기
            let resultText = result.text
            print(resultText)
            let newText = Text(context: self.context) //텍스트모델의 레코드가 될 변수 생성
            //텍스트 모델의 attribute 저장
            newText.localIdentifier = localIdentifier
            newText.content = resultText
            //textArray에 레코드들 추가하기
            self.textArray.append(newText)
            self.saveText()
            self.textArray.removeAll()
        }
    }
    //검색하는 뷰에서 호출하는 메소드
    func screenshotSearch(keyword: String){
        let request: NSFetchRequest<Text> = Text.fetchRequest()
        //SQL query로는 (select * from Text where content LIKE '%keyword%')와 같은 작업
        request.predicate = NSPredicate(format: "content CONTAINS[cd] %@", keyword)
        do{
            fetchedTextArray = try context.fetch(request) //조건에 맞는 레코드들 저장
        }catch{
            print("coredata fetch error")
        }
        if(fetchedTextArray.count > 0){
            for textRecord in fetchedTextArray{
                //각 레코드들의 localIdentifier만 따로 배열에 저장 후 이를 이용해 뷰에 사진 보여주기
                let aTextRecord:Text = textRecord
                searchedLocalIdentifier.append(aTextRecord.localIdentifier!)
            }
        }
        print("***********검색된 사진의 localIdentifier =")
        print(searchedLocalIdentifier)
        searchedLocalIdentifier.removeAll()
    }
    
    func saveText(){
        do{ //디비에 변화 저장하는 메소드
            try context.save()
        }catch{
            print("coredata save error")
        }
    }
    
    private func deleteAllCDRecords() { //디비의 모든 레코드를 삭제하는 메소드
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Text")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("deleteAllCDRecords error")
        }
    }
    
    // 디비에서 데이터 삭제할 때 구현
    //    func destroyText(){
    //        context.delete(textArray)
    //        textArray.remove(at: indexPath.row)
    //        saveText()
    //    }
    
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
        
        // Change notifications may originate from a background queue.
        // Re-dispatch to the main queue before acting on the change,
        // so you can update the UI.
        DispatchQueue.main.sync {
            //            // Check each of the three top-level fetches for changes.
            //            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
            //                // Update the cached fetch result.
            //                allPhotos = changeDetails.fetchResultAfterChanges
            //                // Don't update the table row that always reads "All Photos."
            //            }
            
            // Update the cached fetch results, and reload the table sections to match.
            //            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
            //                smartAlbums = changeDetails.fetchResultAfterChanges
            //                tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
            //            }
            //
            //            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
            //                userCollections = changeDetails.fetchResultAfterChanges
            //                collectionView.reloadData()
            //                tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
            //            }
        }
    }
}


//MARK:- PhotoLibraryML
/*   func photoLibraryDidChange(_ changeInstance: PHChange) {
 
 //        guard let changes = changeInstance.changeDetails(for: assetsFetchResult) else {return}
 //        assetsFetchResult = changes.fetchResultAfterChanges
 //
 //
 //        OperationQueue.main.addOperation {
 //            self.collectionView.reloadData()
 //        }
 
 
 //
 let fetchResultChangeDetails = changeInstance.changeDetails(for: assetsFetchResult)
 if(fetchResultChangeDetails != nil){
 
 guard (fetchResultChangeDetails) != nil else {
 print("No Change in fetch Result Change Details")
 return
 }
 print("Contains changes")
 
 assetsFetchResult = (fetchResultChangeDetails?.fetchResultAfterChanges)!
 let insertedObjects = fetchResultChangeDetails?.insertedObjects
 
 for insertedAsset in insertedObjects!{
 print("insertedAsset이 있어요오니ㅏ어ㅗ미ㅏ엄나ㅣㅓ아ㅣㅁ넝~~!")
 
 manager.requestImage(for: insertedAsset,
 targetSize: PHImageManagerMaximumSize,
 contentMode: .aspectFill,
 options: requestOptions,
 resultHandler: { image, _ in
 self.getText(screenshot: image!, localIdentifier: insertedAsset.localIdentifier)
 let maxIndex = self.screenshotPredict(image: image!)
 self.matchPlatform(maxIndex: maxIndex, imageAsset: insertedAsset)})
 }//for문 돌아서 추가된 이미지오브젝트들 각 앨범 딕셔너리에 저장 완료
 let removedObjects = fetchResultChangeDetails?.removedObjects
 
 for removedAsset in removedObjects!{
 print("removed asset이 있어용~~~!~!")
 
 for var (key, value) in albums {
 if value.contains(removedAsset){ value.remove(at: value.index(of: removedAsset)!)}
 }
 }
 for i in 0..<albumList.count{
 makeAlbumModel(albumTitle: albumList[i].name)
 albumList.remove(at: i)
 }
 }
 //    }
 */

