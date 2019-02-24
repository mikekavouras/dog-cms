//
//  StickerCollectionViewCell.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit

class AddCell: UICollectionViewCell {
    
    var clickHandler: (() -> Void)?
    
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
        
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "add")!, for: .normal)
        
        bgView.addSubview(button)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        button.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: bgView.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        clickHandler?()
    }
}
