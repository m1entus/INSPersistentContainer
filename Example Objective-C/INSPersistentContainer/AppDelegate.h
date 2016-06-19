//
//  AppDelegate.h
//  INSPersistentContainer
//
//  Created by Michal Zaborowski on 15.06.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "INSPersistentContainer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) UIWindow *window;



- (void)saveContext;


@end

