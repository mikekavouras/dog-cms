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

class StickerCollection: Collection {
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
    private var syncType: APIType.Type
    
    init(_ stickers: [Sticker], syncType: APIType.Type) {
        self.stickers = stickers
        self.syncType = syncType
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
    
    func sync(_ onCompletion: @escaping (Response<[Sticker]>) -> Void) {
        stickers.enumerated().forEach { offset, element in
            element.record["sortOrder"] = offset
        }
        syncType.default.sync(self) { response in
            switch response {
            case .success(let records):
                let newStickers = records.compactMap { Sticker.from($0) }.sorted(by: { a, b in
                    return (a.record["sortOrder"] as! Int) < (b.record["sortOrder"] as! Int)
                })
                onCompletion(.success(newStickers))
            default: break
            }

        }
    }
    
    func index(after i: Index) -> Index {
        return stickers.index(after: i)
    }
    
    func remove(at index: Index) {
        if let _ = stickers[index].record.creationDate {
            deletions.append(stickers[index])
        }
        stickers.remove(at: index)
    }

    func remove(at indices: [Index]) {
        indices.forEach { index in
            if let _ = stickers[index].record.creationDate {
                deletions.append(stickers[index])
            }
        }
        stickers.remove(at: indices)
    }

    func append(_ sticker: Sticker) {
        stickers.append(sticker)
    }
    
    func move(_ sticker: Sticker, from: Index, to: Index) {
        stickers.remove(at: from)
        stickers.insert(sticker, at: to)
    }
}
