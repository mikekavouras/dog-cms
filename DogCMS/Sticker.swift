//
//  Sticker.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Sticker {
    let image: UIImage
    let record: CKRecord
    
    var isSelected = false
    
    init(image: UIImage, record: CKRecord) {
        self.image = image
        self.record = record
    }
    
    static func from(_ record: CKRecord) -> Sticker? {
        if let asset = record["image"] as? CKAsset,
           let data = try? Data(contentsOf: asset.fileURL),
           let image = UIImage(data: data) {
            return Sticker(image: image, record: record)
        }
        return nil
    }
}
