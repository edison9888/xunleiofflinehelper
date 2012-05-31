//
//  DocSetDownloadManager.m
//  DocSets
//
//  Created by Ole Zorn on 22.01.12.
//  Copyright (c) 2012 omz:software. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager()

- (void)startNextDownload;
- (void)reloadDownloadedDocSets;
- (void)downloadFinished:(XunleiDownload *)download;
- (void)downloadFailed:(XunleiDownload *)download;
- (void)setFiles:(NSArray *) files;
@end


@implementation DownloadManager

@synthesize downloadeds=_downloadeds, downloadedNames=_downloadedNames, availableDownloads, currentDownload=_currentDownload, lastUpdated=_lastUpdated;

- (id)init
{
	self = [super init];
	if (self) {
		//[self reloadAvailableDocSets];
		_downloadsByURL = [NSMutableDictionary new];
		_downloadQueue = [NSMutableArray new];
		//[self reloadDownloadedDocSets];
	}
	return self;
}


- (void)setFiles:(NSArray *) files{
    //if (_availableDownloads != nil) {
    //    [_availableDownloads release];
        
    //}
    //_availableDownloads = [[NSMutableArray alloc] initWithArray:files];
}

//- (void)reloadAvailableDocSets
//{
//    
//	NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//	NSString *cachedAvailableDownloadsPath = [cachesPath stringByAppendingPathComponent:@"DL.plist"];
//	NSFileManager *fm = [[NSFileManager alloc] init];
//	if (![fm fileExistsAtPath:cachedAvailableDownloadsPath]) {
//		NSString *bundledAvailableDocSetsPlistPath = [[NSBundle mainBundle] pathForResource:@"DL" ofType:@"plist"];
//		[fm copyItemAtPath:bundledAvailableDocSetsPlistPath toPath:cachedAvailableDownloadsPath error:NULL];
//	}
//	self.lastUpdated = [[fm attributesOfItemAtPath:cachedAvailableDownloadsPath error:NULL] fileModificationDate];
//	//_availableDownloads = [[NSDictionary dictionaryWithContentsOfFile:cachedAvailableDownloadsPath] objectForKey:@"DowloadList"];
//}

- (void)reloadDownloadedDocSets
{
    /*
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSArray *documents = [fm contentsOfDirectoryAtPath:docPath error:NULL];
	NSMutableArray *loadedSets = [NSMutableArray array];
	[[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerUpdatedsNotification object:self];
    
    */
}

+ (id)sharedDownloadManager
{
	static id sharedDownloadManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedDownloadManager = [[self alloc] init];
	});
	return sharedDownloadManager;
}

- (XunleiDownload *)downloadForURL:(NSString *)URL
{
	return [_downloadsByURL objectForKey:URL];
}

- (void)stopDownload:(XunleiDownload *)download
{
	if (download.status == DownloadStatusWaiting) {
		[_downloadQueue removeObject:download];
		[_downloadsByURL removeObjectForKey:[download.URL absoluteString]];
		[[NSNotificationCenter defaultCenter] postNotificationName:DownloadFinishedNotification object:download];
	} else if (download.status == DownloadStatusDownloading) {
		[download cancel];
		self.currentDownload = nil;
		[_downloadsByURL removeObjectForKey:[download.URL absoluteString]];
		[[NSNotificationCenter defaultCenter] postNotificationName:DownloadFinishedNotification object:download];
		[self startNextDownload];
	} else if (download.status == DownloadStatusExtracting) {
		download.shouldCancelExtracting = YES;
	}
}

- (void)downloadAtURL:(NSString *)URL Filename:(NSString*) filename Cookies:(NSMutableArray*)cookies
{
	if ([_downloadsByURL objectForKey:URL]) {
		//already downloading
		return;
	}
	
	XunleiDownload *download = [[XunleiDownload alloc] initWithURL:[NSURL URLWithString:URL] Cookies:[[NSMutableArray alloc] initWithArray: cookies]];
    download.filename = filename;
    
	[_downloadQueue addObject:download];
	[_downloadsByURL setObject:download forKey:URL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerStartedDownloadNotification object:self];
	
	[self startNextDownload];
}

- (void)startNextDownload
{
	if ([_downloadQueue count] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		return;
	}
	if (self.currentDownload != nil) return;
	
	self.currentDownload = [_downloadQueue objectAtIndex:0];
	[_downloadQueue removeObjectAtIndex:0];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self.currentDownload start];
}

- (void)downloadFinished:(XunleiDownload *)download
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DownloadFinishedNotification object:download];
	
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:download.filename];
    NSString *targetPath = [docPath stringByAppendingPathComponent:download.filename];
    [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:targetPath error:NULL];
    //NSLog(@"Moved downloaded docset to %@", targetPath);
    //NSLog(@"Moved downloaded docset from %@", fullPath);
 	
	[self reloadDownloadedDocSets];
	
	[_downloadsByURL removeObjectForKey:[download.URL absoluteString]];	
	self.currentDownload = nil;
	[self startNextDownload];
}

- (void)downloadFailed:(XunleiDownload *)download
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DownloadFinishedNotification object:download];
	[_downloadsByURL removeObjectForKey:[download.URL absoluteString]];	
	self.currentDownload = nil;
	[self startNextDownload];
	
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"下载错误", nil) 
								 message:NSLocalizedString(@"下载过程中发生错误，请重试。", nil) 
								delegate:nil 
					   cancelButtonTitle:NSLocalizedString(@"确定", nil) 
					   otherButtonTitles:nil] show];
}

@end



@implementation XunleiDownload

@synthesize connection=_connection, filename=_filename, URL=_URL, fileHandle=_fileHandle, downloadTargetPath=_downloadTargetPath, extractedPath=_extractedPath, progress=_progress, status=_status, shouldCancelExtracting = _shouldCancelExtracting;
@synthesize downloadSize, bytesDownloaded;



- (id)initWithURL:(NSURL *)URL  Cookies:(NSArray*)cookies
{
	self = [super init];
	if (self) {
		_URL = URL;
		self.status = DownloadStatusWaiting;

	}
	return self;
}

- (void)start
{
	if (self.status != DownloadStatusWaiting) {
		return;
	}
	
	_backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
	
	self.status = DownloadStatusDownloading;
	
	self.downloadTargetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:_filename];
	[@"" writeToFile:self.downloadTargetPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.downloadTargetPath];
	
	bytesDownloaded = 0;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                    
    [request setAllHTTPHeaderFields:headers];
    
    
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void)cancel
{
	if (self.status == DownloadStatusDownloading) {
		[self.connection cancel];
		self.status = DownloadStatusFinished;
		if (_backgroundTask != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
	downloadSize = [[headers objectForKey:@"Content-Length"] integerValue];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	bytesDownloaded += [data length];
	if (downloadSize != 0) {
		self.progress = (float)bytesDownloaded / (float)downloadSize;
		//NSLog(@"Download progress: %f", self.progress);
	}
	[self.fileHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.fileHandle closeFile];
	self.fileHandle = nil;
	
	self.status = DownloadStatusExtracting;
	self.progress = 0.0;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	
		dispatch_async(dispatch_get_main_queue(), ^{
			self.status = DownloadStatusFinished;
			[[DownloadManager sharedDownloadManager] downloadFinished:self];
			
			if (_backgroundTask != UIBackgroundTaskInvalid) {
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
			}
		});
	});
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self fail];
}

- (void)fail
{
	[[DownloadManager sharedDownloadManager] downloadFailed:self];
	if (_backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
	}
}



@end