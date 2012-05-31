//
//  MasterViewController.m
//  xunleixiaxia
//
//  Created by Kai Chen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "LocalViewController.h"

#import "DownloadViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AboutViewController.h"

@interface RootViewController () {
    NSMutableArray *_objects;
}
@end

@implementation RootViewController

@synthesize detailViewController = _detailViewController;


@synthesize downloadViewController;

@synthesize popoverController;
@synthesize splitViewController; 
@synthesize rootPopoverButtonItem;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"迅雷下下", @"迅雷下下");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}
							
- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(insertNewObject:)];
        
    
    UIBarButtonItem *addButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(insertNewObject:)];
    
    self.navigationItem.rightBarButtonItem = addButton;

    
    
    if (!_objects) {
        _objects = [[NSMutableArray alloc] initWithObjects:@"我的离线空间",@"本地下载",nil];
    }
    
     self.downloadViewController = [[DownloadViewController alloc] initWithFileList:nil Cookies:nil Style:UITableViewStylePlain];}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)insertNewObject:(id)sender
{
    AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutView];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navController animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }


    NSDate *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
    // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = @"迅雷下下";
    self.popoverController = pc;
    self.rootPopoverButtonItem = barButtonItem;
    UIViewController <SubstitutableDetailViewController> *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
    [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Nil out references to the popover controller and the popover button, and tell the detail view controller to hide the button.
    UIViewController <SubstitutableDetailViewController> *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
    [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
    self.popoverController = nil;
    self.rootPopoverButtonItem = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    UIViewController *detailViewController = nil;
    
     
    if (row == 0) {
       
        detailViewController = self.downloadViewController;
        
    }
    
    if (row == 1) {
        
        detailViewController = self.detailViewController;
    }
    
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    // Update the split view controller's view controllers array.
    
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController] ;
    
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, detailNavigationController, nil];
    
    
    app.splitViewController.viewControllers = viewControllers;
    
    
    // Dismiss the popover if it's present.
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }

}

@end
