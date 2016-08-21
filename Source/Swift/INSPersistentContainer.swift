//
//  INSPersistentContainer.swift
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

// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides convenience methods and properties for common patterns.
open class INSPersistentContainer {
    open class func defaultDirectoryURL() -> URL {
        struct Static {
            static let instance: URL = {
                guard let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                    fatalError("Found no possible URLs for directory type \(FileManager.SearchPathDirectory.applicationSupportDirectory)")
                }
                
                var isDirectory = ObjCBool(false)
                if !FileManager.default.fileExists(atPath: applicationSupportURL.path, isDirectory: &isDirectory) {
                    do {
                        try FileManager.default.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true, attributes: nil)
                        return applicationSupportURL
                    } catch {
                        fatalError("Failed to create directory \(applicationSupportURL)")
                    }
                }
                return applicationSupportURL
            }()
        }
        return Static.instance
    }
    
    open private(set) var name: String
    open private(set) var viewContext: NSManagedObjectContext
    open var managedObjectModel: NSManagedObjectModel {
        return persistentStoreCoordinator.managedObjectModel
    }
    open private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator
    open var persistentStoreDescriptions: [INSPersistentStoreDescription]
    
    public convenience init(name: String) {
        if let modelURL = Bundle.main.url(forResource: name, withExtension: "mom") ?? Bundle.main.url(forResource: name, withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOf: modelURL) {
                self.init(name: name, managedObjectModel: model)
                return
            }
            print("CoreData: Failed to load model at path: \(modelURL)")
        }
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle.main]) else {
            fatalError("Couldn't find managed object model in main bundle.")
        }
        self.init(name: name, managedObjectModel: model)
    }
    
    public init(name: String, managedObjectModel model: NSManagedObjectModel) {
        self.name = name
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        self.persistentStoreDescriptions = [INSPersistentStoreDescription(url: type(of: self).defaultDirectoryURL().appendingPathComponent("\(name).sqlite"))]
    }
    
    // Load stores from the storeDescriptions property that have not already been successfully added to the container. The completion handler is called once for each store that succeeds or fails.
    open func loadPersistentStores(completionHandler block: @escaping (INSPersistentStoreDescription, Error?) -> Swift.Void) {
        for persistentStoreDescription in persistentStoreDescriptions {
            persistentStoreCoordinator.ins_addPersistentStore(with: persistentStoreDescription, completionHandler: block)
        }
    }

    open func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        if let parentContext = viewContext.parent {
            context.parent = parentContext
        } else {
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        return context
    }
    
    open func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = newBackgroundContext()
        context.perform { 
            block(context)
        }
    }
}

