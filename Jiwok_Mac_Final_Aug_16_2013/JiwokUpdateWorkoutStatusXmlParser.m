//
//  JiwokUpdateLoginStatusXmlParser.m
//  Jiwok_Coredata_Trial
//
//  Created by Reubro on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokUpdateWorkoutStatusXmlParser.h"
#import "LoggerClass.h"

@implementation JiwokUpdateWorkoutStatusXmlParser

-(NSMutableDictionary *)parseData:(NSData *)data
{
	//counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
    DUBUG_LOG(@"Now you are in parser parseData method in JiwokUpdateWorkoutStatusXmlParser class");
	[self parseXMLData:data];
	return [entity autorelease];
    DUBUG_LOG(@"Now you are completed parser parseData method in JiwokUpdateWorkoutStatusXmlParser class");

}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	
}



/*
 * Start data parsing
 */
- (void)parseXMLData:(NSData *)dataXml
{	
	//entities = [[NSMutableArray alloc] init];	
	// set parsing properties
    DUBUG_LOG(@"Now you are in parseXMLData method in JiwokUpdateWorkoutStatusXmlParser class");

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
		DUBUG_LOG(@"@catch WorkoutDetailsParser  %@ ",[ex description]);
	}
	
	//NSError *parseError = [dataParser parserError];
//	
//	if(parseError)
//	{
//	  	/*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Some problem has occured. Please try again later.","") message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK"];
//		 [alertView show];
//		 [alertView release];*/
//	}
	DUBUG_LOG(@"Now you are completed parseXMLData method in JiwokUpdateWorkoutStatusXmlParser class");
}



/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	DUBUG_LOG(@"Now you are in didStartElement method in JiwokUpdateWorkoutStatusXmlParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];

		entity = [[NSMutableDictionary alloc] init];
		
		status =[[NSMutableString alloc] init];
	DUBUG_LOG(@"Now you are completed didStartElement method in JiwokUpdateWorkoutStatusXmlParser class");
}


/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
		//NSLog(@"entering");
    DUBUG_LOG(@"Now you are in didEndElement method in JiwokUpdateWorkoutStatusXmlParser class");
		[entity setObject:status forKey:@"result"];
		
		NSLog(@"entity NSMutableDictionary==%@",entity);
		//[entities addObject:[[entity copy] autorelease]];
		[status release];
	DUBUG_LOG(@"Now you are completed didEndElement method in JiwokUpdateWorkoutStatusXmlParser class");	
}	



/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	 DUBUG_LOG(@"Now you are in foundCharacters method in JiwokUpdateWorkoutStatusXmlParser class");
	if ([currentElement isEqualToString:@"result"]) 
	{
		[status appendString:string];
	}
    DUBUG_LOG(@"Now you are completed foundCharacters method in JiwokUpdateWorkoutStatusXmlParser class");
	}	



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
   DUBUG_LOG(@"Now you are in parseErrorOccurred method in JiwokUpdateWorkoutStatusXmlParser class");
	DUBUG_LOG(@"parsing error");
//	entities = nil;
	//dataParser = nil;
    DUBUG_LOG(@"Now you are completed parseErrorOccurred method in JiwokUpdateWorkoutStatusXmlParser class");
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{	
    DUBUG_LOG(@"Now you are in parserDidEndDocument method in JiwokUpdateWorkoutStatusXmlParser class");
	DUBUG_LOG(@"parsing ended");
	/*if(entities.count == 0)
	{
		entities = nil;//
//	}*/
//	[dataParser release];
	//dataParser = nil;
    DUBUG_LOG(@"Now you are completed parserDidEndDocument method in JiwokUpdateWorkoutStatusXmlParser class");
}

/*
 * returns data 
 */
/*-(NSMutableArray *) getData{
	return entities;
}*/


- (void)dealloc {
//    [super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];

}


@end

