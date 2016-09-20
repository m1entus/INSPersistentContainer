//
//  Entity+CoreDataProperties.swift
//  INSPersistentContainer-Swift2
//
//  Created by Michal Zaborowski on 21.08.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

import Foundation
import CoreData

extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity");
    }

    @NSManaged public var name: String?
    @NSManaged public var isEven: NSNumber?

}
