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
    case success(T)
    case error(Error?)
}

protocol Syncable {
    func sync<T: Collection>(_ collection: T, _ onCompletion: @escaping (Response<[CKRecord]>) -> Void)
    static var `default`: APIType { get }
}

protocol StickerDBInteractable {
    func fetchStickers(_ onCompletion: @escaping (Response<[CKRecord]>) -> Void)
}

typealias APIType = Syncable & StickerDBInteractable
