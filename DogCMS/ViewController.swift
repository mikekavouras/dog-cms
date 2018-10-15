//
//  ViewController.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit
import SVProgressHUD

extension Array {
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}

enum ScreenState {
    case edit
    case add
}

class ViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    
    private var stickers: [Sticker] = []
    private var pickerController: UIImagePickerController?
    
    fileprivate let padding: CGFloat = 8
    fileprivate let perRow: CGFloat = 3
    
    private var state: ScreenState = .add

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        fetchStickers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pickerController = UIImagePickerController()
        pickerController?.delegate = self
        pickerController?.sourceType = .photoLibrary
    }

    // MARK: - Setup
    // MARK: -
    
    private func setup() {
        setupCollectionView()
        setupNavigationBar()
        SVProgressHUD.setDefaultStyle(.dark)
    }
    
    private func setupCollectionView() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.allowsSelection = false
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleState)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAssetButtonTapped))
        ]
    }
    
    // MARK: - Actions
    // MARK: -
    
    @objc private func addAssetButtonTapped() {
        guard let controller = pickerController else { return }
        show(controller, sender: self)
    }
    
    @objc private func toggleState() {
        state = state == .edit ? .add : .edit
        refreshNavigationBarState()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard state == .add,
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @objc private func deleteButtonTapped() {
        SVProgressHUD.show(withStatus: "Deleting stickers...")
        
        let stickersToDelete = stickers.filter { $0.isSelected }
        API.default.deleteStickers(stickersToDelete) { response in
            switch response {
            case .success:
                SVProgressHUD.dismiss()
                let itemIndices = self.stickers.enumerated().map { $1.isSelected ? $0 : -1 }.filter { $0 > -1 }
                let indexPaths: [IndexPath] = itemIndices.map { IndexPath(row: $0, section: 0) }
                self.stickers.remove(at: itemIndices)
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: indexPaths)
                }) { _ in
                    self.state = .add
                    self.refreshTrashCanState()
                    self.refreshNavigationBarState()
                }
            case .error:
                SVProgressHUD.showError(withStatus: "Couldn't delete stickers")
                SVProgressHUD.dismiss(withDelay: 2.0)
            }
        }
    }
    
    func fetchStickers() {
        SVProgressHUD.show(withStatus: "Loading stickers...")
        API.default.fetchStickers { response in
            switch response {
            case .success(let records):
                SVProgressHUD.dismiss()
                self.stickers = (records ?? []).compactMap { Sticker.from($0) }
                self.collectionView.reloadData()
            case .error:
                SVProgressHUD.showError(withStatus: "Couldn't load stickers")
                SVProgressHUD.dismiss(withDelay: 2.0)
            }
        }
    }
    
    // MARK: - State
    // MARK: -
    
    fileprivate func refreshTrashCanState() {
        let mSticker = stickers.first { $0.isSelected }
        if let _ = mSticker {
            navigationItem.rightBarButtonItems?.last?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItems?.last?.isEnabled = false
        }
    }
    
    fileprivate func refreshNavigationBarState() {
        switch state {
        case .edit:
            collectionView.allowsMultipleSelection = true
            navigationItem.setRightBarButtonItems([
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleState)),
                UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
                ], animated: true)
            navigationItem.rightBarButtonItems?.last?.isEnabled = false
        case .add:
            collectionView.allowsSelection = false
            navigationItem.setRightBarButtonItems([
                UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleState)),
                UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAssetButtonTapped))
            ], animated: true)
        }
    }
}
    
// MARK: - UICollectionViewDataSource
// MARK: -

extension ViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as? StickerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let sticker = stickers[indexPath.row]
        cell.stickerImageView.image = sticker.image
        cell.sticker = sticker
        cell.isSelected = sticker.isSelected
        return cell
    }
}
    
// MARK: - UICollectionViewDelegate
// MARK: -

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        refreshTrashCanState()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        refreshTrashCanState()
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sticker = stickers[sourceIndexPath.row]
        stickers.remove(at: sourceIndexPath.row)
        stickers.insert(sticker, at: destinationIndexPath.row)
        
        SVProgressHUD.show(withStatus: "Reordering stickers...")
        API.default.updateSortOrders(stickers) { response in
            switch response {
            case .success:
                SVProgressHUD.dismiss()
            case .error: break
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// MARK: -

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.size.width - (padding * 4)) / perRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
}

// MARK: - UIIimagePickerControllerDelegate
// MARK: -

extension ViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { dismiss(animated: true, completion: nil) }

        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            SVProgressHUD.show(withStatus: "Saving sticker...")
            
            API.default.createSticker(path: imageURL, initialSortPosition: stickers.count) { response in
                switch response {
                case .success(let sticker):
                    SVProgressHUD.dismiss()
                    self.stickers.append(sticker!)
                    self.collectionView.reloadData()
                case .error:
                    SVProgressHUD.showError(withStatus: "Couldn't save sticker")
                    SVProgressHUD.dismiss(withDelay: 2.0)
                }
            }
        } else {
            SVProgressHUD.showError(withStatus: "Couldn't find the selected image")
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
    }
}
