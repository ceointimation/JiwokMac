//
//  VersionCheckXmlParser.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 18/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VersionCheckXmlParser.h"
#import "LoggerClass.h"

@implementation VersionCheckXmlParser


/*
 * Object initialization
 */
-(id) initObject
{
    //NSLog(@"Now you are in initObject method in VersionCheckXmlParser class");
    if(self = [super init])
    {
		
	}
    return self;
    //NSLog(@"Now you are completed initObject method in VersionCheckXmlParser class");
}

/*
 * Initialize data parsing
 */
-(NSMutableArray *)startDataParsing:(NSData *)data 
{
    DUBUG_LOG(@"Now you are in startDataParsing method in VersionCheckXmlParser class");
	counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
	
	
	
	[self parseXMLData:data];
	
	return [entities autorelease];
    DUBUG_LOG(@"Now you are completed startDataParsing method in VersionCheckXmlParser class");
}

/*
 * Checks if data is valid for parsing
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	
}

/*
 * Start data parsing
 */
- (void)parseXMLData:(NSData *)dataXml
{		
	//entities = [[NSMutableArray alloc] init];	
	DUBUG_LOG(@"Now you are in parseXMLData method in VersionCheckXmlParser class");
	//NSLog(@"entities entities is %@",entities);
	
	// set parsing properties
 	dataParser = [[NSXMLParser alloc] initWithData:dataXml];
	[dataParser setDelegate:self]; 
	[dataParser setShouldProcessNamespaces:NO]; 
	[dataParser setShouldReportNamespacePrefixes:NO]; 
	[dataParser setShouldResolveExternalEntities:NO]; 
 	// start parsing
	
	
	//@try{
		[dataParser parse]; 
	//}
//	@catch(NSException *ex)
//	{
//		NSLog(@"@catch WorkoutDetailsParser  %@ ",[ex description]);
//	}
//	
	
	//NSError *parseError = [dataParser parserError];
	
	DUBUG_LOG(@"Now you are completed parseXMLData method in VersionCheckXmlParser class");
	
}


/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	DUBUG_LOG(@"Now you are in didStartElement method in VersionCheckXmlParser class");
	
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	
	if([elementName isEqualToString:@"root"])		
	{
		entities = [[NSMutableArray alloc] init];		
		
		entity= [[NSMutableDictionary alloc] init];
		
		updateid = [[NSMutableString alloc] init];
		version = [[NSMutableString alloc] init];
		description=[[NSMutableString alloc]init];
		status = [[NSMutableString alloc] init];
		filepath = [[NSMutableString alloc] init];
		
		releasedate = [[NSMutableString alloc] init];

		
	}
	
	DUBUG_LOG(@"Now you are completed didStartElement method in VersionCheckXmlParser class");
}

/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{    	
	DUBUG_LOG(@"Now you are in didEndElement method in VersionCheckXmlParser class");
	if ([elementName isEqualToString:@"root"]) 
	{					
		[entity setObject:updateid forKey:@"updateid"];
		[entity setObject:version forKey:@"version"];
		[entity setObject:description forKey:@"description"];	
		[entity setObject:status forKey:@"status"];
		[entity setObject:filepath forKey:@"filepath"];	
		[entity setObject:releasedate forKey:@"releasedate"];
		
		
		[entities addObject:entity];	
		
		[updateid release];
		[version release];
		[status release];		
		[description release];	
		[filepath release];			
		[releasedate release];
		
		[entity release];
	}
    DUBUG_LOG(@"Now you are completed didEndElement method in VersionCheckXmlParser class");
}	


/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	DUBUG_LOG(@"Now you are in foundCharacters method in VersionCheckXmlParser class");
	//NSLog(@"currentElement currentElement is %@",currentElement);
	
	if ([currentElement isEqualToString:@"updateid"]) 
	{				
		[updateid appendString:string];
	}
	if ([currentElement isEqualToString:@"version"]) 
	{
		[version appendString:string];
	}
	if ([currentElement isEqualToString:@"description"]) 
	{
		[description appendString:string];
	}
	if ([currentElement isEqualToString:@"status"]) 
	{
		[status appendString:string];
	}
	if ([currentElement isEqualToString:@"filepath"]) 
	{
		[filepath appendString:string];
	}
	if ([currentElement isEqualToString:@"releasedate"]) 
	{
		[releasedate appendString:string];
	}
	DUBUG_LOG(@"Now you are completed foundCharacters method in VersionCheckXmlParser class");
	
}	









- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	DUBUG_LOG(@"Now you are in parseErrorOccurred method in VersionCheckXmlParser class");
	 NSLog(@"parseErrorOccurred  error is %@",[parseError localizedDescription]);
	 /*
	 if((![[parseError localizedDescription] isEqualToString:@"Operation could not be completed. (NSXMLParserErrorDomain error 4.)"]))
	 //ParseError=YES;
	 entities = nil;
	 
	 */
	//dataParser = nil;
    DUBUG_LOG(@"Now you are completed parseErrorOccurred method in VersionCheckXmlParser class");
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	DUBUG_LOG(@"Now you are in parserDidEndDocument method in VersionCheckXmlParser class");
	if(entities.count == 0){
		entities = nil;
	}
	
	//[dataParser release];
//	dataParser = nil;
	DUBUG_LOG(@"Now you are completed parserDidEndDocument method in VersionCheckXmlParser class");
}

/*
 * returns data 
 */
-(NSMutableArray *) getData{
   DUBUG_LOG(@"Now you are in getData method in VersionCheckXmlParser class");
	return entities;
    DUBUG_LOG(@"Now you are completed getData method in VersionCheckXmlParser class");
}


- (void)dealloc {
    //[super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];
}





@end
