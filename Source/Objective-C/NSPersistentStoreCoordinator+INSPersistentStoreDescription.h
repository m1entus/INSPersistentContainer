//
//  NSPersistentStoreCoordinator+PersistentStoreDescription.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 17.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "INSPersistentStoreDescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentStoreCoordinator (INSPersistentStoreDescription)

- (void)ins_addPersistentStoreWithDescription:(INSPersistentStoreDescription *)storeDescription completionHandler:(void (^)(INSPersistentStoreDescription *, NSError * _Nullable))block;

@end

NS_ASSUME_NONNULL_END
