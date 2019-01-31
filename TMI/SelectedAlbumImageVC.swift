//
//  SelectedAlbumImageVC.swift
//  TMI
//
//  Created by CHOMINJI on 2019. 1. 18..
//  Copyright © 2019년 momo. All rights reserved.
//

import UIKit
import Photos

class SelectedAlbumImageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var asset: PHAsset!
    var assetCollecton: PHAssetCollection!
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    @IBOutlet var moveButton: UIBarButtonItem!
    
    @IBOutlet var trashButton: UIBarButtonItem!
    
    @IBOutlet var space: UIBarButtonItem!
    
    var selectedPhoto: [Int] = []
    var selectedAlbums:[PHAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        
        
        setNavigationBar()
        setBackBtn(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        print("받을때 \(selectedAlbums?.count)")
        
        let selectButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.selectAlbum))
        self.navigationItem.rightBarButtonItem = selectButton
        
    }
    
    override func viewWillLayoutSubviews() {
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        view.backgroundColor = isNavigationBarHidden ? .black : .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false
//        navigationController?.hidesBarsOnTap = true //탭하면 사라짐
        
        toolbarItems = [trashButton, space, moveButton]
        
//        if assetCollection != nil {
//            trashButton.isEnabled = assetCollection.canPerform(.removeContent)
//        } else {
//            trashButton.isEnabled = asset.canPerform(.delete)
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedAlbums?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedAlbumCell", for: indexPath) as! SelectedAlbumCollectionViewCell
        
        //cell.detailImageView.image = selectedAlbums?[indexPath.item]
        
        if let albums = selectedAlbums {
//            cell.detailImageView.image = getUIImage(asset: albums[indexPath.row])
            cell.detailImageView.image = convertImageFromAsset(asset: albums[indexPath.row])
        }
//        var image: PHAsset
//
//        for i in selectedAlbums! {
//            image = i
////            cell.detailImageView.image = image
//        }
//        let image: PHAsset = self.selectedAlbums[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedAlbumCell", for: indexPath) as! SelectedAlbumCollectionViewCell
        
        guard detailCollectionView.allowsMultipleSelection else {
            print("detailxxxx: \(detailCollectionView.allowsMultipleSelection)")
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let imageVC = storyBoard.instantiateViewController(withIdentifier: "SelectedImageVC") as! SelectedImageVC
            self.navigationController?.pushViewController(imageVC, animated: true)
            if let albums = selectedAlbums {
                imageVC.selectedImage = convertImageFromAsset(asset: albums[indexPath.row])
                print("image")
                print(convertImageFromAsset(asset: albums[indexPath.row]))
            }
            return
        }
        
       
        
        if let currentCell = collectionView.cellForItem(at: indexPath) as? SelectedAlbumCollectionViewCell {
            
            if currentCell.isChecked == true {
                print("해제할것")
//                currentCell.detailImageView.isHighlighted = false
                currentCell.isChecked = false
                currentCell.layer.borderWidth = 0
                currentCell.checkImageView.isHidden = true
                
                let index: Int? = selectedPhoto.firstIndex(of: indexPath.row)
                selectedPhoto.remove(at: index!)
            } else {
                currentCell.isChecked = true
                print("선택됨")
                currentCell.layer.borderWidth = 2
                currentCell.layer.borderColor = UIColor.init(red: 201/255, green: 201/255, blue: 201/255, alpha: 0.5).cgColor
                currentCell.checkImageView.isHidden = false
                selectedPhoto.append(indexPath.row)
                
            }
            
            print(selectedPhoto)
        }
        
    }
    
    @objc
    func selectAlbum(_ sender: AnyObject) {
        detailCollectionView.allowsMultipleSelection = true
        
        print("detail: \(detailCollectionView.allowsMultipleSelection)")
    }
    
    func getUIImage(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func convertImageFromAsset(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
            image = result!
        })
        return image
    }

}

extension SelectedAlbumImageVC: UICollectionViewDelegateFlowLayout {
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


extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
