//
//  JiwokMainWindowController.h
//  Jiwok
//
//  Created by reubro R on 14/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Delegates.h"
#import "JiwokMyWorkoutPanelViewController.h"
#import "JiwokLoginPanelViewController.h"
#import "JiwokMyMusicPanelViewController.h"
#import "JiwokSupportPanelViewController.h"

@interface JiwokMainWindowController : NSWindowController<FolderIterationDelegate,UserLoggedInDelegate> {
	IBOutlet NSButton	*btnLogintab;
	IBOutlet NSButton	*btnMyMusictab;
	IBOutlet NSButton	*btnMyWorkouttab;
	IBOutlet NSButton	*btnSupporttab;
	
	IBOutlet NSView		*customTabContentView;
	NSViewController	*currentViewController;
	NSInteger			currentTab;
	BOOL				bFolderIterationInProgress;
	JiwokMyWorkoutPanelViewController *workoutVC;
	JiwokLoginPanelViewController *LoginVC;
	JiwokMyMusicPanelViewController *musicVC;
	JiwokSupportPanelViewController *supportVC;
	
	
}

-(IBAction)logintab:(id)sender;
-(IBAction)mymusictab:(id)sender;
-(IBAction)myworkouttab:(id)sender;
-(IBAction)supporttab:(id)sender;
- (void)changeViewController:(NSInteger)tabNumber;
- (void)changeTabButtonImages:(NSInteger)tabNumber;
- (void)showTabs;

-(void)relaunchDetection;
-(void)autoShowTree;

-(void)showWindowAfterHiding;

@end
