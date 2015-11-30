//
//  JiwokLoginPanelViewController.m
//  Jiwok
//  This shows the login tab of the Jiwok application
//  Created by reubro R on 14/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokLoginPanelViewController.h"
#import "JiwokAppDelegate.h"
#import "Common.h"
#import "JiwokUtil.h"
#import "JiwokAPIHelper.h"
#import "JiwokSettingPlistReader.h"
#import "LoggerClass.h"
#import "JiwokMyWorkoutPanelViewController.h"
#import "Variable.h"

#import "GrowlExample.h"



@implementation JiwokLoginPanelViewController

@synthesize delegate;

- (void)awakeFromNib
{
	//NSLog(@"Now you are in awakeFromNib method in JiwokLoginPanelViewController class");
	[btnRememberMe setState:0];
	[btnAutoLogin setState:0];
	
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	
	if (NSAppKitVersionNumber>1038)
	{
	
		userName = (NSString*)CFPreferencesCopyValue(CFSTR("UserName"), CFSTR(APPID), 
													 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
		password = (NSString*)CFPreferencesCopyValue(CFSTR("Password"), CFSTR(APPID), 
													 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
		autoUserName = (NSString*)CFPreferencesCopyValue(CFSTR("AutoUserName"), CFSTR(APPID), 
														 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
		autoPassword = (NSString*)CFPreferencesCopyValue(CFSTR("AutoPassword"), CFSTR(APPID), 
														 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	}
	else {
		
		userName = (NSString*)CFPreferencesCopyValue(CFSTR("UserName"), CFSTR(APPID), 
														 kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	
		password = (NSString*)CFPreferencesCopyValue(CFSTR("Password"), CFSTR(APPID), 
														 kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	
		autoUserName = (NSString*)CFPreferencesCopyValue(CFSTR("AutoUserName"), CFSTR(APPID), 
														   kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	
		autoPassword = (NSString*)CFPreferencesCopyValue(CFSTR("AutoPassword"), CFSTR(APPID), 
														   kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

	}
	
	
	
	if (![userName isEqualToString:@""] && userName != nil )
	{
		[txtUserName setStringValue:userName];
	}
	if (![password isEqualToString:@""] && password != nil)	
	{
		[txtPWD setStringValue:password];
	}

	if (![autoPassword isEqualToString:@""] && autoPassword != nil)
	{
		[btnRememberMe setState:1];
		[txtPWD setStringValue:autoPassword];
	}
	else
	{
		[txtPWD setStringValue:@""];
	}

	if (![autoUserName isEqualToString:@""] && autoUserName != nil)
	{
		[btnAutoLogin setState:1];
		[txtUserName setStringValue:autoUserName];
		
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
		
		if (appdelegate.isLogged == NO)
		{
			[self doLogin:YES];
		}
		else
		{
			
			bAlreadyConnected = YES;
			[btnConnect setHidden:YES];
			[btnDisconnect setHidden:NO];
			[self doLogin:YES];
		}
	}

	if (bAlreadyConnected == YES)
	{
		[btnConnect setHidden:YES];
		[btnDisconnect setHidden:NO];
	}
	else
	{
		[btnConnect setHidden:NO];
		[btnDisconnect setHidden:YES];
	}
	
	NSString *imageNameConnect = [[NSString alloc] initWithFormat:@"connect_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnConnect setImage:[NSImage imageNamed:imageNameConnect]];
	[imageNameConnect release];

	NSString *imageNameDisconnect = [[NSString alloc] initWithFormat:@"disconnect_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnDisconnect setImage:[NSImage imageNamed:imageNameDisconnect]];
	[imageNameDisconnect release];
	
	[btnRememberMe setTitle:JiwokLocalizedString(@"REMEMBER_ME_BUTTON")];
	[btnAutoLogin setTitle:JiwokLocalizedString(@"AUTO_LOGIN_BUTTON")];	
	[lblUsername setStringValue:JiwokLocalizedString(@"LBL_USERNAME")];
	[lblPassword setStringValue: JiwokLocalizedString(@"LBL_PASSWORD")];
	//NSLog(@"Now you are completed awakeFromNib method in JiwokLoginPanelViewController class");
	
}
-(void) doLogin:(BOOL)bAuto
{
    DUBUG_LOG(@"Now you are in doLogin method in JiwokLoginPanelViewController class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	do 
	{
		NSString *sUsername = [txtUserName stringValue];
		NSString *sPassword = [txtPWD stringValue];
				
		if (bAuto == NO)
		{
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
		}
		else
		{
			if ( [sUsername isEqualToString:@""  ] || [sUsername isEqual:nil])
			{
				[[LoggerClass getInstance] logData:@"Autologin - invalid username"];
				return;
			}
			if ([sPassword isEqualToString:@""] || [sPassword isEqual:nil])
			{
				[[LoggerClass getInstance] logData:@"Autologin - invalid password"];
				return;
			}
			
		}
		[progressBar setHidden:NO];
		[progressBar startAnimation:self];
		
		NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
		if (jiwokURL)
		{
			if (![JiwokUtil checkForInternetConnection:jiwokURL])
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
				[progressBar stopAnimation:self];
				[progressBar setHidden:YES];
				[pool release];
				return;
			}
			else
			{
				[[LoggerClass getInstance] logData:@"Preparing for login"];
			}
		}
		
		JiwokAPIHelper *apiHelper =[[JiwokAPIHelper alloc] init];
		[[LoggerClass getInstance] logData:@"username and PWD %@ %@",sUsername,sPassword];
		
		GrowlExample *growlMsger=[[GrowlExample alloc]init];
		[growlMsger growlAlert:JiwokLocalizedString(@"LOGIN_POPUP") title:nil];
		[growlMsger release];
		
		NSMutableDictionary *dictionary = [apiHelper InvokeUserdetailsAPI:sUsername:sPassword];
		 NSLog(@"dictionary NSMutableDictionary==%@",dictionary);
		if([dictionary count] > 0) // login success
		{
				[[LoggerClass getInstance] logData:@"got login response..."];
			
			NSLog(@"parsing got response %@",dictionary );
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			appdelegate.loggedusername = [dictionary objectForKey:@"username"];
			appdelegate.loggedpassword = [dictionary objectForKey:@"password"];
			
			
			//Newly added for changing doc image			
			[appdelegate updateDockImage];
			
			if ([appdelegate.loggedusername isEqualToString:@""] ||  [appdelegate.loggedusername isEqual:nil]  )
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_LOGIN_FAILED"):JIWOK_ALERT_OK];
				[apiHelper release];
				[btnConnect setHidden:NO];
				break;
			}
			
			/*
			GrowlExample *growlMsger=[[GrowlExample alloc]init];
			[growlMsger growlAlert:JiwokLocalizedString(@"LOGIN_POPUP") title:nil];
			[growlMsger release];
			*/
			
			appdelegate.isLogged= YES;
			bAlreadyConnected = YES;
			[[LoggerClass getInstance] logData:@"Login completed successfully..."];
			[btnDisconnect setHidden:YES];
			[btnConnect setHidden:YES];
			[[LoggerClass getInstance] logData:@"Current username and password %@, %@",appdelegate.loggedusername,appdelegate.loggedpassword];
			
			[apiHelper JiwokUpdateLoginStatusAPI:sUsername:@"1"];
			
			[apiHelper release];
			
			if ([btnRememberMe state] == 1)
			{
				[self rememberPWD:YES];
			}
			else
			{
				[self rememberPWD:NO];
			}
			
			if ([btnAutoLogin state] == 1)
			{
				[self rememberUserName:YES];
			}
			else
			{
				[self rememberUserName:NO];
			}
			DUBUG_LOG(@" checkForAutoDisplaying delegate is %@",delegate);
			
			if ((appdelegate.isLogged == YES)&&(bAuto==NO))
			[delegate checkForAutoDisplaying];
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
	[pool release];
    DUBUG_LOG(@"Now you are completed doLogin method in JiwokLoginPanelViewController class");
}
-(IBAction)connect:(id)sender
{
    DUBUG_LOG(@"Now you are in connect method in JiwokLoginPanelViewController class");
	if (bAlreadyConnected)
	{
		[JiwokUtil showAlert:JiwokLocalizedString(@"INFO_ALREADY_CONNECTED"):JIWOK_ALERT_OK];
	}
	else
	{
		[self doLogin:NO];
		if (bAlreadyConnected == YES)
		{
			[btnConnect setHidden:YES];
			[btnDisconnect setHidden:NO];
		}
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
		[appdelegate updateDockImage];
		
	}
      DUBUG_LOG(@"Now you are completed connect method in JiwokLoginPanelViewController class");
	
}
-(IBAction)discconect:(id)sender
{
     DUBUG_LOG(@"Now you are in discconect method in JiwokLoginPanelViewController class");
	if (bAlreadyConnected)
	{
		NSInteger nRet = [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_DISCONNECT"):JIWOK_ALERT_OK];
		
	
		/*if([self superclass].workoutVC.workoutgenerationThread)
		{
			
			if([workoutVC.workoutgenerationThread isExecuting])
				{
					[workoutVC.workoutgenerationThread cancel];
					[workoutVC.workoutgenerationThread release];
				}
		}*/
		/*JiwokMyWorkoutPanelViewController *workoutPanel =[[JiwokMyWorkoutPanelViewController alloc] init];
		if(workoutPanel.workoutgenerationThread)
		{
			if([workoutPanel.workoutgenerationThread isExecuting])
				[workoutPanel.workoutgenerationThread cancel];
				[workoutPanel.workoutgenerationThread release];
		}*/
		
		if (NSAlertFirstButtonReturn == nRet)
		{
			[progressBar setHidden:NO];
			[progressBar startAnimation:self];
			
			JiwokAPIHelper *apiHelper =[[JiwokAPIHelper alloc] init];
			
			GrowlExample *growlMsger=[[GrowlExample alloc]init];
			[growlMsger growlAlert:JiwokLocalizedString(@"LOGOUT_POPUP") title:nil];
			[growlMsger release];
			
			
			NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
			
			
			if ([JiwokUtil checkForInternetConnection:jiwokURL])
			{			
			[apiHelper JiwokUpdateLoginStatusAPI:[txtUserName stringValue]:@"0"];
			}
			[apiHelper release];
			
			//[JiwokUtil showAlert:JiwokLocalizedString(@"INFO_DISCONNECTED"):JIWOK_ALERT_OK];
			bAlreadyConnected = NO;
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			appdelegate.isLogged = NO;
			[btnDisconnect setHidden:YES];
			[btnConnect setHidden:NO];
			[progressBar stopAnimation:self];
			[progressBar setHidden:YES];
			bstopAnalyzeFlag =YES;
			
			//For stopping the currently ruuning workout
			runningPreviousUserWorkout =YES;
			bWorkOutInProgress =NO;
			apiHelper = [[JiwokAPIHelper alloc]init];
			if ([JiwokUtil checkForInternetConnection:jiwokURL])
			{
			[apiHelper InvokeUpdateMP3GenerationStatusAPI:appdelegate.workoutQueueID:@"2"];
			}
			[apiHelper release];
								
			
			[appdelegate updateDockImage];
						
		}
	}
     DUBUG_LOG(@"Now you are completed discconect method in JiwokLoginPanelViewController class");
}
-(void) rememberPWD:(BOOL) bRemember
{
     DUBUG_LOG(@"Now you are in rememberPWD method in JiwokLoginPanelViewController class");
	if (bRemember == YES)
	{
		if (NSAppKitVersionNumber>1038)
			CFPreferencesSetValue(CFSTR("AutoPassword"), [txtPWD stringValue] , CFSTR(APPID), 
								  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
		else 
			CFPreferencesSetValue(CFSTR("AutoPassword"), [txtPWD stringValue] , CFSTR(APPID), 
							  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 
	}
	else
	{
		if (NSAppKitVersionNumber>1038)			
			CFPreferencesSetValue(CFSTR("AutoPassword"),@"", CFSTR(APPID), 
								  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
		else 
			CFPreferencesSetValue(CFSTR("AutoPassword"),@"", CFSTR(APPID), 
							  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 
	}
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
     DUBUG_LOG(@"Now you are completed rememberPWD method in JiwokLoginPanelViewController class");
}
-(void) rememberUserName:(BOOL) bRemember
{
	DUBUG_LOG(@"Now you are in rememberUserName method in JiwokLoginPanelViewController class");
	NSLog(@"VALUE %@",txtUserName.stringValue);
	
	if (bRemember == YES)
	{
		if (NSAppKitVersionNumber>1038)
			CFPreferencesSetValue(CFSTR("AutoUserName"), [txtUserName stringValue] , CFSTR(APPID), 
								  						  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
		
		else		
			CFPreferencesSetValue(CFSTR("AutoUserName"), [txtUserName stringValue] , CFSTR(APPID), 
							  kCFPreferencesAnyUser, kCFPreferencesCurrentHost); 		
	}
	else
	{
		if (NSAppKitVersionNumber>1038)
			CFPreferencesSetValue(CFSTR("AutoUserName"),@"", CFSTR(APPID), 
								  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		else
			CFPreferencesSetValue(CFSTR("AutoUserName"),@"", CFSTR(APPID), 
							  kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	}
	
	NSLog(@"NSAppKitVersionNumber %f ",NSAppKitVersionNumber);
		
	
//	if (NSAppKitVersionNumber>NSAppKitVersionNumber10_6) {
//		
//	}
	//NSString *autoUserName1 = (NSString*)CFPreferencesCopyValue(CFSTR("AutoUserName"), CFSTR(APPID), 
//													 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
//	
//	NSLog(@"autoUserName1 %@",autoUserName1);
//	
//	CFPreferencesSetValue(CFSTR("AutoUserName"), [txtUserName stringValue] , CFSTR(APPID), 
//						  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
//	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);

	
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
   DUBUG_LOG(@"Now you are completed rememberUserName method in JiwokLoginPanelViewController class");

}
-(IBAction)setRememberpassword:(id)sender
{
   DUBUG_LOG(@"Now you are in setRememberpassword method in JiwokLoginPanelViewController class");
	NSButton * remButton = (NSButton *) sender;
	if ([remButton state])
	{
		[self rememberPWD:YES];
	}
	else
	{
		[self rememberPWD:NO];
	}
     DUBUG_LOG(@"Now you are completed setRememberpassword method in JiwokLoginPanelViewController class");
}
-(IBAction)setAutoLogin:(id)sender
{
    DUBUG_LOG(@"Now you are in setAutoLogin method in JiwokLoginPanelViewController class");
	NSButton * autoButton = (NSButton *) sender;
	if ([autoButton state])
	{
		[self rememberUserName:YES];
	}
	else
	{
		[self rememberUserName:NO];
	}
     DUBUG_LOG(@"Now you are completed setAutoLogin method in JiwokLoginPanelViewController class");
}
@end
