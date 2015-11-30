//
//  Autoupdater.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 18/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Autoupdater.h"
#import "VersionCheckXmlParser.h"
#import"JiwokFTPDownloader.h"

#import "JiwokCurlFtpClient.h"
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "LoggerClass.h"

#import "JiwokSettingPlistReader.h"

#import "JiwokUtil.h"


@implementation Autoupdater



//NSComparisonResult compareVersions(NSString* leftVersion, NSString* rightVersion)

-(NSComparisonResult)compareVersions:(NSString*)leftVersion:(NSString*)rightVersion
{
     DUBUG_LOG(@"Now you are in compareVersions method in Autoupdater class");
	int i;	

	// Break version into fields (separated by '.')

	NSMutableArray *leftFields = [[NSMutableArray alloc] initWithArray:[leftVersion componentsSeparatedByString:@"."]];
	NSMutableArray *rightFields = [[NSMutableArray alloc] initWithArray:[rightVersion componentsSeparatedByString:@"."]];	
    NSLog(@"leftFields mutablearray==%@",leftFields);
    NSLog(@"rightFields mutablearray==%@",rightFields);
	// Implict ".0" in case version doesn't have the same number of '.'

	if ([leftFields count] < [rightFields count]) {
		while ([leftFields count] != [rightFields count]) {
			[leftFields addObject:@"0"];
		}
	} else if ([leftFields count] > [rightFields count]) {
		while ([leftFields count] != [rightFields count]) {
			[rightFields addObject:@"0"];
		}
	}

	// Do a numeric comparison on each field

	for(i = 0; i < [leftFields count]; i++) {
		NSComparisonResult result = [[leftFields objectAtIndex:i] compare:[rightFields objectAtIndex:i] options:NSNumericSearch];

		if (result != NSOrderedSame) {
			[leftFields release];
			[rightFields release];
			return result;
		}
	}
	[leftFields release];
	[rightFields release];
    DUBUG_LOG(@"Now you are completed compareVersions method in Autoupdater class");
	return NSOrderedSame;
   
}


-(BOOL)checkForLatestVersion{
	
	DUBUG_LOG(@"Now you are in checkForLatestVersion method in Autoupdater class");
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"checkForLatestVersion");
	
	BOOL updateAvailable=NO;
	
//	// Get current version from database
	
	NSString *post;
	
	BOOL checkTempUpdate=[JiwokSettingPlistReader checkForTemporaryUpdates];
	
	if(checkTempUpdate)
		post =@"http://www.jiwok.com/webservices/GetLatestMacVersionTemp.php";
		else 
			post =@"http://www.jiwok.com/webservices/GetLatestMacVersion.php";
	
	
	// Original value

	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getApplicationDetails];
	currentVersion=[[selectedValuesArray objectAtIndex:0] objectForKey:@"CurrentVersion"];
	//NSString *post =@"http://www.jiwok.com/webservices/GetLatestMacVersion.php";
	NSLog(@"selectedValuesArray array==%@",selectedValuesArray);
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];

	
	NSURL *url = [NSURL URLWithString:post];
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	VersionCheckXmlParser *versionCheckParser = [[VersionCheckXmlParser alloc] init];	
	
	if([JiwokUtil checkForInternetConnection:jiwokURL])
	VersionDetailsArray = [versionCheckParser startDataParsing:data];
	[versionCheckParser autorelease];	
	
	[data release];
	
	//[pool release];
	
	if([VersionDetailsArray count]>0)
	{	
		if([[VersionDetailsArray objectAtIndex:0] objectForKey:@"version"])
		{
		NSString *latestVersion1=[[VersionDetailsArray objectAtIndex:0] objectForKey:@"version"];
		if([latestVersion1 length]>2)
		latestVersion=[latestVersion1 substringToIndex:([latestVersion1 length]-2)];
		releaseDate=[[VersionDetailsArray objectAtIndex:0] objectForKey:@"releasedate"];
		downloadFrom=[[VersionDetailsArray objectAtIndex:0] objectForKey:@"filepath"];
		versionNumber=[[VersionDetailsArray objectAtIndex:0] objectForKey:@"updateid"];		
		
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd-MM-yyyy"];
		
		NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
		
		downloadDate=dateString;
			
		}
		
	}	
		
	int versionCheckValue=[self compareVersions:currentVersion:latestVersion];		
	
	
if([[[VersionDetailsArray objectAtIndex:0] objectForKey:@"version"] length]>0)
{
	//if(![latestVersion isEqualToString:currentVersion])		
	//if([latestVersion floatValue] >[currentVersion floatValue])
	
	if(versionCheckValue==-1)
	{				
		updateAvailable=YES;
	}
	else
	{
		updateAvailable=NO;
	}
}	
	DUBUG_LOG(@"Now you are completed checkForLatestVersion method in Autoupdater class");
	return updateAvailable;	
	 
}


//-(void)copyNewMp3Files{
//	
//	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getApplicationDetails];
//	NSString *currentAppVersion=[[selectedValuesArray objectAtIndex:0] objectForKey:@"CurrentVersion"];
//	NSString *copyAppVersion=@"1.6.8";
//		
//	int versionCheckValue=[self compareVersions:currentAppVersion:copyAppVersion];		
//
//	if(versionCheckValue==-1){
//	
//		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];	
//		NSString *newMp3Path=[bundlePath  stringByAppendingPathComponent:@"Contents/Resources/delivery_mp3.zip"];	
//		NSString *vocalPath=[bundlePath  stringByAppendingPathComponent:@"Vocals"];	
//		NSString *extractedPath=[bundlePath  stringByAppendingPathComponent:@"delivery_mp3"];		
//		
//		BOOL unzipResult=[self unzipInput:newMp3Path:bundlePath];
//		
//		if(unzipResult)
//		{
//			BOOL isDir;			
//			BOOL vocalCheck=[[NSFileManager defaultManager] fileExistsAtPath:vocalPath isDirectory:&isDir];			
//			NSArray *newVocals=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:extractedPath error:nil];			
//			
//			if(vocalCheck)
//			{
//				for (int i=0; i<[newVocals count]; i++) {
//					NSString *currentVocal=[newVocals objectAtIndex:i];
//					NSString *newVocalPath=[extractedPath stringByAppendingPathComponent:currentVocal];
//					NSString *finalVocalPath=[vocalPath stringByAppendingPathComponent:currentVocal];					
//					[[NSFileManager defaultManager] moveItemAtPath:newVocalPath toPath:finalVocalPath error:nil];					
//				}
//				
//				NSString *junkFolder=[bundlePath  stringByAppendingPathComponent:@"__MACOSX"];				
//				[[NSFileManager defaultManager] removeItemAtPath:extractedPath error:nil];
//				
//				if([[NSFileManager defaultManager] fileExistsAtPath:junkFolder isDirectory:&isDir])
//					[[NSFileManager defaultManager] removeItemAtPath:junkFolder error:nil];			
//			}
//		}
//	}	
//}


-(void)downloadLatestVersion{

	 DUBUG_LOG(@"Now you are in downloadLatestVersion method in Autoupdater class");
	//[self copyNewMp3Files];
	
	DUBUG_LOG(@"downloadLatestVersion");
	
	[self checkForLatestVersion];
	
	JiwokCurlFtpClient *ftpDownloader=[[JiwokCurlFtpClient alloc]init];
	
	//NSString *downloadLink=[NSString stringWithFormat:@"ftp://ftp.jiwok-wbdd.najman.lbn.fr/tagupdates/%@/Jiwok.exe",latestVersion];
		
	// Original value
	
	NSString *downloadLink=[NSString stringWithFormat:@"ftp://ftp.jiwok-wbdd.najman.lbn.fr/mactagupdates/%@/Jiwok.zip",latestVersion];
	
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
	NSString *localVocalPath = [bundlePath  stringByAppendingPathComponent:@"Vocals"];
	
	//NSLog(@"localVocalPath localVocalPath is %@",localVocalPath);
	
	NSString *downloadResult= [ftpDownloader DownloadFromFTP:downloadLink:localVocalPath];
////	
	DUBUG_LOG(@"downloadResult downloadResult %@",downloadResult);

	[ftpDownloader release];
		
	NSString *zipPath=[NSString stringWithFormat:@"%@/Jiwok.zip",bundlePath];
	NSString *appPath=[NSString stringWithFormat:@"%@/Jiwok.app",bundlePath];

	if([downloadResult length]>300)
	{
		
		BOOL unzipResult;
		
		unzipResult=[self unzipInput:zipPath:appPath];
		
		if(unzipResult)
		{
			[self updateDataBase];	
			[self LaunchUpdateApp];
		}
	}
     DUBUG_LOG(@"Now you are completed downloadLatestVersion method in Autoupdater class");
}


-(void)updateDataBase{

	 DUBUG_LOG(@"Now you are in updateDataBase method in Autoupdater class");
	NSMutableDictionary *dbValues=[NSMutableDictionary dictionaryWithObjectsAndKeys:latestVersion,@"CurrentVersion",downloadDate,@"DownloadDate",releaseDate,@"ReleaseDate",downloadFrom,@"DownloadFrom",versionNumber,@"VersionNo",nil];

	DUBUG_LOG(@"dbValues dbValues is %@",dbValues);
	
	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertApplicationDetails:dbValues];
	
	NSLog(@"updateDataBase dbValues is== %@",dbValues);
	 DUBUG_LOG(@"Now you are completed updateDataBase method in Autoupdater class");
}

-(void)LaunchBrowser{
	 DUBUG_LOG(@"Now you are in LaunchBrowser method in Autoupdater class");		
	NSWorkspace* ws = [NSWorkspace sharedWorkspace];			
	NSURL * url = [NSURL URLWithString:@"http://www.jiwok.com/help.php"];
	[ws openURL: url];
	 DUBUG_LOG(@"Now you are completed LaunchBrowser method in Autoupdater class");	
}


-(void)LaunchUpdateApp{
     DUBUG_LOG(@"Now you are in LaunchUpdateApp method in Autoupdater class");	
	NSWorkspace* ws = [NSWorkspace sharedWorkspace];	
	 NSString *bundlePath = [[NSBundle mainBundle] bundlePath];	
	 NSString *UpdaterPath=[bundlePath  stringByAppendingPathComponent:@"JiwokUpdater.app"];		
	
	NSLog(@"UpdaterPath UpdaterPath %@",UpdaterPath);
	
	@try {
		if([[NSFileManager defaultManager] fileExistsAtPath:UpdaterPath])
			[ws launchApplication:UpdaterPath];
	}
	@catch (NSException * e) {
		NSLog(@"Description is %@",[e description]);
	}
		
	exit (0);
    DUBUG_LOG(@"Now you are completed LaunchUpdateApp method in Autoupdater class");	
}


-(BOOL)unzipInput:(NSString *)inputPath:(NSString*)outputPath{
    DUBUG_LOG(@"Now you are in unzipInput method in Autoupdater class");	
	BOOL result;
	
	@try
	{
		NSString * toolPath=@"/usr/bin/unzip";			
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"unzipInput --> File not found %@",toolPath];
			//return nil;
		}
		
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-o"];
		[mArray addObject:inputPath];	
		[mArray addObject:@"-d"];	
		[mArray addObject:outputPath];	
		NSLog(@"mArray==%@",mArray);		
		task = [[NSTask alloc] init]; 
		[task setLaunchPath: toolPath];
		[task setArguments: mArray];
		
		NSString *path = @"/tmp/myFile.txt";
		
		if ( [[NSFileManager defaultManager] fileExistsAtPath: path] )
		{
			[[NSFileManager defaultManager] removeFileAtPath: path handler: nil];
		}
		
		BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath: path contents: nil attributes: nil];
		if ( fileCreated )
		{
			NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: path];
			[task setStandardOutput: fileHandle];
			[task setStandardError:fileHandle ];
		}
		
		[task launch];
		[task waitUntilExit];
		NSData *data1 = [NSData dataWithContentsOfFile:path];
		
		NSString *fileContents =  [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding]; 		
		
		NSLog(@"file content isisisisii %@",fileContents);		
		NSLog(@"file content LENGHT isisisisii %d",[fileContents length]);

		if([fileContents length]>1000)
			result=YES;
        DUBUG_LOG(@"Now you are completed unzipInput method in Autoupdater class");
		
		
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch  Exception occured in unzipInput  %@",[ex description]);
		
	}
	@finally {
		
		
		DUBUG_LOG(@"@finally unzipInput  result is %d",result);
	
		return result;
	
	}
    
}


@end
