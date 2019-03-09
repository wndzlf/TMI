//
//  AlbumCollectionViewCell.swift
//  TMI
//
//  Created by CHOMINJI on 2019. 1. 2..
//  Copyright © 2019년 momo. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageCountLabel: UILabel!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            titleImageView.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleImageView.image = nil
        titleLabel.text = nil
        imageCountLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleImageView.applyImageRadius(radius: 10)
    }
}
