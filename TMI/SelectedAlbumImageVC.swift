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
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    
    var selectedAlbums:[PHAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        
        setNavigationBar()
        setBackBtn(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        print("가나다라마바사")
        print("받을때 \(selectedAlbums?.count)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedAlbums?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectedAlbumCollectionViewCell
        
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
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectedAlbumCollectionViewCell
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let imageVC = storyBoard.instantiateViewController(withIdentifier: "SelectedImageVC") as! SelectedImageVC
        self.navigationController?.pushViewController(imageVC, animated: true)
        if let albums = selectedAlbums {
            imageVC.selectedImage = convertImageFromAsset(asset: albums[indexPath.row])
            print("image")
            print(convertImageFromAsset(asset: albums[indexPath.row]))
        }
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
