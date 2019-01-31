//
//  DetailImageVC.swift
//  TMI
//
//  Created by CHOMINJI on 2019. 1. 21..
//  Copyright © 2019년 momo. All rights reserved.
//

import UIKit
import Photos

class AssetVC: UIViewController, UIScrollViewDelegate {

    var selectedImage: UIImage!
    //var selectedAlbums: [PHAsset] = []
    
    @IBOutlet weak var imageView: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setBackBtn(color: .black)
        
        imageView.image = selectedImage
    }
    
    override func viewWillLayoutSubviews() {
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false

        view.backgroundColor = isNavigationBarHidden ? .black : .white
        navigationController?.isToolbarHidden = isNavigationBarHidden ? true : false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true //탭하면 사라짐
    }
}
