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

#if NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
@implementation NSPersistentStoreDescription @end
#endif
