//
//  NSPersistentContainer.h
//  INSFetchResultsControllerDataSource
//
//  Created by Michal Zaborowski on 15.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "INSPersistentStoreDescription.h"
#import "INSPersistentContainerMacros.h"

NS_ASSUME_NONNULL_BEGIN

// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides convenience methods and properties for common patterns.
@interface INSPersistentContainer : NSObject {
#if (!__OBJC2__)
@private
    id _name;
    NSManagedObjectContext *_viewContext;
    id _storeCoordinator;
    id _storeDescriptions;
#endif
}

+ (instancetype)persistentContainerWithName:(NSString *)name;
+ (instancetype)persistentContainerWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model;

+ (NSURL *)defaultDirectoryURL;

@property (copy, readonly) NSString *name;
@property (strong, readonly) NSManagedObjectContext *viewContext;
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (copy) NSArray<INSPersistentStoreDescription *> *persistentStoreDescriptions;

// Creates a container using the model named `name` in the main bundle, or the merged model (from the main bundle) if no match was found.
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model NS_DESIGNATED_INITIALIZER;

// Load stores from the storeDescriptions property that have not already been successfully added to the container. The completion handler is called once for each store that succeeds or fails.
- (void)loadPersistentStoresWithCompletionHandler:(void (^)(INSPersistentStoreDescription *, NSError * _Nullable))block;

- (NSManagedObjectContext *)newBackgroundContext NS_RETURNS_RETAINED;
- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block;

@end

NS_ASSUME_NONNULL_END

#if NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
@interface NSPersistentContainer: INSPersistentContainer @end
#endif
