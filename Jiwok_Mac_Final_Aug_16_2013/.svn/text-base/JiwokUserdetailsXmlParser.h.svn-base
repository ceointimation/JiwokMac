//
//  JiwokUserdetailsXmlParser.h
//  Events
//
//  Created by reubro R on 03/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokUserdetailsXmlParser : NSObject {
	
	//Xml Parser
	NSXMLParser * dataParser;
	// holds the XML entities 
	NSMutableArray * entities;
	// a temporary entity holder added to the "entities" array for each parsed entity
	NSMutableDictionary * entity;
	// Used to track each item to be added to the "entities" array
	NSString * currentElement;
	//NSData *urlData;	

	NSMutableString *validuser,*user_id,*user_type,*username,*password,*payment_status,*tag_login_status,*language,*musiclikes;

}
-(NSMutableDictionary *)parseData:(NSData *)data;
- (void)parseXMLData:(NSData *)dataXml;
@end
