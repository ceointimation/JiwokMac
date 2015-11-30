//
//  SupportTab.h
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 16/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MailCore/MailCore.h>
#import "S7FTPRequest.h"

@interface SupportTab : NSObject {
	
	
	NSMutableArray *mailDetailsArrary;

	NSString *ticketKey;
	
	NSTask *task;
	NSMutableDictionary *profileDictionary;
	
	S7FTPRequest *ftpRequest;
	
	NSString *uploadLink;

}

-(void)parseMailDetails:(NSString*)ticketNo;

-(void)sendSupportMail;

- (NSMutableDictionary*)GetSystemInfo;

-(void)CreateFtpDirectory:(NSString*)ticketNo;

-(void)uploadToFtp;



- (NSAttributedString *)attributedStringWithLink:(NSString *)link:(NSString *)text ;

@end
