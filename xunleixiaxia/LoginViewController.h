//
//  LoginViewController.h
//  xunleixiaxia
//
//  Created by Kai Chen on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"

@interface LoginViewController : UIViewController<UIWebViewDelegate>  {    
	  //IBOutlet UITextField *usernameTextField;
      //IBOutlet UITextField *passwordTextField;
      IBOutlet UIWebView *webView;
      NSMutableArray* cookies;
}

@property (readwrite) BOOL loaded;

//@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
//@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

//- (IBAction)login:(id)sender;
- (IBAction)doneClick:(id)sender;
- (IBAction)refreshClick:(id)sender;

@end

