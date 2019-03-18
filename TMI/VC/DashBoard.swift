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
    
    
    var asset: PHAsset!
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: PageView.bounds.width * scale, height: PageView.bounds.height * scale)
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    var selectedImage: UIImage!
    var selectedAlbums: [PHAsset] = []
    var albumIndex: IndexPath = IndexPath()
    var selectedIndex: Int = 0

    
    @IBOutlet weak var PageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let InitialView = AssetVCIndex(index: selectedIndex) as AssetVC
        let ViewController = NSArray(object: InitialView)
        

        let PageVC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! UIPageViewController
        PageVC.view.frame = PageView.bounds
        PageView.addSubview(PageVC.view)
        addChild(PageVC)
        PageVC.didMove(toParent: self)
        PageVC.dataSource = self
        PageVC.setViewControllers(ViewController as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
    }
    
    //MARK: - Page View
    
    func AssetVCIndex(index: Int) -> AssetVC {
        
        let AssetVC = self.storyboard?.instantiateViewController(withIdentifier: "AssetVC") as! AssetVC
        AssetVC.asset = selectedAlbums[index]
        return AssetVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if selectedIndex == NSNotFound {
            return nil
        }
        
        selectedIndex -= 1
        
        if selectedIndex < albumIndex.startIndex {
            selectedIndex += 1
            return nil
        }
        return AssetVCIndex(index: selectedIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if selectedIndex == NSNotFound {
            return nil
        }
        
        selectedIndex += 1
        
        print(selectedIndex)
        if selectedIndex > albumIndex.endIndex {
            selectedIndex -= 1
            return nil
        }
        return AssetVCIndex(index: selectedIndex)
    }
    //Page View_End
    

}
