//
//  CheckNetwork.m
//  xunleixiaxia
//
//  Created by Kai Chen on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"
@implementation CheckNetwork
+(BOOL)isExistenceNetwork
{
	BOOL isExistenceNetwork;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
			isExistenceNetwork=FALSE;
            //   NSLog(@"没有网络");
            break;
        case ReachableViaWWAN:
			isExistenceNetwork=TRUE;
            //   NSLog(@"正在使用3G网络");
            break;
        case ReachableViaWiFi:
			isExistenceNetwork=TRUE;
            //  NSLog(@"正在使用wifi网络");        
            break;
    }
	if (!isExistenceNetwork) {
		UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"无网络连接！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
		[myalert show];
	}
	return isExistenceNetwork;
}
@end