//
//  INSPersistentStoreDescription.m
//  INSPersistentStoreDescription
//
//  Created by Michal Zaborowski on 15.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSPersistentStoreDescription.h"
#import <objc/runtime.h>

@interface INSPersistentStoreDescription ()
@property (nonatomic, copy) NSMutableDictionary<NSString *, NSObject *> *options;
@end

@implementation INSPersistentStoreDescription
@synthesize URL = _url;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (type: %@, url: %@)", [super description], self.type, self.URL];
}

- (NSDictionary<NSString *, NSObject *> *)options {
    return [self->_options copy];
}

- (BOOL)shouldAddStoreAsynchronously {
    NSNumber *option = (NSNumber *)[self.options objectForKey:@"NSAddStoreAsynchronouslyOption"];
    return [option boolValue];
}

- (void)setShouldAddStoreAsynchronously:(BOOL)shouldAddStoreAsynchronously {
    [self setOption:@(shouldAddStoreAsynchronously) forKey:@"NSAddStoreAsynchronouslyOption"];
}

- (BOOL)shouldMigrateStoreAutomatically {
    NSNumber *option = (NSNumber *)[self.options objectForKey:NSMigratePersistentStoresAutomaticallyOption];
    return [option boolValue];
}

- (void)setShouldMigrateStoreAutomatically:(BOOL)shouldMigrateStoreAutomatically {
    [self setOption:@(shouldMigrateStoreAutomatically) forKey:NSMigratePersistentStoresAutomaticallyOption];
}

- (BOOL)shouldInferMappingModelAutomatically {
    NSNumber *option = (NSNumber *)[self.options objectForKey:NSInferMappingModelAutomaticallyOption];
    return [option boolValue];
}

- (void)setShouldInferMappingModelAutomatically:(BOOL)shouldInferMappingModelAutomatically {
    [self setOption:@(shouldInferMappingModelAutomatically) forKey:NSInferMappingModelAutomaticallyOption];
}

- (NSDictionary<NSString *, NSObject *> *)sqlitePragmas {
    return (NSDictionary<NSString *, NSObject *> *)[self.options objectForKey:NSSQLitePragmasOption] ?: [NSDictionary dictionary];
}

- (BOOL)isReadOnly {
    NSNumber *option = (NSNumber *)[self.options objectForKey:NSReadOnlyPersistentStoreOption];
    return [option boolValue];
}

- (void)setReadOnly:(BOOL)readOnly {
    [self setOption:@(readOnly) forKey:NSReadOnlyPersistentStoreOption];
}

- (NSTimeInterval)timeout {
    NSNumber *option = (NSNumber *)[self.options objectForKey:NSPersistentStoreTimeoutOption];
    return [option doubleValue];
}

- (void)setTimeout:(NSTimeInterval)timeout {
    [self setOption:[NSNumber numberWithDouble:timeout] forKey:NSPersistentStoreTimeoutOption];
}

+ (instancetype)persistentStoreDescriptionWithURL:(NSURL *)URL {
    return [[self alloc] initWithURL:URL];
}

- (instancetype)init {
    return [self initWithURL:[NSURL fileURLWithPath:@"/dev/null"]];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self->_url = [url copy];
        self->_type = @"SQLite";
        self->_options = [@{} mutableCopy];
        self.shouldInferMappingModelAutomatically = YES;
        self.shouldMigrateStoreAutomatically = YES;
    }
    return self;
}

- (void)setValue:(nullable NSObject *)value forPragmaNamed:(NSString *)name {
    NSMutableDictionary<NSString *, NSObject *> *pragmas = [self.sqlitePragmas mutableCopy];
    if (value) {
        [pragmas setObject:value forKey:name];
    } else {
        [pragmas removeObjectForKey:name];
    }
    [self setOption:[pragmas copy] forKey:NSSQLitePragmasOption];
}

- (void)setOption:(NSObject *)option forKey:(NSString *)key {
    NSMutableDictionary<NSString *, NSObject *> *options = self->_options;
    if (option) {
        [options setObject:option forKey:key];
    } else {
        [options removeObjectForKey:key];
    }
}

- (NSUInteger)hash {
    NSURL *URL = self.URL;
    if ([URL isFileURL]) {
        return [URL hash];
    }
    char *result = realpath([[URL path] UTF8String], 0x0);
    if (result) {
        return [[NSURL fileURLWithPath:[NSString stringWithUTF8String:result]] hash];
    }

    return [URL hash];
}

- (id)copyWithZone:(NSZone *)zone {
    INSPersistentStoreDescription *copy = [[INSPersistentStoreDescription alloc] initWithURL:self->_url];
    copy.configuration = [self->_configuration copy];
    copy.type = [self->_type copy];
    copy.options = [self->_options mutableCopy];
    return copy;
}

@end

#pragma mark - Runtime Injection

// ----------------------------------------------------
// Runtime injection start.
// Assemble codes below are based on:
// https://github.com/0xced/NSUUID/blob/master/NSUUID.m
// ----------------------------------------------------
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

__asm(
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_NSPersistentStoreDescription:\n"
      ".quad           _OBJC_CLASS_$_NSPersistentStoreDescription\n"
#else
      ".align          2\n"
      "_OBJC_CLASS_UIStackView:\n"
      ".long           _OBJC_CLASS_$_NSPersistentStoreDescription\n"
#endif
      ".weak_reference _OBJC_CLASS_$_NSPersistentStoreDescription\n"
      );

// Constructors are called after all classes have been loaded.
__attribute__((constructor)) static void INSPersistentStoreDescriptionPatchEntry(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            
            // >= iOS10.
            if (objc_getClass("NSPersistentStoreDescription")) {
                return;
            }
            
            Class *persistentContainerDescriptionClassLocation = NULL;
            
#if TARGET_CPU_ARM
            __asm("movw %0, :lower16:(_OBJC_CLASS_NSPersistentStoreDescription-(LPC0+4))\n"
                  "movt %0, :upper16:(_OBJC_CLASS_NSPersistentStoreDescription-(LPC0+4))\n"
                  "LPC0: add %0, pc" : "=r"(persistentContainerDescriptionClassLocation));
#elif TARGET_CPU_ARM64
            __asm("adrp %0, L_OBJC_CLASS_NSPersistentStoreDescription@PAGE\n"
                  "add  %0, %0, L_OBJC_CLASS_NSPersistentStoreDescription@PAGEOFF" : "=r"(persistentContainerDescriptionClassLocation));
#elif TARGET_CPU_X86_64
            __asm("leaq L_OBJC_CLASS_NSPersistentStoreDescription(%%rip), %0" : "=r"(persistentContainerDescriptionClassLocation));
#elif TARGET_CPU_X86
            void *pc = NULL;
            __asm("calll L0\n"
                  "L0: popl %0\n"
                  "leal _OBJC_CLASS_NSPersistentStoreDescription-L0(%0), %1" : "=r"(pc), "=r"(persistentContainerDescriptionClassLocation));
#else
#error Unsupported CPU
#endif
            
            if (persistentContainerDescriptionClassLocation && !*persistentContainerDescriptionClassLocation) {
                Class class = objc_allocateClassPair(INSPersistentStoreDescription.class, "NSPersistentStoreDescription", 0);
                if (class) {
                    objc_registerClassPair(class);
                    *persistentContainerDescriptionClassLocation = class;
                }
            }
        }
    });
}

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
@implementation NSPersistentStoreDescription @end
#endif
