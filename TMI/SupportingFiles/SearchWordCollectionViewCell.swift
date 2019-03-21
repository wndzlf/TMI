//
//  SearchWordCollectionViewCell.swift
//  TMI
//
//  Created by CHOMINJI on 21/03/2019.
//  Copyright © 2019 momo. All rights reserved.
//

import UIKit

class SearchWordCollectionViewCell: UICollectionViewCell {
    
    var searchWordLabel:UILabel = {
        var textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(searchWordLabel)
        
        NSLayoutConstraint.activate([
            searchWordLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchWordLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        makeRounded(cornerRadius: 19)
 
        layer.borderColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer.borderWidth = 0.5

        layer.shadowPath =
            UIBezierPath(roundedRect: bounds,
                         cornerRadius: layer.cornerRadius).cgPath
        layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 1
        layer.masksToBounds = false
        
        
        addSubview(searchWordLabel)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 96),
            heightAnchor.constraint(equalToConstant: 38),
            searchWordLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchWordLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    
}
