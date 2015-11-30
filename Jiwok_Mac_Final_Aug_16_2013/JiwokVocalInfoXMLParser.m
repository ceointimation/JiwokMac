//
//  JiwokVocalInfoXMLParser.m
//  Jiwok
//
//  Created by reubro R on 17/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokVocalInfoXMLParser.h"
#import "LoggerClass.h"

@implementation JiwokVocalInfoXMLParser
-(NSMutableArray *)parseData:(NSData *)data
{
   DUBUG_LOG(@"Now you are in parseData method in JiwokVocalInfoXMLParser class");
	[self parseXMLData:data];
	return [entities autorelease];
     DUBUG_LOG(@"Now you are completed parseData method in JiwokVocalInfoXMLParser class");

}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
     DUBUG_LOG(@"Now you are in didStartElement method in JiwokVocalInfoXMLParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	
	if ([elementName isEqualToString:@"vocals"])  
	{
		entity = [[NSMutableDictionary alloc] init];
	}
	if ([elementName isEqualToString:@"voc"])  
	{
		vocalID =[[NSMutableString alloc] initWithString:[attributeDict objectForKey:@"id"]];
		vocalFile =[[NSMutableString alloc] initWithString:[attributeDict objectForKey:@"file"]];
		vocalType =[[NSMutableString alloc] initWithString:[attributeDict objectForKey:@"vocal_type"]];
		vocalText =[[NSMutableString alloc] initWithString:[attributeDict objectForKey:@"txt"]];
	}
   DUBUG_LOG(@"Now you are completed didStartElement method in JiwokVocalInfoXMLParser class");
	
}


- (void)parseXMLData:(NSData *)dataXml
{	
    DUBUG_LOG(@"Now you are in parseXMLData method in JiwokVocalInfoXMLParser class");
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
	 DUBUG_LOG(@"Now you are completed parseXMLData method in JiwokVocalInfoXMLParser class");
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{  
    DUBUG_LOG(@"Now you are in didEndElement method in JiwokVocalInfoXMLParser class");
	////NSLog(@"parser didEndElement");
	[entity setObject:vocalID forKey:@"id"];
	[entity setObject:vocalFile forKey:@"file"];
	[entity setObject:vocalType forKey:@"vocal_type"];
	[entity setObject:vocalText forKey:@"txt"];
	
	[entities addObject:[[entity copy] autorelease]];
	//[entity release];
    NSLog(@"entities NSMutabledictionary==%@",entities);
	[vocalID release];
	[vocalFile release];
	[vocalType release];
	[vocalText release];
    DUBUG_LOG(@"Now you are completed didEndElement method in JiwokVocalInfoXMLParser class");

}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
	 DUBUG_LOG(@"Now you are in parseErrorOccurred method in JiwokVocalInfoXMLParser class");
	//NSLog(@"parser error");
	entities = nil;
	//dataParser = nil;
   DUBUG_LOG(@"Now you are completed parseErrorOccurred method in JiwokVocalInfoXMLParser class");
}
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
	DUBUG_LOG(@"Now you are in parserDidEndDocument method in JiwokVocalInfoXMLParser class");
	//NSLog(@"parsing ended");
	if(entities.count == 0)
	{
		entities = nil;
	}
	//[dataParser release];
	//dataParser = nil;
    DUBUG_LOG(@"Now you are completed parserDidEndDocument method in JiwokVocalInfoXMLParser class");
}
- (void)dealloc {
//    [super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];

}



@end
