//
//  JiwokUpdateLoginStatusXmlParser.m
//  Jiwok_Coredata_Trial
//
//  Created by Reubro on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokUpdateLoginStatusXmlParser.h"
#import "LoggerClass.h"

@implementation JiwokUpdateLoginStatusXmlParser

-(NSMutableDictionary *)parseData:(NSData *)data
{
    DUBUG_LOG(@"Now you are in parseData method in JiwokUpdateLoginStatusXmlParser class");
	//counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
	[self parseXMLData:data];
	return [entity autorelease];
     DUBUG_LOG(@"Now you are completed parseData method in JiwokUpdateLoginStatusXmlParser class");
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	
}



/*
 * Start data parsing
 */
- (void)parseXMLData:(NSData *)dataXml
{	
     DUBUG_LOG(@"Now you are in parseXMLData method in JiwokUpdateLoginStatusXmlParser class");
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
//	
//	if(parseError)
//	{
//	  	/*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Some problem has occured. Please try again later.","") message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK"];
//		 [alertView show];
//		 [alertView release];*/
//	}	
     DUBUG_LOG(@"Now you are completed parseXMLData method in JiwokUpdateLoginStatusXmlParser class");
}



/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{		
     DUBUG_LOG(@"Now you are in didStartElement method in JiwokUpdateLoginStatusXmlParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];

		entity = [[NSMutableDictionary alloc] init];
		
		status =[[NSMutableString alloc] init];
	 DUBUG_LOG(@"Now you are completed didStartElement method in JiwokUpdateLoginStatusXmlParser class");
}


/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
		//NSLog(@"entering");
   DUBUG_LOG(@"Now you are in didEndElement method in JiwokUpdateLoginStatusXmlParser class");
		[entity setObject:status forKey:@"result"];
		 NSLog(@"entity NSMutabledictionary==%@",entity);
		
		[entities addObject:[[entity copy] autorelease]];
		[status release];
	DUBUG_LOG(@"Now you are completed didEndElement method in JiwokUpdateLoginStatusXmlParser class");	
}	



/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	DUBUG_LOG(@"Now you are in foundCharacters method in JiwokUpdateLoginStatusXmlParser class");
	if ([currentElement isEqualToString:@"result"]) 
	{
		[status appendString:string];
	}
    DUBUG_LOG(@"Now you are completed foundCharacters method in JiwokUpdateLoginStatusXmlParser class");
	}	



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
    DUBUG_LOG(@"Now you are in parseErrorOccurred method in JiwokUpdateLoginStatusXmlParser class");
	DUBUG_LOG(@"parsing error");
	entities = nil;
    DUBUG_LOG(@"Now you are completed parseErrorOccurred method in JiwokUpdateLoginStatusXmlParser class");
	//dataParser = nil;
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{	
    DUBUG_LOG(@"Now you are in parserDidEndDocument method in JiwokUpdateLoginStatusXmlParser class");
	DUBUG_LOG(@"parsing ended");
	if(entities.count == 0)
	{
		entities = nil;
	}
	//[dataParser release];
	//dataParser = nil;
     DUBUG_LOG(@"Now you are completed parserDidEndDocument method in JiwokUpdateLoginStatusXmlParser class");
}

/*
 * returns data 
 */
-(NSMutableArray *) getData{
     DUBUG_LOG(@"Now you are in getData method in JiwokUpdateLoginStatusXmlParser class");
	return entities;
    DUBUG_LOG(@"Now you are completed getData method in JiwokUpdateLoginStatusXmlParser class");
}


- (void)dealloc {
//    [super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];

}


@end

