//
//  SearchVC.swift
//  TMI
//
//  Created by CHOMINJI on 08/02/2019.
//  Copyright © 2019 momo. All rights reserved.
//

import UIKit
import CoreData
import Photos

class SearchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var searchBarView: UIView!
    
    @IBOutlet weak var searchWordCollectionView: UICollectionView!
    
    var searchWordArray = ["Instagram", "이체", "에타"]
    
    var searchController: UISearchController!
    
    var searchedAssests : PHFetchResult<PHAsset>!
    
    var searchedAssetArray: [PHAsset] = []
    
    var searchImages: [UIImage] = []
    
    var isSearchButtonClicked = false

    var fetchedRecordArray = [Screenshot]()
    
    var searchedLocalIdentifiers: [String] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var recordArray = [Screenshot]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setBackBtn(color: .black)
        setUpSearchController()
        
        searchWordCollectionView.delegate = self
        searchWordCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchWordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchWordCell", for: indexPath) as? SearchWordCollectionViewCell else {
            fatalError("no searchWordCollectionView Cell")
        }
        cell.searchWordLabel.text = searchWordArray[indexPath.item]
        return cell
    }
    
    
    
  
    func setUpSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.becomeFirstResponder()
        if #available(iOS 11.0, *) {
            searchController.searchBar.backgroundImage = UIImage(named: "searchBarBackGround")
            searchController.searchBar.tintColor = UIColor.black
            searchController.searchBar.barTintColor = UIColor.white
            
            searchController.searchBar.placeholder = "사진 속의 단어를 검색해보세요"
            
        }
        
        
     
        searchBarView.addSubview(searchController.searchBar)
        
    }
    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        //        isSearch = false
////        albumGridCollectionView.reloadData()
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("업데이트")
        let searchBar = searchController.searchBar
        
        guard let serachBarText = searchBar.text else {
            return
        }
        
        screenshotSearch(keyword: serachBarText)
        isSearchButtonClicked = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchBar = searchController.searchBar
        screenshotSearch(keyword: searchBar.text!)
        isSearchButtonClicked = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isSearch() -> Bool {
        //        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        if isSearchButtonClicked == true {
            return true
        } else {
            return searchController.isActive && !searchBarIsEmpty()
        }
    }
    
    func screenshotSearch(keyword: String){
        
        guard let _ = storyboard?.instantiateViewController(withIdentifier: "SearchCollectionVC") as? SearchCollectionVC else {
            return
        }
        
        let request: NSFetchRequest<Screenshot> = Screenshot.fetchRequest()
        //SQL query로는 (select * from Text where content LIKE '%keyword%')와 같은 작업
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", keyword)
        do {
            fetchedRecordArray = try context.fetch(request) //조건에 맞는 레코드들 저장
        } catch {
            print("coredata fetch error")
        }
        if(fetchedRecordArray.count > 0){
            for textRecord in fetchedRecordArray{
                //각 레코드들의 localIdentifier만 따로 배열에 저장 후 이를 이용해 뷰에 사진 보여주기
                let aTextRecord:Screenshot = textRecord
                searchedLocalIdentifiers.append(aTextRecord.localIdentifier!)
            }
        }
        print("***********검색된 사진의 localIdentifier =")
        print(searchedLocalIdentifiers)
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        
        searchedAssetArray.removeAll()
        searchImages.removeAll()
        
        searchedAssests = PHAsset.fetchAssets(withLocalIdentifiers: searchedLocalIdentifiers, options: nil)
        if searchedAssests != nil {
            if searchedAssests.count == searchedLocalIdentifiers.count {
                print("asset count: \(searchedAssests.count)")
                for asset in 0..<searchedAssests.count {
                    let asset = searchedAssests.object(at: asset)
                    searchedAssetArray.append(asset)
                    
                }
                //            print("searchAsset: \(searchAssets)")
                //            searchVC.searchedAssetArray = searchedAssetArray
            }
        }
        
        //        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { result, info in
        //                if let image = result {
        //                    self.searchAssets.append(image)
        //                }
        //            })
        
        searchedLocalIdentifiers.removeAll()
        
        if searchedAssetArray.count == fetchedRecordArray.count {
            //            searchVC.fetchedRecordArray = fetchedRecordArray
            //            searchVC.searchedAssetArray = searchedAssetArray
            //            navigationController?.pushViewController(searchVC, animated: true)
            
//            albumGridCollectionView.reloadData()
            
        }
    }
}


extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96, height: 38)
    }
    
}
