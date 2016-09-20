//
//  INSPersistentStoreDescription.swift
//  INSPersistentContainer-Swift2
//
//  Created by Michal Zaborowski on 24.06.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import CoreData

// An instance of NSPersistentStoreDescription encapsulates all information needed to describe a persistent store.

open class INSPersistentStoreDescription: CustomStringConvertible {
    open var type: String = "SQLite"
    open var configuration: String?
    
    open var url: Foundation.URL
    open private(set) var options: [String : Any] = [:]

    open var sqlitePragmas: [String : Any] {
        return options[NSSQLitePragmasOption] as? [String : Any] ?? [:]
    }
    
    open var description: String {
        return "type: \(type), url: \(url)"
    }
    
    // addPersistentStore-time behaviours
    open var shouldAddStoreAsynchronously: Bool {
        set {
            options["NSAddStoreAsynchronouslyOption"] = newValue
        }
        get {
            return options["NSAddStoreAsynchronouslyOption"] as? Bool ?? false
        }
    }
    open var shouldMigrateStoreAutomatically: Bool {
        set {
            options[NSMigratePersistentStoresAutomaticallyOption] = newValue
        }
        get {
            return options[NSMigratePersistentStoresAutomaticallyOption] as? Bool ?? false
        }
    }
    open var shouldInferMappingModelAutomatically: Bool {
        set {
            options[NSInferMappingModelAutomaticallyOption] = newValue
        }
        get {
            return options[NSInferMappingModelAutomaticallyOption] as? Bool ?? false
        }
    }
    
    // Store options
    open var isReadOnly: Bool {
        set {
            options[NSReadOnlyPersistentStoreOption] = newValue
        }
        get {
            return options[NSReadOnlyPersistentStoreOption] as? Bool ?? false
        }
    }
    open var timeout: TimeInterval {
        set {
            options[NSPersistentStoreTimeoutOption] = newValue
        }
        get {
            return options[NSPersistentStoreTimeoutOption] as? TimeInterval ?? 0
        }
    }
    
    // Returns a store description instance with default values for the store located at `URL` that can be used immediately with `addPersistentStoreWithDescription:completionHandler:`.
    public init(url: Foundation.URL) {
        self.url = (url as NSURL).copy() as! Foundation.URL
        self.shouldMigrateStoreAutomatically = true
        self.shouldInferMappingModelAutomatically = true
    }
    
    open func setValue(_ value: NSObject?, forPragmaNamed name: String) {
        var pragmas = sqlitePragmas
        if let value = value {
            pragmas[name] = value
        } else {
            pragmas.removeValue(forKey: name)
        }
        setOption(pragmas as NSObject?, forKey: NSSQLitePragmasOption)
    }
    
    open func setOption(_ option: NSObject?, forKey key: String) {
        var options = self.options
        if let option = option {
            options[key] = option
        } else {
            options.removeValue(forKey: key)
        }
    }
}

extension NSPersistentStoreCoordinator {
    open func ins_addPersistentStore(with storeDescription: INSPersistentStoreDescription, completionHandler block: @escaping (INSPersistentStoreDescription, Error?) -> Swift.Void) {
        if storeDescription.shouldAddStoreAsynchronously {
            DispatchQueue.global(qos: .background).async(execute: {
                do {
                    try self.addPersistentStore(ofType: storeDescription.type, configurationName: storeDescription.configuration, at: storeDescription.url, options: storeDescription.options)
                    block(storeDescription, nil)
                } catch let error as NSError {
                    block(storeDescription, error)
                }
            })
        } else {
            do {
                try self.addPersistentStore(ofType: storeDescription.type, configurationName: storeDescription.configuration, at: storeDescription.url, options: storeDescription.options)
                block(storeDescription, nil)
            } catch let error as NSError {
                block(storeDescription, error)
            }
        }
    }
}
