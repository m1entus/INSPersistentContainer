//
//  INSPersistentContainerMacros.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 20.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <TargetConditionals.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
#define NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK 1
#else
#define NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK 0
#endif
