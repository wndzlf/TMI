//
//  SearchCollectionVC.swift
//  TMI
//
//  Created by CHOMINJI on 12/03/2019.
//  Copyright © 2019 momo. All rights reserved.
//

import UIKit
import Photos

class SearchCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var fetchedRecordArray: [Screenshot] = []
    var searchedAssetArray: [PHAsset] = []
    var searchImages: [UIImage] = []
    private var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
       let imageManager: PHCachingImageManager = PHCachingImageManager()
    var availableWidth: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        //콜렉션 뷰 thumbnailSize
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedRecordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        
        let fetchText: Screenshot

        fetchText = fetchedRecordArray[indexPath.item]
        for searchAsset in searchedAssetArray {
          
//            imageManager.stopCachingImages(for: searchAsset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
            cell.representedAssetIdentifier = searchAsset.localIdentifier
            let option = PHImageRequestOptions()
            option.resizeMode = .fast
            self.imageManager.requestImage(for: searchAsset,
                                           targetSize: self.thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in
                                            // UIKit may have recycled this cell by the handler's activation time.
                                            // Set the cell's thumbnail image only if it's still showing the same asset.
                                            DispatchQueue.main.async {
                                                cell.thumbnailImage = image
                                                self.searchImages.append(cell.thumbnailImage)
                                                cell.titleLabel.text = fetchText.albumName
                                                cell.imageCountLabel.text = nil
                                            }
                                            
                                            
            })
            
        }
        return cell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
