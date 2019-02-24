//
//  ViewController.swift
//  DraggableCollectionView
//
//  Created by Mike on 10/11/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit
import SVProgressHUD
import CloudKit

enum ScreenState {
    case edit
    case add
}

class ViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    
    private var stickers: StickerCollection!
    private var pickerController: UIImagePickerController?
    
    fileprivate let padding: CGFloat = 0
    fileprivate var perRow: CGFloat = 3
    
    private var state: ScreenState = .add {
        didSet {
            if state == .add {
                showAddButton()
            } else {
                hideAddButton()
            }
        }
    }
    private var apiType: APIType.Type

    var collectionView: UICollectionView!
    
    var stickersFetched = false
    
    private var tabBarConfig: (ViewController) -> Void = { _ in }
    
    enum NavigationButtonKey: String {
        case select = "select"
        case publish = "publish"
        case cancel = "cancel"
        case trash = "trash"
    }
    
    lazy var navigationButtons: [NavigationButtonKey: UIBarButtonItem] = {
        return [
            NavigationButtonKey.select : UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleState)),
            NavigationButtonKey.publish : UIBarButtonItem(title: "Publish", style: .done, target: self, action: #selector(sync)),
            NavigationButtonKey.cancel : UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(toggleState)),
            NavigationButtonKey.trash : UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        ]
    }()
    
    init(_ apiType: APIType.Type, title: String, _ tabBarConfig: @escaping (ViewController) -> Void) {
        self.apiType = apiType
        self.stickers = StickerCollection([], syncType: apiType)
        self.tabBarConfig = tabBarConfig
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if pickerController == nil {
            pickerController = UIImagePickerController()
            pickerController?.delegate = self
            pickerController?.sourceType = .photoLibrary
        }
        
        if !stickersFetched {
            fetchStickers()
            stickersFetched = true
        }
    }

    // MARK: - Setup
    // MARK: -
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.light)
        
        setupCollectionView()
        setupNavigationBar()
        setupTabBar()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.register(StickerCollectionViewCell.self, forCellWithReuseIdentifier: "StickerCell")
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: "AddCell")
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
    }
    
    private func setupNavigationBar() {
        navigationItem.title = title
        resetNavigationBar()
    }
    
    private func setupTabBar() {
        tabBarConfig(self)
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
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                let cell = collectionView.cellForItem(at: selectedIndexPath) else {
                break
            }
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
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
    }
    
    // MARK: - Data
    // MARK: - 
    
    @objc private func sync() {
        SVProgressHUD.show(withStatus: "Syncing stickers...")
        stickers.sync { response in
            switch response {
            case .success(let newStickers):
                self.stickers = StickerCollection(newStickers, syncType: self.apiType)
                self.collectionView.reloadData()
                SVProgressHUD.showSuccess(withStatus: "Finished!")
                SVProgressHUD.dismiss(withDelay: 1.0)
            case .error:
                SVProgressHUD.showError(withStatus: "Error syncing")
                SVProgressHUD.dismiss(withDelay: 1.0)
            }
        }
    }
    
    private func fetchStickers() {
        SVProgressHUD.show(withStatus: "Fetching stickers...")
        apiType.default.fetchStickers { response in
            switch response {
            case .success(let records):
                SVProgressHUD.dismiss()
                let stickers = records.compactMap { Sticker.from($0) }
                self.stickers = StickerCollection(stickers, syncType: self.apiType)
                self.collectionView.reloadData()
                
                // always start at the bottom of the collection view
                let lastIndexPath = IndexPath(row: stickers.count, section: 0)
                self.collectionView.scrollToItem(at: lastIndexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
            case .error:
                SVProgressHUD.showError(withStatus: "Couldn't load stickers")
                SVProgressHUD.dismiss(withDelay: 1.0)
            }
        }
    }
    
    // MARK: - State
    // MARK: -
    
    fileprivate func refreshTrashCanState() {
        let selectedSticker = stickers.first { $0.isSelected }
        navigationItem.rightBarButtonItem?.isEnabled = selectedSticker != nil
    }
    
    fileprivate func refreshNavigationBarState() {
        switch state {
        case .edit:
            navigationItem.setLeftBarButtonItems([navigationButtons[.cancel]!], animated: true)
            navigationItem.setRightBarButtonItems([navigationButtons[.trash]!], animated: true)
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .add:
            resetNavigationBar()
        }
    }
    
    // MARK: - Utility
    // MARK: -
    
    private func resetNavigationBar() {
        navigationItem.setLeftBarButtonItems([navigationButtons[.select]!], animated: true)
        navigationItem.setRightBarButtonItems([navigationButtons[.publish]!], animated: true)
        
        deselectAllItems()
    }
    
    
    private func deselectAllItems() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        indexPaths.forEach { collectionView.deselectItem(at: $0, animated: true) }
    }
    
    var lastIndexPath: IndexPath {
        return IndexPath(row: stickers.count, section: 0)
    }
    
    private func hideAddButton() {
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [lastIndexPath])
        })
    }
    
    private func showAddButton() {
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [lastIndexPath])
        })
    }
}
    
// MARK: - UICollectionViewDataSource
// MARK: -

extension ViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = stickers.count
        if state == .add && stickersFetched { count += 1 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == stickers.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! AddCell
            cell.clickHandler = { [weak self] in
                self?.addAssetButtonTapped()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCollectionViewCell
            let sticker = stickers[indexPath.row]
            cell.stickerImageView.image = sticker.image
            cell.sticker = sticker
            cell.isSelected = sticker.isSelected
            return cell
        }
    }
}
    
// MARK: - UICollectionViewDelegate
// MARK: -

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return state == .edit
        if state == .edit {
            return true
        } else {
            return indexPath.row == stickers.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if state != .edit && indexPath.row == stickers.count {
            addAssetButtonTapped()
        } else {
            refreshTrashCanState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        refreshTrashCanState()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.row < stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sticker = stickers[sourceIndexPath.row]
        var destinationRow = destinationIndexPath.row
        if destinationIndexPath.row == stickers.count { destinationRow -= 1 }
        stickers.move(sticker, from: sourceIndexPath.row, to: destinationRow)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.row == stickers.count {
            let indexPath = IndexPath(row: proposedIndexPath.row - 1, section: 0)
            return indexPath
        } else {
            return proposedIndexPath
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
        defer {
            dismiss(animated: true) {
                self.deselectAllItems()
            }
        }

        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let asset = CKAsset(fileURL: imageURL)
            let record = CKRecord(recordType: "Sticker")
            record["image"] = asset
            record["sortOrder"] = stickers.count
            self.stickers.append(Sticker.from(record)!)
            self.collectionView.reloadData()
        } else {
            SVProgressHUD.showError(withStatus: "Couldn't find the selected image")
            SVProgressHUD.dismiss(withDelay: 1.0)
        }
    }
}
