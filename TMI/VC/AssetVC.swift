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
    
    var asset: PHAsset!
    var selectedImage: UIImage?
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    
   var pageIndex = Int()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackBtn(color: .black)
    }
    
    override func viewWillLayoutSubviews() {
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        
        view.backgroundColor = isNavigationBarHidden ? .black : .white
        navigationController?.isToolbarHidden = isNavigationBarHidden ? true : false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true //탭하면 사라짐
        
        updateStaticImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.hidesBarsOnTap = false
    }
    
    
    private func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    private func updateStaticImage() {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: options,
                                              resultHandler: { image, _ in
                                                guard let image = image else { return }
                                                
                                                
                                                self.imageView.isHidden = false
                                                self.imageView.image = image
        })
    }
    
    
}
