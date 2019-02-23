//
//  CreaturesAPI.swift
//  DogCMS
//
//  Created by Mike on 2/23/19.
//  Copyright © 2019 Mike. All rights reserved.
//

import CloudKit

class CreaturesAPI: APIType {
    static var `default`: APIType = CreaturesAPI()
    
    lazy private var database: CKDatabase = {
        let container = CKContainer(identifier: "iCloud.com.mikekavouras.OMG"
        )
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
                    onCompletion(.success(records ?? []))
                }
            }
        }
    }
    
    func sync<T: Collection>(_ collection: T, _ onCompletion: @escaping (Response<[CKRecord]>) -> Void) {
        guard let collection = collection as? StickerCollection else { return }
        let toAdd = collection.map { $0.record }
        let idsToDelete = collection[.deleted].map { $0.record.recordID }
        let operation = CKModifyRecordsOperation(recordsToSave: toAdd, recordIDsToDelete: idsToDelete)
        operation.modifyRecordsCompletionBlock = { records, ids, error in
            DispatchQueue.main.async {
                if let error = error {
                    onCompletion(.error(error))
                } else {
                    onCompletion(.success(records ?? []))
                }
            }
        }
        database.add(operation)
    }
}
