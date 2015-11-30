//
//  JiwokAllWorkoutInfoXMLParser.h
//  Jiwok
//
//  Created by reubro R on 19/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokAllWorkoutInfoXMLParser : NSObject {
	
	//Xml Parser
	NSXMLParser * dataParser;
	// holds the XML entities 
	NSMutableArray * entities;
	// a temporary entity holder added to the "entities" array for each parsed entity
	NSMutableDictionary * entity;
	// Used to track each item to be added to the "entities" array
	NSString * currentElement;
	//NSData *urlData;	
	NSMutableString *workoutstatus,*workouttitle,*workoutQueueID;
	
}
-(NSMutableArray *)parseData:(NSData *)data;
- (void)parseXMLData:(NSData *)dataXml;
@end
