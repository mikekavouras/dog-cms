//
//  StickerCollectionViewCell.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit

class AddCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let bgView = UIView(frame: .zero)
        bgView.backgroundColor = UIColor(red: 246 / 255.0, green: 246 / 255.0, blue: 246 / 255.0, alpha: 1.0)
        contentView.addSubview(bgView)
        
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "add")!
        bgView.addSubview(imageView)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
        
        imageView.frame.size = CGSize(width: 35, height: 35)
    }
}
