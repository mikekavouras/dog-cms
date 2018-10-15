//
//  StickerCollectionViewCell.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit

class StickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stickerImageView: UIImageView!
    @IBOutlet weak var selectionIndicator: UIView!
    
    weak var sticker: Sticker?
    
    override var isSelected: Bool {
        didSet {
            sticker?.isSelected = isSelected
            selectionIndicator.isHidden = !isSelected
        }
    }
    
}
