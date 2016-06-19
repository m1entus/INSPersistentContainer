//
//  Entity+CoreDataProperties.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 19.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Entity.h"

NS_ASSUME_NONNULL_BEGIN

@interface Entity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
