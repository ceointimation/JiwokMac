//
//  JiwokMainWindowController.m
//  Jiwok
//
//  Created by reubro R on 14/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokMainWindowController.h"
#import "JiwokUtil.h"
#import "Common.h"
#import "JiwokAppDelegate.h"
#import "LoggerClass.h"

BOOL shouldAnalyzeSongs=NO;


@implementation JiwokMainWindowController


-(IBAction)logintab:(id)sender
{
   DUBUG_LOG(@"Now you are in logintab method in jiwokMainWindowController class");
	[self changeViewController:0];
	[self changeTabButtonImages:0];
   DUBUG_LOG(@"Now you are completed the logintab method in jiwokMainWindowController class");
}
-(IBAction)mymusictab:(id)sender
{
    DUBUG_LOG(@"Now you are in mymusictab method in jiwokMainWindowController class");	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	if (appdelegate.isLogged == NO)
	{
		return;
	}
	[self changeViewController:1];
	[self changeTabButtonImages:1];
     DUBUG_LOG(@"Now you are completed the mymusictab method in jiwokMainWindowController class");
}
-(IBAction)supporttab:(id)sender
{
     DUBUG_LOG(@"Now you are in supporttab method in jiwokMainWindowController class");
	[self changeViewController:3];
	[self changeTabButtonImages:3];
    DUBUG_LOG(@"Now you are completed the supporttab method in jiwokMainWindowController class");

}
-(IBAction)myworkouttab:(id)sender
{
	//if (bFolderIterationInProgress)
//	{
//		DUBUG_LOG(@"----  bFolderIterationInProgress -------");
//		return;
//	}
	DUBUG_LOG(@"Now you are in myworkouttab method in jiwokMainWindowController class");
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	if (appdelegate.isLogged == NO)
	{
		return;
	}
	
	//NSRect frame = [customTabContentView frame];
//	frame.size.width = 740;
//	frame.size.height = 450;
	
	//[customTabContentView setFrame:frame];
	[self changeViewController:2];
	[self changeTabButtonImages:2];
   DUBUG_LOG(@"Now you are completed the myworkouttab method in jiwokMainWindowController class");
}
- (id)initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];			
	
	return self;
}
- (void)changeTabButtonImages:(NSInteger)tabNumber
{
    DUBUG_LOG(@"Here we start the execution of tabbutton image changing method called changeTabButtonImages in jiwokMainWindowController class");
	if (tabNumber == 0)
	{
		NSString *imageNameLoginHover = [[NSString alloc] initWithFormat:@"loginTab_Hover_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnLogintab setImage:[NSImage imageNamed:imageNameLoginHover]];
		[imageNameLoginHover release];
		
		NSString *imageNameMymusicNormal = [[NSString alloc] initWithFormat:@"myMusicTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyMusictab setImage:[NSImage imageNamed:imageNameMymusicNormal]];
		[imageNameMymusicNormal release];
		
		NSString *imageNameMyWorkoutNormal = [[NSString alloc] initWithFormat:@"myWorkoutTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyWorkouttab setImage:[NSImage imageNamed:imageNameMyWorkoutNormal]];
		[imageNameMyWorkoutNormal release];	
		
		NSString *imageNameSupportNormal = [[NSString alloc] initWithFormat:@"support_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnSupporttab setImage:[NSImage imageNamed:imageNameSupportNormal]];
		[imageNameSupportNormal release];	
	}	
	
	if (tabNumber == 1)
	{
		NSString *imageNameLoginNormal = [[NSString alloc] initWithFormat:@"loginTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnLogintab setImage:[NSImage imageNamed:imageNameLoginNormal]];
		[imageNameLoginNormal release];
		
		NSString *imageNameMymusicHover = [[NSString alloc] initWithFormat:@"myMusicTab_Hover_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyMusictab setImage:[NSImage imageNamed:imageNameMymusicHover]];
		[imageNameMymusicHover release];

		NSString *imageNameMyWorkoutNormal = [[NSString alloc] initWithFormat:@"myWorkoutTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyWorkouttab setImage:[NSImage imageNamed:imageNameMyWorkoutNormal]];
		[imageNameMyWorkoutNormal release];	
		NSString *imageNameSupportNormal = [[NSString alloc] initWithFormat:@"support_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnSupporttab setImage:[NSImage imageNamed:imageNameSupportNormal]];
		[imageNameSupportNormal release];	
	}	
	if (tabNumber == 2)
	{
		NSString *imageNameLoginNormal = [[NSString alloc] initWithFormat:@"loginTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnLogintab setImage:[NSImage imageNamed:imageNameLoginNormal]];
		[imageNameLoginNormal release];
		
		NSString *imageNameMymusicNormal = [[NSString alloc] initWithFormat:@"myMusicTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyMusictab setImage:[NSImage imageNamed:imageNameMymusicNormal]];
		[imageNameMymusicNormal release];
		
		NSString *imageNameMyWorkoutHover = [[NSString alloc] initWithFormat:@"myWorkoutTab_Hover_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyWorkouttab setImage:[NSImage imageNamed:imageNameMyWorkoutHover]];
		[imageNameMyWorkoutHover release];	
		
		NSString *imageNameSupportNormal = [[NSString alloc] initWithFormat:@"support_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnSupporttab setImage:[NSImage imageNamed:imageNameSupportNormal]];
		[imageNameSupportNormal release];	
	}

	if (tabNumber == 3)
	{
		NSString *imageNameLoginNormal = [[NSString alloc] initWithFormat:@"loginTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnLogintab setImage:[NSImage imageNamed:imageNameLoginNormal]];
		[imageNameLoginNormal release];
		
		NSString *imageNameMymusicNormal = [[NSString alloc] initWithFormat:@"myMusicTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyMusictab setImage:[NSImage imageNamed:imageNameMymusicNormal]];
		[imageNameMymusicNormal release];
		
		NSString *imageNameMyWorkoutHover = [[NSString alloc] initWithFormat:@"myWorkoutTab_Normal_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnMyWorkouttab setImage:[NSImage imageNamed:imageNameMyWorkoutHover]];
		[imageNameMyWorkoutHover release];	
		
		NSString *imageNameSupportNormal = [[NSString alloc] initWithFormat:@"support_Hover_%@.png",[JiwokUtil GetShortCurrentLocale]];
		[btnSupporttab setImage:[NSImage imageNamed:imageNameSupportNormal]];
		[imageNameSupportNormal release];	
	}
    DUBUG_LOG(@"Here we end the execution of tabbutton image changing method called changeTabButtonImages in jiwokMainWindowController class");
}
- (void)showTabs
{
	// music tab will be activated only when selected
	DUBUG_LOG(@"Now you are in showTabs method in jiwokMainWindowController class");
	
	NSArray *userSelectedArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetallUserSelectedFolders];

	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	BOOL dbCheck = [appdelegate UpdateStatusOfMusicFiles];
	if(dbCheck)
	{
		
		[self changeTabButtonImages:3];
		[self changeViewController:3];
		[self changeTabButtonImages:2];
		[self changeViewController:2];
		[self changeViewController:0];
		[self changeTabButtonImages:0];
		
		
		NSLog(@"IF IF IF ");
		
	}
	else
	{
		
		NSLog(@"ESLE ELSE ELSE");

		
	//	if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"INFO-FOR_MUSIC_SELECT"):JIWOK_ALERT_YES_NO])
	//	{
			[self changeTabButtonImages:3];
			[self changeViewController:3];
			[self changeTabButtonImages:2];
			[self changeViewController:2];
			[self changeViewController:0];
			[self changeTabButtonImages:0];
			[self changeViewController:1];
			[self changeTabButtonImages:1];
			
		
		
		//[musicVC performSelector:@selector(addFolderAction:)];
		
		//if([userSelectedArray count]==0)
		//[musicVC performSelector:@selector(addFolderAction:) withObject:nil afterDelay:.02f];
			[self autoShowTree];
		
	}
	
	if(([userSelectedArray count]>0)&&([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDetect"]))
	{
		[musicVC performSelector:@selector(didAddFolder) withObject:nil afterDelay:.02f];	
	}
    DUBUG_LOG(@"Now you are completed the showTabs method in jiwokMainWindowController class");
}

-(void)autoShowTree{

	DUBUG_LOG(@"Now you are in autoShowTree method in jiwokMainWindowController class");
	NSArray *userSelectedArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetallUserSelectedFolders];
	 NSLog(@"userSelectedArray NSArray==%@",userSelectedArray);
	if([userSelectedArray count]==0)
	{
		//DUBUG_LOG(@"autoShowTree %d musicVC is %@",[userSelectedArray count],musicVC);		
		[musicVC performSelector:@selector(addFolderAction:) withObject:nil afterDelay:.02f];		
	}
    DUBUG_LOG(@"Now you are completed the autoShowTree method in jiwokMainWindowController class");
}


-(void)checkForAutoDisplaying{
    DUBUG_LOG(@"Now you are in checkForAutoDisplaying method in jiwokMainWindowController class");
	DUBUG_LOG(@"checkForAutoDisplaying");	
	
	[self autoShowTree];
    DUBUG_LOG(@"Now you are completed the checkForAutoDisplaying method in jiwokMainWindowController class");
}


-(void)relaunchDetection{
	 DUBUG_LOG(@"Now you are in relaunchDetection method in jiwokMainWindowController class");
	if(!analysingInProgress){		
		NSArray *userSelectedArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] GetallUserSelectedFolders];
		 NSLog(@"userSelectedArray NSArray==%@",userSelectedArray);
		if([userSelectedArray count]>0)
			[musicVC performSelector:@selector(didAddFolder) withObject:nil afterDelay:.02f];
		else 
			[musicVC performSelector:@selector(addFolderAction:) withObject:nil afterDelay:.02f];	
	
	}
    DUBUG_LOG(@"Now you are completed the relaunchDetection method in jiwokMainWindowController class");
}


- (void)awakeFromNib
{
	//[self.window makeKeyAndOrderFront:self];
	
	//[self.window makeMainWindow];
	
	
	//NSLog(@"awakeFromNib is %@",self.window);
	
	//[self.window makeKeyAndOrderFront:NULL];
	DUBUG_LOG(@"Now you are in awakeFromNib method in jiwokMainWindowController class");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWindow:) name:@"SHOW_MAIN_WINDOW" object:nil];

	
	
	currentTab = -1;
	[self showTabs];
	
	DUBUG_LOG(@"Now you are completed the awakeFromNib method in jiwokMainWindowController class");
	
}
- (void)changeViewController:(NSInteger)tabNumber
{
     DUBUG_LOG(@"Here we start the changeViewController method in jiwokMainWindowController class");
	if (currentTab == tabNumber)
	{
		return;
	}
	currentTab = tabNumber;
	
	[self willChangeValueForKey:@"viewController"];
	
	if ([currentViewController view] != nil)
		[[currentViewController view] removeFromSuperview];	
	
	//if (currentViewController != nil)
	//	[currentViewController release];		
	
	switch (tabNumber)
	{
		case 0:	
		{
			if (!LoginVC)
			{
                NSLog(@"ChangeViewController method in jiwokMainWindowController class is going to load JiwokLoginPanelViewController class");
				LoginVC = [JiwokLoginPanelViewController alloc];
				[LoginVC initWithNibName:@"JiwokLoginPanelView" bundle:nil];
				LoginVC.delegate=self;
				[LoginVC loadView];
                NSLog(@"ChangeViewController method in jiwokMainWindowController class ending loading of JiwokLoginPanelViewController class");
			}
			currentViewController = LoginVC;
			[currentViewController setTitle:JIWOK_TITLE];
			break;
		}
			
		case 1:
		{
			if (!musicVC)
			{
                NSLog(@"ChangeViewController method in jiwokMainWindowController class is going to load JiwokMyMusicPanelViewController class");
				musicVC = [JiwokMyMusicPanelViewController alloc];
				musicVC.delegate = self;
				[musicVC initWithNibName:@"JiwokMyMusicPanelView" bundle:nil];
				[musicVC loadView];
                NSLog(@"ChangeViewController method in jiwokMainWindowController class ending loading of JiwokMyMusicPanelViewController class");
			}
			currentViewController = musicVC;
			[currentViewController setTitle:JIWOK_TITLE];
			break;

		}
			
		case 2:	
		{
			if (!workoutVC)
			{
                NSLog(@"ChangeViewController method in jiwokMainWindowController class is going to load JiwokMyWorkoutPanelViewController class");
				workoutVC = [JiwokMyWorkoutPanelViewController alloc];
				[workoutVC initWithNibName:@"JiwokMyWorkoutPanelView" bundle:nil];
				[workoutVC loadView];
                NSLog(@"ChangeViewController method in jiwokMainWindowController class ending loading of JiwokMyWorkoutPanelViewController class");
			}
			
			currentViewController = workoutVC;
			[currentViewController setTitle:JIWOK_TITLE];
			break;
		}
			
		case 3:
		{
			if (!supportVC)
			{
                NSLog(@"ChangeViewController method in jiwokMainWindowController class is going to load JiwokSupportPanelViewController class");
				supportVC = [JiwokSupportPanelViewController alloc];
				[supportVC initWithNibName:@"JiwokSupportPanelView" bundle:nil];
				[supportVC loadView];
                NSLog(@"ChangeViewController method in jiwokMainWindowController class ending loading of JiwokSupportPanelViewController class");
			}
			
			currentViewController = supportVC;
			[currentViewController setTitle:JIWOK_TITLE];
			break;
		}
	}
	

	[customTabContentView addSubview: [currentViewController view]];
	
	
	//[[currentViewController view] setFrame: [customTabContentView bounds]];
	
	[currentViewController setRepresentedObject: [NSNumber numberWithUnsignedInt: [[[currentViewController view] subviews] count]]];
	
	[self didChangeValueForKey:@"viewController"];
}

-(void)didStartIteration
{
    DUBUG_LOG(@"Now you are in didStartIteration method in jiwokMainWindowController class");
	DUBUG_LOG(@"----  bFolderIterationInProgress -------");
	bFolderIterationInProgress = YES;
   DUBUG_LOG(@"Now you are completed the didStartIteration method in jiwokMainWindowController class");
}
-(void)didCompleteIteration
{
   DUBUG_LOG(@"Now you are in didCompleteIteration method in jiwokMainWindowController class");
	bFolderIterationInProgress = NO;
     DUBUG_LOG(@"Now you are completed the didCompleteIteration method in jiwokMainWindowController class");
}

- (void) windowWillClose:(NSNotification *) notification
{
	DUBUG_LOG(@"Now you are in windowWillClose method in jiwokMainWindowController class");
}

- (BOOL)windowShouldClose:(id)sender{	
	DUBUG_LOG(@"Now you are in windowShouldClose method in jiwokMainWindowController class");
	[sender orderOut:self];
	return NO; 
     DUBUG_LOG(@"Now you are completed the windowShouldClose method in jiwokMainWindowController class");
}


-(void)showWindowAfterHiding{	
	
	//NSLog(@"WINDOW ");
	
	//NSLog(@"WINDOW %@",self.window);

	DUBUG_LOG(@"Now you are in showWindowAfterHiding method in jiwokMainWindowController class");
	[self.window makeKeyAndOrderFront:self];
	DUBUG_LOG(@"Now you are completed the showWindowAfterHiding method in jiwokMainWindowController class");
}

-(void)showWindow:(NSNotification *)pNotification {
   DUBUG_LOG(@"Now you are in showWindow method in jiwokMainWindowController class");
	[self showWindowAfterHiding];
    DUBUG_LOG(@"Now you are completed the showWindow method in jiwokMainWindowController class");

}



- (void)dealloc 
{
	[LoginVC release];
	[musicVC release];
	[workoutVC release];
	[super dealloc];
}
@end
