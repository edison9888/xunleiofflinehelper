//
//  DownloadManager.h
//  s
//
//  Created by Ole Zorn on 22.01.12.
//  Copyright (c) 2012 omz:software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DownloadManagerAvailablesChangedNotification	@"DownloadManagerAvailablesChangedNotification"
#define DownloadManagerStartedDownloadNotification		@"DownloadManagerStartedDownloadNotification"
#define DownloadManagerUpdatedsNotification				@"DownloadManagerUpdatedsNotification"
#define DownloadFinishedNotification					@"DownloadFinishedNotification"

@class XunleiDownload;

@interface DownloadManager : NSObject {

	NSArray *_downloadeds;
	NSSet *_downloadedNames;
	
	//NSMutableArray *_availableDownloads;
	NSMutableDictionary *_downloadsByURL;
	XunleiDownload *_currentDownload;
	NSMutableArray *_downloadQueue;
	
	NSDate *_lastUpdated;
	BOOL _updatingAvailablesFromWeb;
}

@property (nonatomic, strong) NSArray *downloadeds;
@property (nonatomic, strong) NSSet *downloadedNames;
@property (nonatomic, strong) NSMutableArray *availableDownloads;
@property (nonatomic, strong) XunleiDownload *currentDownload;
@property (nonatomic, strong) NSDate *lastUpdated;

+ (id)sharedDownloadManager;
//- (void)reloadAvailables;
//- (void)updateAvailablesFromWeb;
- (void)downloadAtURL:(NSString *)URL Filename:(NSString*) filename Cookies:(NSMutableArray*)cookies;

//- (void)delete:( *)ToDelete;
- (XunleiDownload *)downloadForURL:(NSString *)URL;
- (void)stopDownload:(XunleiDownload *)download;
//- ( *)downloadedWithName:(NSString *)Name;

@end


typedef enum DownloadStatus {
	DownloadStatusWaiting = 0,
	DownloadStatusDownloading,
	DownloadStatusExtracting,
	DownloadStatusFinished
} DownloadStatus;

@interface XunleiDownload : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {

	UIBackgroundTaskIdentifier _backgroundTask;
	NSURL *_URL;
	NSURLConnection *_connection;
	NSFileHandle *_fileHandle;
	NSString *_downloadTargetPath;
	NSString *_extractedPath;
    NSArray *cookies;
    NSString *_filename;
	
	DownloadStatus _status;
	float _progress;
    BOOL _shouldCancelExtracting;
	NSUInteger bytesDownloaded;
	NSInteger downloadSize;
}

@property (nonatomic,strong) NSString *filename;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSURLConnection *connection;
@property (strong) NSString *downloadTargetPath;
@property (nonatomic, strong) NSString *extractedPath;
@property (nonatomic, assign) DownloadStatus status;
@property (nonatomic, assign) float progress;
@property (atomic, assign) BOOL shouldCancelExtracting; // must be atomic
@property (readonly) NSUInteger bytesDownloaded;
@property (readonly) NSInteger downloadSize;

- (id)initWithURL:(NSURL *)URL Cookies:(NSArray*)cookies;
- (void)start;
- (void)cancel;
- (void)fail;

@end