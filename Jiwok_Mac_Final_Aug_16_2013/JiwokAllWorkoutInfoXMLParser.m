//
//  JiwokAllWorkoutInfoXMLParser.m
//  Jiwok
//
//  Created by reubro R on 19/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokAllWorkoutInfoXMLParser.h"
#import "LoggerClass.h"

@implementation JiwokAllWorkoutInfoXMLParser

-(NSMutableArray *)parseData:(NSData *)data
{
    DUBUG_LOG(@"Now you are in parseData method in JiwokAllWorkoutInfoXMLParser class");
	[self parseXMLData:data];
     DUBUG_LOG(@"Now you are completed parseData method in JiwokAllWorkoutInfoXMLParser class");
	return [entities autorelease];
   
	
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
   DUBUG_LOG(@"Now you are in didStartElement method in JiwokAllWorkoutInfoXMLParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	
	if ([elementName isEqualToString:@"workouts"])  
	{
		entity = [[NSMutableDictionary alloc] init];
	}
	if ([elementName isEqualToString:@"workout"])  
	{
		
		workoutstatus = [[NSMutableString alloc] init];
		workouttitle = [[NSMutableString alloc] init];
		workoutQueueID = [[NSMutableString alloc] init];
	}
	DUBUG_LOG(@"Now you are completed didStartElement method in JiwokAllWorkoutInfoXMLParser class");
}


- (void)parseXMLData:(NSData *)dataXml
{	
    DUBUG_LOG(@"Now you are in parseXMLData method in JiwokAllWorkoutInfoXMLParser class");
	entities = [[NSMutableArray alloc] init];	
	// set parsing properties
 	dataParser = [[NSXMLParser alloc] initWithData:dataXml];
	[dataParser setDelegate:self]; 
	[dataParser setShouldProcessNamespaces:NO]; 
	[dataParser setShouldReportNamespacePrefixes:NO]; 
	[dataParser setShouldResolveExternalEntities:NO]; 
 	// strat parsing
	@try{
		[dataParser parse]; 
	}
	@catch(NSException *ex)
	{
		NSLog(@"@catch WorkoutDetailsParser  %@ ",[ex description]);
	}	
	//NSError *parseError = [dataParser parserError];
	 DUBUG_LOG(@"Now you are completed parseXMLData method in JiwokAllWorkoutInfoXMLParser class");
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	////NSLog(@"parser didEndElement");
     DUBUG_LOG(@"Now you are in didEndElement method in JiwokAllWorkoutInfoXMLParser class");
	if ([elementName isEqualToString:@"workout"]) 
	{
	
		[workoutstatus stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[workouttitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[workoutQueueID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		[entity setObject:workoutstatus forKey:@"status"];
		[entity setObject:workouttitle forKey:@"title"];
		[entity setObject:workoutQueueID forKey:@"queueId"];
	
		[entities addObject:[[entity copy] autorelease]];
	//[entity release];
        NSLog(@"entities NSMutabledictionary==%@",entities);
		[workoutstatus release];
		[workouttitle release];
		[workoutQueueID release];
	}
 DUBUG_LOG(@"Now you are completed didEndElement method in JiwokAllWorkoutInfoXMLParser class");
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
     DUBUG_LOG(@"Now you are in foundCharacters method in JiwokAllWorkoutInfoXMLParser class");
	if ([string isEqualToString:@"\n"])
	{
		return;
	}
	if ([currentElement isEqualToString:@"status"]) 
	{
		[workoutstatus appendString:string];
	}
	if ([currentElement isEqualToString:@"title"]) 
	{
		[workouttitle appendString:string];
	}
	if ([currentElement isEqualToString:@"queueId"]) 
	{
		[workoutQueueID appendString:string];
	}
     DUBUG_LOG(@"Now you are completed foundCharacters method in JiwokAllWorkoutInfoXMLParser class");
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
	 DUBUG_LOG(@"Now you are in parseErrorOccurred method in JiwokAllWorkoutInfoXMLParser class");
	//NSLog(@"parser error");
	entities = nil;
	//dataParser = nil;
     DUBUG_LOG(@"Now you are completed parseErrorOccurred method in JiwokAllWorkoutInfoXMLParser class");
}
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{	
     DUBUG_LOG(@"Now you are in parserDidEndDocument method in JiwokAllWorkoutInfoXMLParser class");
	//NSLog(@"parsing ended");
	if(entities.count == 0)
	{
		entities = nil;
	}
	//[dataParser release];
//	dataParser = nil;
     DUBUG_LOG(@"Now you are completed parserDidEndDocument method in JiwokAllWorkoutInfoXMLParser class");
}
- (void)dealloc {
//    [super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];

}


@end
