//
//  JiwokUpdateLoginStatusXmlParser.m
//  Jiwok_Coredata_Trial
//
//  Created by Reubro on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokUpdateTagDetectedGenreXmlParser.h"
#import "LoggerClass.h"

@implementation JiwokUpdateTagDetectedGenreXmlParser

-(NSMutableDictionary *)parseData:(NSData *)data
{
   DUBUG_LOG(@"Now you are in parseData method in JiwokUpdateTagDetectedGenreXmlParser class");
	//counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
	[self parseXMLData:data];
    DUBUG_LOG(@"Now you are completed parseData method in JiwokUpdateTagDetectedGenreXmlParser class");
	return [entity autorelease];
     
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	
}



/*
 * Start data parsing
 */
- (void)parseXMLData:(NSData *)dataXml
{	
     DUBUG_LOG(@"Now you are in parseXMLData method in JiwokUpdateTagDetectedGenreXmlParser class");
	//entities = [[NSMutableArray alloc] init];	
	// set parsing properties
 	dataParser = [[NSXMLParser alloc] initWithData:dataXml];
	[dataParser setDelegate:self]; 
	[dataParser setShouldProcessNamespaces:NO]; 
	[dataParser setShouldReportNamespacePrefixes:NO]; 
	[dataParser setShouldResolveExternalEntities:NO]; 
 	// strat parsing
	@try{
		[dataParser parse]; 
        DUBUG_LOG(@"Now you are completed parseXMLData method in JiwokUpdateTagDetectedGenreXmlParser class");

	}
	@catch(NSException *ex)
	{
		NSLog(@"@catch WorkoutDetailsParser  %@ ",[ex description]);
	}
	
	//NSError *parseError = [dataParser parserError];
//	
//	if(parseError)
//	{
//	  	/*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Some problem has occured. Please try again later.","") message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK"];
//		 [alertView show];
//		 [alertView release];*/
//	}	
}



/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{		
    DUBUG_LOG(@"Now you are in parser didStartElement method in JiwokUpdateTagDetectedGenreXmlParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];

		entity = [[NSMutableDictionary alloc] init];
		
		status =[[NSMutableString alloc] init];
	DUBUG_LOG(@"Now you are completed parser didStartElement method in JiwokUpdateTagDetectedGenreXmlParser class");
}


/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
		//NSLog(@"entering");
    DUBUG_LOG(@"Now you are in parser didEndElement method in JiwokUpdateTagDetectedGenreXmlParser class");
		[entity setObject:status forKey:@"result"];
		
		
		//[entities addObject:[[entity copy] autorelease]];
		[status release];
	DUBUG_LOG(@"Now you are completed parser didEndElement method in JiwokUpdateTagDetectedGenreXmlParser class");	
}	

/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	DUBUG_LOG(@"Now you are in parser foundCharacters method in JiwokUpdateTagDetectedGenreXmlParser class");
	if ([currentElement isEqualToString:@"result"]) 
	{
		[status appendString:string];
	}
   DUBUG_LOG(@"Now you are completed parser foundCharacters method in JiwokUpdateTagDetectedGenreXmlParser class");
	}	



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
    DUBUG_LOG(@"Now you are in parser parseErrorOccurred method in JiwokUpdateTagDetectedGenreXmlParser class");
	DUBUG_LOG(@"parsing error");
	//entities = nil;
	//dataParser = nil;
    DUBUG_LOG(@"Now you are completed parser parseErrorOccurred method in JiwokUpdateTagDetectedGenreXmlParser class");
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{	
    DUBUG_LOG(@"Now you are in parser parserDidEndDocument method in JiwokUpdateTagDetectedGenreXmlParser class");
	DUBUG_LOG(@"parsing ended");
	/*if(entities.count == 0)
	{
		entities = nil;
	}*/
	//[dataParser release];
//	dataParser = nil;
    DUBUG_LOG(@"Now you are completed parser parserDidEndDocument method in JiwokUpdateTagDetectedGenreXmlParser class");
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

