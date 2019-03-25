//
//  DashBoard.swift
//  TMI
//
//  Created by 어혜민 on 31/01/2019.
//  Copyright © 2019 momo. All rights reserved.
//

import UIKit
import Photos

class DashBoard: UIViewController, UIPageViewControllerDataSource {
    
    private var asset: PHAsset!
    
    var fetchResult: PHFetchResult<PHAsset>!
    
    var selectedAlbums: [PHAsset] = []
    
    var albumIndex: IndexPath = IndexPath()
    
    var selectedIndex: Int = 0
    
    private var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: PageView.bounds.width * scale, height: PageView.bounds.height * scale)
    }
    
    @IBOutlet weak var PageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setPageVC()
    }
    
    private func setPageVC() {
        guard let PageVC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as? UIPageViewController else {
            return
        }
        
        let InitialView = AssetVCIndex(index: selectedIndex) as AssetVC
        let ViewController = NSArray(object: InitialView)
        
        PageVC.view.frame = PageView.bounds
        PageView.addSubview(PageVC.view)
        addChild(PageVC)
        
        PageVC.didMove(toParent: self)
        PageVC.dataSource = self
        
        PageVC.setViewControllers(ViewController as? [UIViewController], direction: .forward, animated: true, completion: nil)
    }
    
    //MARK: - Page View
    private func AssetVCIndex(index: Int) -> AssetVC {
        
        guard let AssetVC = self.storyboard?.instantiateViewController(withIdentifier: "AssetVC") as? AssetVC else {
            fatalError("no such VC")
        }
        
        if selectedAlbums.count == 0 || index >= selectedAlbums.count {
            return .init()
        }
        
        AssetVC.pageIndex = index
        AssetVC.asset = selectedAlbums[index]
        
        return AssetVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let assetVC = viewController as? AssetVC else {
            return .init()
        }
        var selectedIndex = assetVC.pageIndex as Int
        
        if selectedIndex == 0 || selectedIndex == NSNotFound {
            return nil
        }
        
        selectedIndex -= 1
        
        return AssetVCIndex(index: selectedIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let assetVC = viewController as? AssetVC else {
            return .init()
        }
        var selectedIndex = assetVC.pageIndex as Int
        
        if selectedIndex == NSNotFound {
            return nil
        }
        
        selectedIndex += 1
        
        if selectedIndex == selectedAlbums.count {
            return nil
        }
        
        return AssetVCIndex(index: selectedIndex)
    }
}
