//
//  FingerPrintParser.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 05/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FingerPrintParser.h"
#import "LoggerClass.h"

@implementation FingerPrintParser



/*
 * Object initialization
 */
-(id) initObject
{
   //DUBUG_LOG(@"Now you are in initObject method in FingerPrintParser class");
    if(self = [super init])
    {
		
	}
    return self;
    //NSLog(@"Now you are completed initObject method in FingerPrintParser class");
}

/*
 * Initialize data parsing
 */
-(NSMutableArray *)startDataParsing:(NSData *)data 
{
    DUBUG_LOG(@"Now you are in startDataParsing method in FingerPrintParser class");
	counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
	[self parseXMLData:data];
	DUBUG_LOG(@"Now you are completed startDataParsing method in FingerPrintParser class");
	return [entities autorelease];
    
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
	 DUBUG_LOG(@"Now you are in parseXMLData method in FingerPrintParser class");
	//NSLog(@"entities entities is %@",entities);
	
	// set parsing properties
 	dataParser = [[NSXMLParser alloc] initWithData:dataXml];
	[dataParser setDelegate:self]; 
	[dataParser setShouldProcessNamespaces:YES]; 
	[dataParser setShouldReportNamespacePrefixes:YES]; 
	[dataParser setShouldResolveExternalEntities:NO]; 
 	// start parsing
	[dataParser parse]; 
	
	//NSError *parseError = [dataParser parserError];
	
    DUBUG_LOG(@"Now you are completed parseXMLData method in FingerPrintParser class");
		
}


/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	
	DUBUG_LOG(@"Now you are in parser didStartElement method in FingerPrintParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	NSLog(@"currentElement NSString==%@",currentElement);
	if([elementName isEqualToString:@"lfm"])		
	{
	entities = [[NSMutableArray alloc] init];		
	}
	
	if([elementName isEqualToString:@"track"])		

	
	{
		
		isAlbumName=YES;
	
		entity = [[NSMutableDictionary alloc] init];
		title=[[NSMutableString alloc]init];

		
	}
	
	if([elementName isEqualToString:@"artist"])		
	{			
		
		isAlbumName=NO;

		
		artist = [[NSMutableString alloc] init];
		url = [[NSMutableString alloc] init];
	}
	
	DUBUG_LOG(@"Now you are completed parser didStartElement method in FingerPrintParser class");	
}

/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	
	DUBUG_LOG(@"Now you are in parser didEndElement method in FingerPrintParser class");	
	if ([elementName isEqualToString:@"track"]) 
	{					
		[entity setObject:artist forKey:@"name"];
		[entity setObject:title forKey:@"title"];
		[entity setObject:url forKey:@"url"];	
		
		[entities addObject:entity];	
		 NSLog(@"entities NSMutableArray==%@",entities);
		[artist release];
		[title release];
		[url release];		
		[entity release];
	}
    DUBUG_LOG(@"Now you are completed parser didEndElement method in FingerPrintParser class");
}	


/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	DUBUG_LOG(@"Now you are in parser foundCharacters method in FingerPrintParser class");	
	if ([currentElement isEqualToString:@"name"]) 
	{				
		
		if(isAlbumName==YES)
			[title appendString:string];
		else
		[artist appendString:string];
	}
	
	if ([currentElement isEqualToString:@"url"]) 
	{
		[url appendString:string];
	}
		
	DUBUG_LOG(@"Now you are completed parser foundCharacters method in FingerPrintParser class");
}	









- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	/*
	NSLog(@"parseErrorOccurred  error is %@",[parseError localizedDescription]);
	
	if((![[parseError localizedDescription] isEqualToString:@"Operation could not be completed. (NSXMLParserErrorDomain error 4.)"]))
		//ParseError=YES;
	entities = nil;
	
	*/
    DUBUG_LOG(@"Now you are in parser parseErrorOccurred method in FingerPrintParser class");
	dataParser = nil;
     DUBUG_LOG(@"Now you are completed parser parseErrorOccurred method in FingerPrintParser class");
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	 DUBUG_LOG(@"Now you are in parser parserDidEndDocument method in FingerPrintParser class");
	if(entities.count == 0){
		entities = nil;
	}
	[dataParser release];
	dataParser = nil;
     DUBUG_LOG(@"Now you are completed parser parserDidEndDocument method in FingerPrintParser class");
}

/*
 * returns data 
 */
-(NSMutableArray *) getData{
     DUBUG_LOG(@"Now you are in getDatat method in FingerPrintParser class");
	return entities;
     DUBUG_LOG(@"Now you are completed getData method in FingerPrintParser class");
}


- (void)dealloc {
    [super dealloc];
}







@end
