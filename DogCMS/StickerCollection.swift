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
    
    var startIndex: Array<Sticker>.Index {
        return stickers.startIndex
    }
    var endIndex: Array<Sticker>.Index {
        return stickers.endIndex
    }
    
    private var stickers = [Sticker]()
    
    init(_ stickers: [Sticker]) {
        self.stickers = stickers
    }
    
    subscript(index: Index) -> Element {
        get { return stickers[index] }
    }
    
    func index(after i: Index) -> Index {
        return stickers.index(after: i)
    }
    
    mutating func remove(at index: Index) {
        stickers.remove(at: index)
    }

    mutating func remove(at indices: [Index]) {
        stickers.remove(at: indices)
    }
    
    mutating func insert(_ sticker: Sticker, at index: Index) {
        stickers.insert(sticker, at: index)
    }
    
    mutating func append(_ sticker: Sticker) {
        stickers.append(sticker)
    }
}
