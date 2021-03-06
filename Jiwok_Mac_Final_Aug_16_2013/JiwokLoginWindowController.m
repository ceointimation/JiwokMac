//
//  JiwokLoginWindowController.m
//  Jiwok
//
//  Created by Reubro on 02/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokLoginWindowController.h"
#import "LoggerClass.h"
#import "JiwokAppDelegate.h"
//#import "JiwokAPIHelper.h"
#import "JiwokUtil.h"
#import "Common.h"
#import "JiwokDownloderWindowController.h"
#import "JiwokSettingPlistReader.h"
//#import "Variable.h"

@implementation JiwokLoginWindowController
 
-(IBAction)login:(id)sender
{
     DUBUG_LOG(@"Now you are in login method in JiwokLoginWindowController class");
	do 
	{
		NSString *sUsername = [Username stringValue];
		NSString *sPassword = [Password stringValue];
		if ( [sUsername isEqualToString:@""  ] || [sUsername isEqual:nil])
		{
			[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_ENTER_USERNAME"):JIWOK_ALERT_OK];
			return;
		}
		if ([sPassword isEqualToString:@""] || [sPassword isEqual:nil])
		{
			[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_ENTER_PWD"):JIWOK_ALERT_OK];
			return;
		}

		NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
		if (jiwokURL)
		{
			if (![JiwokUtil checkForInternetConnection:jiwokURL])
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
				return;
			}
			else
			{
				[[LoggerClass getInstance] logData:@"Preparing for login"];
			}
		}
		

		[btnCancel setEnabled:NO];
		[progressBar setHidden:NO];
		[progressBar startAnimation:self];

		JiwokAPIHelper *apiHelper =[[JiwokAPIHelper alloc] init];
		[[LoggerClass getInstance] logData:@"username and PWD %@ %@",sUsername,sPassword];
		
		NSMutableDictionary *dictionary = [apiHelper InvokeUserdetailsAPI:sUsername:sPassword];
		 NSLog(@"dictionary NSMutableDictionary==%@",dictionary);
		if([dictionary count] > 0) // login success
		{
			[[LoggerClass getInstance] logData:@"got login response..."];
			
			//NSLog(@"parsing got response %@",dictionary );
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			appdelegate.loggedusername = [dictionary objectForKey:@"username"];
			appdelegate.loggedpassword = [dictionary objectForKey:@"password"];
			
			if ([appdelegate.loggedusername isEqualToString:@""] ||  [appdelegate.loggedusername isEqual:nil]  )
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_LOGIN_FAILED"):JIWOK_ALERT_OK];
				[apiHelper release];
				exit(0);
			}
			appdelegate.isLogged	   = YES;
			[[LoggerClass getInstance] logData:@"Current username and password %@, %@",appdelegate.loggedusername,appdelegate.loggedpassword];
			[[LoggerClass getInstance] logData:@"Login completed successfully..."];
			[apiHelper JiwokUpdateLoginStatusAPI:sUsername:@"1"];
			
			[apiHelper release];
			
			if (NSAppKitVersionNumber>1038)
			{
				
				CFPreferencesSetValue(CFSTR("UserName"), sUsername, CFSTR(APPID), 
									  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
				CFPreferencesSetValue(CFSTR("Password"), sPassword, CFSTR(APPID), 
									  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
				CFPreferencesSetValue(CFSTR("AutoUserName"), sUsername, CFSTR(APPID), 
									  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
				CFPreferencesSetValue(CFSTR("AutoPassword"), sPassword, CFSTR(APPID), 
									  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
				CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
			
			}
			else {
				
				CFPreferencesSetValue(CFSTR("UserName"), sUsername, CFSTR(APPID), 
									  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 
				CFPreferencesSetValue(CFSTR("Password"), sPassword, CFSTR(APPID), 
									  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 
				CFPreferencesSetValue(CFSTR("AutoUserName"), sUsername, CFSTR(APPID), 
									  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 
				CFPreferencesSetValue(CFSTR("AutoPassword"), sPassword, CFSTR(APPID), 
									  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 
				CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
			}


			
			
			
			
			NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
			//NSString *localVocalPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Vocals"];
			
			NSString *localVocalPath = [bundlePath  stringByAppendingPathComponent:@"Vocals"];

			
			if(appdelegate.updateAvailable)
			{			
				JiwokDownloderWindowController *downloadwindow = [JiwokDownloderWindowController alloc];
				[downloadwindow initWithWindowNibName:@"JiwokDownloadWindow"];
				[downloadwindow showWindow:self];
				
			}
			else {
							

			NSFileManager *fileManager = [NSFileManager defaultManager];
			if(![fileManager fileExistsAtPath:localVocalPath])
			{				
				JiwokDownloderWindowController *downloadwindow = [JiwokDownloderWindowController alloc];
				[downloadwindow initWithWindowNibName:@"JiwokDownloadWindow"];
				[downloadwindow showWindow:self];
				break;
			}
			else
			{
				// show music search window
				//searchloadwindow = [JiwokMusicalSearchWindowController alloc];
//				[searchloadwindow initWithWindowNibName:@"JiwokMusicalSearchWindow"];
//				[searchloadwindow showWindow:self];
				JiwokMainWindowController * mainwindow = [JiwokMainWindowController alloc];
				[mainwindow initWithWindowNibName:@"JiwokMainWindow"];
				[mainwindow showWindow:self];
			}
				
			}
		}
		else
		{
			[apiHelper release];
			[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_LOGIN_FAILED"):JIWOK_ALERT_OK];
		}
	} 
	while(0);

	[progressBar stopAnimation:self];
	[progressBar setHidden:YES];
	[btnCancel setEnabled:YES];
	[self close];
    DUBUG_LOG(@"Now you are completed login method in JiwokLoginWindowController class");
}

-(IBAction)QuitApplication:(id)sender
{
    DUBUG_LOG(@"Now you are in QuitApplication method in JiwokLoginWindowController class");
    [NSApp terminate:self];
    DUBUG_LOG(@"Now you are completed QuitApplication method in JiwokLoginWindowController class");
	
}
-(IBAction)cancel:(id)sender
{
	
}
- (void)windowDidLoad
{
	

	//NSImage* image = [NSImage imageNamed:@"Login_Bg.png"];
//	NSColor* patColour = [NSColor colorWithPatternImage:image];
//	
//	[self.window setBackgroundColor: [NSColor orangeColor]];

}
- (id)initWithWindowNibName:(NSString *)windowNibName
{
     //DUBUG_LOG(@"Now you are in initWithWindowNibName method in JiwokLoginWindowController class");
	self = [super initWithWindowNibName:windowNibName];

	return self;
    //NSLog(@"Now you are completed initWithWindowNibName method in JiwokLoginWindowController class");
}
- (void)awakeFromNib
{
    [Username becomeFirstResponder];
//	NSLog(@"set image");
	DUBUG_LOG(@"Now you are in awakeFromNib method in JiwokLoginWindowController class");
	NSString *imageNameLogin = [[NSString alloc] initWithFormat:@"logIn_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	NSString *imageNameCancel = [[NSString alloc] initWithFormat:@"logIn_Cancel_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	
//	NSLog(@"image name %@",imageNameCancel);
	
	[btnLogin setImage:[NSImage imageNamed:imageNameLogin]];
	[btnCancel setImage:[NSImage imageNamed:imageNameCancel]];

	[imageNameLogin release];
	[imageNameCancel release];
	[lblUsername setStringValue:JiwokLocalizedString(@"LBL_USERNAME")];
	[lblPassword setStringValue: JiwokLocalizedString(@"LBL_PASSWORD")];
	
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"Login_Bg.png"]]];
    
//	NSImage* image = [NSImage imageNamed:@"Login_Bg.png"];
//	NSColor* patColour = [NSColor colorWithPatternImage:image];
//	[self.window setBackgroundColor:patColour];
	//[self.window setBackgroundColor: [NSColor orangeColor]];
	//NSImageView *imgview =  [NSImage imageNamed: @"Login_Bg.png"];
//	[self.window addSubview:imgview];
	//[self.window setBackgroundColor: [NSColor orangeColor]];//[NSColor colorWithPatternImage: [NSImage imageNamed: @"Login_Bg.png"]];
	DUBUG_LOG(@"Now you are completed awakeFromNib method in JiwokLoginWindowController class");
}
@end
