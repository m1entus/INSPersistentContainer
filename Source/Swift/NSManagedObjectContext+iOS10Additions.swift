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
        static var NotificationQueue: String = "ins_notificationQueue"
    }
    
    private var notificationQueue: DispatchQueue {
        guard let notificationQueue = objc_getAssociatedObject(self, &AssociatedKeys.NotificationQueue) as? DispatchQueue else {
            let queue = DispatchQueue(label: "io.inspace.managedobjectcontext.notificationqueue")
            objc_setAssociatedObject(self, &AssociatedKeys.ObtainPermamentIDsForInsertedObjects, queue, .OBJC_ASSOCIATION_RETAIN)
            return queue
        }
        return notificationQueue
    }
    
    private var _ins_automaticallyObtainPermanentIDsForInsertedObjects: Bool {
        return objc_getAssociatedObject(self, &AssociatedKeys.ObtainPermamentIDsForInsertedObjects) as? Bool ?? false
    }
    
    var ins_automaticallyObtainPermanentIDsForInsertedObjects: Bool {
        set {
            notificationQueue.sync {
                if newValue != self._ins_automaticallyObtainPermanentIDsForInsertedObjects {
                    objc_setAssociatedObject(self, &AssociatedKeys.ObtainPermamentIDsForInsertedObjects, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    if newValue {
                        NotificationCenter.default.addObserver(self, selector: #selector(NSManagedObjectContext.ins_automaticallyObtainPermanentIDsForInsertedObjectsFromWillSaveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: self)
                    } else {
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextWillSave, object: self)
                    }
                }
            }
        }
        get {
            var value = false
            notificationQueue.sync {
                value = self._ins_automaticallyObtainPermanentIDsForInsertedObjects
            }
            return value
        }
    }
    
    private var _ins_automaticallyMergesChangesFromParent: Bool {
        return objc_getAssociatedObject(self, &AssociatedKeys.MergesChangesFromParent) as? Bool ?? false
    }
    
    var ins_automaticallyMergesChangesFromParent: Bool {
        set {
            if concurrencyType == NSManagedObjectContextConcurrencyType(rawValue: 0)/* .ConfinementConcurrencyType */ {
                fatalError("Automatic merging is not supported by contexts using NSConfinementConcurrencyType")
            }
            if parent == nil && persistentStoreCoordinator == nil {
                fatalError("Cannot enable automatic merging for a context without a parent, set a parent context or persistent store coordinator first.")
            }
            notificationQueue.sync {
                if newValue != self._ins_automaticallyMergesChangesFromParent {
                    objc_setAssociatedObject(self, &AssociatedKeys.MergesChangesFromParent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    if newValue {
                        NotificationCenter.default.addObserver(self, selector: #selector(NSManagedObjectContext.ins_automaticallyMergeChangesFromContextDidSaveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.parent)
                    } else {
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.parent)
                    }
                }
            }
        }
        get {
            if concurrencyType == NSManagedObjectContextConcurrencyType(rawValue: 0)/* .ConfinementConcurrencyType */ {
                return false
            }
            var value = false
            notificationQueue.sync {
                value = self._ins_automaticallyMergesChangesFromParent
            }
            return value
        }
    }
    
    @objc private func ins_automaticallyMergeChangesFromContextDidSaveNotification(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext, let persistentStoreCoordinator = persistentStoreCoordinator, let contextCoordinator = context.persistentStoreCoordinator , persistentStoreCoordinator == contextCoordinator else {
            return
        }
        let isRootContext = context.parent == nil
        let isParentContext = parent == context
        guard (isRootContext || isParentContext) && context != self else {
            return
        }
        perform {
            // WORKAROUND FOR: http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different/3927811#3927811
            if let updatedObjects = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> , !updatedObjects.isEmpty {
                for updatedObject in updatedObjects {
                    self.object(with: updatedObject.objectID).willAccessValue(forKey: nil) // ensures that a fault has been fired
                }
            }

            self.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc private func ins_automaticallyObtainPermanentIDsForInsertedObjectsFromWillSaveNotification(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext , context.insertedObjects.count > 0 else {
            return
        }
        context.perform {
            _ = try? context.obtainPermanentIDs(for: Array(context.insertedObjects))
        }
    }
}
