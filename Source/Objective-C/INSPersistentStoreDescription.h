//
//  INSPersistentStoreDescription.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 15.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "INSPersistentContainerMacros.h"

NS_ASSUME_NONNULL_BEGIN

// An instance of NSPersistentStoreDescription encapsulates all information needed to describe a persistent store.
@interface INSPersistentStoreDescription : NSObject <NSCopying> {
#if (!__OBJC2__)
@private
    id _type;
    id _configuration;
    id _url;
    id _options;
#endif
}

+ (instancetype)persistentStoreDescriptionWithURL:(NSURL *)URL;

@property (copy) NSString *type;
@property (copy, nullable) NSString *configuration;
@property (copy, nullable) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSObject *> *options;

- (void)setOption:(nullable NSObject *)option forKey:(NSString *)key;

// Store options
@property (getter = isReadOnly) BOOL readOnly;
@property NSTimeInterval timeout;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSObject *> *sqlitePragmas;

- (void)setValue:(nullable NSObject *)value forPragmaNamed:(NSString *)name;

// addPersistentStore-time behaviours
@property BOOL shouldAddStoreAsynchronously;
@property BOOL shouldMigrateStoreAutomatically;
@property BOOL shouldInferMappingModelAutomatically;

// Returns a store description instance with default values for the store located at `URL` that can be used immediately with `addPersistentStoreWithDescription:completionHandler:`.
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#if NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
@interface NSPersistentStoreDescription: INSPersistentStoreDescription @end
#endif
