//
//  DownloadViewController.m
//  DocSets
//
//  Created by Ole Zorn on 22.01.12.
//  Copyright (c) 2012 omz:software. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import <UIKit/UIKit.h>
#import "HTMLParser.h"
#import "LocalViewController.h"
#import "FolderViewController.h"
#import "JSON/SBJson.h"
#import "LoginViewController.h"
#import "CheckNetwork.h"


@interface DownloadViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation DownloadViewController

@synthesize masterPopoverController;
@synthesize loginViewController;
@synthesize folderViewController;

- (id)initWithFileList:(NSMutableArray*)downlodList Cookies:(NSMutableArray*)cookies Style:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		self.title = NSLocalizedString(@"我的离线空间", nil);
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(docSetsChanged:) name:DownloadManagerUpdatedsNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(availableDocSetsChanged:) name:DownloadManagerAvailablesChangedNotification object:nil];
    }
    
    //  if (_cookies != nil) {
    //      [_cookies release];
    //  }
    
    _cookies = [[NSMutableArray alloc] initWithArray:cookies];
    return self;
}

- (UIAlertView *) showWaitingAlert{
	UIAlertView *waittingAlert = [[UIAlertView alloc] initWithTitle: @"正在获取数据"
                                                            message: @"请稍候..."
                                                           delegate: nil
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: nil];
	
	
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
	//[waittingAlert addSubview:activityView];
	//[activityView startAnimating];
	
	[waittingAlert show];
	
	return waittingAlert;
    
}

- (void) dismissWaitingAlert:(UIAlertView**)waittingAlert
{
    
	if (*waittingAlert != nil) {
		[*waittingAlert dismissWithClickedButtonIndex:0 animated:YES];
        
		*waittingAlert =nil;
	}
}

-(void) refreshFolder{
    [folderViewController.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.rowHeight = 64.0;
    
    loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    folderViewController = [[FolderViewController alloc] initWithNibName:@"FolderViewController" bundle:nil];
    

    
    UIBarButtonItem *loginButton  = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];

    self.navigationItem.leftBarButtonItem = loginButton;
    
    //	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
   
    
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 133, 44)];
    
    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    
    /*
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [backButton setTitle:@"前一页" forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor blueColor]];
    [backButton setFrame:CGRectMake(0, 0, 64, 64)];
    [backButton addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchDown];

    */
    // create a standard "add" button
    //UIBarButtonItem* bi = [[UIBarButtonItem alloc]
    //                       initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(nextPage:)];
    
    
    
    //UIBarButtonItem *leftButton_  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(prevPage:)];
    //UIBarButtonItem *rightButton_  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_right.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(nextPage:)];
    
    
   //UIBarButtonItem *refreshButton_= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateAvailableFiles:)];
   
    UIBarButtonItem *refreshButton_= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_refresh.png"] style:UIBarButtonItemStylePlain target:self action:@selector(updateAvailableFiles:)];
    
   UIBarButtonItem* bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //[buttons addObject:bi];
    
    //UIBarButtonItem *leftButton_= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(prevPage:)];
    
    
    
    //UIBarButtonItem *rightButton_= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextPage:)];
    
    
    UIBarButtonItem *leftButton_  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_page_prev.png"] style:UIBarButtonItemStylePlain target:self action:@selector(prevPage:)];
    UIBarButtonItem *rightButton_  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_page_next.png"] style:UIBarButtonItemStylePlain target:self action:@selector(nextPage:)];
    
    
    [buttons addObject:refreshButton_];
    [buttons addObject:bi];
    [buttons addObject:leftButton_];
    bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [buttons addObject:bi];
    [buttons addObject:rightButton_];
    /*
    UIBarButtonItem* bi =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    
    
    bi.style = UIBarButtonItemStyleBordered;
    [buttons addObject:bi];
    
    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //[buttons addObject:bi];
    
    
    
    // create a standard "refresh" button
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    bi.style = UIBarButtonItemStyleBordered;
    //[buttons addObject:bi];
    
    */
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)login:(id)sender
{
    
	loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentModalViewController:loginViewController animated:YES];
    
    
   

}
- (void)nextPage:(id)sender
{
    
    if(![CheckNetwork isExistenceNetwork])
        return;
    
    if([nextPage isEqualToString:@""] || (nextPage == nil))
        return;
    
    UIAlertView * alterView = [self showWaitingAlert];
        
	//self.navigationItem.leftBarButtonItem.enabled = NO;
    //AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    //RootViewController *rootViewController = app.rootViewController;
    
    //LocalViewController * localViewController = rootViewController.detailViewController;
    
    //[localViewController.documentURLs];

    
    //UIWebView *webView = [app.loginViewController.webView retain];
    
   
    //Create a URL object.
    NSString *pageUrl = [[NSString alloc] initWithFormat:@"http://%@%@",homeUrl,nextPage];
    NSURL *url = [NSURL  URLWithString:pageUrl];
    
    
    NSMutableURLRequest* request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response;
    
    NSError *requestError = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&requestError];
    
    NSString* strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",strRet);
    
    NSError *error = nil;
    
    if (requestError != nil) {
        return ;
    }
    else {
        prevPage = curPage;
        curPage = nextPage;
    }
    
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:strRet error:&error];
    
    if (error) {
        //NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *inputNodes = [bodyNode findChildTags:@"div"];
    
    NSMutableString *downloadlinks = [[NSMutableString alloc] init];
    
    for (HTMLNode *inputNode in inputNodes) {
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"rw_list"]) {
            
            if([inputNode getAttributeNamed:@"taskid"] != nil){
                
                NSString *taskid = [inputNode getAttributeNamed:@"taskid"];
                NSString *durl = [[NSString alloc] initWithFormat:@"durl%@",taskid];
                NSString *dl_url = [[NSString alloc] initWithFormat:@"dl_url%@",taskid];
                NSString *dcid = [[NSString alloc] initWithFormat:@"dcid%@",taskid];

                
                
                //NSLog(@"%@", durl); //Answer to first question
                
                
                NSArray *_inputNodes = [inputNode findChildTags:@"input"];
                
                NSString *title = nil;
                NSString *download_link=nil;
                int i=0;
                for (HTMLNode *_inputNode in _inputNodes) {
                    
                    if ([[_inputNode getAttributeNamed:@"id"] isEqualToString:durl]) {
                        title = [[NSString alloc] initWithString:[_inputNode getAttributeNamed:@"title"]];
                        i++;
                    }
                    
                    if ([[_inputNode getAttributeNamed:@"id"] isEqualToString:dl_url]) {
                        download_link = [[NSString alloc] initWithString:[_inputNode getAttributeNamed:@"value"]];
                        i++;
                    }
                    
                    if(i==2)
                    {
                        [downloadlinks appendFormat:@"%@::%@::%@::%@|||",title,download_link,dcid,taskid];
                        
                        break;
                    }
                    
                    
                }
                
                
                
                
            }
     
            
        }
        
        
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"pginfo"]) {
            
            NSArray * pageNodes = [inputNode findChildTags:@"li"];
            
            
            for (HTMLNode *pageNode in pageNodes) {
                if ([[pageNode getAttributeNamed:@"class"] isEqualToString:@"pre"]) {
                    
                    NSArray *_pageNodes = [pageNode findChildTags:@"a"];
                    if([_pageNodes count] == 1){
                        
                        prevPage = [[NSString alloc] initWithString:[[_pageNodes objectAtIndex:0] getAttributeNamed:@"href"]];
                    }
                    
                    
                }
                if ([[pageNode getAttributeNamed:@"class"] isEqualToString:@"next"]) {
                    
                    NSArray *_pageNodes = [pageNode findChildTags:@"a"];
                    if([_pageNodes count] == 1){
                        
                        nextPage = [[NSString alloc] initWithString:[[_pageNodes objectAtIndex:0] getAttributeNamed:@"href"]];
                    }
                    
                    
                }
                
                
                
            }

            
        }
      
        
    }

    
   
    
    NSArray *firstSplit = [downloadlinks componentsSeparatedByString:@"|||"]; 
    
    if([firstSplit count] >0){
        
        
        DownloadManager *p = [DownloadManager sharedDownloadManager] ;
        
        if(p.availableDownloads != nil) {
            [p.availableDownloads removeAllObjects];
        }
        else
            p.availableDownloads = [NSMutableArray alloc];
        
        
        p.availableDownloads = [NSMutableArray arrayWithCapacity:[firstSplit count]-1];  
        
        for(NSString *item in firstSplit)
        {
            NSArray *secondSplit = [item componentsSeparatedByString:@"::"]; 
            
            if([secondSplit count] == 4){
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[secondSplit objectAtIndex:0],@"NAME",[secondSplit objectAtIndex:1],@"URL",[secondSplit objectAtIndex:2],@"DCID",[secondSplit objectAtIndex:3],@"TASKID",nil];
                ;

                //NSLog(@"string:%@",[dic objectForKey:@"NAME"]);
                
                [p.availableDownloads addObject:dic];
                //[dic release];
            }
            
        }
        
    }        
    [self.tableView reloadData];
    
//    [self dismissWaitingAlert:alterView];
    
    if (alterView != nil) {
		[alterView dismissWithClickedButtonIndex:0 animated:YES];
    }

}


- (void)prevPage:(id)sender
{
    if(![CheckNetwork isExistenceNetwork])
        return;
    
    
	//self.navigationItem.leftBarButtonItem.enabled = NO;
    
    
        if ([prevPage isEqualToString:@""] || (prevPage == nil)) {
        return;
    }
    
    
    UIAlertView * alterView = [self showWaitingAlert];

    
    //Create a URL object.
    NSString *pageUrl = [[NSString alloc] initWithFormat:@"http://%@%@",homeUrl,prevPage];
    NSURL *url = [NSURL  URLWithString:pageUrl];
    
    
    NSMutableURLRequest* request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response;
    
    NSError *requestError =nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&requestError];
    
    NSString* strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",strRet);
    
    NSError *error = nil;
    
    
    if (requestError != nil) {
        return ;
    }
    else {
        nextPage = curPage;
        curPage = prevPage;
    }

    
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:strRet error:&error];
    
    if (error) {
        //NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *inputNodes = [bodyNode findChildTags:@"div"];
    
    NSMutableString *downloadlinks = [[NSMutableString alloc] init];
    
    for (HTMLNode *inputNode in inputNodes) {
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"rw_list"]) {
            
            
            if([inputNode getAttributeNamed:@"taskid"] != nil){
                
                NSString *taskid = [inputNode getAttributeNamed:@"taskid"];
                NSString *durl = [[NSString alloc] initWithFormat:@"durl%@",taskid];
                NSString *dl_url = [[NSString alloc] initWithFormat:@"dl_url%@",taskid];
                NSString *dcid = [[NSString alloc] initWithFormat:@"dcid%@",taskid];
                
                
                
                //NSLog(@"%@", durl); //Answer to first question
                
                
                NSArray *_inputNodes = [inputNode findChildTags:@"input"];
                
                NSString *title = nil;
                NSString *download_link=nil;
                int i=0;
                for (HTMLNode *_inputNode in _inputNodes) {
                    
                    if ([[_inputNode getAttributeNamed:@"id"] isEqualToString:durl]) {
                        title = [[NSString alloc] initWithString:[_inputNode getAttributeNamed:@"title"]];
                        i++;
                    }
                    
                    if ([[_inputNode getAttributeNamed:@"id"] isEqualToString:dl_url]) {
                        download_link = [[NSString alloc] initWithString:[_inputNode getAttributeNamed:@"value"]];
                        i++;
                    }
                    
                    if(i==2)
                    {
                        [downloadlinks appendFormat:@"%@::%@::%@::%@|||",title,download_link,dcid,taskid];
                        
                        break;
                    }
                    
                    
                }
                
                
            }
            
            
        }
        
        
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"pginfo"]) {
            
            NSArray * pageNodes = [inputNode findChildTags:@"li"];
            
            
            for (HTMLNode *pageNode in pageNodes) {
                if ([[pageNode getAttributeNamed:@"class"] isEqualToString:@"pre"]) {
                    
                    NSArray *_pageNodes = [pageNode findChildTags:@"a"];
                    if([_pageNodes count] == 1){
                        
                        prevPage = [[NSString alloc] initWithString:[[_pageNodes objectAtIndex:0] getAttributeNamed:@"href"]];
                    }
                    
                    
                }
                if ([[pageNode getAttributeNamed:@"class"] isEqualToString:@"next"]) {
                    
                    NSArray *_pageNodes = [pageNode findChildTags:@"a"];
                    if([_pageNodes count] == 1){
                        
                        nextPage = [[NSString alloc] initWithString:[[_pageNodes objectAtIndex:0] getAttributeNamed:@"href"]];
                    }
                    
                    
                }
                
                
                
            }
            
            
        }
        
        
    }
    
    
    
    
    
    NSArray *firstSplit = [downloadlinks componentsSeparatedByString:@"|||"]; 
    
    if([firstSplit count] >0){
        
        
        DownloadManager *p = [DownloadManager sharedDownloadManager] ;
        
        if(p.availableDownloads != nil) {
            [p.availableDownloads removeAllObjects];
        }
        else
            p.availableDownloads = [NSMutableArray alloc];
        
        
        p.availableDownloads = [NSMutableArray arrayWithCapacity:[firstSplit count]-1];  
        
        for(NSString *item in firstSplit)
        {
            NSArray *secondSplit = [item componentsSeparatedByString:@"::"]; 
            if([secondSplit count] == 4){
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[secondSplit objectAtIndex:0],@"NAME",[secondSplit objectAtIndex:1],@"URL",[secondSplit objectAtIndex:2],@"DCID",[secondSplit objectAtIndex:3],@"TASKID",nil];
                ;                
                //NSLog(@"string:%@",[dic objectForKey:@"NAME"]);
                
                [p.availableDownloads addObject:dic];
                //[dic release];
            }
            
        }
        
    }        
    [self.tableView reloadData];
    
    if (alterView != nil) {
		[alterView dismissWithClickedButtonIndex:0 animated:YES];
    }

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		return YES;
	}
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)docSetsChanged:(NSNotification *)notification
{
	[self.tableView reloadData];
}

- (void)availableDocSetsChanged:(NSNotification *)notification
{
	self.navigationItem.leftBarButtonItem.enabled = YES;
	[self.tableView reloadData];
}

-(void) refresh{
    
    
    if (![CheckNetwork isExistenceNetwork]) {
        return;   
    }
    
    //AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    
    //UIWebView *webView = app.loginViewController.webView ;
    
    UIWebView *webView = loginViewController.webView ;
    
    
    
    NSString *js = @"\
    function f(){\
    try\
    {\
    var downloadlinks=\"\";\
    var rw_lists = document.body.getElementsByClassName('rw_list');\
    for (var i = 0; i<rw_lists.length; i++) {\
    var taskid = rw_lists[i].getAttribute('taskid');\
    var durl='durl'+taskid;\
    var title = document.getElementById(durl).getAttribute('title');\
    var dl_url = 'dl_url'+taskid;\
    var dcid = 'dcid'+taskid;\
    var download_link = document.getElementById(dl_url).getAttribute('value');\
    var dcid_link = document.getElementById(dcid).getAttribute('value');\
    downloadlinks += title+\"::\"+download_link+\"::\"+dcid_link+\"::\"+taskid+\"|||\";\
    }\
    return downloadlinks;\
    }\
    catch(err)\
    {\
    return \"\";\
    }\
    }\
    f();\
    ";
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString: js];
    
    //if(html.length>1)
    //    NSLog(@"%@",html);
    
    NSArray *firstSplit = [html componentsSeparatedByString:@"|||"]; 
    
    if([firstSplit count] >0){
        
        
        DownloadManager *p = [DownloadManager sharedDownloadManager] ;
        
        if(p.availableDownloads != nil) {
            [p.availableDownloads removeAllObjects];
        }
        else
            p.availableDownloads = [NSMutableArray alloc];
        
        
        
        
        p.availableDownloads = [NSMutableArray arrayWithCapacity:[firstSplit count]-1];  
        
        for(NSString *item in firstSplit)
        {
            NSArray *secondSplit = [item componentsSeparatedByString:@"::"]; 
            
            if([secondSplit count] == 4){
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[secondSplit objectAtIndex:0],@"NAME",[secondSplit objectAtIndex:1],@"URL",[secondSplit objectAtIndex:2],@"DCID",[secondSplit objectAtIndex:3],@"TASKID",nil];
                ;               
                //NSLog(@"string:%@",[dic objectForKey:@"NAME"]);
                
                [p.availableDownloads addObject:dic];
                //[dic release];
            }
            
        }
        
        
        [self.tableView reloadData];
        
        
        NSString *js_next =@"$(\".next a\").attr(\"href\")";
        
        
        nextPage = [[NSString alloc] initWithString:[webView stringByEvaluatingJavaScriptFromString: js_next]];
        
        
        NSString *js_prev =@"$(\".pre a\").attr(\"href\")";
        
        prevPage = [[NSString alloc] initWithString:[webView stringByEvaluatingJavaScriptFromString: js_prev]];
        
        NSString *js_home =@"function f(){return window.location.hostname;}f();";
        
        
        homeUrl = [[NSString alloc] initWithString:[webView stringByEvaluatingJavaScriptFromString: js_home]];
        
        
        curPage = [[NSString alloc] initWithString: [webView.request.URL.absoluteString substringFromIndex:[webView.request.URL.absoluteString rangeOfString:homeUrl].location+homeUrl.length]];
        
        int nStart = [curPage rangeOfString:@"userid="].location+7;
        int nEnd = [curPage rangeOfString:@"&"].location; //options:NSAnchoredSearch range:NSMakeRange(nStart,curPage.length-nStart+1)].location;
        
        userid =  [[NSString alloc] initWithString: [curPage substringWithRange:NSMakeRange(nStart, nEnd-nStart)]];
        
        //NSLog(@"%@",prevPage);
        
        //NSLog(@"%@",curPage);
    
        
        //NSLog(@"%@",nextPage);
        
        //NSLog(@"%@",homeUrl);
    }
    
}

- (void)updateAvailableFiles:(id)sender
{
	//self.navigationItem.leftBarButtonItem.enabled = NO;
    [self refresh];
}

- (void)done:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = [[[DownloadManager sharedDownloadManager] availableDownloads] count];
    
	return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    DownloadCell *cell = (DownloadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[DownloadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    }
	
    NSDictionary *downloadInfo = [[[DownloadManager sharedDownloadManager] availableDownloads] objectAtIndex:indexPath.row];
    
    cell.downloadInfo  = downloadInfo;
    cell.cookies = _cookies;
    
     
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return [NSString stringWithFormat:NSLocalizedString(@"Last updated: %@", nil), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle]];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *downloadInfo = [[[DownloadManager sharedDownloadManager] availableDownloads] objectAtIndex:indexPath.row];
    
    if([[downloadInfo objectForKey:@"URL"] isEqualToString:@""]){
        
        NSString *pageUrl = [[NSString alloc] initWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/fill_bt_list?callback=fill_bt_list&tid=%@&infoid=%@&g_net=1&p=1&uid=%@",[downloadInfo objectForKey:@"TASKID"],[downloadInfo objectForKey:@"DCID"],userid];
        NSURL *url = [NSURL  URLWithString:pageUrl];
        
        //NSLog(@"%@",pageUrl);

        
        NSMutableURLRequest* request = [NSMutableURLRequest new];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        NSURLResponse* response;
        
        NSError *requestError = nil;
        
        NSData* data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response error:&requestError];
        
        NSString* strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",strRet);
        
                
        //NSError *error = nil;
        
        if (requestError != nil) {
            return ;
        }
        else {
            
            NSString *jsonString = [[NSString alloc] initWithString:[strRet substringWithRange:NSMakeRange(13, strRet.length-14)]];
            //NSLog(@"%@",jsonString);
            
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *json = [parser objectWithString:jsonString error:nil];
            
            NSDictionary *result = [json objectForKey:@"Result"];
            self.folderViewController.availableDownloads = nil;
            id item = [result valueForKeyPath:@"Record"];
            if ([item isKindOfClass:[NSArray class]]) {
                self.folderViewController.availableDownloads  = [NSMutableArray arrayWithCapacity:[item count]]; 
                NSEnumerator *enumerator = [item objectEnumerator];
                NSDictionary* item;
                while (item = (NSDictionary*)[enumerator nextObject]) {
                    
                    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[item objectForKey:@"title"],@"NAME",[item objectForKey:@"downurl"],@"URL",[item objectForKey:@"cid"],@"DCID",[item objectForKey:@"taskid"],@"TASKID",nil];
                    ; 
                    [self.folderViewController.availableDownloads addObject:dic];
                }
                
            }
            else if ([item isKindOfClass:[NSDictionary class]]) {
                
                self.folderViewController.availableDownloads  = [NSMutableArray arrayWithCapacity:1]; 

                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[item objectForKey:@"title"],@"NAME",[item objectForKey:@"downurl"],@"URL",[item objectForKey:@"cid"],@"DCID",[item objectForKey:@"taskid"],@"TASKID",nil];
                ; 
                [self.folderViewController.availableDownloads addObject:dic];
                
            }

            
            [self.navigationController pushViewController:self.folderViewController animated:YES];   
            [self refreshFolder];
        }

    }
    else {
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
            
            [[DownloadManager sharedDownloadManager] downloadAtURL:docSetURL Filename:docSetName Cookies:_cookies];
        }

        
    }
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    // [super dealloc];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"迅雷下下", @"迅雷下下");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end



@implementation DownloadCell

@synthesize downloadInfo=_downloadInfo, download=_download, downloadInfoView=_downloadInfoView, progressView=_progressView, cancelDownloadButton=_cancelDownloadButton ;
@synthesize cookies;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    _cancelDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    /*
    statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [statusButton setTitle:@"下载" forState:UIControlStateNormal]; 
    [statusButton setFrame:CGRectMake(20, 17, 58, 36)];
    */
    
    
    //[self.contentView addSubview:statusButton];
    
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStarted:) name:DownloadManagerStartedDownloadNotification object:nil];
		[self setupDownloadInfoView];
		
	}
	return self;
}

- (void)setupDownloadInfoView
{
    CGFloat progressViewWidth = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 120 : 70;
    CGFloat cancelButtonWidth = 30;
    CGFloat cancelButtonHeight = 29;
    CGFloat margin = 10;
    
    
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	
    _cancelDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //_cancelDownloadButton = [[UIButton alloc] init];
    _cancelDownloadButton.frame = CGRectMake(progressViewWidth + margin, 0, cancelButtonWidth, cancelButtonHeight);
    
    [_cancelDownloadButton setImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
    [_cancelDownloadButton setImage:[UIImage imageNamed:@"Cancel-Pressed.png"] forState:UIControlStateHighlighted];
    [_cancelDownloadButton setImage:[UIImage imageNamed:@"Cancel-Pressed.png"] forState:UIControlStateSelected];
    [_cancelDownloadButton addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (!self.download) {
		return;
	}
	DownloadStatus status = self.download.status;
	if (status == DownloadStatusWaiting || status == DownloadStatusDownloading || status == DownloadStatusExtracting) {	
		self.progressView.frame = CGRectMake(60, CGRectGetMidY(self.contentView.bounds) - self.progressView.bounds.size.height * 0.5, CGRectGetWidth(self.contentView.bounds) - 70, self.progressView.frame.size.height);
		CGRect textLabelFrame = self.textLabel.frame;
		self.textLabel.frame = CGRectMake(textLabelFrame.origin.x, 3, textLabelFrame.size.width, textLabelFrame.size.height);
		CGRect detailLabelFrame = self.detailTextLabel.frame;
		self.detailTextLabel.frame = CGRectMake(detailLabelFrame.origin.x, self.contentView.bounds.size.height - CGRectGetHeight(detailLabelFrame) - 3, detailLabelFrame.size.width, detailLabelFrame.size.height);
	}
}

- (void)downloadStarted:(NSNotification *)notification
{
	if (!self.download) {
        self.download.filename =[NSString stringWithFormat:[self.downloadInfo objectForKey:@"NAME"]]; 
		self.download = [[DownloadManager sharedDownloadManager] downloadForURL:[self.downloadInfo objectForKey:@"URL"]];
	}
}

- (void)downloadFinished:(NSNotification *)notification
{
	if (notification.object == self.download) {
		self.download = nil;
	}
}

-(void)setCookies:(NSMutableArray *)mycookies{
    
    cookies = [[NSMutableArray alloc] initWithArray:mycookies];
}

- (void)setDownloadInfo:(NSDictionary *)downloadInfo
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    RootViewController *rootViewController = app.rootViewController;
    
    LocalViewController * localViewController = rootViewController.detailViewController;
    
    
    BOOL bDownload = NO;
    for (NSURL *fileURL in localViewController.documentURLs) {
        
        if (([[[fileURL path] lastPathComponent] isEqualToString:[downloadInfo objectForKey:@"NAME"]]) && (![[downloadInfo objectForKey:@"URL"] isEqualToString:@""]))
        {
            //NSLog(@"-----%@------",[[fileURL path] lastPathComponent]);
            bDownload = YES;
            break;
        }
        
    }
    
    if (bDownload) {
        self.userInteractionEnabled = NO;
    }
    else {
        self.userInteractionEnabled = YES;
    }
    
	_downloadInfo = downloadInfo;
	NSString *URL = [_downloadInfo objectForKey:@"URL"];
	NSString *name = [_downloadInfo objectForKey:@"NAME"];
    NSArray *fmtList = [[NSArray alloc] initWithObjects:@"mkv",@"rmvb",@"mov",@"mp4",@"avi",@"wmv", nil];
	BOOL downloaded = [[[DownloadManager sharedDownloadManager] downloadedNames] containsObject:name];
	if (downloaded) {
		self.textLabel.textColor = [UIColor grayColor];
	} else {
		self.textLabel.textColor = [UIColor blackColor];
	}
    
	self.download = [[DownloadManager sharedDownloadManager] downloadForURL:URL];
    
	
	self.textLabel.text = [_downloadInfo objectForKey:@"NAME"];
    
    if([URL isEqualToString:@""]){
	
        self.imageView.image = [UIImage imageNamed:@"icon_file_folder.png"];
    }
    else {
        NSString *filename = [_downloadInfo objectForKey:@"NAME"];
        int npos = [filename rangeOfString:@"." options:NSBackwardsSearch].location;
        
        if (npos>0){
            BOOL bFind = NO;
            NSString *tmp = [filename substringWithRange:NSMakeRange(npos+1,filename.length-npos-1)];
            for (NSString *ext in fmtList) {
                if ([ext isEqualToString:tmp]) {
                    bFind = YES;
                    break;
                    
                }
            }
            if (bFind) {
    
                if (bDownload) {
                    self.imageView.image = [UIImage imageNamed:@"icon_downloaded.png"];
                }
                else{
                    self.imageView.image = [UIImage imageNamed:@"video.png"];
                }
            }
            else {
                if (bDownload) {
                    self.imageView.image = [UIImage imageNamed:@"icon_downloaded.png"];
                }
                else{
                self.imageView.image = [UIImage imageNamed:@"icon_file_others.png"];
                }
            }
        }
        else
        {
            if (bDownload) {
                self.imageView.image = [UIImage imageNamed:@"icon_downloaded.png"];
            }
            else{
            self.imageView.image = [UIImage imageNamed:@"icon_file_others.png"];
            }
            
        }
    }

}

- (void)setDownload:(XunleiDownload *)download
{
	if (_download) {
		[_download removeObserver:self forKeyPath:@"progress"];
		[_download removeObserver:self forKeyPath:@"status"];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadFinishedNotification object:_download];
	}
	
	_download = download;
	[_download addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
	[_download addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:DownloadFinishedNotification object:_download];
	
	if (_download) {
		self.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
		self.progressView.progress = self.download.progress;
		self.accessoryView = self.cancelDownloadButton;
		[self.contentView addSubview:self.progressView];
	} else {
		self.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
		self.accessoryView = nil;
		[self.progressView removeFromSuperview];
	}
	[self updateStatusLabel];
}

- (void)updateStatusLabel
{
	if (!self.download) {
		self.detailTextLabel.text = nil;
	} else if (self.download.status == DownloadStatusWaiting) {
		self.detailTextLabel.text = NSLocalizedString(@"Waiting...", nil);
	} else if (self.download.status == DownloadStatusDownloading) {
		NSInteger downloadSize = self.download.downloadSize;
		NSUInteger bytesDownloaded = self.download.bytesDownloaded;
		if (downloadSize != 0) {
			NSString *totalMegabytes = [NSString stringWithFormat:@"%.01f", (float)(downloadSize / pow(2, 20))];
			NSString *downloadedMegabytes = [NSString stringWithFormat:@"%.01f", (float)(bytesDownloaded / pow(2, 20))];
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
				self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Downloading... (%@ MB / %@ MB)", nil), downloadedMegabytes, totalMegabytes];
			} else {
				self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ MB / %@ MB", nil), downloadedMegabytes, totalMegabytes];
			}
		} else {
			self.detailTextLabel.text = NSLocalizedString(@"Downloading...", nil);
		}
	} else if (self.download.status == DownloadStatusExtracting) {
		int extractedPercentage = (int)(self.download.progress * 100);
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Extracting Download... (%i%%)", nil), extractedPercentage];
		} else {
			self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Extracting (%i%%)", nil), extractedPercentage];
		}
	} else {
		self.detailTextLabel.text = nil;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"progress"]) {
		self.progressView.progress = self.download.progress;
		[self updateStatusLabel];
	} else if ([keyPath isEqualToString:@"status"]) {
		[self updateStatusLabel];
	}
}

- (void)cancelDownload:(id)sender
{
    [[DownloadManager sharedDownloadManager] stopDownload:self.download];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_download removeObserver:self forKeyPath:@"progress"];
	[_download removeObserver:self forKeyPath:@"status"];
}



@end