//
//  AboutViewController.h
//  xunleixiaxia
//
//  Created by Kai Chen on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface AboutViewController : UITableViewController<MFMailComposeViewControllerDelegate,UITableViewDelegate>{

}

@property (nonatomic, retain) NSMutableArray *contentsList;


- (void)mailDidPush;

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
@end
