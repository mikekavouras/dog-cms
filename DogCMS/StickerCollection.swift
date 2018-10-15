//
//  StickerCollection.swift
//  DogCMS
//
//  Created by Mike on 10/15/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import Foundation

extension Array {
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}

struct StickerCollection: Collection {
    typealias Element = Sticker
    typealias Index = Array<Sticker>.Index
    
    enum ModificationType {
        case added
        case deleted
    }
    
    var startIndex: Array<Sticker>.Index {
        return stickers.startIndex
    }
    var endIndex: Array<Sticker>.Index {
        return stickers.endIndex
    }
    
    private var stickers: [Sticker] = []
    private var deletions: [Sticker] = []
    
    init(_ stickers: [Sticker]) {
        self.stickers = stickers
    }
    
    subscript(index: Index) -> Element {
        get { return stickers[index] }
    }
    
    subscript(type: ModificationType) -> [Element] {
        get {
            switch type {
            case .added:
                return stickers.filter { $0.record.creationDate == nil }
            case .deleted:
                return deletions
            }
        }
    }
    
    mutating func flushChanges() {
        deletions = []
        stickers.forEach { sticker in
            if sticker.record.creationDate == nil {
                sticker.record["creationDate"] = Date()
            }
        }
    }
    
    func index(after i: Index) -> Index {
        return stickers.index(after: i)
    }
    
    mutating func remove(at index: Index) {
        if let _ = stickers[index].record.creationDate {
            deletions.append(stickers[index])
        }
        stickers.remove(at: index)
    }

    mutating func remove(at indices: [Index]) {
        indices.forEach { index in
            if let _ = stickers[index].record.creationDate {
                deletions.append(stickers[index])
            }
        }
        stickers.remove(at: indices)
    }
    
    mutating func insert(_ sticker: Sticker, at index: Index) {
        stickers.insert(sticker, at: index)
    }
    
    mutating func append(_ sticker: Sticker) {
        stickers.append(sticker)
    }
    
    mutating func move(_ sticker: Sticker, from: Index, to: Index) {
        stickers.remove(at: from)
        stickers.insert(sticker, at: to)
    }
}
