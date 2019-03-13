//
//  SelectedAlbumImageVC.swift
//  TMI
//
//  Created by CHOMINJI on 2019. 1. 18..
//  Copyright © 2019년 momo. All rights reserved.
//

import UIKit
import Photos

class AssetGridVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet var moveButton: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!
    @IBOutlet var space: UIBarButtonItem!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var selectedAssetIndex: [Int] = []
    var selectedAlbums: [PHAsset] = []
    var selectedIndexPath: [IndexPath] = []
    
    var currentAlbumIndex: Int = 0
    var fetchResult: PHFetchResult<PHAsset>!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        
//        setNavigationBar()
        setBackBtn(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        let selectButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.selectAssets))
        self.navigationItem.rightBarButtonItem = selectButton
        moveButton.isEnabled = false
        trashButton.isEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        view.backgroundColor = isNavigationBarHidden ? .black : .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnTap = false
        
        toolbarItems = [trashButton, space, moveButton]
        
        //        if assetCollection != nil {
        //            trashButton.isEnabled = assetCollection.canPerform(.removeContent)
        //        } else {
        //            trashButton.isEnabled = asset.canPerform(.delete)
        //        }
        
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedAlbumCell", for: indexPath) as! AssetGridViewCell
//        cell.detailImageView.image = convertImageFromAsset(asset: selectedAlbums[indexPath.row])
//        let asset = selectedAlbums[indexPath.item]
        let asset = fetchResult.object(at: indexPath.item)
         cell.representedAssetIdentifier = asset.localIdentifier
        
//        cell.detailImageView.image = convertImageFromAsset(asset: selectedAlbums[indexPath.row], targetSize: thumbnailSize)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        return cell
    }
    
    //////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard detailCollectionView.allowsMultipleSelection else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let imageVC = storyBoard.instantiateViewController(withIdentifier: "AssetVC") as! AssetVC
            //self.navigationController?.pushViewController(imageVC, animated: true)
            
            ////
            let dashBoard = storyBoard.instantiateViewController(withIdentifier: "DashBoard") as! DashBoard
//            dashBoard.selectedImage = convertImageFromAsset(asset: selectedAlbums[indexPath.row])
            
            dashBoard.selectedAlbums = selectedAlbums
            dashBoard.albumIndex = indexPath
            dashBoard.selectedIndex = indexPath.row
            dashBoard.fetchResult = fetchResult
            
            self.navigationController?.pushViewController(dashBoard, animated: true)
            
            ////
            
            
            //imageVC.selectedImage = convertImageFromAsset(asset: selectedAlbums[indexPath.row])
            //imageVC.selectedAlbums = selectedAlbums
            print(convertImageFromAsset(asset: selectedAlbums[indexPath.row]))
            return
        }
        
        //선택버튼 눌러서 이미지 선택 시
        
        if let currentCell = collectionView.cellForItem(at: indexPath) as? AssetGridViewCell {
            if currentCell.isChecked == true {
                print("해제할것")
                currentCell.isChecked = false
//                currentCell.layer.borderWidth = 0
                currentCell.checkImageView.isHidden = true
                
//                let index: Int? = selectedAssetIndex.firstIndex(of: indexPath.item)
//                selectedAssetIndex.remove(at: index!)
                let deselectIndex = selectedAssetIndex.filter({ (index) -> Bool in
                    if index == indexPath.item {
                        let deselect = selectedAssetIndex.firstIndex(of: index)
                        selectedAssetIndex.remove(at: deselect!)
                        return true
                    }
                    return false
                })
                
                if let indexPath = collectionView.indexPath(for: currentCell) {
                    selectedIndexPath.removeAll { (index) -> Bool in
                        return index == indexPath
                    }
                }
            } else {
                currentCell.isChecked = true
                print("선택됨")
//                currentCell.layer.borderWidth = 2
//                currentCell.layer.borderColor = UIColor.init(red: 201/255, green: 201/255, blue: 201/255, alpha: 0.5).cgColor
                currentCell.checkImageView.isHidden = false
                selectedAssetIndex.append(indexPath.item)
                if let indexPath = collectionView.indexPath(for: currentCell) {
                    selectedIndexPath.append(indexPath)
                }
            }
            print("selectedAsset: \(selectedAssetIndex)")
            
            //이동버튼 활성화 비활성화
            if selectedAssetIndex.count > 0 {
                moveButton.isEnabled = true
                trashButton.isEnabled = true
                moveButton.target = self
                moveButton.action = #selector(moveToAlbumGridView(_:))
                
                trashButton.target = self
                trashButton.action = #selector(deleteSelectAlbum(_:))
                
            } else {
                moveButton.isEnabled = false
                trashButton.isEnabled = false
            }
        }
    }
    
    @objc
    func selectAssets(_ sender: UIBarButtonItem) {
        detailCollectionView.allowsMultipleSelection = true
        
        if sender.title == "선택" {
            sender.title = "취소"
        } else {
            sender.title = "선택"
            detailCollectionView.allowsMultipleSelection = false
            selectedAssetIndex.removeAll()
//            selectedIndexPath.removeAll()
            detailCollectionView.reloadItems(at: selectedIndexPath)
//            detailCollectionView.reloadData()
        }
    }
    
    //trashButton
    @objc func deleteSelectAlbum(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "remove", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            
            var count = AlbumGridVC.albumList[self.currentAlbumIndex].count
            
            for i in self.selectedAssetIndex {
                let indexPath = IndexPath(row: i, section: 0)
                
                self.selectedAlbums.remove(at: indexPath.item)
                self.detailCollectionView.deleteItems(at: [indexPath])
                
                AlbumGridVC.albumList[self.currentAlbumIndex].collection.remove(at: i)
                count = count - 1
            }
            
            //AlbumGridVC.albumList[self.currentAlbumIndex].image = convertImageFromAsset(asset: self.selectedAlbums[0])
            AlbumGridVC.albumList[self.currentAlbumIndex].count = count
            
            var userInfo: [String: Any] = [:]
            userInfo["selectedAlbum"] = "others"
            userInfo["selectedAssetIndex"] = self.selectedAssetIndex
            
             NotificationCenter.default.post(
                name: NSNotification.Name("deleteAsset"),
                object: nil, userInfo: userInfo)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //moveButton 누르면 동작하는 함수, modal AlbumGridView
    @objc
    func moveToAlbumGridView(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let popVC = storyBoard.instantiateViewController(withIdentifier: "PopupAlbumGridVC") as! PopupAlbumGridVC
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        
        popVC.didMove(toParent: self)
        
        for i in selectedAssetIndex {
            print("selectedImage: \(selectedAlbums[i])")
            popVC.movingAssets.append(selectedAlbums[i])
        }
        popVC.movingAssetIndexs = selectedAssetIndex
    }
}


//MARK:- CollectionViewFlowLayout
extension AssetGridVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.frame.width) / 4 - 8
        let height: CGFloat = (view.frame.width) / 4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
}

