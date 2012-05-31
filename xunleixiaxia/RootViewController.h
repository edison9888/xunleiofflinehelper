//
//  MasterViewController.h
//  xunleixiaxia
//
//  Created by Kai Chen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalViewController;
@class DownloadViewController;

@protocol SubstitutableDetailViewController
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end



@interface RootViewController : UITableViewController<UISplitViewControllerDelegate> {
	
	
}

@property (nonatomic,retain) DownloadViewController *downloadViewController;
@property (nonatomic,retain) LocalViewController *detailViewController;
@property (nonatomic,retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic,retain) UIPopoverController *popoverController;
@property (nonatomic,retain) UIBarButtonItem *rootPopoverButtonItem;
@end
