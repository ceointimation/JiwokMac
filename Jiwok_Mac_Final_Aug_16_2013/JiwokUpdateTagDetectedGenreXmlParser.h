//
//  JiwokUpdateLoginStatusXmlParser.h
//  Jiwok_Coredata_Trial
//
//  Created by Reubro on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokUpdateTagDetectedGenreXmlParser : NSObject {
	
	//Xml Parser
	NSXMLParser * dataParser;
	// holds the XML entities 
	NSMutableArray * entities;
	// a temporary entity holder added to the "entities" array for each parsed entity
	NSMutableDictionary * entity;
	// Used to track each item to be added to the "entities" array
	NSString * currentElement;
	//NSData *urlData;	
	
	NSMutableString *status;

}

-(NSMutableDictionary *)parseData:(NSData *)data;
- (void)parseXMLData:(NSData *)dataXml;
@end
