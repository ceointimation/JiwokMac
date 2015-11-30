//
//  Autoupdater.h
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 18/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Autoupdater : NSObject {
	
	NSMutableArray *VersionDetailsArray;
	NSString *currentVersion;
	NSString *latestVersion,*releaseDate,*downloadFrom,*versionNumber,*downloadDate;
	
	NSTask  *task;
}

-(BOOL)checkForLatestVersion;

-(void)downloadLatestVersion;

-(void)LaunchBrowser;

-(void)LaunchUpdateApp;

-(void)updateDataBase;

-(BOOL)unzipInput:(NSString *)inputPath:(NSString*)outputPath;

-(NSComparisonResult)compareVersions:(NSString*)leftVersion:(NSString*)rightVersion;

@end
