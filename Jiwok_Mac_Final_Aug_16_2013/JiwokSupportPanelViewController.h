//
//  JiwokSupportPanelViewController.h
//  Jiwok
//
//  Created by reubro R on 19/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokSupportPanelViewController : NSViewController {
	IBOutlet NSButton *btnSend;
	IBOutlet NSTextField  *txtTicket;
	IBOutlet NSTextField  *txtGetTicketURL;
	IBOutlet NSTextField  *typeComments;
	IBOutlet NSProgressIndicator *progressBar;
}
-(IBAction)sendMailAction:(id)sender;
-(void)sendmailtoJiwokSupport;
@end
