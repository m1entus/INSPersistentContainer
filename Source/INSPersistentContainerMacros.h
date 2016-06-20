//
//  INSPersistentContainerMacros.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 20.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
    #ifndef NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
        #ifdef __IPHONE_10_0
            #define NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK 0
        #else
            #define NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK 1
        #endif
    #endif
#else
    #ifndef NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK
        #ifdef __MAC_10_12
            #define NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK 0
        #else
            #define NS_PERSISTENT_STORE_NOT_AVAILABLE_IN_SDK 1
        #endif
    #endif
#endif
