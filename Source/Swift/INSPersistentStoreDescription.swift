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
public struct INSPersistentStoreDescription: CustomStringConvertible {
    public var type: String = "SQLite"
    public var configuration: String?
    
    public var URL: NSURL
    public private(set) var options: [String : NSObject] = [:]

    public var sqlitePragmas: [String : NSObject] {
        return options[NSSQLitePragmasOption] as? [String : NSObject] ?? [:]
    }
    
    public var description: String {
        return "type: \(type), url: \(URL)"
    }
    
    // addPersistentStore-time behaviours
    public var shouldAddStoreAsynchronously: Bool {
        set {
            options["NSAddStoreAsynchronouslyOption"] = newValue
        }
        get {
            return options["NSAddStoreAsynchronouslyOption"] as? Bool ?? false
        }
    }
    public var shouldMigrateStoreAutomatically: Bool {
        set {
            options[NSMigratePersistentStoresAutomaticallyOption] = newValue
        }
        get {
            return options[NSMigratePersistentStoresAutomaticallyOption] as? Bool ?? false
        }
    }
    public var shouldInferMappingModelAutomatically: Bool {
        set {
            options[NSInferMappingModelAutomaticallyOption] = newValue
        }
        get {
            return options[NSInferMappingModelAutomaticallyOption] as? Bool ?? false
        }
    }
    
    // Store options
    public var readOnly: Bool {
        set {
            options[NSReadOnlyPersistentStoreOption] = newValue
        }
        get {
            return options[NSReadOnlyPersistentStoreOption] as? Bool ?? false
        }
    }
    public var timeout: NSTimeInterval {
        set {
            options[NSPersistentStoreTimeoutOption] = newValue
        }
        get {
            return options[NSPersistentStoreTimeoutOption] as? NSTimeInterval ?? 0
        }
    }
    
    // Returns a store description instance with default values for the store located at `URL` that can be used immediately with `addPersistentStoreWithDescription:completionHandler:`.
    public init(URL url: NSURL) {
        self.URL = url.copy() as! NSURL
        self.shouldMigrateStoreAutomatically = true
        self.shouldInferMappingModelAutomatically = true
    }
    
    public func setValue(value: NSObject?, forPragmaNamed name: String) {
        var pragmas = sqlitePragmas
        if let value = value {
            pragmas[name] = value
        } else {
            pragmas.removeValueForKey(name)
        }
        setOption(pragmas, forKey: NSSQLitePragmasOption)
    }
    
    public func setOption(option: NSObject?, forKey key: String) {
        var options = self.options
        if let option = option {
            options[key] = option
        } else {
            options.removeValueForKey(key)
        }
    }
}

extension NSPersistentStoreCoordinator {
    public func ins_addPersistentStoreWithDescription(storeDescription: INSPersistentStoreDescription, completionHandler block: (INSPersistentStoreDescription, NSError?) -> Void) {
        if storeDescription.shouldAddStoreAsynchronously {
            dispatch_async(dispatch_get_global_queue(0, 0), {
                do {
                    try self.addPersistentStoreWithType(storeDescription.type, configuration: storeDescription.configuration, URL: storeDescription.URL, options: storeDescription.options)
                    block(storeDescription, nil)
                } catch let error as NSError {
                    block(storeDescription, error)
                }
            })
        } else {
            do {
                try self.addPersistentStoreWithType(storeDescription.type, configuration: storeDescription.configuration, URL: storeDescription.URL, options: storeDescription.options)
                block(storeDescription, nil)
            } catch let error as NSError {
                block(storeDescription, error)
            }
        }
    }
}
