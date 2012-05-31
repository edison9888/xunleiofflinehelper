//
//  DownloadViewController.h
//  DocSets
//
//  Created by Ole Zorn on 22.01.12.
//  Copyright (c) 2012 omz:software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;
@class FolderViewController;

@interface DownloadViewController : UITableViewController<UISplitViewControllerDelegate,UIPopoverControllerDelegate> {
	NSMutableArray * _cookies;
    NSString *prevPage;
    NSString *curPage;
    NSString *nextPage;
    NSString *homeUrl;
    NSString *userid;
}
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) FolderViewController *folderViewController;

-(void) refresh;

-(void) refreshFolder;

- (id)initWithFileList:(NSMutableArray*)downlodList Cookies:(NSMutableArray*)cookies Style:(UITableViewStyle)style;
    
@end


@class XunleiDownload;

@interface DownloadCell : UITableViewCell {
	NSDictionary *_downloadInfo;
	XunleiDownload *_download;
    UIView *_downloadInfoView;
	UIProgressView *_progressView;
    UIButton *_cancelDownloadButton;
    NSMutableArray *cookies;
    UIButton *statusButton;
    
}

@property (nonatomic, strong) NSDictionary *downloadInfo;
@property (nonatomic, strong) NSMutableArray *cookies;


@property (nonatomic, strong) XunleiDownload *download;
@property (nonatomic, strong) UIView *downloadInfoView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *cancelDownloadButton;


- (void)setupDownloadInfoView;
- (void)updateStatusLabel;
- (void)cancelDownload:(id)sender;

@end