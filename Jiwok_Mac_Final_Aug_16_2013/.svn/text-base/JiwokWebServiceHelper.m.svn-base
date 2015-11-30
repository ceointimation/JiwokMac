//
//  JiwokWebServiceHelper.m
//  Jiwok
//
//  Created by Reubro on 02/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokWebServiceHelper.h"


@implementation JiwokWebServiceHelper
- (NSString *)sendRequestToURL:(NSString *) strURL withData:(NSString *) strPostData
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
	[request setHTTPMethod:@"GET"];
	// Perform request and get JSON back as a NSData object
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString * returnData = [[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];	
	return [returnData autorelease];
}
@end
