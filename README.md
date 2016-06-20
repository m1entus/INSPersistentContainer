[![](http://inspace.io/github-cover.jpg)](http://inspace.io)

# Introduction

**INSPersistentContainer** was written by **[Michał Zaborowski](https://github.com/m1entus)** for **[inspace.io](http://inspace.io)**

# INSPersistentContainer
Open Source, 100% API compatible replacement of NSPersistentContainer for iOS8+/macOS 10.10+

You want to use NSPersistentContainer, but need to support older versions of iOS?
I created INSPersistentContainer which is drop-in replacement for NSPersistentContainer.
I reverse engeneered NSPersistentContainer which you can find in iOS10b1.
There is still not so much information about it in [Apple Documentation](https://developer.apple.com/reference/coredata/nspersistentcontainer), but i found note from Apple which is explining this class: "An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides convenience methods and properties for common patterns."

INSPersistentContainer also contains extension for new method in NSManagedObjectContext like:
```objective-c
/* Whether the context automatically merges changes saved to its parent. Setting this property to YES when the context is pinned to a non-current query generation is not supported.
*/
@property (nonatomic) BOOL automaticallyMergesChangesFromParent;
```

Additionally i have added method for automaticallyObtainPermanentIDsForInsertedObjects which is common to use.

```objective-c
/**
 *  If the main context is not the parent of the background context, retrieving the object by ID will fail. The temporary ID only exists in the main context and not in the store. The background context therefore has no access to that ID. In that case, you will need to obtain a permanent object ID for the objects in the main context using the API obtainPermanentIDsForObjects(:error:) before you can retrieve them in the background context.
 */
@property (nonatomic) BOOL ins_automaticallyObtainPermanentIDsForInsertedObjects;
```

And last thing which i added is custom data stack which is using automaticallyMergesChangesFromParent and automaticallyObtainPermanentIDsForInsertedObjects which works very well for background batch updates.

# Simple Usage (Same as NSPersistentContainer)

```objective-c
- (INSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[INSDataStackContainer alloc] initWithName:@"INSPersistentContainer"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(INSPersistentStoreDescription *storeDescription, NSError *error) {

                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}
```

```swift
lazy var persistentContainer: INSPersistentContainer = {
    let stack = INSDataStackContainer(name: "INSPersistentContainer")
    stack.loadPersistentStoresWithCompletionHandler({ desc, error in
        if error != nil {
            print(error)
            abort()
        }
    })
    return stack
}()
```
# Background Saving

```objective-c
[self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * context) {
    Entity *desc = (Entity *)[NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:context];
    desc.name = @"test";
    [context save:nil];
}];
```

```swift
persistentContainer.performBackgroundTask { context in
    let obj = NSEntityDescription.insertNewObjectForEntityForName("Entity", inManagedObjectContext: context) as! Entity
    obj.name = "test"
    _ = try? context.save()
}
```

## CocoaPods

Add the following to your `Podfile` and run `$ pod install`.

``` ruby
pod 'INSPersistentContainer'
```

If you don't have CocoaPods installed, you can learn how to do so [here](http://cocoapods.org).

## Contact

[inspace.io](http://inspace.io)

[Twitter](https://twitter.com/inspace_io)

# License

INSPersistentContainer is available under the MIT license. See the LICENSE file for more info.
