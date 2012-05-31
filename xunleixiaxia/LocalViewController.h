//
//  DetailViewController.h
//  xunleixiaxia
//
//  Created by Kai Chen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectoryWatcher.h"
#import <QuickLook/QuickLook.h>


@interface LocalViewController : UITableViewController <UISplitViewControllerDelegate,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
DirectoryWatcherDelegate,
UIDocumentInteractionControllerDelegate,
UIPopoverControllerDelegate>

{
    DirectoryWatcher *docWatcher;
    NSMutableArray *documentURLs;
    UIDocumentInteractionController *docInteractionController;
    UIAlertView *_waittingAlert;
    UIBarButtonItem* editButton;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) UIDocumentInteractionController *docInteractionController;
@property (nonatomic, retain) DirectoryWatcher *docWatcher;
@property (nonatomic, retain) NSMutableArray *documentURLs;

@end
