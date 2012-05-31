//
//  AppDelegate.h
//  xunleixiaxia
//
//  Created by Kai Chen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;
@class RootViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
//@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;

- (void)hideLogin;
@end
