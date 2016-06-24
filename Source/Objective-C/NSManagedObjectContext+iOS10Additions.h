//
//  NSManagedObjectContext+iOS10Additions.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 17.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "INSPersistentContainerMacros.h"

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

#ifndef NSFoundationVersionNumber10_11_Max
#define NSFoundationVersionNumber10_11_Max 1299
#endif

@interface NSManagedObjectContext (iOS10Additions)

#if NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
@property (nonatomic) BOOL automaticallyMergesChangesFromParent;
#endif
@property (nonatomic) BOOL ins_automaticallyMergesChangesFromParent;

/**
 *  If the main context is not the parent of the background context, retrieving the object by ID will fail. The temporary ID only exists in the main context and not in the store. The background context therefore has no access to that ID. In that case, you will need to obtain a permanent object ID for the objects in the main context using the API obtainPermanentIDsForObjects(:error:) before you can retrieve them in the background context.
 */
@property (nonatomic) BOOL ins_automaticallyObtainPermanentIDsForInsertedObjects;
@end
