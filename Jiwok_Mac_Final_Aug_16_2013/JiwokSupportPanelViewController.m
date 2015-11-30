//
//  JiwokSupportPanelViewController.m
//  Jiwok
//
//  Created by reubro R on 19/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokSupportPanelViewController.h"
#import "SupportTab.h"
#import "JiwokUtil.h"
#import "LoggerClass.h"

@implementation JiwokSupportPanelViewController
- (void)awakeFromNib
{
    NSLog(@"Now you are in awakeFromNib method in JiwokSupportPanelViewController class");
	NSString *imageNameSave = [[NSString alloc] initWithFormat:@"Save_WorkoutLoc_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnSend setImage:[NSImage imageNamed:imageNameSave]];
	[imageNameSave release];
	
	[txtGetTicketURL setAllowsEditingTextAttributes: YES];
	
	NSDictionary *attributes
    = [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
       @"http://www.jiwok.com/ticket",NSLinkAttributeName,
       [NSFont systemFontOfSize:13], NSFontAttributeName,
       [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0],
       NSForegroundColorAttributeName,
       nil];
	NSLog(@"attributes NSDictionary==%@",attributes);
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:JiwokLocalizedString(@"GET_TICKETS") attributes:attributes] autorelease];
    [txtGetTicketURL setAttributedStringValue:attrString];
	[txtGetTicketURL setEditable:NO];
	[txtGetTicketURL setSelectable: YES];
	//[txtGetTicketURL setTextColor:[NSColor blueColor]];

	
	//[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]
	
	NSFont* font = [NSFont systemFontOfSize:13];
	[txtGetTicketURL setFont:font];
	
	[typeComments setStringValue:JiwokLocalizedString(@"TYPE_COMMENTS")];
	 NSLog(@"Now you are completed awakeFromNib method in JiwokSupportPanelViewController class");
}

-(void)sendmailtoJiwokSupport
{
     NSLog(@"Now you are in sendmailtoJiwokSupport method in JiwokSupportPanelViewController class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try
	{
		[progressBar startAnimation:self];
		[progressBar setHidden:NO];
		
		SupportTab *supportMailObj = [[SupportTab alloc]init];
		[supportMailObj parseMailDetails:[txtTicket stringValue]];
		[supportMailObj release];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in sendMailAction %@",[ex description]];
	}
	@finally 
	{
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
		
		[JiwokUtil showAlert:JiwokLocalizedString(@"SUCCESSFULLY_COMMENTED"):JIWOK_ALERT_OK];
		
	}
	[pool release];
    NSLog(@"Now you are completed sendmailtoJiwokSupport method in JiwokSupportPanelViewController class");
}
-(IBAction)sendMailAction:(id)sender
{
    NSLog(@"Now you are in sendMailAction method in JiwokSupportPanelViewController class");
	if ([[txtTicket stringValue] isEqualToString:@""])
	{
		[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_ENTER_TICKET_NUMBER"):JIWOK_ALERT_OK];
		return;
	}
	
	[NSThread detachNewThreadSelector:@selector(sendmailtoJiwokSupport) toTarget:self withObject:nil];
     NSLog(@"Now you are completed sendMailAction method in JiwokSupportPanelViewController class");
}
@end
