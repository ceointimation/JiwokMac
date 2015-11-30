//
//  JiwokAppDelegate.h
//  Jiwok
//
//  Created by Reubro on 02/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JiwokLoginWindowController.h"
#import "JiwokDownloderWindowController.h"
#import "JiwokMainWindowController.h"
#import "Variable.h"

#import "Delegates.h"


BOOL analysingInProgress ;
BOOL workoutGenerationInProgress ;
BOOL forceFullygeneratedWorkout  ;
BOOL runningPreviousUserWorkout;
BOOL bstopAnalyzeFlag;
BOOL bWorkOutInProgress;

@interface JiwokAppDelegate : NSObject {
	JiwokLoginWindowController* loginwindow;
	JiwokDownloderWindowController* downloadwindow;
	JiwokMainWindowController *mainwindow;
	
	NSString * loggedusername;
	NSString * loggedpassword;
	NSString * workoutQueueID;
	BOOL isLogged,updateAvailable;
	
	IBOutlet NSMenu *dynamicMenu;	
	IBOutlet NSMenu *topMenu;
	
	NSMenuItem *dynamicItem,*dynamicItem1,*dynamicItem2,*dynamicItem3;
	
	NSStatusItem * statusItem;
}

 @property (nonatomic,retain) NSString * loggedusername;
 @property (nonatomic,retain) NSString * loggedpassword;
 @property (nonatomic,assign) BOOL isLogged;
 @property (nonatomic,assign) BOOL updateAvailable;
 @property (nonatomic,retain) NSString * workoutQueueID;

- (void)copyDatabaseFile;
-(BOOL)UpdateStatusOfMusicFiles;
-(void)UpdateTagDetectedGenres;

-(void)updateDockImage;
-(void)setDocMenuiTems;
-(void)setTopMenuiTems;

-(void) addAppAsLoginItem;
-(void) deleteAppFromLoginItem;


-(IBAction)StartAutomaticallyAction:(NSMenuItem *)menuItem;
-(IBAction)RelaunchMusicDetectionAction:(NSMenuItem *)menuItem;
-(IBAction)AutoDetectionAction:(NSMenuItem *)menuItem;
-(IBAction)VersionAction:(NSMenuItem *)menuItem;
-(IBAction)closeAction:(NSMenuItem *)menuItem;

- (IBAction)showAboutPanel:(id)sender;


-(void)cleanUpDisk;
-(void)cleanUpdates;
-(void)cleanUpLog;

-(void)copyNewMp3Files;

@end
