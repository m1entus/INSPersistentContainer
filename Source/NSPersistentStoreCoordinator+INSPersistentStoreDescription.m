//
//  NSPersistentStoreCoordinator+PersistentStoreDescription.m
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 17.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "NSPersistentStoreCoordinator+INSPersistentStoreDescription.h"

@implementation NSPersistentStoreCoordinator (INSPersistentStoreDescription)

- (void)ins_addPersistentStoreWithDescription:(INSPersistentStoreDescription *)storeDescription completionHandler:(void (^)(INSPersistentStoreDescription *, NSError * _Nullable))block {
    if (storeDescription.shouldAddStoreAsynchronously) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error = nil;
            [self addPersistentStoreWithType:storeDescription.type configuration:storeDescription.configuration URL:storeDescription.URL options:storeDescription.options error:&error];
            if (block) {
                block(storeDescription,error);
            }
        });
    } else {
        NSError *error = nil;
        [self addPersistentStoreWithType:storeDescription.type configuration:storeDescription.configuration URL:storeDescription.URL options:storeDescription.options error:&error];
        if (block) {
            block(storeDescription,error);
        }
    }
}

@end
