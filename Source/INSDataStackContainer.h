//
//  CustomContainer.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 19.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSPersistentContainer.h"

NS_ASSUME_NONNULL_BEGIN

// Custom Data Stack which automatically merges changes from parent context and automatically obtain permanent IDs for inserted objects in background context.
// Use containerWithName:managedObjectModel to initialize it, because of dynamic NSPersistentContainer class injection explained in implementation file.

@interface INSDataStackContainer : INSPersistentContainer

+ (NSPersistentContainer *)containerWithName:(NSString *)name;
+ (NSPersistentContainer *)containerWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model;

@end

NS_ASSUME_NONNULL_END
