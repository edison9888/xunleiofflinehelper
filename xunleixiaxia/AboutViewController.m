//
//  AboutViewController.m
//  xunleixiaxia
//
//  Created by Kai Chen on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "HelpViewController.h"
@interface AboutViewController ()

@end



@implementation AboutViewController

@synthesize contentsList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";   
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    NSArray *firstSection = [NSArray arrayWithObjects:@"当前版本                                                                v1.0.0", nil];
	NSArray *secondSection = [NSArray arrayWithObjects:@"使用帮助",@"向朋友推荐", @"意见反馈", nil];
   
	NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:firstSection, secondSection, nil];
	[self setContentsList:array];

    
}

-(void) done:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
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
	NSInteger sections = [[self contentsList] count];
	
	return sections;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if((indexPath.section == 1) && (indexPath.row == 2)) {
        [self mailComment];
    }
    
    if((indexPath.section == 1) && (indexPath.row == 1)) {
        [self mailDidPush];
    }
    
    if((indexPath.section == 1) && (indexPath.row == 0)) {
        [self help];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	
	NSArray *sectionContents = [[self contentsList] objectAtIndex:section];
	NSInteger rows = [sectionContents count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *sectionContents = [[self contentsList] objectAtIndex:[indexPath section]];
	NSString *contentForThisRow = [sectionContents objectAtIndex:[indexPath row]];
	
	static NSString *CellIdentifier = @"CellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    if((indexPath.section == 1) && (indexPath.row == 0)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	[[cell textLabel] setText:contentForThisRow];
	
	return cell;
}


-(void) help{
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    
        
    [self.navigationController pushViewController:helpViewController animated:YES];  
    
}

- (void)mailComment {
	
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
		mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[[NSArray alloc] initWithObjects:@"xunleixiaxia@qq.com", nil]];
		[mailViewController setSubject:@"意见反馈"];
		[mailViewController setMessageBody:@"迅雷下下:\n\t    我在使用迅雷下下中发现问题:" isHTML:NO];
		//[mailViewController addAttachmentData:data mimeType:@"text/plain" fileName:[path_ lastPathComponent]];
		
		[self presentModalViewController:mailViewController animated:YES];
	}
}


- (void)mailDidPush {
	
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
		mailViewController.mailComposeDelegate = self;
        //[mailViewController setToRecipients:[[NSArray alloc] initWithObjects:@"xunleixiaxia@qq.com", nil]];
		[mailViewController setSubject:@"推荐使用迅雷下下"];
		[mailViewController setMessageBody:@"我使用了迅雷下下很不错，也推荐你使用！" isHTML:NO];
		//[mailViewController addAttachmentData:data mimeType:@"text/plain" fileName:[path_ lastPathComponent]];
		
		[self presentModalViewController:mailViewController animated:YES];
	}
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
}


@end
