//
//  CustomContainer.m
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 19.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSDataStackContainer.h"
#import "NSManagedObjectContext+iOS10Additions.h"

/**
 We are replacing INSPersistentContainer to NSPersistentContainer in runtime,
 so for iOS less than 10, INSDataStackContainer is nil after allocating,
 thats why i created INSNSDataStackContainer inherited from NSPersistentContainer for iOS 10 and grater,
 and INSDataStackContainer for iOS less than 10.
 */
@interface INSNSDataStackContainer : NSPersistentContainer
@end

@implementation INSNSDataStackContainer

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    if (self = [super initWithName:name managedObjectModel:model]) {
        self.viewContext.automaticallyMergesChangesFromParent = YES;
    }
    return self;
}

- (NSManagedObjectContext *)newBackgroundContext {
    NSManagedObjectContext *context = [super newBackgroundContext];
    context.ins_automaticallyObtainPermanentIDsForInsertedObjects = YES;
    return context;
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
    NSManagedObjectContext *context = [super newBackgroundContext];
    context.ins_automaticallyObtainPermanentIDsForInsertedObjects = YES;
    return context;
}

+ (NSPersistentContainer *)containerWithName:(NSString *)name {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max) {
        return [[INSNSDataStackContainer alloc] initWithName:name];
    }
    return (NSPersistentContainer *)[[INSDataStackContainer alloc] initWithName:name];
}
+ (NSPersistentContainer *)containerWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max) {
        return [[INSNSDataStackContainer alloc] initWithName:name managedObjectModel:model];
    }
    return (NSPersistentContainer *)[[INSDataStackContainer alloc] initWithName:name managedObjectModel:model];
}

@end
