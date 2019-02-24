//
//  StickerCollectionViewCell.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit

class StickerCollectionViewCell: UICollectionViewCell {
    
    var stickerImageView: UIImageView = UIImageView(frame: .zero)
    var selectionIndicatorView: UIView = UIView(frame: .zero)
    
    weak var sticker: Sticker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            sticker?.isSelected = isSelected
            selectionIndicatorView.isHidden = !isSelected
        }
    }
    
    private func setup() {
        setupImageView()
        setupSelectionIndicator()
    }
    
    private func setupImageView() {
        contentView.addSubview(stickerImageView)
        stickerImageView.translatesAutoresizingMaskIntoConstraints = false
        stickerImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stickerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stickerImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        stickerImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    private func setupSelectionIndicator() {
        contentView.addSubview(selectionIndicatorView)
        selectionIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        selectionIndicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        selectionIndicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        selectionIndicatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
}
