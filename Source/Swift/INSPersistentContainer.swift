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
public class INSPersistentContainer {
    
    public class func defaultDirectoryURL() -> NSURL {
        struct Static {
            static let instance: NSURL = {
                guard let applicationSupportURL = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first else {
                    fatalError("Found no possible URLs for directory type \(NSSearchPathDirectory.ApplicationSupportDirectory)")
                }
                
                var isDirectory = ObjCBool(false)
                if !NSFileManager.defaultManager().fileExistsAtPath(applicationSupportURL.path!, isDirectory: &isDirectory) {
                    do {
                        try NSFileManager.defaultManager().createDirectoryAtURL(applicationSupportURL, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        fatalError("Failed to create directory \(applicationSupportURL)")
                    }
                }
                return applicationSupportURL
            }()
        }
        return Static.instance
    }
    
    public private(set) var name: String
    public var viewContext: NSManagedObjectContext
    public var managedObjectModel: NSManagedObjectModel {
        return persistentStoreCoordinator.managedObjectModel
    }
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator
    public private(set) var persistentStoreDescriptions: [INSPersistentStoreDescription]
    
    public convenience init(name: String) {
        if let modelURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mom") ?? NSBundle.mainBundle().URLForResource(name, withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                self.init(name: name, managedObjectModel: model)
                return
            }
            print("CoreData: Failed to load model at path: \(modelURL)")
        }
        guard let model = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()]) else {
            fatalError("Couldn't find managed object model in main bundle.")
        }
        self.init(name: name, managedObjectModel: model)
    }
    
    public init(name: String, managedObjectModel model: NSManagedObjectModel) {
        self.name = name
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.viewContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        #if swift(>=2.3)
            self.persistentStoreDescriptions = [INSPersistentStoreDescription(URL: self.dynamicType.defaultDirectoryURL().URLByAppendingPathComponent("\(name).sqlite")!)]
        #else
            self.persistentStoreDescriptions = [INSPersistentStoreDescription(URL: self.dynamicType.defaultDirectoryURL().URLByAppendingPathComponent("\(name).sqlite"))]
        #endif
    }
    
    // Load stores from the storeDescriptions property that have not already been successfully added to the container. The completion handler is called once for each store that succeeds or fails.
    public func loadPersistentStoresWithCompletionHandler(block: (INSPersistentStoreDescription, NSError?) -> Void) {
        for persistentStoreDescription in persistentStoreDescriptions {
            persistentStoreCoordinator.ins_addPersistentStoreWithDescription(persistentStoreDescription, completionHandler: block)
        }
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        if let parentContext = viewContext.parentContext {
            context.parentContext = parentContext
        } else {
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        return context
    }
    
    public func performBackgroundTask(block: (NSManagedObjectContext) -> Void) {
        let context = newBackgroundContext()
        context.performBlock { 
            block(context)
        }
    }
}

