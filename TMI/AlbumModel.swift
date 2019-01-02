//
//  AlbumModel.swift
//  TMI
//
//  Created by CHOMINJI on 2019. 1. 3..
//  Copyright © 2019년 momo. All rights reserved.
//
import Photos

class AlbumModel {
    let name:String
    let count:Int
    let collection:PHAssetCollection
    init(name:String, count:Int, collection:PHAssetCollection) {
        self.name = name
        self.count = count
        self.collection = collection
    }
}
