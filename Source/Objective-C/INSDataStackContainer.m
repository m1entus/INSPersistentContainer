//
//  CustomContainer.m
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 19.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSDataStackContainer.h"
#import "NSManagedObjectContext+iOS10Additions.h"

@interface INSDataStackContainerManagedObjectContext : NSManagedObjectContext
@end

@implementation INSDataStackContainerManagedObjectContext

- (void)dealloc {
    self.ins_automaticallyObtainPermanentIDsForInsertedObjects = NO;
    self.ins_automaticallyMergesChangesFromParent = NO;
}

@end

@implementation INSDataStackContainer

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    if (self = [super initWithName:name managedObjectModel:model]) {
        self.viewContext.automaticallyMergesChangesFromParent = YES;
    }
    return self;
}

- (NSManagedObjectContext *)newBackgroundContext {
    NSManagedObjectContext *context = [[INSDataStackContainerManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (self.viewContext.parentContext) {
        context.parentContext = self.viewContext.parentContext;
    } else {
        context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    context.ins_automaticallyObtainPermanentIDsForInsertedObjects = YES;
    return context;
}

@end
