//
//  NSManagedObjectContext+iOS10Additions.swift
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
import ObjectiveC

extension NSManagedObjectContext {
    private struct AssociatedKeys {
        static var MergesChangesFromParent: String = "ins_automaticallyMergesChangesFromParent"
        static var ObtainPermamentIDsForInsertedObjects: String = "ins_automaticallyObtainPermanentIDsForInsertedObjects"
    }

    var ins_automaticallyObtainPermanentIDsForInsertedObjects: Bool {
        set {
            performBlockAndWait {
                if newValue != self.ins_automaticallyObtainPermanentIDsForInsertedObjects {
                    objc_setAssociatedObject(self, &AssociatedKeys.ObtainPermamentIDsForInsertedObjects, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    if newValue {
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NSManagedObjectContext.ins_automaticallyObtainPermanentIDsForInsertedObjectsFromWillSaveNotification(_:)), name: NSManagedObjectContextWillSaveNotification, object: self)
                    } else {
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextWillSaveNotification, object: self)
                    }
                }
            }
            
        }
        get {
            var value = false
            performBlockAndWait { 
                value = objc_getAssociatedObject(self, &AssociatedKeys.ObtainPermamentIDsForInsertedObjects) as? Bool ?? false
            }
            return value
        }
    }
    
    var ins_automaticallyMergesChangesFromParent: Bool {
        set {
            if concurrencyType == NSManagedObjectContextConcurrencyType(rawValue: 0)/* .ConfinementConcurrencyType */ {
                fatalError("Automatic merging is not supported by contexts using NSConfinementConcurrencyType")
            }
            if parentContext == nil && persistentStoreCoordinator == nil {
                fatalError("Cannot enable automatic merging for a context without a parent, set a parent context or persistent store coordinator first.")
            }
            performBlockAndWait { 
                if newValue != self.ins_automaticallyMergesChangesFromParent {
                    objc_setAssociatedObject(self, &AssociatedKeys.MergesChangesFromParent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    if newValue {
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NSManagedObjectContext.ins_automaticallyMergeChangesFromContextDidSaveNotification(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.parentContext)
                    } else {
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: self.parentContext)
                    }
                }
            }
        }
        get {
            if concurrencyType == NSManagedObjectContextConcurrencyType(rawValue: 0)/* .ConfinementConcurrencyType */ {
                return false
            }
            var value = false
            performBlockAndWait {
                value = objc_getAssociatedObject(self, &AssociatedKeys.MergesChangesFromParent) as? Bool ?? false
            }
            return value
        }
    }
    
    @objc private func ins_automaticallyMergeChangesFromContextDidSaveNotification(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext, let persistentStoreCoordinator = persistentStoreCoordinator, let contextCoordinator = context.persistentStoreCoordinator where persistentStoreCoordinator == contextCoordinator else {
            return
        }
        let isRootContext = context.parentContext == nil
        let isParentContext = parentContext == context
        guard (isRootContext || isParentContext) && context != self else {
            return
        }
        performBlock {
            // WORKAROUND FOR: http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different/3927811#3927811
            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> where !updatedObjects.isEmpty {
                for updatedObject in updatedObjects {
                    self.objectWithID(updatedObject.objectID).willAccessValueForKey(nil) // ensures that a fault has been fired
                }
            }

            self.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    @objc private func ins_automaticallyObtainPermanentIDsForInsertedObjectsFromWillSaveNotification(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext where context.insertedObjects.count > 0 else {
            return
        }
        _ = try? context.obtainPermanentIDsForObjects(Array(context.insertedObjects))
    }
}