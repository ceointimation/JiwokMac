//
//  JiwokMyMusicPanelViewController.m
//  Jiwok
//
//  Created by reubro R on 14/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokMyMusicPanelViewController.h"
#import "JiwokUtil.h"
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "Common.h"
#import "JiwokFfmpegID3TagReader.h"
#import "JiwokFMODUtil.h"
#import "JiwokAnalysisSummaryWindowController.h"
#import "LoggerClass.h"
#import "JiwokAPIHelper.h"
#import "JiwokMusicConverter.h"
#import"Variable.h"
#import "JiwokAppDelegate.h"
#import "JiwokMusicProcessor.h"
#import "JiwokBPMDetector.h"

#import "BpmCalculator.h"
#import "GrowlExample.h"
#import "JiwokLastfmClient.h"
#import "Autoupdater.h"


#include <pthread.h>


#define ANALYSIS_COMPLETED @"kDidFinishAnalysisNotification"

@implementation JiwokMyMusicPanelViewController
@synthesize delegate;

- (BOOL)shouldAnalyzeSongBySizeCheck:(NSString *)filePath{		
	//DUBUG_LOG(@"filepath is %@",filePath);
    DUBUG_LOG(@"Now you are in shouldAnalyzeSongBySizeCheck method in JiwokMyMusicPanelViewController class");
	if([fileManager fileExistsAtPath:filePath])
	{		
		NSDictionary *attributes= [fileManager attributesOfItemAtPath:filePath error:NULL];		
		//DUBUG_LOG(@"shouldAnalyzeSongBySizeCheck is %f",[([attributes objectForKey:NSFileSize]) floatValue]);
		 NSLog(@"attributes nsdictionary==%@",attributes);
		if([([attributes objectForKey:NSFileSize]) floatValue]<(15 * 1048576))
			return YES;
		else 
			return NO;
	}
	else return NO;
    // NSLog(@"Now you are completed shouldAnalyzeSongBySizeCheck method in JiwokMyMusicPanelViewController class");
}


- (unsigned long long) fastFolderSize:(NSString*)path
{
     DUBUG_LOG(@"Now you are in fastFolderSize method in JiwokMyMusicPanelViewController class");
	unsigned long long bytes;
	
	BOOL isDir;
	
	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	if (isDir) {
				
		NSPipe *pipe = [NSPipe pipe];
		NSTask *t = [[[NSTask alloc] init] autorelease];
		[t setLaunchPath:@"/usr/bin/du"];
		[t setArguments:[NSArray arrayWithObjects:@"-k", @"-d", @"0", path, nil]];
		[t setStandardOutput:pipe];
		[t setStandardError:[NSPipe pipe]];
		
		[t launch];		
		//[t waitUntilExit];
		
		NSString *sizeString = [[[NSString alloc] initWithData:[[pipe fileHandleForReading] availableData] encoding:NSASCIIStringEncoding] autorelease];
		sizeString = [[sizeString componentsSeparatedByString:@" "] objectAtIndex:0];
		bytes = [sizeString longLongValue]*1024;
		
		
	}
	else {
		bytes = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];		
	}
	 DUBUG_LOG(@"Now you are completed fastFolderSize method in JiwokMyMusicPanelViewController class");
	return bytes;
  
}


- (void)iterateMyFolderForBPMAnalysisByFolder:(NSString *)folderPath
{
    DUBUG_LOG(@"Now you are in iterateMyFolderForBPMAnalysisByFolder method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"iterateMyFolderForBPMAnalysisByFolder %@",folderPath);
	
	NSArray *files = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
     NSLog(@"files NSArray==%@",files);
	for (NSString *element in files)
	{
		NSString *urlStr = [folderPath stringByAppendingPathComponent:element];
		NSString *extension = [urlStr pathExtension];
		if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"m4a"])
		{
			
			processesFileSize+=[[[fileManager attributesOfItemAtPath:urlStr error:NULL] objectForKey:NSFileSize] intValue];						
			[analysisProgress setDoubleValue:processesFileSize];
			
			BOOL checkValue=[self checkFileInDatabase:urlStr];
			BOOL sizeCheck=[self shouldAnalyzeSongBySizeCheck:urlStr];
			if(!checkValue&&sizeCheck)
			[self processSongFile:urlStr];
		}
	}
     DUBUG_LOG(@"Now you are completed iterateMyFolderForBPMAnalysisByFolder method in JiwokMyMusicPanelViewController class");
}

- (void)iterateMyFolderForBPMAnalysis:(NSMutableDictionary *)item
{
	 DUBUG_LOG(@"Now you are in iterateMyFolderForBPMAnalysis method in JiwokMyMusicPanelViewController class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	DUBUG_LOG(@"iterateMyFolderForBPMAnalysis %@ bstopAnalyzeFlag is %d",item,bstopAnalyzeFlag);	
	
	if (bstopAnalyzeFlag == YES)
	{
		[btnCancel setHidden:YES];
		[btnCancel setImage:[NSImage imageNamed:@"noimage.png"]];		
		
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
		
		[analysisProgress setHidden:YES];
		[animationImage setHidden:YES];

		
		return;
	}
	
	
	// Newly added to display the progress bar and button
	else{
		
		NSString *imageNameCancel = [[NSString alloc] initWithFormat:@"cancel_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
		[btnCancel setImage:[NSImage imageNamed:imageNameCancel]];
		[imageNameCancel release];
		
		
		[btnCancel setHidden:NO];
		[progressBar startAnimation:self];
		//[progressBar setHidden:NO];
		
		[progressBar setHidden:YES];
		
		[analysisProgress setHidden:NO];
		
		[animationImage setHidden:NO];


				
	}
	
	
	
	
	//DUBUG_LOG(@"iterateMyFolderForBPMAnalysis");
	
	
	NSString *itemPath = [item objectForKey:NAME_KEY];
	
	// check for specific songs/vocal folder. if so exit
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *localVocalPath = [bundlePath  stringByAppendingPathComponent:@"Vocals"];
	NSString *localSPPath = [bundlePath  stringByAppendingPathComponent:@"SpecificSongs"];
	
	if ([itemPath isEqualToString:localVocalPath] || [itemPath isEqualToString:localSPPath])
	{
		return;
	}
	
	//	//NSLog(@" itemPath BPM analysis %@ ",itemPath);	
	
	if ([JiwokUtil isvalidFolder:itemPath] )
	{
		//NSLog(@" itemPath BPM analysis %@ 111",itemPath);	
		
		if (![JiwokUtil isSkipItemPackage:itemPath])
		{
			
			BOOL shouldProcessFile=NO;
			
			NSArray *checkFolder=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:itemPath];
			 NSLog(@"checkFolder NSArray==%@",checkFolder);
			if ([checkFolder count]>0)					
			{							
				NSString *checkValue=[[checkFolder objectAtIndex:0] objectForKey:@"Selected"];				
				
				if([checkValue isEqualToString:@"true"])				 
				{
					shouldProcessFile=YES;
				}
			}
			else {
				shouldProcessFile =YES;
			}

			DUBUG_LOG(@"shouldProcessFile shouldProcessFile shouldProcessFile %d",shouldProcessFile);	
			
			//NSLog(@" itemPath BPM analysis %@ 2222 ",itemPath);				
			//NSString *checkValue = [item objectForKey:CHECK_KEY];
			
			
			if(shouldProcessFile)
			{
			NSArray * children = [item objectForKey:CHILD_KEY];	
			[children retain];
			 NSLog(@"children NSArray==%@",children);	
			//NSLog(@"children %@",children);
				
				
			NSArray *childrenUsingFileManager = [fileManager contentsOfDirectoryAtPath:itemPath error:nil];
						
			 NSLog(@"childrenUsingFileManager NSArray==%@",childrenUsingFileManager);	
				//NSLog(@"childrenUsingFileManager %@",childrenUsingFileManager);

				
			if(([children count]>0)&&([childrenUsingFileManager count]>0))
			
				// Added on 30th april
				//if(([children count]>0)||([childrenUsingFileManager count]>0))
				{			
				
				
				if ((children) || ([children count] > 1)) 
				{							
					NSArray *files = [fileManager contentsOfDirectoryAtPath:itemPath error:nil];					
					
					NSLog(@"files %@",files);
					
					for (NSString *element in files)
					{						
						NSString *urlStr = [itemPath stringByAppendingPathComponent:element];
						
						processesFileSize+=[[[fileManager attributesOfItemAtPath:urlStr error:NULL] objectForKey:NSFileSize] intValue];						
						[analysisProgress setDoubleValue:processesFileSize];
						
						NSString *extension = [urlStr pathExtension];						
						if([extension isEqualToString:@"m4a"]||[extension isEqualToString:@"mp3"])
						{						
						BOOL checkValue=[self checkFileInDatabase:urlStr];
						BOOL sizeCheck=[self shouldAnalyzeSongBySizeCheck:urlStr];
							
						if(!checkValue&&sizeCheck)
						[self processSongFile:urlStr];							
						}
					}
					@try {
					
					for (NSMutableDictionary *element in children)
					{
						
						[self iterateMyFolderForBPMAnalysis:element];

					}
					}
					@catch (NSException * e) {
						
						NSLog(@"EXCEPTION %@",[e description]);
					}
					@finally {
						
					}
						
//						[self iterateMyFolderForBPMAnalysis:element];
					
				}
				else // leaf nodes
				{		
					
					NSArray *files = [fileManager contentsOfDirectoryAtPath:itemPath error:nil];					
					 NSLog(@"files NSArray==%@",files);	
					for (NSString *element in files)
					{
						NSString *urlStr = [itemPath stringByAppendingPathComponent:element];
						
						processesFileSize+=[[[fileManager attributesOfItemAtPath:urlStr error:NULL] objectForKey:NSFileSize] intValue];						
						[analysisProgress setDoubleValue:processesFileSize];
						
						NSString *extension = [urlStr pathExtension];						
						if([extension isEqualToString:@"m4a"]||[extension isEqualToString:@"mp3"])
						{
							
						BOOL checkValue=[self checkFileInDatabase:urlStr];
						BOOL sizeCheck=[self shouldAnalyzeSongBySizeCheck:urlStr];
						
							if(!checkValue&&sizeCheck)
						[self processSongFile:urlStr];
						
						}
						
					}
										
				}	
				
			}			
			//if([files count]>0)&&(![element isEqualToString:@".DS_Store"])			
			else if(([children count]==0)&&([childrenUsingFileManager count]>0))
			{						
				for (NSString *element in childrenUsingFileManager)
				{					
					NSString *urlStr = [itemPath stringByAppendingPathComponent:element];					
					NSArray *files = [fileManager contentsOfDirectoryAtPath:urlStr error:nil];
					 NSLog(@"files NSArray==%@",files);						
					if(([files count]>0)&&(![element isEqualToString:@".DS_Store"]))
					{						
						NSMutableDictionary *parent = [[[NSMutableDictionary alloc] init]autorelease];
						[parent setObject:urlStr forKey:NAME_KEY];
						[parent setObject:[fileManager displayNameAtPath:element] forKey:DESC_KEY];
						[parent setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];		
						 NSLog(@"parent NSMutableDictionary==%@",parent);			
												
						[self iterateMyFolderForBPMAnalysis:parent];						
					}
					
					else{						
						
						//	NSString *urlStr = [itemPath stringByAppendingPathComponent:element];					
						NSString *extension = [urlStr pathExtension];
						
						processesFileSize+=[[[fileManager attributesOfItemAtPath:urlStr error:NULL] objectForKey:NSFileSize] intValue];						
						[analysisProgress setDoubleValue:processesFileSize];						
						
						if([extension isEqualToString:@"m4a"]||[extension isEqualToString:@"mp3"])
						{
							BOOL checkValue=[self checkFileInDatabase:urlStr];
							BOOL sizeCheck=[self shouldAnalyzeSongBySizeCheck:urlStr];
							
							if(!checkValue&&sizeCheck)
							[self processSongFile:urlStr];
						}
						
					}
					
				}
				
			}
				
			
				[children release];	
				
			
			}
			
		}
	}
	
	[pool release];
   // NSLog(@"Now you are completed iterateMyFolderForBPMAnalysis method in JiwokMyMusicPanelViewController class");
}



- (void)iterateMyFolder:(NSString *)itemPath: (NSMutableDictionary *) parent
{
	////NSLog(@" itemPath  %@ parent %@",itemPath,parent);
	DUBUG_LOG(@"Now you are in iterateMyFolder method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"iterateMyFolder %@ ",parent);
	
	NSArray *files = [fileManager contentsOfDirectoryAtPath:itemPath error:nil];
     NSLog(@"files NSArray==%@",files);
	for (NSString *element in files)
	{
		// we need to reconstruct the full path of the object since 'directoryContentsAtPath' only gives us the object name
		NSString *urlStr = [itemPath stringByAppendingPathComponent:element];
		if ([JiwokUtil isvalidFolder:urlStr] )
		{
			if (![JiwokUtil isSkipItemPackage:urlStr])
			{
				BOOL bFoundInDB = NO;
				NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr];
				if ([selectedValuesArray count] > 0)
				{
					bFoundInDB = YES;
				}
				
				
				
				// node item
				NSMutableDictionary *nodeitem = [[[NSMutableDictionary alloc] init] autorelease];
				
				NSMutableArray *children =  [parent objectForKey:CHILD_KEY]; 
                NSLog(@"children NSMutableArray==%@",children);
				if (children  && [children count] > 0)
				{
					//NSLog(@" adding to child array  %@",element);
					[nodeitem setObject:urlStr forKey:NAME_KEY];
					[nodeitem setObject:[[NSFileManager defaultManager] displayNameAtPath:urlStr] forKey:DESC_KEY];
					[nodeitem setObject:[parent objectForKey:CHECK_KEY] forKey:CHECK_KEY];
					
					//[nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
					
					
					//For checking
					//[children addObject:nodeitem];
					
					//NSLog(@" adding to child array  %@",urlStr);
					 NSLog(@"nodeitem NSMutableDictionary==%@",nodeitem);
					
					NSArray *selectedArray=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr];
					 NSLog(@"selectedArray NSArray==%@",selectedArray);
					if ([selectedArray count]>0)					
					{							
						NSString *checkValue=[[selectedArray objectAtIndex:0] objectForKey:@"Selected"];
						
						//NSLog(@"CHILD NOT ADDED 111 >>>> |%@|",checkValue);
						
						if([checkValue isEqualToString:@"true"])
						[children addObject:nodeitem];	
						else {
							//NSLog(@"CHILD NOT ADDED");
						}
					}	
					
					else {
						[children addObject:nodeitem];	
					}

					
					
				}
				else
				{
					
					
					
					NSMutableArray *childArray = [[[NSMutableArray alloc] init] autorelease];
					[nodeitem setObject:urlStr forKey:NAME_KEY];
					[nodeitem setObject:[[NSFileManager defaultManager] displayNameAtPath:urlStr] forKey:DESC_KEY];
					[nodeitem setObject:[parent objectForKey:CHECK_KEY] forKey:CHECK_KEY];
					
					//[nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
					
					// Old code
					//[parent setObject:childArray forKey:CHILD_KEY];						
					//[childArray addObject:nodeitem];
					
					NSString *childPath=[nodeitem objectForKey:NAME_KEY];
					
					
					//NSLog(@" creating child array  %@",childArray);
					
					NSArray *selectedFolders=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:childPath];
					 NSLog(@"selectedFolders NSArray==%@",selectedFolders);
					if ([selectedFolders count]>0)					
					{							
						NSString *checkValue=[[selectedFolders objectAtIndex:0] objectForKey:@"Selected"];
						
						///NSLog(@"CHILD NOT ADDED 111 >>>> |%@|",checkValue);
						
						if([checkValue isEqualToString:@"true"])
						{
							//[children addObject:nodeitem];	
							[parent setObject:childArray forKey:CHILD_KEY];						
							[childArray addObject:nodeitem];
						
						}
							else {
						//	NSLog(@"CHILD NOT ADDED");
						}
					}		
					else {
						[parent setObject:childArray forKey:CHILD_KEY];						
						[childArray addObject:nodeitem];
					}

					
					
				}
				
				
				
				NSLog(@"parent NSMutableDictionary==%@",parent);
			
				
				
				
				
				
				/*
				 
				 // node item
				 NSMutableDictionary *nodeitem = [[[NSMutableDictionary alloc] init] autorelease];
				 if (bFoundInDB)
				 {
				 NSMutableDictionary *settingsDict = [selectedValuesArray objectAtIndex:0];
				 
				 NSMutableArray *children =  [parent objectForKey:CHILD_KEY]; 
				 if (children  && [children count] > 0)
				 {
				 ////NSLog(@" adding to child array  %@",element);
				 [nodeitem setObject:urlStr forKey:NAME_KEY];
				 [nodeitem setObject:[fileManager displayNameAtPath:urlStr] forKey:DESC_KEY];
				 if (settingsDict)
				 {
				 if (bFoundInDB)
				 {
				 [nodeitem setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
				 [children addObject:nodeitem];
				 }
				 else
				 {
				 [nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
				 }
				 }
				 else
				 {
				 [nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
				 }
				 ////san
				 }
				 else // leaf nodes
				 {
				 ////NSLog(@" creating child array  %@",itemPath);
				 NSMutableArray *childArray = [[[NSMutableArray alloc] init] autorelease];
				 [nodeitem setObject:urlStr forKey:NAME_KEY];
				 [nodeitem setObject:[fileManager displayNameAtPath:urlStr] forKey:DESC_KEY];
				 NSMutableDictionary *settingsDict = [selectedValuesArray objectAtIndex:0];
				 if (settingsDict)
				 {
				 if (bFoundInDB)
				 {
				 [nodeitem setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
				 [childArray addObject:nodeitem];
				 }
				 else
				 {
				 [nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
				 }
				 
				 }
				 else
				 {
				 [nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
				 }
				 [parent setObject:childArray forKey:CHILD_KEY];	
				 ///san
				 }
				 }
				 
				 
				 */
				////NSLog(@" Visbile normal items  %@",urlStr);
				//[self iterateMyFolder:urlStr:nodeitem];
			}
		}
	}
    DUBUG_LOG(@"Now you are completed iterateMyFolder method in JiwokMyMusicPanelViewController class");
}

- (void)populateFolderTree
{
    DUBUG_LOG(@"Now you are in populateFolderTree method in JiwokMyMusicPanelViewController class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DUBUG_LOG(@"populateFolderTree   bAnalyseSongs is %d",bAnalyseSongs);
	
	
	@try
	{
		
		[txtStatus setStringValue:JiwokLocalizedString(@"INFO_CHECKING_FOLDERS")];
		
		[[LoggerClass getInstance] logData:@"checking folders"];
		
		[delegate didStartIteration];
		bSearchingInPanel = YES;
		//[progressBar setHidden:NO];
		[progressBar setHidden:YES];
		[progressBar startAnimation:self];
	
		if(analysingInProgress)
		[analysisProgress setHidden:NO];

		/*
		 
		 NSArray *drives = [[NSWorkspace sharedWorkspace]mountedLocalVolumePaths];	
		 
		 
		 if (drives)
		 {
		 if (treedataStore)
		 {
		 [treedataStore release];
		 treedataStore = nil;
		 }
		 treedataStore = [[NSMutableArray alloc] init];
		 
		 for (NSString * item in drives)
		 {
		 ////NSLog(@" itemmm ---> %@",[[NSFileManager defaultManager] displayNameAtPath:item]);
		 if ([JiwokUtil isNetworkMountAtPath:item])
		 {
		 DUBUG_LOG(@"network drive skipping  "); 
		 continue;
		 }
		 
		 NSMutableDictionary *parent = [[NSMutableDictionary alloc] init];
		 [parent setObject:item forKey:NAME_KEY];
		 [parent setObject:[fileManager displayNameAtPath:item] forKey:DESC_KEY];
		 [parent setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
		 
		 DUBUG_LOG(@"parent parent parent \n is %@  ",[fileManager displayNameAtPath:item]); 
		 
		 
		 BOOL bFoundInDB = NO;
		 NSArray * selectedValuesArray;
		 if([item isEqualToString:@"/"])
		 {
		 selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkVolumeForselection:@"/"];
		 }
		 else					
		 
		 selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkVolumeForselection:item];
		 
		 if ([selectedValuesArray count] > 0)
		 {
		 //NSLog(@"path is %@",selectedValuesArray);
		 
		 
		 bFoundInDB = YES;
		 }
		 
		 ////NSLog(@"RESULT IS %d   treedataStore is %@",bFoundInDB,treedataStore);				
		 //NSLog(@"bFoundInDB bFoundInDB bFoundInDB is %d  item item is %@  parent parent %@",bFoundInDB,item,parent);
		 
		 
		 */
		
		
		NSArray *drives = [[NSWorkspace sharedWorkspace]mountedLocalVolumePaths];	
		NSLog(@"drives NSArray==%@",drives);		
		
		NSArray *selectedFolders=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetallUserSelectedFolders];
		NSLog(@"selectedFolders NSArray==%@",selectedFolders);
		
		if (Roots)
		{
			[Roots release];
			Roots = nil;
		}
		
	
		//NSMutableArray *Roots=[[NSMutableArray alloc]init];
		
		Roots=[[NSMutableArray alloc]init];
		
		for(NSString *folder in selectedFolders)
		{					
			NSString *parentLink;			
			int i=0;
			
			for(NSString * volume in drives)
			{				
				if([volume isEqualToString:folder])
					i++;				
			}
						
			if(i>0)
				parentLink=folder;
			else				
				parentLink=[folder stringByDeletingLastPathComponent];
						
			NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:parentLink];			
			NSLog(@"selectedValuesArray NSArray==%@",selectedValuesArray);
			if(i>0)
				[Roots addObject:folder];
			else	if([selectedValuesArray count]==0)
				[Roots addObject:folder];
					
		}
			NSLog(@"Roots NSArray==%@",Roots);
		
		totalSizeInSelectedFolders=0;
		processesFileSize=0;		
		
		for(int i=0;i<[Roots count];i++)
		totalSizeInSelectedFolders+=[self fastFolderSize:[Roots objectAtIndex:i]];
				
		[analysisProgress setMaxValue:totalSizeInSelectedFolders];
		[analysisProgress setMinValue:processesFileSize];
			
		if (treedataStore)
		{
			[treedataStore release];
			treedataStore = nil;
		}
		treedataStore = [[NSMutableArray alloc] init];
		
		for (NSString * item in Roots)
		{			
			NSMutableDictionary *parent = [[NSMutableDictionary alloc] init];
			[parent setObject:item forKey:NAME_KEY];			
			[parent setObject:[fileManager displayNameAtPath:item] forKey:DESC_KEY];
			[parent setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];		
			NSLog(@"parent NSMutableDictionary==%@",parent);
			[self iterateMyFolder:item : parent];		
			[treedataStore addObject:parent];			
			[parent release];			
		}
			
		
		[outlineView reloadData];
		[delegate didCompleteIteration];
		bSearchingInPanel = NO;
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
		
		[analysisProgress setHidden:YES];

		
		////
		if (bAnalyseSongs)
		{
			//[self analyseSongs];			
			//if(shouldAnalyzeSongs)
			[NSThread detachNewThreadSelector:@selector(analyseSongs) toTarget:self withObject:nil];			
		}
		
		
		[[LoggerClass getInstance] logData:@"checking folders complete"];
		
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch populateFolderTree  ");
		[[LoggerClass getInstance] logData:@"Exception occured in populateFolderTree %@",[ex description]];
	}
	@finally 
	{
		DUBUG_LOG(@"@finally populateFolderTree  ");
		
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
		
		[analysisProgress setHidden:YES];

		
		[txtStatus setStringValue:JiwokLocalizedString(@"INFO_CHECKING_FOLDERS_COMPLETE")];
		
		
		DUBUG_LOG(@"@finally populateFolderTree 1");
	}
	
	DUBUG_LOG(@"	@finally populateFolderTree   After pool release");
	
	
	[pool release];
	DUBUG_LOG(@"Now you are completed populateFolderTree method in JiwokMyMusicPanelViewController class");
	
}

- (void)dealloc 
{
    
	DUBUG_LOG(@"dealloc for music panel view ");
	[searchloadwindow release];
	searchloadwindow = nil;
	[treedataStore release];
	[tempMusicData release];
	[failedMusicData release];
	[fpclient release];
	[super dealloc];
}
- (NSString *) checkAndGetJiwokGenre:(NSString *) id3Genre
{
   DUBUG_LOG(@"Now you are in checkAndGetJiwokGenre method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"checkAndGetJiwokGenre  id3Genre is %@  bstopAnalyzeFlag is %d",id3Genre,bstopAnalyzeFlag);
	return [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getJiwokMusicalGenre:id3Genre];
    //NSLog(@"Now you are completed checkAndGetJiwokGenre method in JiwokMyMusicPanelViewController class");
}

- (void) insertMusicAfterLastFM:(NSMutableDictionary *) dict
{
   DUBUG_LOG(@"Now you are in insertMusicAfterLastFM method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"insertMusicAfterLastFM %@",[dict objectForKey:DB_KEY_FILEPATH]);	
	//DUBUG_LOG(@"insertMusicAfterLastFM dict %@",dict);	
	
	NSMutableDictionary * dbdict = [[NSMutableDictionary alloc]init];
	[dbdict setObject:DB_VAL_FALSE forKey:DB_KEY_ACTIVE];
	
	if([dict objectForKey:keyArtist])
	[dbdict setObject:[dict objectForKey:keyArtist] forKey:DB_KEY_ARTIST];
	if([dict objectForKey:keyAlbum])
	[dbdict setObject:[dict objectForKey:keyAlbum] forKey:DB_KEY_ALBUM];
	if([dict objectForKey:ID3_TAG_BPM])
	[dbdict setObject:[dict objectForKey:ID3_TAG_BPM] forKey:DB_KEY_BPM];
	if([dict objectForKey:DB_KEY_DURATION])
	[dbdict setObject:[dict objectForKey:DB_KEY_DURATION] forKey:DB_KEY_DURATION];
	if([dict objectForKey:DB_KEY_FILEPATH])
	[dbdict setObject:[[dict objectForKey:DB_KEY_FILEPATH] lastPathComponent] forKey:DB_KEY_FILENAME];
	if([dict objectForKey:DB_KEY_FILEPATH])
	[dbdict setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];
	if([dict objectForKey:DB_KEY_GENRE])
	[dbdict setObject:[dict objectForKey:DB_KEY_GENRE] forKey:DB_KEY_GENRE];
	if([dict objectForKey:DB_KEY_JIWOK_GENRE])
	[dbdict setObject:[dict objectForKey:DB_KEY_JIWOK_GENRE]  forKey:DB_KEY_JIWOK_GENRE];
	[dbdict setObject:DB_VAL_FALSE forKey:DB_KEY_SELECTED];
	if([dict objectForKey:keyTitle])
	[dbdict setObject:[dict objectForKey:keyTitle] forKey:DB_KEY_TITLE];
	if([dict objectForKey:keyTrack])
	[dbdict setObject:[dict objectForKey:keyTrack] forKey:DB_KEY_TRACK];
	[dbdict setObject:DB_VAL_USAGE_ONE forKey:DB_KEY_USAGE];
	NSLog(@"dict NSMutableDictionary==%@",dict);
	NSLog(@"dbdict NSMutableDictionary==%@",dbdict);
	//Newly added to prevent insertion of music without jiwok genre	
	if(([[dict objectForKey:DB_KEY_JIWOK_GENRE] length]>2)&&(![[dict objectForKey:keyArtist] isEqualToString:@"Jiwok"]))		
	{
		//[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertOrUpdateMusicFiles:dbdict];
		
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertMusicFiles:dbdict];

		
		
		NSString *urlStr = [dict objectForKey:DB_KEY_FILEPATH];
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteMusicFilesTemp:urlStr];		
	}
	
	[dbdict release];
     DUBUG_LOG(@"Now you are completed insertMusicAfterLastFM method in JiwokMyMusicPanelViewController class");
}

- (void) insertMusicTempAfterLastFM:(NSMutableDictionary *) dict
{
     DUBUG_LOG(@"Now you are in insertMusicTempAfterLastFM method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"insertMusicTempAfterLastFM %@",[dict objectForKey:DB_KEY_FILEPATH]);
	///
	
	//DUBUG_LOG(@"insertMusicTempAfterLastFM dict %@",dict);
	
	///
	[dict setObject:@"nil" forKey:ID3_TAG_GENRE];// genre is not obtained so nil
	NSMutableDictionary * dbdict = [[NSMutableDictionary alloc]init];
	[dbdict setObject:DB_VAL_FALSE forKey:DB_KEY_ACTIVE];
	
	[dbdict setObject:[dict objectForKey:keyArtist] forKey:DB_KEY_ARTIST];
	[dbdict setObject:[dict objectForKey:keyAlbum] forKey:DB_KEY_ALBUM];
	[dbdict setObject:[dict objectForKey:ID3_TAG_BPM] forKey:DB_KEY_BPM];
	[dbdict setObject:[dict objectForKey:DB_KEY_DURATION] forKey:DB_KEY_DURATION];
	[dbdict setObject:[[dict objectForKey:DB_KEY_FILEPATH] lastPathComponent] forKey:DB_KEY_FILENAME];
	[dbdict setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];

	
	
	
	NSString *extension = [[dict objectForKey:DB_KEY_FILEPATH] pathExtension];
	
	if ([extension isEqualToString:@"m4a"])
		[dbdict setObject:[dict objectForKey:M4A_ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
	else						
		[dbdict setObject:[dict objectForKey:ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
		
	//[dbdict setObject:[dict objectForKey:ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
	
	[dbdict setObject:[dict objectForKey:DB_KEY_JIWOK_GENRE]  forKey:DB_KEY_JIWOK_GENRE];
	[dbdict setObject:DB_VAL_FALSE forKey:DB_KEY_SELECTED];
	[dbdict setObject:[dict objectForKey:keyTitle] forKey:DB_KEY_TITLE];
	[dbdict setObject:[dict objectForKey:keyTrack] forKey:DB_KEY_TRACK];
	[dbdict setObject:DB_VAL_USAGE_ONE forKey:DB_KEY_USAGE];
	
	//NSLog(@"dictionary isisis %@",dbdict);
	NSLog(@"dict NSMutableDictionary==%@",dict);
	NSLog(@"dbdict NSMutableDictionary==%@",dbdict);
	if(![[dict objectForKey:ID3_TAG_ARTIST] isEqualToString:@"Jiwok"])
	
	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertOrUpdateMusicFilesTemp:dbdict];
	
	[dbdict release];
    DUBUG_LOG(@"Now you are completed insertMusicTempAfterLastFM method in JiwokMyMusicPanelViewController class");
	
}
- (void) doMusicFilesTemp:(NSMutableDictionary *) dict:(unsigned int) duration:(NSString *) filePath:(NSString *) jiwok_genre
{
    DUBUG_LOG(@"Now you are in doMusicFilesTemp method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"doMusicFilesTemp  %@",dict);
	
	if ([[dict objectForKey:keyArtist] isEqualToString:@""] || [dict objectForKey:keyArtist] == nil)
	{
		[dict setObject:@"nil" forKey:keyArtist];
	}
	
	if ([[dict objectForKey:keyAlbum] isEqualToString:@"" ] || [dict objectForKey:keyAlbum] == nil)
	{
		[dict setObject:@"nil" forKey:keyAlbum];
	}
	
	if ([[dict objectForKey:ID3_TAG_BPM] isEqualToString:@""] || [dict objectForKey:ID3_TAG_BPM] == nil)
	{
		[dict setObject:@"nil" forKey:ID3_TAG_BPM];
	}
	
	
	if ([[dict objectForKey:keyTrack] isEqualToString:@""] || [dict objectForKey:keyTrack] == nil)
	{
		[dict setObject:@"nil" forKey:keyTrack];
	}
	
	if ([[dict objectForKey:keyTitle] isEqualToString:@""] || [dict objectForKey:keyTitle] == nil)
	{
		[dict setObject:@"nil" forKey:keyTitle];
	}
	
	
	BOOL IfCondition;
	
	NSString *extension = [[dict objectForKey:DB_KEY_FILEPATH] pathExtension];
	
	if ([extension isEqualToString:@"m4a"])
	{
		IfCondition=([[dict objectForKey:M4A_ID3_TAG_GENRE] isEqualToString:@""] || [dict objectForKey:M4A_ID3_TAG_GENRE] == nil);		
	if(IfCondition)
	{		
		[dict setObject:@"nil" forKey:M4A_ID3_TAG_GENRE];	
		
	}
	}
	
	else
	{
			IfCondition=([[dict objectForKey:ID3_TAG_GENRE] isEqualToString:@""] || [dict objectForKey:ID3_TAG_GENRE] == nil);
		if(IfCondition)
		[dict setObject:@"nil" forKey:ID3_TAG_GENRE];
		
	}
		
	[self insertMusicTempAfterLastFM:dict];// same as inserting after failed last fm cases
    DUBUG_LOG(@"Now you are completed doMusicFilesTemp method in JiwokMyMusicPanelViewController class");
}
- (void) processSongFile:(NSString *) filePath
{
    DUBUG_LOG(@"Now you are in processSongFile method in JiwokMyMusicPanelViewController class");
	if(!bstopAnalyzeFlag)
	{
	NSString *extension = [filePath pathExtension];
	//NSString *tempfilePath = filePath;
	
		//processesFileSize+=[[[fileManager attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileSize] intValue];
		
	DUBUG_LOG(@"processSongFile1  %@  extension is %@ size is %lld",filePath,extension,processesFileSize);
	
	
		[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_SONGS")];
		
	//float bmp1;

	
	////NSLog(@"bmp1 bmp1 bmp1 bmp1 bmp1 %f",bmp1);
	
//	[analysisProgress setDoubleValue:processesFileSize];
	
	
	
	BOOL bInsertTempDB = NO ;
	unsigned int duration = 0;
	if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"m4a"])		
	{
		
		numberOfSongsAnalyzed++;
		
		NSString *tempfilePath=[[NSString alloc]init];
		
		if ([extension isEqualToString:@"m4a"])
		{
			//NSString *
			
			tempfilePath = filePath;
			
			JiwokMusicConverter *convObj = [[JiwokMusicConverter alloc]init];
			[convObj convertToMp3:filePath];
			tempfilePath = [[filePath stringByDeletingPathExtension]stringByAppendingPathExtension:@"mp3"];
			[convObj release];
		}	
					
		
		JiwokFfmpegID3TagReader *tagReader = [[JiwokFfmpegID3TagReader alloc]init];
		NSMutableDictionary * dict;		
		
		if ([extension isEqualToString:@"m4a"])
			dict = [tagReader getID3TagInfoOfAac:filePath];
		else
			dict = [tagReader getID3TagInfo:filePath];
		
		[tagReader release];
		
		//NSLog(@"TAG READ IS %@",dict);
		
		if (dict == nil || [dict count] <= 0)
		{
			return;
		}
		
		
		NSString *genre ;//= [dict objectForKey:ID3_TAG_GENRE];
		
		if ([extension isEqualToString:@"m4a"])
			genre = [dict objectForKey:M4A_ID3_TAG_GENRE];
			else 
		genre = [dict objectForKey:ID3_TAG_GENRE];
		
				
		
		NSString *jiwok_genre = @"";
		if (![genre isEqualToString:@""])
		{
			if ([genre rangeOfString:@"Other"].location == NSNotFound)
			{
				NSRange range = [genre rangeOfString:@"("];
				if (range.length > 0)
				{
					genre = [genre substringToIndex:range.location];
				}
				
				jiwok_genre = [self checkAndGetJiwokGenre:genre];
				
				////NSLog(@" dict cnt jiwok_genre is %@",jiwok_genre);
			}
		}
		
		
		if([[dict objectForKey:ID3_TAG_ARTIST] isEqualToString:@"Jiwok"]||[[dict objectForKey:ID3_TAG_ARTIST] isEqualToString:@" Jiwok"])
		{		
			
		return;
			
		}		
		
		if ([extension isEqualToString:@"m4a"])
		{			
			// Newly added to prevent crashing
			if([fileManager fileExistsAtPath:tempfilePath])
			{
				// pass converted wav file path
				JiwokFMODUtil *utilObj = [[JiwokFMODUtil alloc]init];
				duration = [utilObj getDuration:tempfilePath];
				[utilObj release];				
			}
			
		}
		else // mp3
		{
			////NSLog(@" File %@ ",filePath);
			JiwokFMODUtil *utilObj = [[JiwokFMODUtil alloc]init];
			duration = [utilObj getDuration:filePath];
			[utilObj release];
		}
			
		
		NSMutableDictionary * dbdict = [[NSMutableDictionary alloc]init];
		
		do
		{				
			keyArtist = ID3_TAG_ARTIST;
			keyAlbum = ID3_TAG_ALBUM;
			keyTrack = ID3_TAG_TRACK;
			keyTitle = ID3_TAG_TITLE;
			
			
			if ([extension isEqualToString:@"m4a"])
			{
				keyArtist = M4A_ID3_TAG_ARTIST;
				keyAlbum = M4A_ID3_TAG_ALBUM;
				keyTrack = M4A_ID3_TAG_TRACK;
				keyTitle = M4A_ID3_TAG_TITLE;
			}
			
			
			
			
			
			DUBUG_LOG(@"DO OD OD OD >>>>>%@>>>>>>>>>%@>>>>>>>>>%@>>>>>>>>>>%@",keyArtist,keyAlbum,keyTrack,keyTitle);

				
			/*
			if ([[dict objectForKey:keyArtist] isEqualToString:@""] || [dict objectForKey:keyArtist] == nil)
			{
				bInsertTempDB = YES;
				break;
			}
			
			if ([[dict objectForKey:keyAlbum] isEqualToString:@"" ] || [dict objectForKey:keyAlbum] == nil)
			{
				//NSLog(@"NO NO NON ALBUM");
				
				bInsertTempDB = YES;
				break;
			}
			
			
			//NSLog(@"NO NO NON ALBUM 1");

			*/
			
			if ([[dict objectForKey:ID3_TAG_BPM] isEqualToString:@""] || [dict objectForKey:ID3_TAG_BPM] == nil)
			{								
				if ([extension isEqualToString:@"m4a"])
				{
				/*
					JiwokMusicConverter *convObj = [[JiwokMusicConverter alloc]init];
					[convObj convertToWav:tempfilePath];
					[convObj release];
					
					*/
					
					/*
					JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
					[musicProcessor ChangeOutputFormat:filePath:@"mp3"];
					[musicProcessor release];
					
					*/
										
					//Wavefilepath = [[filePath stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"];
			}
				
				float bpm=0;
				
				if ([extension isEqualToString:@"mp3"])
				{
	
					
					BpmCalculator *bpmCalculator = [[BpmCalculator alloc]init];
					//float 
					bpm = [[bpmCalculator GetBpm:filePath] floatValue];			
					[bpmCalculator release];
					
					
				}
				else if ([extension isEqualToString:@"m4a"])
				{									
					BpmCalculator *bpmCalculator = [[BpmCalculator alloc]init];
					//float 
					bpm = [[bpmCalculator GetBpm:tempfilePath] floatValue];			
					[bpmCalculator release];
					
					
				}
				
				if(bpm>180)
					bpm/=2;
							
				
				// delete wav file after getting BPM
				if ([extension isEqualToString:@"m4a"])
					if ( [fileManager fileExistsAtPath: tempfilePath] )
					{
						
						if (![fileManager removeFileAtPath: tempfilePath handler: nil])
						{
						
							[[LoggerClass getInstance] logData:@"processSongFile --> unable to delete file  %@",tempfilePath];
						
						}
						 
					}
											
				
				if(bpm <= 0.0)// still bpm is not found
				{
					DUBUG_LOG(@"if(bpm <= 0.0)  ");
					
					bInsertTempDB = YES;
					break;
				}
				NSString *bpmString = [NSString  stringWithFormat:@"%f",bpm];
				[dict setObject: bpmString forKey:ID3_TAG_BPM];
				
				//bInsertTempDB = YES;
				//break;
				
			}
						
			
			
			if ([[dict objectForKey:keyArtist] isEqualToString:@""] || [dict objectForKey:keyArtist] == nil)
			{
				bInsertTempDB = YES;
				break;
			}
			
			if ([[dict objectForKey:keyAlbum] isEqualToString:@"" ] || [dict objectForKey:keyAlbum] == nil)
			{
				////NSLog(@"NO NO NON ALBUM");
				
				bInsertTempDB = YES;
				break;
			}	
			
			
			if ([[dict objectForKey:keyTrack] isEqualToString:@""] || [dict objectForKey:keyTrack] == nil)
			{
				bInsertTempDB = YES;
				break;
			}
			
			if ([[dict objectForKey:keyTitle] isEqualToString:@""] || [dict objectForKey:keyTitle] == nil)
			{
				bInsertTempDB = YES;
				break;
			}
						
			
			////NSLog(@"keyArtist %@ keyAlbum %@ keyTrack %@ keyTitle %@",[dict objectForKey:keyArtist], [dict objectForKey:keyAlbum], [dict objectForKey:keyTrack], [dict objectForKey:keyTitle]);
			
			BOOL IfCondition;
			
			
			NSString *extension = [[dict objectForKey:@"FILENAME"] pathExtension];
			
			if ([extension isEqualToString:@"m4a"])
				IfCondition=([[dict objectForKey:M4A_ID3_TAG_GENRE] isEqualToString:@""] || [dict objectForKey:M4A_ID3_TAG_GENRE] == nil);
			else						
				IfCondition= ([[dict objectForKey:ID3_TAG_GENRE] isEqualToString:@""] || [dict objectForKey:ID3_TAG_GENRE] == nil);
						
					
			if(IfCondition)				
			{
				bInsertTempDB = YES;				
				break;
			}
					
			
			
			// insert into musicfiles table only if it is not save no use
			if (![jiwok_genre isEqualToString:JIWOK_GENRE_SAVE_NO_USE])
			{
				
				//NSLog(@"IF IF IF ");
				
				[dbdict setObject:DB_VAL_FALSE forKey:DB_KEY_ACTIVE];
				[dbdict setObject:[dict objectForKey:keyArtist] forKey:DB_KEY_ARTIST];
				[dbdict setObject:[dict objectForKey:keyAlbum] forKey:DB_KEY_ALBUM];
				[dbdict setObject:[dict objectForKey:ID3_TAG_BPM] forKey:DB_KEY_BPM];
				
				[dbdict setObject:[NSString stringWithFormat:@"%d", duration] forKey:DB_KEY_DURATION];
				[dbdict setObject:[filePath lastPathComponent] forKey:DB_KEY_FILENAME];
				[dbdict setObject:filePath forKey:DB_KEY_FILEPATH];				
				
				NSString *extension = [[dict objectForKey:@"FILENAME"] pathExtension];
				
				if ([extension isEqualToString:@"m4a"])
					[dbdict setObject:[dict objectForKey:M4A_ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
				else						
				[dbdict setObject:[dict objectForKey:ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
				
				[dbdict setObject:jiwok_genre forKey:DB_KEY_JIWOK_GENRE];
				[dbdict setObject:DB_VAL_FALSE forKey:DB_KEY_SELECTED];
				[dbdict setObject:[dict objectForKey:keyTitle] forKey:DB_KEY_TITLE];
				[dbdict setObject:[dict objectForKey:keyTrack] forKey:DB_KEY_TRACK];
				[dbdict setObject:DB_VAL_USAGE_ONE forKey:DB_KEY_USAGE];
				
				
				DUBUG_LOG(@"insertOrUpdateMusicFiles after first analysis genre is |%@|",[dbdict objectForKey:DB_KEY_JIWOK_GENRE]);
				
				if(([[dbdict objectForKey:DB_KEY_JIWOK_GENRE] length]>2)&&(![[dict objectForKey:keyArtist] isEqualToString:@"Jiwok"]))
					[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertOrUpdateMusicFiles:dbdict];
				else if(![[dict objectForKey:keyArtist] isEqualToString:@"Jiwok"]) 
					
					[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertOrUpdateMusicFilesTemp:dbdict];
				
			}
		}while(0);
		
		NSLog(@"dict NSMutableDictionary==%@",dict);
        NSLog(@"dbdict NSMutableDictionary==%@",dbdict);
		
		if (bInsertTempDB == YES)
		{
			// do operations with bmpm if bpm 0 do not insert
			//NSString *bpm = [dict objectForKey:ID3_TAG_BPM];
			
			//NSLog(@" bpm bpm is %f",[bpm floatValue]); 
			
			//if (([bpm floatValue] != 0.0)||([bpm floatValue] != 0.000000))
			//{
				//NSLog(@"[bpm floatValue] [bpm floatValue] is %f  jiwok_genre is %@",[bpm floatValue],jiwok_genre);
				
				
				//[dbdict setObject:[filePath lastPathComponent] forKey:DB_KEY_FILENAME];
				//[dbdict setObject:filePath forKey:DB_KEY_FILEPATH];
				if(![jiwok_genre isEqualToString:@""])
				{
					//	[dbdict setObject:jiwok_genre forKey:DB_KEY_JIWOK_GENRE];
					[dict setObject:jiwok_genre forKey:DB_KEY_JIWOK_GENRE];
				}
				else
				{
					//	[dbdict setObject:@"nil" forKey:DB_KEY_JIWOK_GENRE];
					[dict setObject:@"nil" forKey:DB_KEY_JIWOK_GENRE];
				}
				//[tempMusicData addObject:dbdict];
				[failedMusicData addObject:dict];
				
			
			//[dict release];
				//nTempMusicFiles++;
				nFailedMusicFiles++;
				////NSLog(@" temp DB file %@",[dbdict objectForKey:DB_KEY_FILENAME]);
				
				[dict setObject:[NSString stringWithFormat:@"%d", duration] forKey:DB_KEY_DURATION];
				[dict setObject:filePath forKey:DB_KEY_FILEPATH];
				
				
				DUBUG_LOG(@"processSongFile  beginning doMusicFilesTemp dict %@",dict);
				
				[self doMusicFilesTemp:dict:duration:filePath:jiwok_genre];
			//}
		}
	}			
	
}
DUBUG_LOG(@"Now you are completed processSongFile method in JiwokMyMusicPanelViewController class");		
}
- (void)analyseSongs
{	
   DUBUG_LOG(@"Now you are in analyseSongs method in JiwokMyMusicPanelViewController class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DUBUG_LOG(@"analyseSongs btnCancel Hidden is %d",btnCancel.isHidden);
	@try
	{
		if(!workoutGenerationInProgress)
		{
			
			canDeleteFolder=NO;
			
			numberOfSongsAnalyzed=0;
			
			[[LoggerClass getInstance] logData:@"Analysing songs"];
			
			//[progressBar setHidden:NO];
			[progressBar setHidden:YES];
			[progressBar startAnimation:self];
			[btnCancel setHidden:NO];			
			
			[analysisProgress setHidden:NO];			
			[animationImage setHidden:NO];
			
			NSString *imageNameCancel = [[NSString alloc] initWithFormat:@"cancel_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
			[btnCancel setImage:[NSImage imageNamed:imageNameCancel]];
			[imageNameCancel release];
			
			//[self checkAndHandleItunesDirAndMydoc];
			
			
			DUBUG_LOG(@"analyseSongs btnCancel Hidden 111 is %d  %@",btnCancel.isHidden,btnCancel.image);

			
			[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_SONGS")];
			nTempMusicFiles = 0;
			nFailedMusicFiles = 0;
			if (tempMusicData)
			{
				[tempMusicData removeAllObjects];
			}
			if (failedMusicData)
			{
				//[failedMusicData release];
//				
//				failedMusicData = [[NSMutableArray alloc]init];

				
				if([failedMusicData count])
				[failedMusicData removeAllObjects];
				//[failedMusicData autorelease];
				
				//failedMusicData=[[NSMutableArray alloc]init];
			}
			if (treedataStore)
			{				
				for (NSMutableDictionary * item in treedataStore)
				{
					@try {
								
						
						// FOR TESTING 
//						for(int i=0;i<100;i++)
//							[self performSelectorInBackground:@selector(iterateMyFolderForBPMAnalysis:) withObject:item];
						
						
						[self iterateMyFolderForBPMAnalysis:item];
						
					

					}
					@catch (NSException * e) {
						NSLog(@"EXCEPTION %@",[e description]);
					}
					@finally {
						
					}
						
								
					//[self iterateMyFolderForBPMAnalysis:item];
				}
			}
			
			[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_COMPLETE")];
			
			//[[LoggerClass getInstance] logData:@"Analysing complete"];			
//			[[NSNotificationCenter defaultCenter] postNotificationName:ANALYSIS_COMPLETED object:nil];
		}
		
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch  Exception occured in analyseSongs");		
		
		[[LoggerClass getInstance] logData:@"Exception occured in analyseSongs %@",[ex description]];
		
		
	}
	@finally 
	{
		DUBUG_LOG(@"	@finally    occured in analyseSongs numberOfSongsAnalyzed is %d",numberOfSongsAnalyzed);
		
		
		[[LoggerClass getInstance] logData:@"Analysing complete"];			
		[[NSNotificationCenter defaultCenter] postNotificationName:ANALYSIS_COMPLETED object:nil];
		
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];
		
		[btnCancel setHidden:YES];
		[btnCancel setImage:[NSImage imageNamed:@"noimage.png"]];

		[progressBar setHidden:YES];
		[progressBar stopAnimation:self];
		
		[analysisProgress setHidden:YES];

		[animationImage setHidden:YES];

		canDeleteFolder=YES;
		
		DUBUG_LOG(@"	@finally    occured in analyseSongs 1");
		
		
		
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];	
		[appdelegate updateDockImage];
		
		
	//	
//		// To keep the thread alive
//		while(1){
//			
//		}
//		
		
	}
	
	DUBUG_LOG(@"	@finally    After pool release");
	
	
	[pool release];
	DUBUG_LOG(@"Now you are completed analyseSongs method in JiwokMyMusicPanelViewController class");
}


- (void)checkAndRemoveItunesDirAndMydoc:(NSString *)folderPath
{
   DUBUG_LOG(@"Now you are in checkAndRemoveItunesDirAndMydoc method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"checkAndRemoveItunesDirAndMydoc %@",folderPath);
	NSArray *files = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
	for (NSString *element in files)
	{
		continue;
		NSString *urlStr = [folderPath stringByAppendingPathComponent:element];
		NSString *extension = [urlStr pathExtension];
		if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"m4a"])
		{
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteMusicFiles:urlStr];
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteMusicFilesTemp:urlStr];
		}
	}
    DUBUG_LOG(@"Now you are completed checkAndRemoveItunesDirAndMydoc method in JiwokMyMusicPanelViewController class");
}


- (void)checkAndHandleItunesDirAndMydoc
{
    DUBUG_LOG(@"Now you are in checkAndHandleItunesDirAndMydoc alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"checkAndHandleItunesDirAndMydoc");
	
	NSString *mydocDir =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *itunesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Music/iTunes/iTunes Music"];	
	
	
	if ([[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkSearchSelectedFolderExists:mydocDir])
	{
		[self iterateMyFolderForBPMAnalysisByFolder:mydocDir];
	}
	else
	{
		[self checkAndRemoveItunesDirAndMydoc:mydocDir];
	}
	
	if ([[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkSearchSelectedFolderExists:itunesDir])
	{
		[self iterateMyFolderForBPMAnalysisByFolder:itunesDir];	
	}
	else
	{
		//[self checkAndRemoveItunesDirAndMydoc:itunesDir];
	}
	DUBUG_LOG(@"Now you are completed checkAndHandleItunesDirAndMydoc alone method in JiwokMyMusicPanelViewController class");
}

- (void)awakeFromNib
{
	//DUBUG_LOG(@"JiwokMyMusicPanelViewController -> analyseSongs delegate is %@",delegate);	
	
	//NSImage *myImage = [NSImage imageNamed: @"02.png"];	
	//[NSApp setApplicationIconImage: myImage];	
	
	//[NSApp setApplicationIconImage: nil];	

	//NSRect testRect;	
	//testRect = NSMakeRect (0, 0, 100, 200);
	
	
	//NSImageView *myImageView=[[NSImageView alloc] init];
	//[myImageView setImage:myImage];
	
	//[[NSApp dockTile] setContentView: myImageView];
	
	//[[NSApp dockTile] display];	
	//[[NSApp dockTile] setBadgeLabel:@"42222222222222222222222222"];
	
	
	
	
	
	///XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Original code
	NSLog(@"Now you are in awakeFromNib alone method in JiwokMyMusicPanelViewController class");
	tempMusicData = [[NSMutableArray alloc]init];
	
	failedMusicData = [[NSMutableArray alloc]init];
	
	fpclient = [[JiwokLastfmClient alloc]init];
	
	fileManager=[NSFileManager defaultManager];
	
	
	shouldAnalyzeSongs=NO;
	
//	//New code
//	isSearchWidowOpen=NO;

	
	NSString *imageNameCancel = [[NSString alloc] initWithFormat:@"cancel_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnCancel setImage:[NSImage imageNamed:imageNameCancel]];
	[imageNameCancel release];
	
	NSString *imageNameAddNew = [[NSString alloc] initWithFormat:@"addNewFolder_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
    NSLog(@"imageNameNew is %@",imageNameAddNew);
	[btnAddNew setImage:[NSImage imageNamed:imageNameAddNew]];
	[imageNameAddNew release];
	
	[txtStatus setStringValue:@" "];

	
	
	canDeleteFolder=YES;
	
	
	[selectedFoldersLabel setStringValue:JiwokLocalizedString(@"SELECTED_FOLDERS")];
	[musicDetection setStringValue:JiwokLocalizedString(@"MUSIC_AND_BPM")];
	
	
	[analysisProgress setHidden:YES];
	[animationImage setHidden:YES];

	
	
	int checkboxColumnIndex; 
    NSTableColumn *checkboxColumn = 
	[outlineView tableColumnWithIdentifier:CHECK_KEY]; 
    NSButtonCell *checkbox = [NSButtonCell new]; 
    [checkbox setButtonType:NSSwitchButton]; 
    [checkbox setTitle:@""]; 
	[checkbox setState:NSOnState];
    [checkbox setImagePosition:NSImageOnly]; 
    [checkboxColumn setDataCell:checkbox]; 
    checkboxColumnIndex = [outlineView columnWithIdentifier:CHECK_KEY]; 
    [outlineView moveColumn:checkboxColumnIndex toColumn:0]; 
	
	////////
	
	//	JiwokAnalysisSummaryWindowController *summayWindow = [JiwokAnalysisSummaryWindowController alloc];
	//	[summayWindow initWithWindowNibName:@"JiwokAnalysisSummaryWindow"];
	//	[summayWindow showWindow:self];
	//
	//	return;
	
	///////
	//[txtJiwokURL setAllowsEditingTextAttributes: YES];
	//	[txtJiwokURL setSelectable: YES];
	//		
	//	NSURL* url = [NSURL URLWithString:@"http://www.jiwok.com"];
	//	 	
	//	 NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
	//	 [string appendAttributedString: [NSAttributedString hyperlinkFromString:@"www.jiwok.com" withURL:url]];
	//	  	
	//	  [txtJiwokURL setAttributedStringValue: string];
	
	//////
	
	[txtJiwokURL setAllowsEditingTextAttributes: YES];
	
	NSDictionary *attributes
    = [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
       @"http://www.jiwok.com",NSLinkAttributeName,
       [NSFont systemFontOfSize:13], NSFontAttributeName,
       [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0],	  
       NSForegroundColorAttributeName,
       nil];
	
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:@"www.jiwok.com" attributes:attributes] autorelease];
    [txtJiwokURL setAttributedStringValue:attrString];
	[txtJiwokURL setEditable:NO];
	[txtJiwokURL setSelectable: YES];
	
	NSFont* font = [NSFont systemFontOfSize:13];
	[txtJiwokURL setFont:font];
	
	//[txtJiwokURL setAllowsEditingTextAttributes: NO];
	////
	
	
	//NSMutableAttributedString* attrstr =[[NSMutableAttributedString alloc]
	//										 initWithString:@"www.jiwok.com" ];
	//	NSRange selectedRange = { 0, [[txtJiwokURL stringValue] length] };
	//	
	//	[attrstr beginEditing];
	//	[attrstr addAttribute:NSLinkAttributeName value:@"http://www.jiwok.com" range:selectedRange];
	//	[attrstr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:selectedRange];
	//	[attrstr endEditing];
	//	
	//	[txtJiwokURL setAttributedStringValue:attrstr];
	
	////
	
	//////
	
	//	BOOL success;
	//	NSFileManager *fileManager = [NSFileManager defaultManager];
	//	NSError *error;
	//	
	//	NSString *filepath = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"lastfmfpclient"];
	//	success = [fileManager fileExistsAtPath:filepath];
	//	if (!success) 
	//	{
	//	NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lastfmfpclient"];
	//	
	//	//NSLog(@"from info %@",defaultPath);
	//		//NSLog(@"to path info %@",filepath);
	//	
	//	success = [fileManager copyItemAtPath:defaultPath toPath:filepath error:&error];
	//	}
	/////
	////NSLog(@"calling fpclient");
	//	NSString *filePath = @"/samplemusic/01September123.mp3";
	//	JiwokLastfmClient *fpclient = [[JiwokLastfmClient alloc]init];
	//	NSArray * artistInfo = [fpclient getArtists:filePath];	// get artist info (artist and album title)
	//	//NSLog(@"artist info %@",artistInfo);
	
	//[self performSelectorOnMainThread:@selector(testLastFM) toTarget:self withObject:nil];
	//[self performSelectorOnMainThread:@selector(testLastFM) withObject:nil waitUntilDone:YES];
	//[self performSelectorOnMainThread:@selector(runLastFMGetAlbumTopTag) withObject:nil waitUntilDone:YES];
	
	
	// register notification for changes in current path
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	//Adding observer for getting current path changed notification
	[notificationCenter addObserver:self  selector:@selector(didFinishAnalysis) 
							   name:ANALYSIS_COMPLETED object:nil];
	
	[notificationCenter addObserver:self selector:@selector(didFinishGetAlbumTopTag:) name:@"GetAlbumTopTagFinished" object:nil];
	[notificationCenter addObserver:self selector:@selector(DidFinishGetArtistTopTag:) name:@"GetArtistTopTagFinished" object:nil];
	
	[notificationCenter addObserver:self selector:@selector(startGetAlbumTopTag:) name:@"GetAlbumTopTagStarted" object:nil];
	//////
	
	
	//[fpclient GetArtistTopTag:@"Earth, Wind & Fire"];
	//[fpclient GetAlbumTopTag:@"Madonna":@"Hung Up"];
	//return;
	///////
	
	
	
	[self CheckAndUpdateUserSelectedFolders];
	
	/*
	 NSArray *UserSelectedFolders=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetallUserSelectedFolders];	
	 
	 NSString *filePath;
	 
	 for (int i=0; i<[UserSelectedFolders count]; i++) {
	 
	 filePath=[UserSelectedFolders objectAtIndex:i];
	 //NSLog(@"selectedValuesArray selectedValuesArray is %@",filePath);		
	 
	 if([fileManager fileExistsAtPath:filePath])			
	 {
	 
	 }
	 else {						
	 [[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:filePath];			
	 }				
	 }	
	 */
	
	
	//////
	BOOL bFoundInDB = NO;
	bFoundInDB = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] isAnyUserFoldersSelected];
	
	if (bFoundInDB)
	{
		[NSThread detachNewThreadSelector:@selector(populateFolderTree) toTarget:self withObject:nil];
		//[self populateFolderTree];
	}
	
	
	//NSLog(@"AWAKE FROM NIB");
	
	//	[NSThread detachNewThreadSelector:@selector(startGetAlbumTopTag:) toTarget:self withObject:nil];
	/////
	//[self startGetAlbumTopTag:nil];
	
	//[fpclient GetAlbumTopTag:@"Madonna":@"Hung Up"];
	
	//[fpclient GetArtistTopTag:@"Earth, Wind & Fire"];
   DUBUG_LOG(@"Now you are completed awakeFromNib alone method in JiwokMyMusicPanelViewController class");
}



-(void)CheckAndUpdateUserSelectedFolders
{
    DUBUG_LOG(@"Now you are in CheckAndUpdateUserSelectedFolders alone method in JiwokMyMusicPanelViewController class");
	NSArray *UserSelectedFolders=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetallUserSelectedFolders];		
	NSString *filePath;
	
	for (int i=0; i<[UserSelectedFolders count]; i++) {
		
		filePath=[UserSelectedFolders objectAtIndex:i];
		
		if([fileManager fileExistsAtPath:filePath])			
		{
			
		}
		else {						
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:filePath];	
			
			//[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:filePath];
		}				
	}
	DUBUG_LOG(@"Now you are completed CheckAndUpdateUserSelectedFolders alone method in JiwokMyMusicPanelViewController class");
}



-(void)runLastFMGetAlbumTopTag
{
	//BOOL done = NO;
	//	
	//	[NSRunLoop currentRunLoop];
	//
	//	
	//	[fpclient GetAlbumTopTag:[tempDict objectForKey:keyArtist]:[tempDict objectForKey:keyTitle]];
	//	
	//	do {
	//		SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES);
	//		if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
	//			done = YES;
	//		}
	//	} while (!done);
	DUBUG_LOG(@"Now you are in runLastFMGetAlbumTopTag alone method in JiwokMyMusicPanelViewController class");
	[fpclient GetAlbumTopTag:[tempDict objectForKey:keyArtist]:[tempDict objectForKey:keyTitle]];
	DUBUG_LOG(@"Now you are completed runLastFMGetAlbumTopTag alone method in JiwokMyMusicPanelViewController class");
	
	//[fpclient GetAlbumTopTag:@"Madonna":@"Hung Up"];
}

-(void)startGetAlbumTopTag:(NSNotification*)notification 
{
	
	//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DUBUG_LOG(@"Now you are in startGetAlbumTopTag alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"startGetAlbumTopTag");
	//[fpclient GetAlbumTopTag:@"Madonna":@"Hung Up"];
	
	
	//[self doLastFMAnalysis];	
	if (fpclient && tempDict)
	{
		
		static pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
		if (pthread_mutex_lock(&mtx)) {
			DUBUG_LOG(@"lock failed sigh...");
			exit(-1);
		}
		
		////////
		//@synchronized(self) 
		//{
			[self performSelectorOnMainThread:@selector(runLastFMGetAlbumTopTag) withObject:nil waitUntilDone:YES];
			//[self runLastFMGetAlbumTopTag];
		//}
		
		if (pthread_mutex_unlock(&mtx) != 0) {
			DUBUG_LOG(@"unlock failed sigh...");
			exit(-1);
		}
		
	}
	//	[pool release];
	DUBUG_LOG(@"Now you are completed startGetAlbumTopTag alone method in JiwokMyMusicPanelViewController class");
}
-(void)DidFinishGetArtistTopTag:(NSNotification*)notification 
{
    DUBUG_LOG(@"Now you are in DidFinishGetArtistTopTag alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"DidFinishGetArtistTopTag");
	
	////NSLog(@"DidFinishGetArtistTopTag  object is %@",[notification object]);
	NSArray *toptagsArray = (NSArray *)[notification object];
	
	DUBUG_LOG(@"[topTags count nnnnn] %d", [toptagsArray count]);
	DUBUG_LOG(@"Now you are completed DidFinishGetArtistTopTag alone method in JiwokMyMusicPanelViewController class");
	
}

-(void)didFinishGetAlbumTopTag:(NSNotification*)notification 
{
    DUBUG_LOG(@"Now you are in didFinishGetAlbumTopTag alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"didFinishGetAlbumTopTag ");
	 DUBUG_LOG(@"Now you are completed didFinishGetAlbumTopTag alone method in JiwokMyMusicPanelViewController class");
	//NSLog(@"didFinishGetAlbumTopTag  object is %@",[notification object]);
	//NSArray *toptagsArray = (NSArray *)[notification object];
	
}

-(void)doLastFMAnalysis
{
     DUBUG_LOG(@"Now you are in doLastFMAnalysis alone method in JiwokMyMusicPanelViewController class");
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[analysisProgress setMaxValue:[failedMusicData count]];	
	
	DUBUG_LOG(@"doLastFMAnalysis");
	@try
	{
		[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_SONGS")];
		[progressBar startAnimation:self];
		//[progressBar setHidden:NO];
		[progressBar setHidden:YES];
		
		[analysisProgress setHidden:NO];
		[animationImage setHidden:NO];
		
		for (int index = 0 ;index < [failedMusicData count] ; index++)
		{
			if(!bstopAnalyzeFlag){			
				
				[analysisProgress setDoubleValue:index];
				
			NSMutableDictionary *dict = [failedMusicData objectAtIndex:index];
			[dict retain];
				
			// for last fm processing
			DUBUG_LOG(@"Genre %@ for file %@",[dict objectForKey:ID3_TAG_GENRE],[dict objectForKey:DB_KEY_FILEPATH]);			
			DUBUG_LOG(@"dict %@",dict);			
						
				BOOL IfCondition;				
			
				// Old Code			
			//if ([[dict objectForKey:DB_KEY_FILEPATH] isEqualToString:@"m4a"])				
//				IfCondition=([[dict objectForKey:M4A_ID3_TAG_GENRE] isEqualToString:@"nil"] || [dict objectForKey:M4A_ID3_TAG_GENRE] == nil);			
//			else			
//				IfCondition=([[dict objectForKey:ID3_TAG_GENRE] isEqualToString:@"nil"] || [dict objectForKey:ID3_TAG_GENRE] == nil);					
			
				
				
				if ([[dict objectForKey:DB_KEY_FILEPATH] isEqualToString:@"m4a"])				
					IfCondition=([[dict objectForKey:DB_KEY_JIWOK_GENRE] isEqualToString:@"nil"] || [dict objectForKey:DB_KEY_JIWOK_GENRE] == nil);			
				else			
					IfCondition=([[dict objectForKey:DB_KEY_JIWOK_GENRE] isEqualToString:@"nil"] || [dict objectForKey:DB_KEY_JIWOK_GENRE] == nil);					
				
				
				
				
				
			if(IfCondition)			
			{
				NSString *artist = @"";				
				artist = [dict objectForKey:keyArtist];				
				
				NSString *album = @"";		
				//Old code
				//album = [dict objectForKey:keyAlbum];	
				
				album = [dict objectForKey:keyTrack];	

				
				
				
				DUBUG_LOG(@"artist = %@",artist);				
				DUBUG_LOG(@"album = %@",album);
				
				if (artist != nil && ![artist isEqualToString:@"nil"]  && album != nil && ![album isEqualToString:@"nil"] )
				{
					NSArray *toptagsArray =  [fpclient GetAlbumTopTag:artist:album];
					
					if ([toptagsArray count] > 0)
					{
						for (int index = 0 ;index < [toptagsArray count] ; index++)
						{
							// get genre , jiwok genre and update in music files
							NSString * songGenre = [toptagsArray objectAtIndex:index];
							// set songGenre as from toptagsarray							
							
							//NSString *extension = [filePath pathExtension];							
							NSString * jiwok_genre = [self checkAndGetJiwokGenre:songGenre];
							[dict setObject:jiwok_genre forKey:DB_KEY_JIWOK_GENRE];
							[dict setObject:songGenre forKey:DB_KEY_GENRE];
							
							DUBUG_LOG(@"doLastFMAnalysis inserting dict %@ ", dict);		
							
							
							[self insertMusicAfterLastFM:dict];
						}
					}
					else
					{
						DUBUG_LOG(@"doLastFMAnalysis inserting to array 1");
						///
						NSMutableDictionary *dbdict = [[NSMutableDictionary alloc]init];
						[dbdict setObject:[[dict objectForKey:DB_KEY_FILEPATH] lastPathComponent] forKey:DB_KEY_FILENAME];
						[dbdict setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];					
						
						NSString *extension = [[dict objectForKey:DB_KEY_FILEPATH] pathExtension];
						
						if ([extension isEqualToString:@"m4a"])
							[dbdict setObject:[dict objectForKey:M4A_ID3_TAG_GENRE] forKey:DB_KEY_GENRE];

							else							
						[dbdict setObject:[dict objectForKey:ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
						
						///
						nTempMusicFiles++;						
						DUBUG_LOG(@"doLastFMAnalysis inserting to array 1  dbdict is %@",dbdict);
						
						[tempMusicData addObject:dbdict];
						[dbdict release];	
					}
				}
				else if (artist == nil || [artist isEqualToString:@"nil"])// if no artist in id3v2
				{					
					NSString *title = @"";
					NSString *outputName=[[NSString alloc]init];
					NSArray * artistInfo;
				
					NSString *extCheck =[[dict objectForKey:DB_KEY_FILEPATH] substringFromIndex:([[dict objectForKey:DB_KEY_FILEPATH] length]-3)];
					if([extCheck isEqualToString:@"m4a"])
					{									
						NSString *extension =@"mp3";
						NSString *outputPath =[[dict objectForKey:DB_KEY_FILEPATH] substringToIndex:([[dict objectForKey:DB_KEY_FILEPATH] length]-4)];
						NSString *outputName=[NSString stringWithFormat:@"%@.%@",outputPath,extension];
													
						//JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
//						[musicProcessor ChangeOutputFormat:[dict objectForKey:DB_KEY_FILEPATH]:@"mp3"];
//						[musicProcessor release];
						
						
						JiwokMusicConverter *convObj = [[JiwokMusicConverter alloc]init];
						[convObj convertToMp3:[dict objectForKey:DB_KEY_FILEPATH]];
						[convObj release];
						
						 artistInfo = [fpclient getArtists:outputName];
												
						[[NSFileManager defaultManager]removeItemAtPath:outputName error:nil];						
					}
					else
					{
						 artistInfo = [fpclient getArtists:[dict objectForKey:DB_KEY_FILEPATH]];
					}
															
						// get artist info (artist and album title)
					if ([artistInfo count] > 0 )
					{
						DUBUG_LOG(@"Artist by last FM  %@",artistInfo);
						
						NSMutableDictionary * dictArtist = [artistInfo objectAtIndex:0];
						artist = [dictArtist objectForKey:@"name"];// artist name
						if (artist != nil && ![artist isEqualToString:@""])
						{
							[dict setObject:artist forKey:keyArtist];
							tempArtist = [NSString stringWithString:artist];
						}
						title = [dictArtist objectForKey:@"title"];// album
						
						if (title != nil && ![title isEqualToString:@""])
						{
							[dict setObject:title forKey:keyTitle];
						}
						
						//DUBUG_LOG(@"dict after lastfm set  %@",dict);
						
					}
					
					if (![artist isEqualToString:@""] && artist != nil)// if got artist and album after fpcleint execution
					{
						NSArray *toptagsArray =  [fpclient GetAlbumTopTag:artist:title];
						
						if ([toptagsArray count] > 0)
						{
							for (int index = 0 ;index < [toptagsArray count] ; index++)
							{
								// get genre , jiwok genre and update in music files
								NSString * songGenre = [toptagsArray objectAtIndex:index];
								// set songGenre as from toptagsarray
								NSString * jiwok_genre = [self checkAndGetJiwokGenre:songGenre];
								[dict setObject:jiwok_genre forKey:DB_KEY_JIWOK_GENRE];
								[dict setObject:songGenre forKey:DB_KEY_GENRE];
								
								DUBUG_LOG(@"doLastFMAnalysis inserting dict %@ ", dict);
								[self insertMusicAfterLastFM:dict];
							}
						}
						else
						{
							DUBUG_LOG(@"doLastFMAnalysis inserting to array 2");
							///
							NSMutableDictionary *dbdict = [[NSMutableDictionary alloc]init];
							[dbdict setObject:[[dict objectForKey:DB_KEY_FILEPATH] lastPathComponent] forKey:DB_KEY_FILENAME];
							[dbdict setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];
							
							
							
							NSString *extension = [[dict objectForKey:DB_KEY_FILEPATH] pathExtension];
							
							if ([extension isEqualToString:@"m4a"])
								[dbdict setObject:[dict objectForKey:M4A_ID3_TAG_GENRE] forKey:DB_KEY_GENRE]	;
								else								
							[dbdict setObject:[dict objectForKey:ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
							
							
							///
							nTempMusicFiles++;
							//NSMutableDictionary * dictTemp = [[NSMutableDictionary alloc]initWithDictionary:dict  copyItems:YES];
							[tempMusicData addObject:dbdict];
							[dbdict release];	
						}
						/*	else // not getting genre by getalbum top tags, then call getartisttop tag
						 {
						 DUBUG_LOG(@"didFinishGetAlbumTopTag calling  GetArtistTopTag");
						 if (![tempArtist isEqualToString:@""])
						 {
						 [fpclient GetArtistTopTag:tempArtist];
						 }
						 }*/
						
						//tempDict = dict;
						///[[NSNotificationCenter defaultCenter] postNotificationName:@"GetAlbumTopTagStarted" object:nil];
						
						
						
						//DUBUG_LOG(@" tempDict dict after lastfm set  %@",tempDict);
						//tempduration = [dict objectForKey:DB_KEY_DURATION];
						//tempfilePath = [dict objectForKey:DB_KEY_FILEPATH];
						//tempjiwok_genre = [dict objectForKey:DB_KEY_JIWOK_GENRE];
					}
					
					////NSLog(@"outputName outputName %@",outputName);
					
					if([[NSFileManager defaultManager] fileExistsAtPath:outputName])
					
					[[NSFileManager defaultManager] removeFileAtPath:outputName handler: nil];
					
					[outputName release];
					
				}
				else
				{
					
					DUBUG_LOG(@"doLastFMAnalysis inserting with temp dict ");
					
					NSArray *toptagsArray = [fpclient GetArtistTopTag:artist];
					//tempArtist = artist;
					if ([toptagsArray count] > 0)
					{
						for (int index = 0 ;index < [toptagsArray count] ; index++)
						{
							// get genre , jiwok genre and update in music files
							NSString * songGenre = [toptagsArray objectAtIndex:index];
							// set songGenre as from toptagsarray
							NSString * jiwok_genre = [self checkAndGetJiwokGenre:songGenre];
							[dict setObject:jiwok_genre forKey:DB_KEY_JIWOK_GENRE];
							[dict setObject:songGenre forKey:DB_KEY_GENRE];
							
							DUBUG_LOG(@"doLastFMAnalysis inserting with temp dict %@",dict);
							
							[self insertMusicAfterLastFM:dict];
						}
						
					}
					else // not getting genre (failed to get genre in all cases by tagreader and last FM )
					{
						DUBUG_LOG(@"doLastFMAnalysis inserting to array 3");
						///
						NSMutableDictionary *dbdict = [[NSMutableDictionary alloc]init];
						[dbdict setObject:[[dict objectForKey:DB_KEY_FILEPATH] lastPathComponent] forKey:DB_KEY_FILENAME];
						[dbdict setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];
						
						
						
						NSString *extension = [[dict objectForKey:DB_KEY_FILEPATH] pathExtension];
						
						if ([extension isEqualToString:@"m4a"])
							[dbdict setObject:[dict objectForKey:M4A_ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
							
							else
								
								
								[dbdict setObject:[dict objectForKey:ID3_TAG_GENRE] forKey:DB_KEY_GENRE];
						
						NSLog(@"dict NSMutableDictionary==%@",dict);
                        NSLog(@"dbdict NSMutableDictionary==%@",dbdict);
						///
						nTempMusicFiles++;
						//NSMutableDictionary * dictTemp = [[NSMutableDictionary alloc]initWithDictionary:dict  copyItems:YES];
						[tempMusicData addObject:dbdict];
						[dbdict release];	
						//[self insertMusicTempAfterLastFM:tempDict];
					}
				}
			}
				
				[dict release];

				
		}
		}
		
		
		[btnCancel setHidden:YES];
		[btnCancel setImage:[NSImage imageNamed:@"noimage.png"]];

		
		
		DUBUG_LOG(@"if(nTempMusicFiles is %d",nTempMusicFiles);
		
		
		//if(nTempMusicFiles > 0)
//		{
//			DUBUG_LOG(@"if(nTempMusicFiles > 0)");
//			
//			
//			JiwokAnalysisSummaryWindowController *summayWindow = [JiwokAnalysisSummaryWindowController alloc];
//			[summayWindow initWithWindowNibName:@"JiwokAnalysisSummaryWindow" andlist:tempMusicData];
//			
//			DUBUG_LOG(@"if(nTempMusicFiles > 0) After initWithWindowNibName ");
//			
//			[summayWindow showWindow:self];
//		}
//		else {
//			
//			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
//			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];
//		}
//
//		
		
		
		
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in doLastFMAnalysis %@",[ex description]];
	}
	@finally 
	{
		
		[analysisProgress setDoubleValue:[failedMusicData count]];

		[analysisProgress setHidden:YES];

		
		[appdelegate UpdateTagDetectedGenres];

		
		
		if(nTempMusicFiles > 0)
		{
			DUBUG_LOG(@"if(nTempMusicFiles > 0)");
			
			if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_IMPROOVE_ANALYSIS"):JIWOK_ALERT_YES_NO])
			{
			JiwokAnalysisSummaryWindowController *summayWindow = [JiwokAnalysisSummaryWindowController alloc];
			[summayWindow initWithWindowNibName:@"JiwokAnalysisSummaryWindow" andlist:tempMusicData];			
			DUBUG_LOG(@"if(nTempMusicFiles > 0) After initWithWindowNibName ");
			
			[summayWindow showWindow:self];
			}
		}
		//else {
//			
//			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
//			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];
//		}
		
		
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];

		
		
		DUBUG_LOG(@"@finally");
		
		[progressBar stopAnimation:self];
		DUBUG_LOG(@"@finally 1");
		[progressBar setHidden:YES];
		
		[analysisProgress setHidden:YES];
		[animationImage setHidden:YES];


		
		DUBUG_LOG(@"@finally 2");
		[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_COMPLETE")];
		DUBUG_LOG(@"@finally 3");
		//[appdelegate UpdateTagDetectedGenres];
		analysingInProgress = NO;
		
		GrowlExample *growlMsger=[[GrowlExample alloc]init];
		[growlMsger growlAlert:JiwokLocalizedString(@"FINISHED_ANALYSIS_POPUP") title:nil];
		[growlMsger release];
		
		
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];	
		[appdelegate updateDockImage];
		
		
	}
	//	[pool release];
    DUBUG_LOG(@"Now you are completed doLastFMAnalysis alone method in JiwokMyMusicPanelViewController class");
}

-(void)didFinishAnalysis
{
    DUBUG_LOG(@"Now you are in didFinishAnalysis alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"didFinishAnalysis %d",nFailedMusicFiles);
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	
	// Newly added to hide the button
	[btnCancel setHidden:YES];
	[btnCancel setImage:[NSImage imageNamed:@"noimage.png"]];

	[animationImage setHidden:YES];
	
	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];
	
	[analysisProgress setDoubleValue:totalSizeInSelectedFolders];
	
	[analysisProgress setHidden:YES];
	
	
	[appdelegate UpdateTagDetectedGenres];
	
	if(appdelegate.isLogged == YES)
	{
				
		if (nFailedMusicFiles > 0)
		{
			//if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_IMPROOVE_ANALYSIS"):JIWOK_ALERT_YES_NO])// OK selected
			//{
				[btnCancel setHidden:NO];
				
				NSString *imageNameCancel = [[NSString alloc] initWithFormat:@"cancel_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
				[btnCancel setImage:[NSImage imageNamed:imageNameCancel]];
				[imageNameCancel release];
				
				if(!bstopAnalyzeFlag)
				[self doLastFMAnalysis];
			
			
				//[NSThread detachNewThreadSelector:@selector(doLastFMAnalysis) toTarget:self withObject:nil];
			//}
		//	else
//			{
//				[analysisProgress setHidden:YES];
//				[animationImage setHidden:YES];
//
//				
//				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
//				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];
//
//				
//				GrowlExample *growlMsger=[[GrowlExample alloc]init];
//				[growlMsger growlAlert:JiwokLocalizedString(@"FINISHED_ANALYSIS_POPUP") title:nil];
//				[growlMsger release];
//				
//				
//				
//				//[appdelegate UpdateTagDetectedGenres];
//				analysingInProgress =NO;
//				
//				JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];	
//				[appdelegate updateDockImage];
//			}
		}
		else
		{
			[analysisProgress setHidden:YES];
			[animationImage setHidden:YES];


			
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];

			
			GrowlExample *growlMsger=[[GrowlExample alloc]init];
			[growlMsger growlAlert:JiwokLocalizedString(@"FINISHED_ANALYSIS_POPUP") title:nil];
			[growlMsger release];
			
			
			//[appdelegate UpdateTagDetectedGenres];
			analysingInProgress =NO;
			
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];	
			[appdelegate updateDockImage];
		}
		
	}
	DUBUG_LOG(@"Now you are completed didFinishAnalysis alone method in JiwokMyMusicPanelViewController class");
}


-(void)didAddFolder
{
    DUBUG_LOG(@"Now you are in didAddFolder alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"didAddFolder");
	//[progressBar setHidden:NO];
	[progressBar setHidden:YES];
	[progressBar startAnimation:self];
	
	[analysisProgress setHidden:NO];
	
	
	[animationImage setHidden:NO];
	
	[btnCancel setHidden:NO];
	
	
	GrowlExample *growlMsger=[[GrowlExample alloc]init];
	[growlMsger growlAlert:JiwokLocalizedString(@"ANALYZING_SONGS_POPUP") title:nil];
	//[growlMsger growlAlertWithClickContext:@"Detection started" title:@"Music Detection started"];
	[growlMsger release];
	
	//[NSThread detachNewThreadSelector:@selector(populateFolderTree) toTarget:self withObject:nil];
	
	//for checking Lastfm
	//[self doLastFMAnalysis];
	
	bAnalyseSongs = YES;
	analysingInProgress =YES;
	
	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	[appdelegate updateDockImage];
	
	
	
	[NSThread detachNewThreadSelector:@selector(populateFolderTree) toTarget:self withObject:nil];
	 DUBUG_LOG(@"Now you are completed didAddFolder alone method in JiwokMyMusicPanelViewController class");
}

-(void)relaunchMusicDetection:(NSNotification *)notification{

	//NSLog(@"relaunchMusicDetection relaunchMusicDetection");

}


-(void)searchWindowClosed{
     DUBUG_LOG(@"Now you are in searchWindowClosed alone method in JiwokMyMusicPanelViewController class");
	isSearchWidowOpen=NO;	
    DUBUG_LOG(@"Now you are completed searchWindowClosed alone method in JiwokMyMusicPanelViewController class");

}

-(void)displayTreeAutomatically{

	//NSLog(@"displayTreeAutomatically displayTreeAutomatically displayTreeAutomatically");
	
	//[self performSelector:@selector(addFolderAction:)];

}
-(BOOL)checkFileInDatabase:(NSString *)folderPath
{
     DUBUG_LOG(@"Now you are in checkFileInDatabase alone method in JiwokMyMusicPanelViewController class");
	BOOL musicCheck=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkForMusicFiles:folderPath];
	BOOL tempCheck=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkForMusicFilesTemp:folderPath];
	//return(musicCheck&&tempCheck);
	DUBUG_LOG(@"Now you are completed checkFileInDatabase alone method in JiwokMyMusicPanelViewController class");
	return(musicCheck||tempCheck);
	
	//return(musicCheck);


}

-(IBAction)cancelAction:(id)sender
{
   DUBUG_LOG(@"Now you are in cancelAction alone method in JiwokMyMusicPanelViewController class");
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	bstopAnalyzeFlag = YES;
	[appdelegate UpdateTagDetectedGenres];
	analysingInProgress =NO;
	DUBUG_LOG(@"Now you are completed cancelAction alone method in JiwokMyMusicPanelViewController class");
	// Not required
	//[appdelegate updateDockImage];
}
-(IBAction)addFolderAction:(id)sender
{	
	DUBUG_LOG(@"Now you are in addFolderAction alone method in JiwokMyMusicPanelViewController class");
	DUBUG_LOG(@"addFolderAction");
	
		
	DUBUG_LOG(@"isSearchWidowOpen = %d analysingInProgress=%d canDeleteFolder= %d",isSearchWidowOpen,analysingInProgress,canDeleteFolder);

//	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
//
//	
//	for(int i=0;i<10000;i++)
//	
//		[appdelegate performSelectorInBackground:@selector(UpdateStatusOfMusicFiles) withObject:nil];
	
	
	
	
	//if ((bSearchingInPanel)||(isSearchWidowOpen)||(analysingInProgress))

	// Added on may 3
	//if ((isSearchWidowOpen)||(analysingInProgress))
	if ((isSearchWidowOpen)||(analysingInProgress)||(!canDeleteFolder))

	{
		DUBUG_LOG(@"searching in progress");
		return;
	}
	else {
		
	bstopAnalyzeFlag=NO;
	
		isSearchWidowOpen=YES;
		
	// show music search window
	searchloadwindow = [JiwokMusicalSearchWindowController alloc];
	[searchloadwindow initWithWindowNibName:@"JiwokMusicalSearchWindow"];
	searchloadwindow.delegate = self;
	[searchloadwindow showWindow:self];
	//[searchloadwindow autorelease];
	}
	DUBUG_LOG(@"Now you are completed addFolderAction alone method in JiwokMyMusicPanelViewController class");	
}

#pragma mark  NSOutlineView data source methods
- (void) syncStatusinDB:(id)item:( NSString *) checkValue
{
    DUBUG_LOG(@"Now you are in syncStatusinDB alone method in JiwokMyMusicPanelViewController class");
	@try{
	
	NSString * urlPath = [item objectForKey:NAME_KEY];
	
	DUBUG_LOG(@"syncStatusinDB checkValue and urlPath %@, %@",checkValue,urlPath);
	//DUBUG_LOG(@"syncStatusinDB checkValue and item %@, %@",checkValue,item);	
	
	BOOL bFoundInDB = NO;
	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlPath];
	if ([selectedValuesArray count] > 0)
	{
		bFoundInDB = YES;
	}
	
	//E:\FromCDs\FLASH 8
	if (bFoundInDB)
	{
		////NSLog(@" found in db ");
		NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
		[foldersDict setObject:urlPath forKey:DB_KEY_PATH];
		[foldersDict setObject:DB_VAL_FALSE forKey:DB_KEY_SELECTED];
		
        NSLog(@"foldersDict NSMutableDictionary==%@",foldersDict);
		if ([checkValue intValue] == 1) // 1 to 0
		{ 
			if([Roots indexOfObject:urlPath]==NSNotFound)
			{
				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] changeSelectionStatusOfUserSelectedFolders:urlPath];

			}
			else			
			{
				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:urlPath];
				
				//[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:urlPath];
			}
			
		}
	}
	else // not found in DB, so insert
	{
		if ([checkValue intValue] == 0) // 0 to 1
		{
			////NSLog(@"not found in db ");
			NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
			[foldersDict setObject:[urlPath lastPathComponent] forKey:DB_KEY_FOLDER_NAME];
			[foldersDict setObject:urlPath forKey:DB_KEY_PATH];
			[foldersDict setObject:DB_VAL_TRUE forKey:DB_KEY_SELECTED];
			 NSLog(@"foldersDict NSMutableDictionary==%@",foldersDict);
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];
			[foldersDict release];
		}
	}
	
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in syncStatusinDB %@",[ex description]];
	}
	DUBUG_LOG(@"Now you are completed syncStatusinDB alone method in JiwokMyMusicPanelViewController class");
}
- (void) checkUncheckItem:(id)item:(NSOutlineView *)ov:(id)object forTableColumn:(NSTableColumn *)tableColumn:( NSString *) checkValue
{	
    DUBUG_LOG(@"Now you are in checkUncheckItem alone method in JiwokMyMusicPanelViewController class");
	@try{		
		
	shouldAnalyzeSongs=NO;	
	
	DUBUG_LOG(@"checkUncheckItem ");
	NSString *theKey = [tableColumn identifier];
    GET_CHILDREN;
    if ((children) || ([children count] > 1)) 
	{
		////NSLog(@"selection check box for parent %@",checkValue);
		if ([theKey compare:CHECK_KEY] == NSOrderedSame) 
		{
			NSArray * children = [item objectForKey:CHILD_KEY];
			////NSLog(@"child %@",children);
			for (NSMutableDictionary *element in children)
			{
				[self checkUncheckItem:element:ov:object forTableColumn:tableColumn:checkValue];
			}
			if ([checkValue intValue] == 1)
			{
				[item setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
			}
			else
			{
				[item setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
			}
			[self syncStatusinDB:item:checkValue];
			[ov reloadItem:item reloadChildren:YES];
		} 		
	}
	else
	{
		if ([theKey compare:CHECK_KEY] == NSOrderedSame) 
		{			
			//[self checkUncheckItem:item:ov:object forTableColumn:tableColumn];
			////NSLog(@"selection check box for node %@",checkValue);
			if ([checkValue intValue] == 1)
			{
				/// changed from 1 to 0
				[item setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
			}
			else
			{
				/// changed from 0 to 1
				[item setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
			}
			[self syncStatusinDB:item:checkValue];
			[ov reloadItem:item reloadChildren:YES];
			
		}
	}
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkUncheckItem %@",[ex description]];
	}
     DUBUG_LOG(@"Now you are completed checkUncheckItem alone method in JiwokMyMusicPanelViewController class");
}


// required
- (id)outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item
{
	//DUBUG_LOG(@"outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item");
	
	DUBUG_LOG(@"Now you are in outlineView alone method in JiwokMyMusicPanelViewController class");
    // item is an NSDictionary...
    GET_CHILDREN;
    if ((!children) || ([children count] <= index)) return nil;
    return [children objectAtIndex:index];
    //NSLog(@"Now you are completed outlineView alone method in JiwokMyMusicPanelViewController class");
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
	//DUBUG_LOG(@"- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item %@",item);
	DUBUG_LOG(@"Now you are in (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item method in JiwokMyMusicPanelViewController class");
	BOOL returnValue=NO;
	
    GET_CHILDREN;
    if ((!children) || ([children count] < 1)) return NO;
	else {
		
		for(int i=0;i<[[item objectForKey:@"children"] count];i++)
		{
		
		NSString *urlStr=[[[item objectForKey:@"children"] objectAtIndex:i] objectForKey:NAME_KEY];
			
			NSArray *selectedFolders=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr];
			
	if ([selectedFolders count]>0)
	{
		
		NSString *checkValue=[[selectedFolders objectAtIndex:0] objectForKey:@"Selected"];
		if([checkValue isEqualToString:@"true"])
		{
			returnValue=YES;
		}
		
		else {
			
			//NSLog(@"EEEEEEEE");
		}
		
		
	}
		else {
			returnValue=YES;
		}
	
			
		}
			
    return returnValue;
		
		
	}
    //NSLog(@"Now you are completed (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item method in JiwokMyMusicPanelViewController class");
}

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
   DUBUG_LOG(@"Now you are in (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item method in JiwokMyMusicPanelViewController class");
	//DUBUG_LOG(@"- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item");
	
	
    GET_CHILDREN;
    return [children count];
   // NSLog(@"Now you are completed (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item method in JiwokMyMusicPanelViewController class");
}
- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)ov
{
   DUBUG_LOG(@"Now you are in selectionShouldChangeInOutlineView method in JiwokMyMusicPanelViewController class");
	return YES;
    //NSLog(@"Now you are completed selectionShouldChangeInOutlineView method in JiwokMyMusicPanelViewController class");
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
   DUBUG_LOG(@"Now you are in outlineViewSelectionDidChange method in JiwokMyMusicPanelViewController class");
	@try{
	
	//DUBUG_LOG(@"- (void)outlineViewSelectionDidChange:(NSNotification *)notification");	
	
	NSOutlineView				*outView			= [notification object];
	int							selectedRow			= [outView selectedRow];
	id							item				= [outView itemAtRow:selectedRow];
		
	NSString *itemPath = [item objectForKey:NAME_KEY];
	
	//	NSLog(@"item item item item is %@",item);
		
		
		if([[item objectForKey:CHECK_KEY] intValue]==1)
		{
		
	NSArray *files = [fileManager contentsOfDirectoryAtPath:itemPath error:nil];
	if (files)
	{
		if (detailTableData)
		{
			[detailTableData release];
		}
		detailTableData = [[NSMutableArray alloc]init];
		
		for (NSString *element in files)
		{
			NSString *extension = [element pathExtension];
			if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"m4a"])
			{
				JiwokFfmpegID3TagReader *tagReader = [[JiwokFfmpegID3TagReader alloc]init];
				NSString *urlStr = [itemPath stringByAppendingPathComponent:element];
				NSMutableDictionary * dict;// = [tagReader getID3TagInfo:urlStr];//am_1minute_v3 //@"/13September.mp3"
				////NSLog(@"tag -><<<<<<<<< %@",dict);
				
				
				
				if ([extension isEqualToString:@"m4a"])
					dict = [tagReader getID3TagInfoOfAac:urlStr];
				else
					dict = [tagReader getID3TagInfo:urlStr];							
				
				[detailTableData addObject:dict];
			}			
		}
		[detailTableView reloadData];
	}
		
	}
	
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in outlineViewSelectionDidChange %@",[ex description]];
	}
	DUBUG_LOG(@"Now you are completed outlineViewSelectionDidChange method in JiwokMyMusicPanelViewController class");
}


- (void)outlineViewItemWillExpand:(NSNotification *)notification{
	DUBUG_LOG(@"Now you are in outlineViewItemWillExpand method in JiwokMyMusicPanelViewController class");
	@try{
	
//	NSOutlineView				*outView			= [notification object];
//	int							selectedRow			= [outView rowForItem:[[notification userInfo] objectForKey:@"NSObject"]];
//	id							item				= [outView itemAtRow:selectedRow];
//	
//		DUBUG_LOG(@"outlineViewItemWillExpand id is %@",item);
		
	//NSString *itemPath = [item objectForKey:NAME_KEY];
			
	//           	[treedataStore removeObjectAtIndex:selectedRow];
		
		for(int i=0;i<[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] count];i++)
		{
			NSDictionary *child=[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i];
			
			if ([[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:[child objectForKey:@"NAME"]] count]==0)
			//if([child objectForKey:@"NAME"])
			{
			NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
			[foldersDict setObject:[child objectForKey:@"DESC"] forKey:DB_KEY_FOLDER_NAME];
			[foldersDict setObject:[child objectForKey:@"NAME"] forKey:DB_KEY_PATH];
			[foldersDict setObject:DB_VAL_TRUE forKey:DB_KEY_SELECTED];
			 NSLog(@"foldersDict NSMutableDictionary==%@",foldersDict);
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];
			[foldersDict release];	
			}	
		
		}
		
		
	
	for(int i=0;i<[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] count];i++)
	{
		//[[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i] objectForKey:@"NAME"]
		
	//	NSLog(@"CHILD ISZZZ %@",[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i]);

		
		
		[[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i] removeObjectForKey:@"children"];

		
		
		NSString *urlStr=[[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i] objectForKey:NAME_KEY];
		
		NSArray *seletedFolders=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr];
		
		if ([seletedFolders count]>0)
		{
		
			NSString *checkValue=[[seletedFolders objectAtIndex:0] objectForKey:@"Selected"];
			if([checkValue isEqualToString:@"true"])
			{
				[self iterateMyFolder:[[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i] objectForKey:@"NAME"]:[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i]];
	
				//NSLog(@"checkValue checkValue checkValue is %@",checkValue);
			}
			
			else {
				
				//NSLog(@"EEEEEEEE");
			}			
			}
	
		}
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in outlineViewItemWillExpand %@",[ex description]];
	}
	
	DUBUG_LOG(@"Now you are completed outlineViewItemWillExpand method in JiwokMyMusicPanelViewController class");
}


- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	//DUBUG_LOG(@"- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item");
	NSLog(@"Now you are in (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item method in JiwokMyMusicPanelViewController class");
	
    return [item objectForKey:[tableColumn identifier]];
   // NSLog(@"Now you are completed (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item method in JiwokMyMusicPanelViewController class");
}


- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{ 
   DUBUG_LOG(@"Now you are in (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item method in JiwokMyMusicPanelViewController class");
	@try{
	
	//DUBUG_LOG(@"setObjectValue OV object %@ item %@",object,item);
	
	//[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_SONGS")];
	
	//[progressBar setHidden:NO];
	[progressBar setHidden:YES];
	[progressBar startAnimation:self];	
		
		//[analysisProgress setHidden:NO];

		
	// This method handles changes to the items.
    NSString *theKey = [tableColumn identifier];
	NSString *oldValue = [item objectForKey:theKey];
	
		if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"REMOVE_FOLDER"):JIWOK_ALERT_YES_NO])
		{			
			
			
			if(analysingInProgress||!canDeleteFolder)
				{
					[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_ANALYZING_INPROGRESS"):JIWOK_ALERT_OK];
				}
			else{
				
			//	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] changeSelectionStatusOfUserSelectedFolders:[item objectForKey:@"NAME"]];
				
				
				// Newly added for preventing automatic selection of folders
				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:[item objectForKey:@"NAME"]];
				
				
				
				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteMusicFilesInFolder:[item objectForKey:@"NAME"]];

				[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteTempMusicFilesInFolder:[item objectForKey:@"NAME"]];

				
				
				[ov collapseItem:item collapseChildren:YES];

				
					[self checkUncheckItem:item:ov:object forTableColumn:tableColumn:oldValue];	
					[NSThread detachNewThreadSelector:@selector(populateFolderTree) toTarget:self withObject:nil];
				
				// Commented on april 30th
					//[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_COMPLETE")];
				
				
				[analysisProgress setHidden:YES];
				[animationImage setHidden:YES];
				
				}
		}
				
	//[self iterateMyFolderForBPMAnalysis:item];
	
	////[txtStatus setStringValue:JiwokLocalizedString(@"INFO_ANALYSING_COMPLETE")];
	
	[progressBar setHidden:YES];
	[progressBar stopAnimation:self];	
		
//	[analysisProgress setHidden:YES];
//	[animationImage setHidden:YES];


		
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in setObjectValue %@",[ex description]];
	}
   DUBUG_LOG(@"Now you are completed (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item method in JiwokMyMusicPanelViewController class");
}

#pragma mark  NSTableView data source methods


- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
     //NSLog(@"Now you are in numberOfRowsInTableView method in JiwokMyMusicPanelViewController class");
	return [detailTableData count];
    //NSLog(@"Now you are completed numberOfRowsInTableView method in JiwokMyMusicPanelViewController class");
}

- (id)tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row:(int)rowIndex
{
	
	///NSLog(@"Now you are in tableView objectValueForTableColumn method in JiwokMyMusicPanelViewController class");	
	id result = nil;
	@try{
	int cont = [detailTableData count];
	NSMutableDictionary *dict = nil;
	if (cont > 0)
	{
		NSString *lkeyArtist = @"";
		NSString *lkeyAlbum = @"";
		dict = (NSMutableDictionary *)[detailTableData objectAtIndex: rowIndex];
		NSString *filePath = [dict objectForKey:ID3_TAG_FILENAME];
		NSString *extension = [filePath pathExtension];
		
		if ([extension isEqualToString:@"mp3"] )
		{
			lkeyArtist = ID3_TAG_ARTIST;
			lkeyAlbum = ID3_TAG_ALBUM;
		}
		else if ([extension isEqualToString:@"m4a"] )// m4a
		{
			lkeyArtist = M4A_ID3_TAG_ARTIST;
			lkeyAlbum = M4A_ID3_TAG_ALBUM;
		}
		
		if (tableColumn && [[tableColumn identifier] isEqualToString:TABLE_COL_FILENAME]) 
		{
			result = [dict objectForKey:ID3_TAG_FILENAME];
		} 
		else if ([[tableColumn identifier] isEqualToString:TABLE_COL_ARTIST]) 
		{
			result = [dict objectForKey:lkeyArtist];
		}  
		else if ([[tableColumn identifier] isEqualToString:TABLE_COL_ALBUM]) 
		{
			result = [dict objectForKey:lkeyAlbum];
		}
		////NSLog(@"tag -> object value  %@",[dict objectForKey:ID3_TAG_ARTIST]);
		
	}
	
	//return result;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in objectValueForTableColumn %@",[ex description]];
	}
	
	@finally {
		return result;
	}
	//NSLog(@"Now you are completed tableView objectValueForTableColumn method in JiwokMyMusicPanelViewController class");
}	


@end
