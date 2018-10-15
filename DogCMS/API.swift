//
//  API.swift
//  DogCMS
//
//  Created by Mike on 10/13/18.
//  Copyright © 2018 Mike. All rights reserved.
//

import Foundation
import CloudKit

enum Response<T> {
    case success(T?)
    case error(Error?)
}

class API {
    static let `default` = API()
    
    lazy private var database: CKDatabase = {
        let container = CKContainer.default()
        return container.publicCloudDatabase
    }()
    
    func fetchStickers(_ onCompletion: @escaping (Response<[CKRecord]>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Sticker", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    onCompletion(.error(error))
                } else {
                    onCompletion(.success(records))
                }
            }
        }
    }    
    
    func updateSortOrders(_ stickers: StickerCollection, _ onCompletion: @escaping (Response<[Sticker]>) -> Void) {
        stickers.enumerated().forEach { (offset, element) in
            element.record.setValue(offset, forKey: "sortOrder")
        }
        
        let records = stickers.map { $0.record }
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { records, ids, error in
            DispatchQueue.main.async {
                if let error = error {
                    onCompletion(.error(error))
                } else {
                    onCompletion(.success(nil))
                }
            }
        }
        database.add(operation)
    }
    
    func sync(_ stickers: StickerCollection, _ onCompletion: @escaping (Response<Void>) -> Void) {
        let toAdd = stickers[.added].map { $0.record }
        let idsToDelete = stickers[.deleted].map { $0.record.recordID }
        let operation = CKModifyRecordsOperation(recordsToSave: toAdd, recordIDsToDelete: idsToDelete)
        operation.modifyRecordsCompletionBlock = { records, ids, error in
            DispatchQueue.main.async {
                if let error = error {
                    onCompletion(.error(error))
                } else {
                    self.updateSortOrders(stickers) { response in
                        switch response {
                        case .success:
                            onCompletion(.success(nil))
                        case .error:
                            onCompletion(.error(error))
                        }
                    }
                }
            }
        }
        database.add(operation)
    }
}
