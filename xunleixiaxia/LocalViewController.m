//
//  DetailViewController.m
//  xunleixiaxia
//
//  Created by Kai Chen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalViewController.h"

#import "AppDelegate.h"
#import "RootViewController.h"
#import "DownloadViewController.h"

@interface LocalViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation LocalViewController
@synthesize tableView;

@synthesize docWatcher, documentURLs, docInteractionController;

@synthesize masterPopoverController = _masterPopoverController;

- (void)dealloc
{
 
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
   //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(editAction)];
    self.navigationItem.rightBarButtonItem = editButton;
    

    [self configureView];
    
    self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
    
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    
    NSArray *filelist;
    
    filelist = [filemgr contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:NULL];
    
    self.documentURLs = [NSMutableArray array];
    
    // scan for existing documents
    [self directoryDidChange:self.docWatcher];
    

}

-(void)editAction{
    if(editButton.title == @"编辑") {
        [editButton setTitle:@"确定"];
        [editButton setStyle:UIBarButtonItemStyleDone];
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        [editButton setTitle:@"编辑"];    
        [editButton setStyle:UIBarButtonItemStylePlain];
        [self.tableView setEditing:NO animated:YES];
    }
    
}

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark -
#pragma mark View Controller

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"目录", @"目录");
        //self.clearsSelectionOnViewWillAppear = NO;
        //self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return documentURLs.count;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *CellIdentifier = @"Cell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
     cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
     }
     
     NSURL *url = [documentURLs objectAtIndex:indexPath.row];
     cell.textLabel.text =[[url path] lastPathComponent]; 
     return cell;
     */
    
    
    NSInteger iconCount = [docInteractionController.icons count];
    
    
    
    static NSString *cellIdentifier = @"cellID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    if (documentURLs.count>0) {
        
        
        
        NSURL *fileURL;
        
        // second section is the contents of the Documents folder
        fileURL = [self.documentURLs objectAtIndex:indexPath.row];
        
        [self setupDocumentControllerWithURL:fileURL];
        
        // layout the cell
        cell.textLabel.text = [[fileURL path] lastPathComponent];
        
        if (iconCount > 0)
        {
            cell.imageView.image = [docInteractionController.icons objectAtIndex:iconCount - 1];
        }
        
        NSError *error;
        NSString *fileURLString = [self.docInteractionController.URL path];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error:&error];
        NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                     [self formattedFileSize:fileSize], docInteractionController.UTI];
        
        
        // attach to our view any gesture recognizers that the UIDocumentInteractionController provides
        //cell.imageView.userInteractionEnabled = YES;
        //cell.contentView.gestureRecognizers = self.docInteractionController.gestureRecognizers;
        //
        // or
        // add a custom gesture recognizer in lieu of using the canned ones
    }
    
    
//    UISwipeGestureRecognizer *swipeGestureRecognizer=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
//    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [cell addGestureRecognizer:swipeGestureRecognizer];
//    
    return cell;
     
    
    
}

//-(void) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//{
//    
//    /*if([[gestureRecognizer view] isKindOfClass:[UITableViewCell class]]){
//        if([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
//    
//            UISwipeGestureRecognizer* sg = (UISwipeGestureRecognizer*)gestureRecognizer;
//            
//            if ((sg.direction ==UISwipeGestureRecognizerDirectionLeft) ||  (sg.direction ==UISwipeGestureRecognizerDirectionRight)){
//                
//            }
//                
//         }
//    }
//    */
//    
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        UIGestureRecognizer *swipeGestureRecognizer=(UISwipeGestureRecognizer*)gestureRecognizer;
//        CGPoint swipeLocation = [swipeGestureRecognizer locationInView:self.tableView];
//        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
//        //UITableViewCell* swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
//        
//        [self tableView:self.tableView editingStyleForRowAtIndexPath:swipedIndexPath];
//
//        /*
//        //you can now use these two to perform delete operation
//        
//        NSFileManager *filemgr;
//        filemgr = [NSFileManager defaultManager];
//        
//        NSURL *fileURL;
//        
//        // second section is the contents of the Documents folder
//        fileURL = [self.documentURLs objectAtIndex:swipedIndexPath.row];
//        
//        
//        //NSLog(@"%@",[fileURL path]);
//        
//        [filemgr removeItemAtPath:[fileURL path] error:nil];       
//        
//        [self.documentURLs removeObjectAtIndex:swipedIndexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:swipedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//         */
//
//    }
//    
//}


- (UIAlertView *) showWaitingAlert{
	UIAlertView *waittingAlert = [[UIAlertView alloc] initWithTitle: @"正在获取数据"
                                                            message: @"请稍候..."
                                                           delegate: nil
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: nil];
	
	
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
	[waittingAlert addSubview:activityView];
	[activityView startAnimating];
	
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

- (void) documentInteractionController: (UIDocumentInteractionController *)controller willBeginSendingToApplication: (NSString *) application
{
    _waittingAlert = [self showWaitingAlert];
    //NSLog(@"Starting Sending");
}

- (void) documentInteractionController: (UIDocumentInteractionController *)controller didEndSendingToApplication: (NSString *) application
{
  //  [self dismissWaitingAlert:&_waittingAlert];
    //NSLog(@"Finished Sending");
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    //NSLog(@"Dismiss Sending");
    
}

- (void)didReceiveMemoryWarning
{ 
    // default behavior is to release the view if it doesn't have a superview.
    
    // remember to clean up anything outside of this view's scope, such as
    // data cached in the class instance and other global data.
    [super didReceiveMemoryWarning];
}

- (NSString *)formattedFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;
    if (size == 0) 
		formattedStr = @"Empty";
	else 
		if (size > 0 && size < 1024) 
			formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
        else 
            if (size >= 1024 && size < pow(1024, 2)) 
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            else 
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                else 
                    if (size >= pow(1024, 3)) 
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
	
	return formattedStr;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.documentURLs count];
	
    if (row < count) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSFileManager *filemgr;
        filemgr = [NSFileManager defaultManager];
        
        NSURL *fileURL;
        
        // second section is the contents of the Documents folder
        fileURL = [self.documentURLs objectAtIndex:indexPath.row];

        
        //NSLog(@"%@",[fileURL path]);
        
        [filemgr removeItemAtPath:[fileURL path] error:nil];       
        
        [self.documentURLs removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
       

        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    // three ways to present a preview:
    // 1. Don't implement this method and simply attach the canned gestureRecognizers to the cell
    //
    // 2. Don't use canned gesture recognizers and simply use UIDocumentInteractionController's
    //      presentPreviewAnimated: to get a preview for the document associated with this cell
    //
    // 3. Use the QLPreviewController to give the user preview access to the document associated
    //      with this cell and all the other documents as well.
    
    // for case 2 use this, allowing UIDocumentInteractionController to handle the preview:
    /*
     NSURL *fileURL;
    
     fileURL = [self.documentURLs objectAtIndex:indexPath.row];
     [self setupDocumentControllerWithURL:fileURL];
     [self.docInteractionController presentPreviewAnimated:YES];
     */
    
    
    // for case 3 we use the QuickLook APIs directly to preview the document -
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
    // start previewing the document at the current section index
    previewController.currentPreviewItemIndex = indexPath.row;
    [[self navigationController] pushViewController:previewController animated:YES];
    
    /*
     UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:previewController];
     navController.modalPresentationStyle = UIModalPresentationFormSheet;
     [self presentModalViewController:navController animated:YES];
     */

}



- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	[self.documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath =[self applicationDocumentsDirectory];
    //[self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
	{
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory))
        {
            [self.documentURLs addObject:fileURL];
        }
	}
	
	[self.tableView reloadData];
    
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    RootViewController *rootViewController = app.rootViewController;
    
    DownloadViewController * downloadViewController = rootViewController.downloadViewController;
    [downloadViewController.tableView reloadData];
    [downloadViewController refreshFolder];
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}


#pragma mark -
#pragma mark QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSInteger numToPreview = 0;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath.section == 0)
        numToPreview = self.documentURLs.count;
    
    return numToPreview;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should previewgg
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = nil;
    
    
    fileURL = [self.documentURLs objectAtIndex:idx];
    
    return fileURL;
}



@end
