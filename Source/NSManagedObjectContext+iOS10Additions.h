//
//  NSManagedObjectContext+iOS10Additions.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 17.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <CoreData/CoreData.h>

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@interface NSManagedObjectContext (iOS10Additions)
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
@property (nonatomic) BOOL automaticallyMergesChangesFromParent;
#endif
@property (nonatomic) BOOL ins_automaticallyMergesChangesFromParent;
@property (nonatomic) BOOL ins_automaticallyObtainPermanentIDsForInsertedObjects;
@end
