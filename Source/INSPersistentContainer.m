//
//  NSPersistentContainer.m
//  INSFetchResultsControllerDataSource
//
//  Created by Michal Zaborowski on 15.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSPersistentContainer.h"
#import "NSPersistentStoreCoordinator+INSPersistentStoreDescription.h"
#import "NSManagedObjectContext+iOS10Additions.h"
#import <objc/runtime.h>

@interface INSPersistentContainer ()
@property (copy) NSString *name;
@property (strong) NSManagedObjectContext *viewContext;
@property (strong) NSManagedObjectModel *managedObjectModel;
@property (strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation INSPersistentContainer
@synthesize name = _name;
@synthesize viewContext = _viewContext;
@synthesize persistentStoreCoordinator = _storeCoordinator;
@synthesize persistentStoreDescriptions = _storeDescriptions;

+ (NSURL *)defaultDirectoryURL {
    static dispatch_once_t onceToken;
    static NSURL *_defaultDirectoryURL = nil;
    dispatch_once(&onceToken, ^{
        _defaultDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    });
    return _defaultDirectoryURL;
}

+ (instancetype)persistentContainerWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}
+ (instancetype)persistentContainerWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    return [[self alloc] initWithName:name managedObjectModel:model];
}

- (instancetype)init {
    return [self initWithName:NSStringFromClass([self class])];
}

- (instancetype)initWithName:(NSString *)name {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"mom"] ?: [[NSBundle mainBundle] URLForResource:name withExtension:@"momd"];
    if (modelURL) {
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        if (model) {
            return [self initWithName:name managedObjectModel:model];
        }
        NSLog(@"CoreData: Failed to load model at path: %@", [modelURL path]);
    }
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]];
    return [self initWithName:name managedObjectModel:model];
}

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    if (self = [super init]) {
        self->_name = name;
        self->_storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        self->_viewContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self->_viewContext.persistentStoreCoordinator = self->_storeCoordinator;
        
        self->_storeDescriptions = @[[INSPersistentStoreDescription persistentStoreDescriptionWithURL:[[[self class] defaultDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",name]]]];
    }
    return self;
}

- (void)loadPersistentStoresWithCompletionHandler:(void (^)(INSPersistentStoreDescription *, NSError * _Nullable))block {
    [self.persistentStoreDescriptions enumerateObjectsUsingBlock:^(INSPersistentStoreDescription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self->_storeCoordinator ins_addPersistentStoreWithDescription:obj completionHandler:block];
    }];
}

- (NSManagedObjectContext *)newBackgroundContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (self.viewContext.parentContext) {
        context.parentContext = self.viewContext.parentContext;
    } else {
        context.persistentStoreCoordinator = self->_storeCoordinator;
    }
    return context;
}

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block {
    NSManagedObjectContext *context = [self newBackgroundContext];
    [context performBlock:^{
        block(context);
    }];
}

@end

#if NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
@implementation NSPersistentContainer @end
#endif
