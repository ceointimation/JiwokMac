//
//  JiwokAppDelegate.m
//  Jiwok
//
//  Created by Reubro on 02/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokAppDelegate.h"
#import "LoggerClass.h"
#import "JiwokSettingPlistReader.h"
#import "Common.h"
#import "JiwokDownloderWindowController.h"
#import "JiwokUtil.h"
#import "JiwokAPIHelper.h"

#import "JiwokMusicSystemDBMgrWrapper.h"
#import "JiwokMyMusicPanelViewController.h"

#import "Autoupdater.h"


@implementation JiwokAppDelegate
@synthesize loggedusername,loggedpassword,isLogged,workoutQueueID,updateAvailable;


- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender{
    DUBUG_LOG(@"Now you are in applicationShouldOpenUntitledFile method in jiwokAppDelegate class");
	return YES;
     //NSLog(@"Now you are completed the applicationShouldOpenUntitledFile method in jiwokAppDelegate class");
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication{
	DUBUG_LOG(@"Now you are in applicationOpenUntitledFile method in jiwokAppDelegate class");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_MAIN_WINDOW" object:nil]; 	
	return YES;
    //NSLog(@"Now you are completed applicationOpenUntitledFile method in jiwokAppDelegate class");
}



- (IBAction)showAboutPanel:(id)sender
{
    DUBUG_LOG(@"Now you are in showAboutPanel method in jiwokAppDelegate class");
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];
     //NSLog(@"Now you are completed showAboutPanel method in jiwokAppDelegate class");
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
					hasVisibleWindows:(BOOL)flag{
    DUBUG_LOG(@"Now you are in applicationShouldHandleReopen method in jiwokAppDelegate class");
	return YES;
     //NSLog(@"Now you are completed applicationShouldHandleReopen method in jiwokAppDelegate class");
}

- (void)copyDatabaseFile
{
     DUBUG_LOG(@"Now you are in copyDatabaseFile method in jiwokAppDelegate class");
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	//NSString *filepath = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:JIWOK_DB_NAME];

	NSString *filepath = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:JIWOK_DB_NAME];

	
	success = [fileManager fileExistsAtPath:filepath];
	if (success) return;
	NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:JIWOK_DB_NAME];
	success = [fileManager copyItemAtPath:defaultPath toPath:filepath error:&error];
     DUBUG_LOG(@"Now you are completed copyDatabaseFile method in jiwokAppDelegate class");
}

- (void)copyUpdaterApp
{
     DUBUG_LOG(@"Now you are in copyUpdaterApp method in jiwokAppDelegate class");
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	//NSString *filepath = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:JIWOK_DB_NAME];
	
	NSString *filepath = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:JIWOK_UPDATER_NAME];
	
	
	success = [fileManager fileExistsAtPath:filepath];
	if (success) return;
	NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:JIWOK_UPDATER_NAME];
	success = [fileManager copyItemAtPath:defaultPath toPath:filepath error:&error];
     DUBUG_LOG(@"Now you are completed copyUpdaterApp method in jiwokAppDelegate class");
    
}



-(void)applicationDidFinishLaunching:(NSNotification*) notification
{ // NSSquareStatusItemLength NSVariableStatusItemLength
    
    DUBUG_LOG(@"Now you are in applicationDidFinishLaunching method in jiwokAppDelegate class");
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:topMenu];
	[statusItem setHighlightMode:YES];	
	[statusItem setImage:[NSImage imageNamed:@"Dock_gray_Menu_Bar.png"]];
	
	//[self updateDockImage];

	//delegate=self;
	
	

	
	[NSApp setApplicationIconImage: [NSImage imageNamed:@"Dock_gray.png"]];
	
	NSConnection *theConnection;
	theConnection = [NSConnection defaultConnection];

    [theConnection setRootObject:nil];
    if ([theConnection registerName:@"JiwokMAC"] == NO) 
    {
        exit(1);
    }
	
	[self copyDatabaseFile];
	[self copyUpdaterApp];
	
	
	[self cleanUpdates];
	
	[self cleanUpLog];
	
	NSString *bundlePath =[[NSBundle mainBundle] bundlePath];
	
	//[[LoggerClass getInstance] Open:[bundlePath stringByDeletingLastPathComponent] withAppName:@"Jiwok_Mac"];
	
	
	[[LoggerClass getInstance] Open:bundlePath  withAppName:@"Jiwok_Mac"];
	
	
	
	[JiwokSettingPlistReader initialise];
	

	
	
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	
	NSString *autoUserName = (NSString*)CFPreferencesCopyValue(CFSTR("AutoUserName"), CFSTR(APPID), 
														 kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	
	NSString *autoPassword = (NSString*)CFPreferencesCopyValue(CFSTR("AutoPassword"), CFSTR(APPID), 
														 kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	
	
	
	if(NSAppKitVersionNumber>1038)
	{
	
		autoUserName = (NSString*)CFPreferencesCopyValue(CFSTR("AutoUserName"), CFSTR(APPID), 
														 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		autoPassword = (NSString*)CFPreferencesCopyValue(CFSTR("AutoPassword"), CFSTR(APPID), 
														 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	}
	
	
	
	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getApplicationDetails];
	
	
	NSLog(@"selectedValuesArray is %@",selectedValuesArray);
	
	[[LoggerClass getInstance] logData:@"xxxxxxxxxxxxxxx Applicaion Version is %@ (Test) xxxxxxxxxxxxxxxxxxxxxxxx",[[selectedValuesArray objectAtIndex:0] objectForKey:@"CurrentVersion"]];

	NSString *version = [[NSProcessInfo processInfo] operatingSystemVersionString];
    
    NSLog(@"OS X Version == %@", version);
    
    [[LoggerClass getInstance] logData:@"-----XX----- OS X Version is == %@ -----XX-----",version];
    
	[[LoggerClass getInstance] logData:@"autoUserName and Password -- %@ %@",autoUserName,autoPassword];
    
    	
	[self setDocMenuiTems];
	[self setTopMenuiTems];
	
	
	
/*	
	
	// Newly added code for adding newly added vocals
	[self copyNewMp3Files];

*/	
	
	BOOL updateAvailable1=NO;
	
	Autoupdater *autoUpdater=[[Autoupdater alloc]init];
	
	
	//NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
//	if (![JiwokUtil checkForInternetConnection:jiwokURL])
//	{
//		
//		//[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
//	}
//	
//	else {		
			updateAvailable1= [autoUpdater checkForLatestVersion];

		
		

	//}

	
	//BOOL updateAvailable1= [autoUpdater checkForLatestVersion];
	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	
	if(updateAvailable1)
	{
		appdelegate.updateAvailable=YES;
		DUBUG_LOG(@"UPDATE AVAILABLE");
	
	}
	else {
		DUBUG_LOG(@"NO UPDATE");
	}

	
	
	[autoUpdater release];
	
		
	
	/////////
	
/*
	
//To Display Main window directly		
	mainwindow = [JiwokMainWindowController alloc];
	[mainwindow initWithWindowNibName:@"JiwokMainWindow"];
	[mainwindow showWindow:self];
	return;
	////////

 */
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainWindow:) name:@"DOWNLOAD_COMPLETE" object:nil];

	
	
	if (![autoUserName isEqualToString:@""] && [autoUserName isNotEqualTo:nil]  &&  ![autoPassword isEqualToString:@""] && [autoPassword isNotEqualTo:nil]) 
	{
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			appdelegate.loggedusername = autoUserName;
			appdelegate.loggedpassword = autoPassword;
			appdelegate.isLogged = YES;
		
		
		[self updateDockImage];
		
		
		
		if(appdelegate.updateAvailable)
		{
			downloadwindow = [JiwokDownloderWindowController alloc];
			[downloadwindow initWithWindowNibName:@"JiwokDownloadWindow"];
			[downloadwindow showWindow:self];
			
		}
		else {	
		
		// do music analysis?
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
				
		NSString *localVocalPath = [bundlePath  stringByAppendingPathComponent:@"Vocals"];
		NSString *SpeceficSongPath = [bundlePath  stringByAppendingPathComponent:@"SpecificSongs"];
			
		NSString *localColorVocalPath = [bundlePath  stringByAppendingPathComponent:@"color_vocals"];	

		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:localVocalPath]||(![fileManager fileExistsAtPath:SpeceficSongPath])||(![fileManager fileExistsAtPath:localColorVocalPath]))
		{
			
			//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainWindow:) name:@"DOWNLOAD_COMPLETE" object:nil];
			
			downloadwindow = [JiwokDownloderWindowController alloc];
			[downloadwindow initWithWindowNibName:@"JiwokDownloadWindow"];
			[downloadwindow showWindow:self];
			//[downloadwindow release];
			//[downloadwindow showWindow:nil];
		}
		else
		{
			mainwindow = [JiwokMainWindowController alloc];
			[mainwindow initWithWindowNibName:@"JiwokMainWindow"];
			[mainwindow showWindow:self];
		}
			
		}
	}
	else
	{
		loginwindow = [JiwokLoginWindowController alloc];
		[loginwindow initWithWindowNibName:@"JiwokLoginWindow"];
		[loginwindow showWindow:self];	
	}
	
	[self UpdateStatusOfMusicFiles];	
	[self performSelectorInBackground:@selector(UpdateTagDetectedGenres) withObject:nil];
		
	 DUBUG_LOG(@"Now you are completed applicationDidFinishLaunching method in jiwokAppDelegate class");
	
}


-(void)copyNewMp3Files{
	DUBUG_LOG(@"Now you are in copyNewMp3Files method in jiwokAppDelegate class");
	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getApplicationDetails];
     NSLog(@"selectedValuesArray NSArray==%@",selectedValuesArray);
	NSString *currentAppVersion=[[selectedValuesArray objectAtIndex:0] objectForKey:@"CurrentVersion"];
	NSString *copyAppVersion=@"1.6.9";
	
	
	Autoupdater *autoUpdater=[[Autoupdater alloc]init];

	int versionCheckValue=[autoUpdater compareVersions:currentAppVersion:copyAppVersion];		
	
	if((versionCheckValue==-1)||(versionCheckValue==0)){
		
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];	
		NSString *newMp3Path=[bundlePath  stringByAppendingPathComponent:@"Contents/Resources/delivery_mp3.zip"];	
		NSString *vocalPath=[bundlePath  stringByAppendingPathComponent:@"Vocals"];	
		NSString *extractedPath=[bundlePath  stringByAppendingPathComponent:@"delivery_mp3"];		
		
		BOOL isDirectory;			

		if(([[NSFileManager defaultManager] fileExistsAtPath:newMp3Path isDirectory:&isDirectory]))
		{
		BOOL unzipResult=[autoUpdater unzipInput:newMp3Path:bundlePath];
		
		if(unzipResult)
		{
			BOOL isDir;			
			BOOL vocalCheck=[[NSFileManager defaultManager] fileExistsAtPath:vocalPath isDirectory:&isDir];			
			NSArray *newVocals=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:extractedPath error:nil];			
			
			if(vocalCheck)
			{
				for (int i=0; i<[newVocals count]; i++) {
					NSString *currentVocal=[newVocals objectAtIndex:i];
					NSString *newVocalPath=[extractedPath stringByAppendingPathComponent:currentVocal];
					NSString *finalVocalPath=[vocalPath stringByAppendingPathComponent:currentVocal];					
					[[NSFileManager defaultManager] moveItemAtPath:newVocalPath toPath:finalVocalPath error:nil];					
				}
				
				NSString *junkFolder=[bundlePath  stringByAppendingPathComponent:@"__MACOSX"];				
				[[NSFileManager defaultManager] removeItemAtPath:extractedPath error:nil];
				
				if([[NSFileManager defaultManager] fileExistsAtPath:junkFolder isDirectory:&isDir])
					[[NSFileManager defaultManager] removeItemAtPath:junkFolder error:nil];	
				
				if([[NSFileManager defaultManager] fileExistsAtPath:newMp3Path isDirectory:&isDir])
					[[NSFileManager defaultManager] removeItemAtPath:newMp3Path error:nil];	
				
				
			}
		}
		}
	}	
	
	[autoUpdater release];
    DUBUG_LOG(@"Now you are completed copyNewMp3Files method in jiwokAppDelegate class");
}


-(void)showMainWindow:(NSNotification *)pNotification{
	DUBUG_LOG(@"Now you are in showMainWindow method in jiwokAppDelegate class");
	DUBUG_LOG(@"showMainWindow showMainWindow");

	
	[self performSelectorOnMainThread:@selector(createObject) withObject:nil waitUntilDone:YES];
	DUBUG_LOG(@"Now you are completed showMainWindow method in jiwokAppDelegate class");
	}
	
-(void)createObject{
    DUBUG_LOG(@"Now you are in createObject method in jiwokAppDelegate class");
	DUBUG_LOG(@"createObject createObject");

	
	mainwindow = [JiwokMainWindowController alloc];
	[mainwindow initWithWindowNibName:@"JiwokMainWindow"];
	[mainwindow showWindow:self];
 DUBUG_LOG(@"Now you are completed createObject method in jiwokAppDelegate class");
}


-(void)updateDockImage{

	 DUBUG_LOG(@"Now you are in updateDockImage method in jiwokAppDelegate class");
	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSString *statusString;

	
	if(appdelegate.isLogged)
	{
		statusString=@"Dock_green.png";
		
		if(analysingInProgress)
			statusString=@"Dock_blue.png";
		
		if(workoutGenerationInProgress)
			statusString=@"Dock_pink.png";		
	}
	else 
	{
		statusString=@"Dock_gray.png";
	}

	NSImage *myImage = [NSImage imageNamed:statusString];	
	[NSApp setApplicationIconImage: myImage];	
	[statusItem setImage:[NSImage imageNamed:[NSString stringWithFormat:@"%@_Menu_Bar.png",[statusString stringByDeletingPathExtension]]]];
	DUBUG_LOG(@"Now you are completed updateDockImage method in jiwokAppDelegate class");
}


-(BOOL)UpdateStatusOfMusicFiles{	
	DUBUG_LOG(@"Now you are in UpdateStatusOfMusicFiles method in jiwokAppDelegate class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	
	BOOL status;
	// To check the db
	
	
	@try {
		
		
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] findAllMusicFilePaths];
	NSString *filePath;
	 NSLog(@"selectedValuesArray NSArray==%@",selectedValuesArray);
	int deletedFilesCount=0;
	
	for (int i=0; i<[selectedValuesArray count]; i++) {
		
		filePath=[[selectedValuesArray objectAtIndex:i] objectForKey:@"FilePath"];
		
		if([fileManager fileExistsAtPath:filePath])			
		{
			
		}
		else {						
			deletedFilesCount++;			
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteMusicFiles:filePath];			
		}				
	}
			
	if(([selectedValuesArray count]-deletedFilesCount)>0)
	{		DUBUG_LOG(@"File exists in db");
		
		status=YES;		
	}
	else{
		DUBUG_LOG(@"File Doesn't exists in db");
		
		status=NO;	
		
	}	
	
	[pool release];
	
	}
	@catch (NSException * e) {
		 
		DUBUG_LOG(@"XXXXception");

	}
	@finally {
		return(status);	

	}
	
	
//	return(status);	
	
	 DUBUG_LOG(@"Now you are completed UpdateStatusOfMusicFiles method in jiwokAppDelegate class");
	
}

-(void)UpdateTagDetectedGenres{
	 DUBUG_LOG(@"Now you are in UpdateTagDetectedGenres method in jiwokAppDelegate class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	DUBUG_LOG(@"UpdateTagDetectedGenres");

	NSArray * jiwokGenres= [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getAllMusicalGenre];	
	
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
	
//	if ([JiwokUtil checkForInternetConnection:jiwokURL])	
	//{
	NSMutableDictionary *GenreCounts=[[NSMutableDictionary alloc]init];
	
	for(int i=0;i<[jiwokGenres count];i++)	
	{		
		NSArray *CountA=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetCountForGenreFromMusicFiles:[[jiwokGenres objectAtIndex:i]objectForKey:@"jiwok_genre"]];		
		 NSLog(@"CountA NSArray==%@",CountA);
		if([CountA count]>0)
		{
			if([[[CountA objectAtIndex:0]objectForKey:@"COUNT(*)"]intValue]>0)
				
				[GenreCounts setObject:[[CountA objectAtIndex:0]objectForKey:@"COUNT(*)"] forKey:[[jiwokGenres objectAtIndex:i]objectForKey:@"jiwok_genre"] ];
			
		}
		 NSLog(@"GenreCounts NSMutableDictionary==%@",GenreCounts);
	}
	
	NSArray *array;
	if([GenreCounts count]>0)
	{
		array =[GenreCounts allKeys];
	}
	
	for(int i=0;i<[GenreCounts count];i++)
		
	{
		JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
		if(!([[NSString stringWithFormat:@"%@",[array objectAtIndex:i]] isEqualToString:@"test"] ||[[NSString stringWithFormat:@"%@",[array objectAtIndex:i]] isEqualToString:@"Loundge"] || [[NSString stringWithFormat:@"%@",[array objectAtIndex:i]] isEqualToString:@"loundge"]))
			if ([JiwokUtil checkForInternetConnection:jiwokURL])	

		[apiHelper InvokeUpdateTagDetectedGenreAPI:[NSString stringWithFormat:@"%@",[array objectAtIndex:i]]:[NSString stringWithFormat:@"%@",[GenreCounts objectForKey:[array objectAtIndex:i]]]];
		
		[apiHelper release];
		
	}
	
	//}
	[pool release];
	 DUBUG_LOG(@"Now you are completed UpdateTagDetectedGenres method in jiwokAppDelegate class");
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
     DUBUG_LOG(@"Now you are in validateMenuItem method in jiwokAppDelegate class");    
    return YES;
     //NSLog(@"Now you are completed validateMenuItem method in jiwokAppDelegate class");
}


-(IBAction)StartAutomaticallyAction:(NSMenuItem *)menuItem{	
	DUBUG_LOG(@"Now you are in StartAutomaticallyAction method in jiwokAppDelegate class"); 
	if(menuItem.state == NSOffState)
	{
		[menuItem setState:NSOnState];
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Start Automatically"];
	}
	else
	{
		[menuItem setState:NSOffState];
		
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Start Automatically"];

	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Start Automatically"]) 
			[self addAppAsLoginItem];
		else	
			[self deleteAppFromLoginItem];
	
	DUBUG_LOG(@"Now you are completed StartAutomaticallyAction method in jiwokAppDelegate class"); 
}


-(IBAction)RelaunchMusicDetectionAction:(NSMenuItem *)menuItem{
	DUBUG_LOG(@"Now you are in RelaunchMusicDetectionAction method in jiwokAppDelegate class"); 

	if(mainwindow)
		[mainwindow relaunchDetection];	
    DUBUG_LOG(@"Now you are completed RelaunchMusicDetectionAction method in jiwokAppDelegate class"); 

}


-(IBAction)AutoDetectionAction:(NSMenuItem *)menuItem{	
	DUBUG_LOG(@"Now you are in AutoDetectionAction method in jiwokAppDelegate class"); 
	if(menuItem.state == NSOffState)
	{
		[menuItem setState:NSOnState];		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AutoDetect"];
	}
	else
	{
		[menuItem setState:NSOffState];		
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoDetect"];		
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	DUBUG_LOG(@"Now you are completed AutoDetectionAction method in jiwokAppDelegate class"); 
}


-(IBAction)VersionAction:(NSMenuItem *)menuItem{	
	DUBUG_LOG(@"Now you are in VersionAction method in jiwokAppDelegate class"); 
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:menuItem];
    DUBUG_LOG(@"Now you are completed VersionAction method in jiwokAppDelegate class"); 
}

-(IBAction)closeAction:(NSMenuItem *)menuItem{	
	DUBUG_LOG(@"Now you are in closeAction method in jiwokAppDelegate class"); 

	//if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_EXIT_APP"):JIWOK_ALERT_OK_CANCEL])// OK selected
//	{
		[NSApp terminate:self]; 
	//	[self cleanUpDisk];
    DUBUG_LOG(@"Now you are completed closeAction method in jiwokAppDelegate class"); 

//	}		
}



-(void)setDocMenuiTems{
	DUBUG_LOG(@"Now you are in setDocMenuiTems method in jiwokAppDelegate class"); 
	[dynamicMenu itemAtIndex:0].title=JiwokLocalizedString(@"AUTO-START");
	[dynamicMenu itemAtIndex:1].title=JiwokLocalizedString(@"RELAUNCH-DETECTION");
	[dynamicMenu itemAtIndex:2].title=JiwokLocalizedString(@"AUTO-DETECT");
	[dynamicMenu itemAtIndex:3].title=@"Version";
	
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Start Automatically"]) {
		[dynamicMenu itemAtIndex:0].state=NSOnState;
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDetect"]) {
		[dynamicMenu itemAtIndex:2].state=NSOnState;	
	}
	DUBUG_LOG(@"Now you are completed setDocMenuiTems method in jiwokAppDelegate class"); 
}


-(void)setTopMenuiTems{

	DUBUG_LOG(@"Now you are in setTopMenuiTems method in jiwokAppDelegate class");
	[topMenu itemAtIndex:0].title=JiwokLocalizedString(@"AUTO-START");
	[topMenu itemAtIndex:1].title=JiwokLocalizedString(@"RELAUNCH-DETECTION");
	[topMenu itemAtIndex:2].title=JiwokLocalizedString(@"AUTO-DETECT");
	[topMenu itemAtIndex:3].title=@"Version";
	[topMenu itemAtIndex:4].title=JiwokLocalizedString(@"CLOSE_APP");
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Start Automatically"]) {
		[topMenu itemAtIndex:0].state=NSOnState;
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDetect"]) {
		[topMenu itemAtIndex:2].state=NSOnState;	
	}	
	DUBUG_LOG(@"Now you are completed setTopMenuiTems method in jiwokAppDelegate class");

}


- (BOOL)menu:(NSMenu *)menu
  updateItem:(NSMenuItem *)item 
	 atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel{
	DUBUG_LOG(@"Now you are in updateItem method in jiwokAppDelegate class");
	return YES;
    //NSLog(@"Now you are completed updateItem method in jiwokAppDelegate class");
}


- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu{
	DUBUG_LOG(@"Now you are in numberOfItemsInMenu method in jiwokAppDelegate class");
	return 4;
    //NSLog(@"Now you are completed numberOfItemsInMenu method in jiwokAppDelegate class");
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{	
    DUBUG_LOG(@"Now you are in menuNeedsUpdate method in jiwokAppDelegate class");
    if (!dynamicMenu)
        dynamicMenu = menu;
    if (!menu)
        menu = dynamicMenu;
    NSInteger count = [self numberOfItemsInMenu:menu];
    while ([menu numberOfItems] < count)
        [menu insertItem:[[NSMenuItem new] autorelease] atIndex:0];
    while ([menu numberOfItems] > count)
        [menu removeItemAtIndex:0];
    for (NSInteger index = 0; index < count; index++)
        [self menu:menu updateItem:[menu itemAtIndex:index] atIndex:index shouldCancel:NO];
   DUBUG_LOG(@"Now you are completed menuNeedsUpdate method in jiwokAppDelegate class");
}





-(void) addAppAsLoginItem{
     DUBUG_LOG(@"Now you are in addAppAsLoginItem method in jiwokAppDelegate class");
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
	
	// Create a reference to the shared file list.
	// We are adding it to the current user only.
	// If we want to add it all users, use
	// kLSSharedFileListGlobalLoginItems instead of
	//kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
															kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
																	 kLSSharedFileListItemLast, NULL, NULL,
																	 url, NULL, NULL);
		if (item){
			CFRelease(item);
		}
	}	
	
	CFRelease(loginItems);
     DUBUG_LOG(@"Now you are completed addAppAsLoginItem method in jiwokAppDelegate class");
}

-(void) deleteAppFromLoginItem{
    DUBUG_LOG(@"Now you are in deleteAppFromLoginItem method in jiwokAppDelegate class");
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
															kLSSharedFileListSessionLoginItems, NULL);
	
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(i ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
																		objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
     DUBUG_LOG(@"Now you are completed deleteAppFromLoginItem method in jiwokAppDelegate class");
}

-(void)cleanUpDisk{
    DUBUG_LOG(@"Now you are in cleanUpDisk method in jiwokAppDelegate class");
	
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
	NSFileManager *fileManager=[NSFileManager defaultManager];
	
	NSString *tmpPath1=[[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp" ];
	NSString *tmpPath2=[bundlePath  stringByAppendingPathComponent:@"Temp" ];
	
	[fileManager removeItemAtPath:tmpPath1 error:nil];
	[fileManager removeItemAtPath:tmpPath2 error:nil];
	
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
																   kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
	
	NSString *localVocalPath=[workOutDirectory stringByAppendingPathComponent:@"Temp"];
	
	[fileManager removeItemAtPath:localVocalPath error:nil];
    DUBUG_LOG(@"Now you are completed cleanUpDisk method in jiwokAppDelegate class");
}

-(void)cleanUpLog{
 DUBUG_LOG(@"Now you are in cleanUpLog method in jiwokAppDelegate class");
	NSFileManager *fileManager=[NSFileManager defaultManager];
	
	NSString *logFilePath = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:JIWOK_LOG_NAME];	
	if([fileManager fileExistsAtPath:logFilePath])
	{		
		NSDictionary *attributes= [fileManager attributesOfItemAtPath:logFilePath error:NULL];
		if([[attributes objectForKey:NSFileSize] intValue]>10000000) 
		{
			[fileManager removeItemAtPath:logFilePath error:nil];
		}
	}
DUBUG_LOG(@"Now you are completed cleanUpLog method in jiwokAppDelegate class");
}


-(void)cleanUpdates{
     DUBUG_LOG(@"Now you are in cleanUpdates method in jiwokAppDelegate class");

	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];	
	NSString *updateAppPath=[NSString stringWithFormat:@"%@/Jiwok.app",bundlePath ];	
	NSString *updateZipPath=[NSString stringWithFormat:@"%@/Jiwok.zip",bundlePath ];

	[[NSFileManager defaultManager] removeItemAtPath:updateAppPath error:nil];	
	[[NSFileManager defaultManager] removeItemAtPath:updateZipPath error:nil];
     DUBUG_LOG(@"Now you are completed cleanUpdates method in jiwokAppDelegate class");
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
     DUBUG_LOG(@"Now you are in applicationShouldTerminate method in jiwokAppDelegate class");
	if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_EXIT_APP"):JIWOK_ALERT_OK_CANCEL])// OK selected
	{	
		return NSTerminateNow;
	
	}
	else {
		return NSTerminateCancel;
	}

 //NSLog(@"Now you are completed applicationShouldTerminate method in jiwokAppDelegate class");
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
	DUBUG_LOG(@"Now you are in applicationWillTerminate method in jiwokAppDelegate class");
	DUBUG_LOG(@"applicationWillTerminate");
	
	//if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_EXIT_APP"):JIWOK_ALERT_OK_CANCEL])// OK selected
//	{
	
		//[self cleanUpLog];
	
		[self cleanUpDisk];		
		[NSApp terminate:self]; 
	DUBUG_LOG(@"Now you are completed applicationWillTerminate method in jiwokAppDelegate class");
	//}
}

@end
