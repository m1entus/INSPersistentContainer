//
//  CustomContainer.m
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 19.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSDataStackContainer.h"
#import "NSManagedObjectContext+iOS10Additions.h"

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

@end
