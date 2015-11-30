//
//  JiwokDownloderWindowController.m
//  Jiwok
//
//  Created by Reubro on 06/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokDownloderWindowController.h"
#import "JiwokSettingPlistReader.h"
#import "JiwokUtil.h"
#import "JiwokFTPDownloader.h"
#import "JiwokSettingPlistReader.h"
#import "LoggerClass.h"
#import "JiwokMainWindowController.h"
#import "JiwokCurlFtpClient.h"

#import "JiwokAppDelegate.h"
#import "Autoupdater.h"
#import "GrowlExample.h"
#import "LoggerClass.h"

// For testing purpose 
#define shouldDownloadFiles 1

@implementation JiwokDownloderWindowController


- (void)windowDidResignMain:(NSNotification *)notification{
	
	NSLog(@"windowDidResignMain");
}

- (void)windowDidBecomeMain:(NSNotification *)notification{
	NSLog(@"windowDidBecomeMain");
	
}


- (void)windowDidBecomeKey:(NSNotification *)notification{
	
	NSLog(@"windowDidBecomeKey");
	
	
}


-(IBAction)cancel:(id)sender
{
	
}
- (id)initWithWindowNibName:(NSString *)windowNibName
{
   // NSLog(@"Now you are in initWithWindowNibName method in JiwokDownloderWindowController class");
	self = [super initWithWindowNibName:windowNibName];
	
	return self;
    //NSLog(@"Now you are completed initWithWindowNibName method in JiwokDownloderWindowController class");
}
- (void)windowDidLoad
{
	//	[progressBar startAnimation:self];
	//	[progressBar setMaxValue:44];
	//	[progressBar setDoubleValue:(1.0)];
	//	[progressBar setControlTint:NSDefaultControlTint];
	
	DUBUG_LOG(@"Now you are in windowDidLoad method in JiwokDownloderWindowController class");
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainWindow:) name:@"DOWNLOAD_COMPLETE" object:nil];
	
	GrowlExample *growlMsger=[[GrowlExample alloc]init];
	[growlMsger growlAlert:JiwokLocalizedString(@"INFO_DOWNLOAD_MUSIC") title:nil];
	[growlMsger release];
	
	[messagelabel setStringValue:JiwokLocalizedString(@"INFO_DOWNLOAD_MUSIC")];
	
	[NSThread detachNewThreadSelector:@selector(downloadFiles) toTarget:self withObject:nil];
	
	//[self downloadFiles];
	
	
	[levelBar setDoubleValue:0];
    DUBUG_LOG(@"Now you are completed windowDidLoad method in JiwokDownloderWindowController class");
}

- (void) windowWillClose:(NSNotification *) notification
{
	NSLog(@"WINDOW WILL CLOSE 111 ");
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_COMPLETE" object:nil];
	
	//[self autorelease];
	
	
}
//
//- (BOOL)windowShouldClose:(id)sender{	
//	
//	NSLog(@"windowShouldClose windowShouldClose");
//
//	
//	[sender orderOut:self];
//	return NO; 
//}
//


-(void)downloadFiles
{
   DUBUG_LOG(@"Now you are in downloadFiles method in JiwokDownloderWindowController class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[statuslabel setStringValue: JiwokLocalizedString(@"INFO_CHECK_CONNECTION")];
	
	
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
	int nTotalMusicCount = 0;
	if (jiwokURL)
	{
		if (![JiwokUtil checkForInternetConnection:jiwokURL])
		{
			[statuslabel setStringValue:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION")];
			[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
			return;
		}
		else
		{
			//NSLog(@"Preparing for download");
		}
	}
	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	if(appdelegate.updateAvailable)
	{
		
		[statuslabel setStringValue: JiwokLocalizedString(@"INFO_DOWNLOAD_AUTOUPDATE")];
		
		GrowlExample *growlMsger=[[GrowlExample alloc]init];
		[growlMsger growlAlert:JiwokLocalizedString(@"INFO_DOWNLOAD_AUTOUPDATE") title:nil];
		[growlMsger release];
		
		Autoupdater *autoUpdater=[[Autoupdater alloc]init];
		[autoUpdater downloadLatestVersion];
		[autoUpdater release];
		
	}
	else {
				
		[statuslabel setStringValue: JiwokLocalizedString(@"INFO_PREPARE_DOWNLOAD")];
		[statuslabel setStringValue: JiwokLocalizedString(@"INFO_PREPARE_VOCAL_DOWNLOAD")];
		//[[LoggerClass getInstance] logData:@"Preparing for download vocal pack."];
		//JiwokFTPDownloader * fileDownloader = [[JiwokFTPDownloader alloc] init];
		
		JiwokCurlFtpClient *curlDownloader=[[JiwokCurlFtpClient alloc]init];
		
		
		NSString *vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/"];		
		
		if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
			vocalPath=[NSString stringWithFormat:@"%@french/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"])	
			vocalPath=[NSString stringWithFormat:@"%@english/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])	
			vocalPath=[NSString stringWithFormat:@"%@spanish/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])	
			vocalPath=[NSString stringWithFormat:@"%@italian/",vocalPath];
        else if ([[JiwokUtil GetCurrentLocale]isEqualToString:@"polish"])
            vocalPath=[NSString stringWithFormat:@"%@polish/",vocalPath];
            
				
		NSString *finalPath = [[NSString alloc] initWithFormat:@"%@",vocalPath];
		
        NSLog(@"final path is %@",finalPath);
		
		NSMutableArray *listoffiles = [curlDownloader ListDirectoriesFromFTP:finalPath];
		NSLog(@"listoffiles NSMutableArray==%@",listoffiles);
        NSLog(@"list of files is %d",[listoffiles count]);
		if ([listoffiles count] > 5)
		{
			nTotalMusicCount += [listoffiles count];
			[[LoggerClass getInstance] logData:@"Total music count = %d",nTotalMusicCount];
		}
		else
		{
			[statuslabel setStringValue: JiwokLocalizedString(@"ERROR_GETTING_VOCALS")];
			[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
			return;
		}
		
		[listoffiles retain];
		
		////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////
		// Color Vocals	
        
        
		
		NSString *colorVocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/"];		
		
		if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
			colorVocalPath=[NSString stringWithFormat:@"%@french/",colorVocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"])	
			colorVocalPath=[NSString stringWithFormat:@"%@english/",colorVocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])	
			colorVocalPath=[NSString stringWithFormat:@"%@spanish/",colorVocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])	
			colorVocalPath=[NSString stringWithFormat:@"%@italian/",colorVocalPath];
        else if([[JiwokUtil GetCurrentLocale]isEqualToString:@"polish"])
		     colorVocalPath=[NSString stringWithFormat:@"%@polish/",colorVocalPath];
        
		NSString *finalColorVocalPath = [[NSString alloc] initWithFormat:@"%@",colorVocalPath];	
        NSLog(@"finalColourVocal path is %@",finalColorVocalPath);
		
		NSMutableArray *listofColorFiles = [curlDownloader ListDirectoriesFromFTP:finalColorVocalPath];
        NSLog(@"Colour vocal path is array count is %d",[listofColorFiles count]);
		NSLog(@"listofColorFiles NSMutableArray==%@",listofColorFiles);
        
        if([JiwokUtil GetCurrentLocale]!=@"polish")
        {
		if ([listofColorFiles count] > 5)
		{
			nTotalMusicCount += [listoffiles count];
			[[LoggerClass getInstance] logData:@"Total music count = %d",nTotalMusicCount];
		}
		else
		{
			[statuslabel setStringValue: JiwokLocalizedString(@"ERROR_GETTING_VOCALS")];
			[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
			return;
		}
		}
		[listofColorFiles retain];
				
		NSLog(@"finalColorVocalPath %@",finalColorVocalPath);
		
		
		////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////
		// Color Vocals	Ends
		
		
				
		
		
		///// spec songs pack
		[statuslabel setStringValue: JiwokLocalizedString(@"INFO_PREPARE_SP_SONGS_DOWNLOAD")];
		[[LoggerClass getInstance] logData:@"Preparing for download specific song pack."];
		
		NSString * spSongPath = [JiwokSettingPlistReader GetDownLoadSpSongsPath];
		NSString *finalspSongPath = [[NSString alloc] initWithFormat:@"%@/",spSongPath];
		
		NSMutableArray *listoffilesSpSongFolders = [curlDownloader ListDirectoriesFromFTP:finalspSongPath];
		 NSLog(@"listoffilesSpSongFolders NSMutableArray==%@",listoffilesSpSongFolders);
		[listoffilesSpSongFolders retain];
		
		if ([listoffilesSpSongFolders count] > 0)
		{
			[[LoggerClass getInstance] logData:@"Listing specific songs path %@",spSongPath];
			
			for (NSString *spFolderName in listoffilesSpSongFolders)
			{
				NSString *newSPFolder = [[NSString alloc] initWithFormat:@"%@%@/",finalspSongPath,spFolderName];
				NSMutableArray *listoffilesInSPFolder = [curlDownloader ListDirectoriesFromFTP:newSPFolder];
				[[LoggerClass getInstance] logData:@"File count %d, at path %@",[listoffilesInSPFolder count],newSPFolder];
                NSLog(@"listoffilesInSPFolder NSMutableArray==%@",listoffilesInSPFolder);
				nTotalMusicCount += [listoffilesInSPFolder count];
				[newSPFolder release];
			}
		}
		else
		{
			[statuslabel setStringValue: JiwokLocalizedString(@"ERROR_GETTING_SP_SONGS")];
			return;
		}
		
		[levelBar setMaxValue:nTotalMusicCount];
		[[LoggerClass getInstance] logData:@"Total music count = %d",nTotalMusicCount];
		[levelBar setDoubleValue:0];
		
		
		
		
		
		// starting download create folder if it does not exist
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		//NSString *localVocalPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Vocals"];
		
		NSString *localVocalPath = [bundlePath  stringByAppendingPathComponent:@"Vocals"];
		
		//
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:localVocalPath])
		{
			if(![fileManager createDirectoryAtPath:localVocalPath attributes:nil])
			{
				[[LoggerClass getInstance] logData:@"local vocal folder creation failed"];
				return;
			}
		}
		int nIndex = 1;
		//
		[statuslabel setStringValue: JiwokLocalizedString(@"INFO_VOCAL_DOWNLOAD")];
		
		int vocalFailCount=0;		
		
		if(shouldDownloadFiles)
			
			
			for (NSString *vocalName in listoffiles)		
			{	
				
				//NSLog(@"MMMMMMMMMMMMMMMMMMMMMMMMMMMM listoffilesSpSongFolders is %@ MMMMMMMMMMMMMMMMMMMMMMMMMMMM %@",listoffilesSpSongFolders,listoffiles);
				
				if (jiwokURL)
				{ 				
					// Old code
					if ([JiwokUtil checkForInternetConnection:jiwokURL])
					{					
						NSString *newVocalPath = [[NSString alloc] initWithFormat:@"%@%@",finalPath,vocalName];
						NSString *newLocalVocalPath = [[NSString alloc] initWithFormat:@"%@/%@",localVocalPath,vocalName];
						
						if(![fileManager fileExistsAtPath:newLocalVocalPath])
						{					
							[curlDownloader performSelectorInBackground:@selector(DownloadFromFTP:) withObject:[NSArray arrayWithObjects:newVocalPath,newLocalVocalPath,nil]];						
							
						}
						
						[levelBar setDoubleValue:nIndex++];
						
						[newVocalPath release];
						[newLocalVocalPath release];
					}
					else
					{
						vocalFailCount++;
						
						if(vocalFailCount>[listoffiles count]/10)
						{
							[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
							return;
						}
					}
				}
			}
		[finalPath release];
		
		
		
		
		
		
		////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////
		// Color Vocals				
		
		// starting download create folder if it does not exist
		
		NSString *localColorVocalPath = [bundlePath  stringByAppendingPathComponent:@"color_vocals"];
		
		//
		if(![fileManager fileExistsAtPath:localColorVocalPath])
		{
			if(![fileManager createDirectoryAtPath:localColorVocalPath attributes:nil])
			{
				[[LoggerClass getInstance] logData:@"local Color vocal folder creation failed"];
				return;
			}
		}
		 nIndex = 1;
		//
		//[statuslabel setStringValue: JiwokLocalizedString(@"INFO_VOCAL_DOWNLOAD")];
		
		 vocalFailCount=0;		
			
		
		NSLog(@"listofColorFiles %@",listofColorFiles);
		
			for (NSString *colorVocalName in listofColorFiles)		
			{					
				if (jiwokURL)
				{ 				
					// Old code
					if ([JiwokUtil checkForInternetConnection:jiwokURL])
					{					
						NSString *newColorVocalPath = [[NSString alloc] initWithFormat:@"%@%@",finalColorVocalPath,colorVocalName];
						NSString *newColorLocalVocalPath = [[NSString alloc] initWithFormat:@"%@/%@",localColorVocalPath,colorVocalName];
						
						if(![fileManager fileExistsAtPath:newColorLocalVocalPath])
						{					
							[curlDownloader performSelectorInBackground:@selector(DownloadFromFTP:) withObject:[NSArray arrayWithObjects:newColorVocalPath,newColorLocalVocalPath,nil]];						
							
						}
						
						[levelBar setDoubleValue:nIndex++];
						
						[newColorVocalPath release];
						[newColorLocalVocalPath release];
					}
					else
					{
						vocalFailCount++;
						
						if(vocalFailCount>[listofColorFiles count]/10)
						{
							[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
							return;
						}
					}
				}
			}
		[finalColorVocalPath release];		
				
		////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////
		// Color Vocals	Ends
		
		
		
		
		
		
		
		
		
		
		
		// download specific songs
		// starting download create folder if it does not exist
		
		
		NSString *localSPPath = [bundlePath  stringByAppendingPathComponent:@"SpecificSongs"];
		
		if(![fileManager fileExistsAtPath:localSPPath])
		{
			if(![fileManager createDirectoryAtPath:localSPPath attributes:nil])
			{
				[[LoggerClass getInstance] logData:@"local Specific songs folder creation failed"];
				return;
			}
		}
		
		[statuslabel setStringValue: JiwokLocalizedString(@"INFO_SP_SONGS_DOWNLOAD")];
		
		int specificSongsFailCount=0;
		
		// Added code to correct progress bar
		nIndex=nIndex-10;
		
		//NSLog(@"listoffilesSpSongFolders listoffilesSpSongFolders listoffilesSpSongFolders %d %@",[listoffilesSpSongFolders count],listoffilesSpSongFolders);
		
		
		if(shouldDownloadFiles)
			
			
			for (NSString *spSongFolderName in listoffilesSpSongFolders)
			{		
				NSString *newSPPath = [[NSString alloc] initWithFormat:@"%@%@/",finalspSongPath,spSongFolderName];
				NSString *newLocalSPPath = [[NSString alloc] initWithFormat:@"%@/%@",localSPPath,spSongFolderName];
				NSMutableArray *listoffilesInSPFolder = [curlDownloader ListDirectoriesFromFTP:newSPPath];
				[[LoggerClass getInstance] logData:@"downloading special songs pack from %@",newSPPath];
				
				NSLog(@"listoffilesInSPFolder NSMutableArray==%@",listoffilesInSPFolder);
				//NSLog(@"listoffilesInSPFolder listoffilesInSPFolder listoffilesInSPFolder %d %@",[listoffilesInSPFolder count],listoffilesInSPFolder);
				
				
				// create the spsongs subfolder if it does not exist
				if(![fileManager fileExistsAtPath:newLocalSPPath])
				{
					if(![fileManager createDirectoryAtPath:newLocalSPPath attributes:nil])
					{
						[[LoggerClass getInstance] logData:@"local Specific songs folder creation failed for folder %@",newLocalSPPath];
						return;
					}
				}
				// Original code
				//for (NSString *spsongName in listoffilesInSPFolder)
				
				for(int i=0;i<[listoffilesInSPFolder count];i++)				
				{
					
					
					
					
					if (jiwokURL)
					{
						if ([JiwokUtil checkForInternetConnection:jiwokURL])
						{
							
							NSString *spsongName=[listoffilesInSPFolder objectAtIndex:i];
							
							NSString *newSPSongFilePath = [[NSString alloc] initWithFormat:@"%@%@",newSPPath,spsongName];
							NSString *newLocalSPSongFilePath = [[NSString alloc] initWithFormat:@"%@/%@",newLocalSPPath,spsongName];
							
							[[LoggerClass getInstance] logData:@"downloading specialsong file first time %@ to local path %@ i is %d count is %d",newSPSongFilePath,newLocalSPSongFilePath,i,[listoffilesInSPFolder count]];
							
							//if(![fileManager fileExistsAtPath:newLocalSPSongFilePath])
							//[curlDownloader DownloadFromFTP:newSPSongFilePath:newLocalSPSongFilePath];
							
							if(i+1==[listoffilesInSPFolder count])
								[curlDownloader DownloadFromFTP:[NSArray arrayWithObjects:newSPSongFilePath,newLocalSPSongFilePath,nil]];				
							else					
								[curlDownloader performSelectorInBackground:@selector(DownloadFromFTP:) withObject:[NSArray arrayWithObjects:newSPSongFilePath,newLocalSPSongFilePath,nil]];
							
							[newSPSongFilePath release];
							[newLocalSPSongFilePath release];
							[levelBar setDoubleValue:nIndex++];
							
							i++;
							
							// Newly added code
							
							for(int j=0;j<3;j++)
							{
								
								if((i+1)<[listoffilesInSPFolder count])
								{
									NSString *spsongName1=[listoffilesInSPFolder objectAtIndex:i+1];					
									NSString *newSPSongFilePath1 = [[NSString alloc] initWithFormat:@"%@%@",newSPPath,spsongName1];
									NSString *newLocalSPSongFilePath1 = [[NSString alloc] initWithFormat:@"%@/%@",newLocalSPPath,spsongName1];
									
									[[LoggerClass getInstance] logData:@"downloading specialsong file using thread %@ to local path %@ is %d",newSPSongFilePath1,newLocalSPSongFilePath1,i];
									
									if(![fileManager fileExistsAtPath:newLocalSPSongFilePath1])
										//[curlDownloader DownloadFromFTP:newSPSongFilePath:newLocalSPSongFilePath];
										
										[curlDownloader performSelectorInBackground:@selector(DownloadFromFTP:) withObject:[NSArray arrayWithObjects:newSPSongFilePath1,newLocalSPSongFilePath1,nil]];
									
									[newSPSongFilePath1 release];
									[newLocalSPSongFilePath1 release];
									[levelBar setDoubleValue:nIndex++];
									
									i++;					
								}					
							}										
							
							if(i<[listoffilesInSPFolder count])
							{
								NSString *spsongName1=[listoffilesInSPFolder objectAtIndex:i];					
								NSString *newSPSongFilePath1 = [[NSString alloc] initWithFormat:@"%@%@",newSPPath,spsongName1];
								NSString *newLocalSPSongFilePath1 = [[NSString alloc] initWithFormat:@"%@/%@",newLocalSPPath,spsongName1];
								
								[[LoggerClass getInstance] logData:@"downloading specialsong file %@ to local path %@  is %d",newSPSongFilePath1,newLocalSPSongFilePath1,i];
								
								if(![fileManager fileExistsAtPath:newLocalSPSongFilePath1])
									[curlDownloader DownloadFromFTP:[NSArray arrayWithObjects:newSPSongFilePath1,newLocalSPSongFilePath1,nil]];
								
								
								[newSPSongFilePath1 release];
								[newLocalSPSongFilePath1 release];
								[levelBar setDoubleValue:nIndex++];
								
								//i++;					
							}
							
							
							
						}
						
						else
						{
							specificSongsFailCount++;
							
							if(specificSongsFailCount>[listoffilesInSPFolder count]/10)
							{
								[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
								return;
							}
						}
					}
				}
			}
		[finalspSongPath release];
		//	 
		
		
		
		/// downloading completed
		
		//	JiwokMainWindowController * mainwindow = [JiwokMainWindowController alloc];
		//	[mainwindow initWithWindowNibName:@"JiwokMainWindow"];
		//	//[mainwindow showWindow:self];
		//	[mainwindow showWindow:nil];
		//		
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_COMPLETE" object:nil];
		
		
		NSLog(@"DOWNLOAD_COMPLETE");
		
		//[[self window] performClose:nil];
		
		//[self setShouldCloseDocument:YES];
		
		[self close];
		
		//[super close];
		
		
		[pool release];
		
		//[self autorelease];
		
	}
    DUBUG_LOG(@"Now you are completed downloadFiles method in JiwokDownloderWindowController class");
}



//-(void)showMainWindow:(NSNotification *)pNotification{
//
//	JiwokMainWindowController * mainwindow = [JiwokMainWindowController alloc];
//	[mainwindow initWithWindowNibName:@"JiwokMainWindow"];
//	//[mainwindow showWindow:self];
//	[mainwindow showWindow:nil];
//
//}
//


@end
