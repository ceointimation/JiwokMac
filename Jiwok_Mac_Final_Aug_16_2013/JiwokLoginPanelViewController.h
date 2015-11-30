//
//  JiwokLoginPanelViewController.h
//  Jiwok
//
//  Created by reubro R on 14/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Delegates.h"
#import <AppKit/NSApplication.h>

@interface JiwokLoginPanelViewController : NSViewController {
	IBOutlet NSButton	*btnConnect;
	IBOutlet NSButton	*btnDisconnect;
	IBOutlet NSButton	*btnRememberMe;
	IBOutlet NSButton	*btnAutoLogin;
	
	IBOutlet NSTextField	*txtUserName;
	IBOutlet NSSecureTextField	*txtPWD;
	
	IBOutlet NSProgressIndicator *progressBar;
	
	IBOutlet NSTextField *lblUsername;
	IBOutlet NSTextField *lblPassword;
	

	
	NSString *userName;
	NSString *password;
	NSString *autoUserName ;
	NSString *autoPassword;
	BOOL bAlreadyConnected;
	
	
	id<UserLoggedInDelegate> delegate;
}
@property(nonatomic,assign) id<UserLoggedInDelegate> delegate;


-(IBAction)connect:(id)sender;
-(IBAction)discconect:(id)sender;
-(IBAction)setRememberpassword:(id)sender;
-(IBAction)setAutoLogin:(id)sender;

-(void) rememberPWD:(BOOL) bRemember;
-(void) rememberUserName:(BOOL) bRemember;
-(void) doLogin:(BOOL)bAuto;
@end
