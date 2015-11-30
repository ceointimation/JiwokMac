//
//  GrowlExample.m
//  Jiwok
//
//  Created by Reubro on 2010-12-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GrowlExample.h"

#import "JiwokUtil.h"



#define GROWL_ALERT							JiwokLocalizedString(@"Display a Growl notification")
#define GROWL_STICKY_ALERT					JiwokLocalizedString(@"Display a sticky Growl notification")

#define GROWL_INSTALLATION_WINDOW_TITLE		JiwokLocalizedString(@"Growl Installation Recommended")
#define GROWL_UPDATE_WINDOW_TITLE			JiwokLocalizedString(@"Growl Update Available")

#define GROWL_INSTALLATION_EXPLANATION		JiwokLocalizedString(@"Jiwok uses the Growl notification system to provide a configurable interface to display status changes, incoming messages and more.\n\nIt is strongly recommended that you allow Jiwok to automatically install Growl; no download is required.")
#define GROWL_UPDATE_EXPLANATION			JiwokLocalizedString(@"Jiwok uses the Growl notification system to provide a configurable interface to display status changes, incoming messages and more.\n\nThis release of Jiwok includes an updated version of Growl. It is strongly recommended that you allow Adium to automatically update Growl; no download is required.")

#define GROWL_TEXT_SIZE 11

#define GROWL_EVENT_ALERT_IDENTIFIER		@"Growl"

#define KEY_FILE_TRANSFER_ID	@"fileTransferUniqueID"
#define KEY_CHAT_ID				@"uniqueChatID"
#define KEY_LIST_OBJECT_ID		@"internalObjectID"








@implementation GrowlExample


/* Init method */
- (id) init { 
    NSLog(@"Now you are in init method in GrowlExample class");
    if ( self = [super init] ) {
        /* Tell growl we are going to use this class to hand growl notifications */
        [GrowlApplicationBridge setGrowlDelegate:self];		
		//[GrowlApplicationBridge launchGrowlIfInstalled];
    }
    return self;
    NSLog(@"Now you are completed init method in GrowlExample class");
}

/* Begin methods from GrowlApplicationBridgeDelegate */
- (NSDictionary *) registrationDictionaryForGrowl { /* Only implement this method if you do not plan on just placing a plist with the same data in your app bundle (see growl documentation) */
    NSLog(@"Now you are in registrationDictionaryForGrowl method in GrowlExample class");
	NSArray *array = [NSArray arrayWithObjects:@"example", @"error", nil]; /* each string represents a notification name that will be valid for us to use in alert methods */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1], /* growl 0.7 through growl 1.1 use ticket version 1 */
                          @"TicketVersion", /* Required key in dictionary */
                          array, /* defines which notification names our application can use, we defined example and error above */
                          @"AllNotifications", /*Required key in dictionary */
                          array, /* using the same array sets all notification names on by default */
                         @"DefaultNotifications", /* Required key in dictionary */
                         nil];
    NSLog(@"dict==%@",dict);	
    return dict;   
	
	
	
	/*
	NSMutableArray  *notifNames = [[NSMutableArray alloc] init];
	 [notifNames addObject:@"example"];
	 [notifNames addObject:@"error"];
	
	 NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
							                                 notifNames, GROWL_NOTIFICATIONS_ALL,
							                                 notifNames, GROWL_NOTIFICATIONS_DEFAULT,
							                                 nil];
	
	 [notifNames release];
	
	return regDict;
	 
	 */
	
	NSLog(@"Now you are completed registrationDictionaryForGrowl method in GrowlExample class");
}

- (void) growlNotificationWasClicked:(id)clickContext{
    NSLog(@"Now you are in growlNotificationWasClicked method in GrowlExample class");
    if (clickContext && [clickContext isEqualToString:@"exampleClickContext"])
        [self exampleClickContext];
    return;
    NSLog(@"Now you are completed growlNotificationWasClicked method in GrowlExample class");
}
/*
- (NSString *)applicationNameForGrowl
{
	return @"Jiwok";
}

/*

/*!
 * @brief The title of the window shown if Growl needs to be installed
 
- (NSString *)growlInstallationWindowTitle
{
	return GROWL_INSTALLATION_WINDOW_TITLE;	
}

/*!
 * @brief The title of the window shown if Growl needs to be updated
 
- (NSString *)growlUpdateWindowTitle
{
	return GROWL_UPDATE_WINDOW_TITLE;
}

/*!
 * @brief The body of the window shown if Growl needs to be installed
 *
 * This method calls _growlInformationForUpdate.
 
- (NSAttributedString *)growlInstallationInformation
{
	return [self _growlInformationForUpdate:NO];
}

/*!
 * @brief The body of the window shown if Growl needs to be update
 *
 * This method calls _growlInformationForUpdate.
 
- (NSAttributedString *)growlUpdateInformation
{
	return [self _growlInformationForUpdate:YES];
}

/*!
 * @brief Returns the body text for the window displayed when Growl needs to be installed or updated
 *
 * @param isUpdate YES generates the message for the update window, NO likewise for the install window.

- (NSAttributedString *)_growlInformationForUpdate:(BOOL)isUpdate
{
	NSMutableAttributedString	*growlInfo;
	
	//Start with the window title, centered and bold
	NSMutableParagraphStyle	*centeredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[centeredStyle setAlignment:NSCenterTextAlignment];
	
	growlInfo = [[NSMutableAttributedString alloc] initWithString:(isUpdate ? GROWL_UPDATE_WINDOW_TITLE : GROWL_INSTALLATION_WINDOW_TITLE)
													   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
																   centeredStyle,NSParagraphStyleAttributeName,
																   [NSFont boldSystemFontOfSize:GROWL_TEXT_SIZE], NSFontAttributeName,
																   nil]];
	//Skip a line
	[[growlInfo mutableString] appendString:@"\n\n"];
	
	//Now provide a default explanation
	NSAttributedString *defaultExplanation;
	defaultExplanation = [[[NSAttributedString alloc] initWithString:(isUpdate ? GROWL_UPDATE_EXPLANATION : GROWL_INSTALLATION_EXPLANATION)
														  attributes:[NSDictionary dictionaryWithObjectsAndKeys:
																	  [NSFont systemFontOfSize:GROWL_TEXT_SIZE], NSFontAttributeName,
																	  nil]] autorelease];
	
	[growlInfo appendAttributedString:defaultExplanation];
	
	return [growlInfo autorelease];
}






/* These methods are not required to be implemented, so we will skip them in this example 
 - (NSString *) applicationNameForGrowl;
 - (NSData *) applicationIconDataForGrowl;
 - (void) growlNotificationTimedOut:(id)clickContext;
 */ 
/* There is no good reason not to rely on the what Growl provides for the next two methods, in otherwords, do not override these methods
 - (void) growlIsReady;
 - (void) growlIsInstalled;
 */
/* End Methods from GrowlApplicationBridgeDelegate */

/* Simple method to make an alert with growl that has no click context */
-(void) growlAlert:(NSString *)message title:(NSString *)title{
	NSLog(@"Now you are in growlAlert method in GrowlExample class");
	NSLog(@"isGrowlInstalled is %d isGrowlRunning is %d",[GrowlApplicationBridge isGrowlInstalled],[GrowlApplicationBridge isGrowlRunning]);
	
	
	NSLog(@"BOOLS are %d %d",[[NSUserDefaults standardUserDefaults] objectForKey:@"Growl Update:Do Not Prompt Again:Last Version"],[[NSUserDefaults standardUserDefaults] boolForKey:@"Growl Installation:Do Not Prompt Again"]);
	//[GrowlApplicationBridge launchGrowlIfInstalled];
	
	//NSLog(@"isGrowlInstalled is %d isGrowlRunning is %d",[GrowlApplicationBridge isGrowlInstalled],[GrowlApplicationBridge isGrowlRunning]);

	
    [GrowlApplicationBridge notifyWithTitle:title /* notifyWithTitle is a required parameter */
								description:message /* description is a required parameter */
						   notificationName:@"example" /* notification name is a required parameter, and must exist in the dictionary we registered with growl */
								   iconData:nil /* not required, growl defaults to using the application icon, only needed if you want to specify an icon. */ 
								   priority:0 /* how high of priority the alert is, 0 is default */
								   isSticky:NO /* indicates if we want the alert to stay on screen till clicked */
							   clickContext:nil]; /* click context is the method we want called when the alert is clicked, nil for none */
	
	//[GrowlApplicationBridge launchGrowlIfInstalled];
	
	NSLog(@"BOOLS are %d %d",[[NSUserDefaults standardUserDefaults] objectForKey:@"Growl Update:Do Not Prompt Again:Last Version"],[[NSUserDefaults standardUserDefaults] boolForKey:@"Growl Installation:Do Not Prompt Again"]);
NSLog(@"Now you are completed growlAlert method in GrowlExample class");
}

/* Simple method to make an alert with growl that has a click context */
-(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title{
    NSLog(@"Now you are in growlAlertWithClickContext method in GrowlExample class");
    [GrowlApplicationBridge notifyWithTitle:title /* notifyWithTitle is a required parameter */
                                description:message /* description is a required parameter */
                           notificationName:@"example" /* notification name is a required parameter, and must exist in the dictionary we registered with growl */
                                   iconData:nil /* not required, growl defaults to using the application icon, only needed if you want to specify an icon. */ 
                                   priority:0 /* how high of priority the alert is, 0 is default */
                                   isSticky:NO /* indicates if we want the alert to stay on screen till clicked */
                               clickContext:@"exampleClickContext"]; /* click context is the method we want called when the alert is clicked, nil for none */
     NSLog(@"Now you are completed growlAlertWithClickContext method in GrowlExample class");
}

/* An example click context */
-(void) exampleClickContext{
    /* code to execute when alert is clicked */
     NSLog(@"Now you are in exampleClickContext method in GrowlExample class");
    return;
    NSLog(@"Now you are completed exampleClickContext method in GrowlExample class");
}

/* Dealloc method */
- (void) dealloc { 
    [super dealloc]; 
}


@end
