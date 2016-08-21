//
//  INSDataStackContainer.swift
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

import CoreData

class INSDataStackContainer: INSPersistentContainer {
    private class INSDataStackContainerManagedObjectContext: NSManagedObjectContext {
        deinit {
            self.ins_automaticallyObtainPermanentIDsForInsertedObjects = false
            
            guard #available(iOS 10.0, OSX 10.12, *) else {
                self.ins_automaticallyMergesChangesFromParent = false
                return
            }
        }
    }
    
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
        if #available(iOS 10.0, OSX 10.12, *) {
            #if swift(>=2.3)
                viewContext.automaticallyMergesChangesFromParent = true
            #endif
        } else {
            viewContext.ins_automaticallyMergesChangesFromParent = true
        }
    }
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let context = INSDataStackContainerManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        if let parentContext = viewContext.parentContext {
            context.parentContext = parentContext
        } else {
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        context.ins_automaticallyObtainPermanentIDsForInsertedObjects = true
        return context
    }
}
