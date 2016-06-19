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

#pragma mark - Runtime Injection

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

// ----------------------------------------------------
// Runtime injection start.
// Assemble codes below are based on:
// https://github.com/0xced/NSUUID/blob/master/NSUUID.m
// ----------------------------------------------------

__asm(
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_NSPersistentContainer:\n"
      ".quad           _OBJC_CLASS_$_NSPersistentContainer\n"
#else
      ".align          2\n"
      "_OBJC_CLASS_NSPersistentContainer:\n"
      ".long           _OBJC_CLASS_$_NSPersistentContainer\n"
#endif
      ".weak_reference _OBJC_CLASS_$_NSPersistentContainer\n"
      );

// Constructors are called after all classes have been loaded.
__attribute__((constructor)) static void INSPersistentContainerPatchEntry(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            
            // >= iOS10.
            if (objc_getClass("NSPersistentContainer")) {
                return;
            }
            
            Class *persistentContainerClassLocation = NULL;
            
#if TARGET_CPU_ARM
            __asm("movw %0, :lower16:(_OBJC_CLASS_NSPersistentContainer-(LPC0+4))\n"
                  "movt %0, :upper16:(_OBJC_CLASS_NSPersistentContainer-(LPC0+4))\n"
                  "LPC0: add %0, pc" : "=r"(persistentContainerClassLocation));
#elif TARGET_CPU_ARM64
            __asm("adrp %0, L_OBJC_CLASS_NSPersistentContainer@PAGE\n"
                  "add  %0, %0, L_OBJC_CLASS_NSPersistentContainer@PAGEOFF" : "=r"(persistentContainerClassLocation));
#elif TARGET_CPU_X86_64
            __asm("leaq L_OBJC_CLASS_NSPersistentContainer(%%rip), %0" : "=r"(persistentContainerClassLocation));
#elif TARGET_CPU_X86
            void *pc = NULL;
            __asm("calll L0\n"
                  "L0: popl %0\n"
                  "leal _OBJC_CLASS_NSPersistentContainer-L0(%0), %1" : "=r"(pc), "=r"(persistentContainerClassLocation));
#else
#error Unsupported CPU
#endif
            
            if (persistentContainerClassLocation && !*persistentContainerClassLocation) {
                Class class = objc_allocateClassPair(INSPersistentContainer.class, "NSPersistentContainer", 0);
                if (class) {
                    objc_registerClassPair(class);
                    *persistentContainerClassLocation = class;
                }
            }
        }
    });
}

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
@implementation NSPersistentContainer @end
#endif
