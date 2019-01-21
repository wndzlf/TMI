//
//  DetailImageVC.swift
//  TMI
//
//  Created by CHOMINJI on 2019. 1. 21..
//  Copyright © 2019년 momo. All rights reserved.
//

import UIKit

class SelectedImageVC: UIViewController {

    var selectedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setBackBtn(color: .black)
        
        imageView.image = selectedImage
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
