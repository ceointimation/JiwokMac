//
//  GetSupportMailDetailsXmlParser.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 16/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GetSupportMailDetailsXmlParser.h"
#import "LoggerClass.h"

@implementation GetSupportMailDetailsXmlParser





/*
 * Object initialization
 */
-(id) initObject
{
    //DUBUG_LOG(@"Now you are in initObject method in GetSupportMailDetailsXmlParser class");
    if(self = [super init])
    {
		
	}
    return self;
     
}

/*
 * Initialize data parsing
 */
-(NSMutableArray *)startDataParsing:(NSData *)data 
{
    DUBUG_LOG(@"Now you are in startDataParsing method in GetSupportMailDetailsXmlParser class");
	counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
	[self parseXMLData:data];
	DUBUG_LOG(@"Now you are completed startDataParsing method in GetSupportMailDetailsXmlParser class");
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
	
	//NSLog(@"entities entities is %@",entities);
	DUBUG_LOG(@"Now you are in parseXMLData method in GetSupportMailDetailsXmlParser class");
	// set parsing properties
 	dataParser = [[NSXMLParser alloc] initWithData:dataXml];
	[dataParser setDelegate:self]; 
	[dataParser setShouldProcessNamespaces:YES]; 
	[dataParser setShouldReportNamespacePrefixes:YES]; 
	[dataParser setShouldResolveExternalEntities:NO]; 
 	// start parsing
	@try{
		[dataParser parse]; 
	}
	@catch(NSException *ex)
	{
		NSLog(@"@catch WorkoutDetailsParser  %@ ",[ex description]);
	}
	
	//NSError *parseError = [dataParser parserError];
	
	DUBUG_LOG(@"Now you are completed parseXMLData method in GetSupportMailDetailsXmlParser class");
	
}


/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	
	DUBUG_LOG(@"Now you are in didStartElement method in GetSupportMailDetailsXmlParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	
	if([elementName isEqualToString:@"mail"])		
	{
		entities = [[NSMutableArray alloc] init];		
		entity = [[NSMutableDictionary alloc] init];
		
		from = [[NSMutableString alloc] init];
		host=[[NSMutableString alloc]init];
		username = [[NSMutableString alloc] init];
		password = [[NSMutableString alloc] init];
		port= [[NSMutableString alloc] init];

		
	}
	DUBUG_LOG(@"Now you are completed didStartElement method in GetSupportMailDetailsXmlParser class");
	
}

/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	DUBUG_LOG(@"Now you are in didEndElement method in GetSupportMailDetailsXmlParser class");
	
	if ([elementName isEqualToString:@"mail"]) 
	{					
		[entity setObject:from forKey:@"from"];
		[entity setObject:host forKey:@"host"];
		[entity setObject:username forKey:@"username"];
		[entity setObject:password forKey:@"password"];
		[entity setObject:port forKey:@"port"];	

		
		[entities addObject:entity];	
		NSLog(@"entities NSMutableArray==%@",entities);
		[from release];
		[host release];
		[username release];
		[password release];		
		[port release];
	}
    DUBUG_LOG(@"Now you are completed didEndElement method in GetSupportMailDetailsXmlParser class");
}	


/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	DUBUG_LOG(@"Now you are in foundCharacters method in GetSupportMailDetailsXmlParser class");
	//NSLog(@"currentElement currentElement is %@",currentElement);
	
	if ([currentElement isEqualToString:@"from"]) 
	{				
		[from appendString:string];
	}
	if ([currentElement isEqualToString:@"host"]) 
	{
		[host appendString:string];
	}
	if ([currentElement isEqualToString:@"username"]) 
	{
		[username appendString:string];
	}
	if ([currentElement isEqualToString:@"password"]) 
	{
		[password appendString:string];
	}
	if ([currentElement isEqualToString:@"port"]) 
	{
		[port appendString:string];
	}
	
	DUBUG_LOG(@"Now you are completed foundCharacters method in GetSupportMailDetailsXmlParser class");
}	









- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	/*
	 NSLog(@"parseErrorOccurred  error is %@",[parseError localizedDescription]);
	 
	 if((![[parseError localizedDescription] isEqualToString:@"Operation could not be completed. (NSXMLParserErrorDomain error 4.)"]))
	 //ParseError=YES;
	 entities = nil;
	 
	 */
	//dataParser = nil;
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	DUBUG_LOG(@"Now you are in parserDidEndDocument method in GetSupportMailDetailsXmlParser class");
	if(entities.count == 0){
		entities = nil;
	}
	[dataParser release];
	dataParser = nil;
   DUBUG_LOG(@"Now you are completed parserDidEndDocument method in GetSupportMailDetailsXmlParser class");
}

/*
 * returns data 
 */
-(NSMutableArray *) getData{
   DUBUG_LOG(@"Now you are in getData method in GetSupportMailDetailsXmlParser class");
	return entities;
    
}


- (void)dealloc {
    [super dealloc];
}




@end
