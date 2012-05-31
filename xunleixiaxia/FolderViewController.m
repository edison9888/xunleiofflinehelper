//
//  FolderViewController.m
//  xunleixiaxia
//
//  Created by Kai Chen on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FolderViewController.h"
#import "DownloadManager.h"
#import "DownloadViewController.h"
#import "CheckNetwork.h"

@interface FolderViewController ()

@end

@implementation FolderViewController

@synthesize availableDownloads;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
            }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.rowHeight = 64.0;
    
}

-(void)reload{
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = [self.availableDownloads count];
    
	return n;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *downloadInfo = [self.availableDownloads objectAtIndex:indexPath.row];
    
    NSString *name = [downloadInfo objectForKey:@"NAME"];
    BOOL downloaded = [[[DownloadManager sharedDownloadManager] downloadedNames] containsObject:name];
    if (downloaded) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"已经下载", nil) 
                                    message:NSLocalizedString(@"已经下载此文件。", nil) 
                                   delegate:nil 
                          cancelButtonTitle:NSLocalizedString(@"确定", nil) 
                          otherButtonTitles:nil] show];
    } else {
        NSString *docSetURL = [downloadInfo objectForKey:@"URL"];
        NSString *docSetName = [downloadInfo objectForKey:@"NAME"];
        
        if(![CheckNetwork isExistenceNetwork])
            return;
        
        [[DownloadManager sharedDownloadManager] downloadAtURL:docSetURL Filename:docSetName Cookies:nil];
    }
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    DownloadCell *cell = (DownloadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[DownloadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    }
	
    NSDictionary *downloadInfo = [self.availableDownloads objectAtIndex:indexPath.row];
    
    cell.downloadInfo  = downloadInfo;
    //cell.cookies = _cookies;
    
    return cell;
}
@end
