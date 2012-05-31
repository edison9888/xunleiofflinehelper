//
//  LoginViewController.m
//  xunleixiaxia
//
//  Created by Kai Chen on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "DownloadViewController.h"
#import "Reachability.h"
#import "CheckNetwork.h"

@interface LoginViewController ()

@end



@implementation LoginViewController
@synthesize loaded;

@synthesize webView;

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
	// Do any additional setup after loading the view.
    
     UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    webView.scalesPageToFit = YES;
    webView.autoresizesSubviews = YES;
    
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:@"http://lixian.vip.xunlei.com"];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
    self.loaded = NO;

}

-(void) done:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
     webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    //NSLog(@"start");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentURL = self.webView.request.URL.absoluteString;
    //NSLog(@"%@",currentURL);
    
    
    NSRange range = [currentURL rangeOfString:@"http://dynamic.cloud.vip.xunlei.com"];

    if(range.location != NSNotFound) 
    { 
        //Get Cookies
        cookies = [[NSMutableArray alloc] initWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage]
                                                         cookiesForURL:[NSURL URLWithString:currentURL]]];
        /*
        for (int j=0; j<[cookies count];j++) {
            NSLog(@"%@",[cookies objectAtIndex:j]);
        }
        */
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        RootViewController *rootViewController = app.rootViewController;
        
        DownloadViewController *downloadViewController = rootViewController.downloadViewController;
        
        [downloadViewController refresh];
        
        
        //[app hideLogin];
        [self dismissModalViewControllerAnimated:YES];
 
    } 
    
      self.loaded = YES;
    
}

/*
- (IBAction)login:(id)sender {
    

     
    NSString *js = @"\
    $(u).value=\"%@\";\
    $(p_show).value= \"%@\";\
    document.getElementById(\"button_submit4reg\").click();";
    
    NSString *dojs = [[NSString alloc] initWithFormat:js, usernameTextField.text,passwordTextField.text];
    
    NSLog(@"%@",usernameTextField.text);
    NSLog(@"%@",passwordTextField.text);
    NSLog(@"%@",dojs);
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString: dojs];
     
    
   
}
*/

- (IBAction)doneClick:(id)sender {
    [self dismissModalViewControllerAnimated:TRUE];
}

- (IBAction)refreshClick:(id)sender {
    
    if([CheckNetwork isExistenceNetwork]){
    
    NSURL *url = [NSURL URLWithString:@"http://lixian.vip.xunlei.com"];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
    //[webView reload];
    }
}
@end
