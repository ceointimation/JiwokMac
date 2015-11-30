//
//  JiwokFTPDownloader.h
//  Jiwok
//
//  Created by reubro R on 12/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokFTPDownloader : NSObject {
	
	NSTask*task;
	NSNotificationCenter*defaultCenter;
	NSString *downloadLink,*directoryUrl,*destinationPath,*uploadLink,*uploadfilePath;
}
- (NSString *)DownloadFromFTP:(NSString*)Url:(NSString*)Path;
- (NSMutableArray*)ListDirectoriesFromFTP:(NSString*)DUrl;
- (NSString *)UploadToFTP:(NSString*)Url:(NSString*)Path;
@end
