//
//  FolderViewController.h
//  xunleixiaxia
//
//  Created by Kai Chen on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *availableDownloads;
-(void)reload;

@end
