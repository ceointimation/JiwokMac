//
//  JiwokCurlFtpClient.h
//  Jiwok
//
//  Created by Reubro on 05/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokCurlFtpClient : NSObject {
	
	NSTask*task,*theTask;

	NSString *downloadLink,*directoryUrl,*destinationPath,*uploadLink,*uploadfilePath;
	

}



- (NSString *)DownloadFromFTP:(NSString*)Url:(NSString*)Path;

- (NSString *)DownloadFromFTP:(NSArray*)input ;


- (NSMutableArray*)ListDirectoriesFromFTP:(NSString*)DUrl;
- (NSString *)UploadToFTP:(NSString*)Url:(NSString*)Path;
- (NSString *)CreateDirectory:(NSString*)Path;

@end


