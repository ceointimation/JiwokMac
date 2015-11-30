//
//  JiwokUserdetailsXmlParser.m
//  Events
//
//  Created by reubro R on 03/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokUserdetailsXmlParser.h"
#import "LoggerClass.h"

@implementation JiwokUserdetailsXmlParser


-(NSMutableDictionary *)parseData:(NSData *)data
{
     NSLog(@"Now you are in parseData method in JiwokUserdetailsXmlParser class");
	//counter = 0;
	////NSLog(@"  START PARSING FUNCTION ");
	[self parseXMLData:data];
	return [entity autorelease];
    NSLog(@"Now you are completed parseData method in JiwokUserdetailsXmlParser class");
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	
}



/*
 * Start data parsing
 */
- (void)parseXMLData:(NSData *)dataXml
{	
    DUBUG_LOG(@"Now you are in parseXMLData method in JiwokUserdetailsXmlParser class");
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
//		[alertView show];
//		[alertView release];*/
//	}	
   DUBUG_LOG(@"Now you are completed parseXMLData method in JiwokUserdetailsXmlParser class");
}



/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	DUBUG_LOG(@"Now you are in didStartElement method in JiwokUserdetailsXmlParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	
	if ([elementName isEqualToString:@"root"])  
	{
		entity = [[NSMutableDictionary alloc] init];
				
		validuser =[[NSMutableString alloc] init];
		user_id = [[NSMutableString alloc] init];
		user_type = [[NSMutableString alloc] init];
		username = [[NSMutableString alloc] init];
		password = [[NSMutableString alloc] init];
		payment_status =[[NSMutableString alloc] init];
		tag_login_status =[[NSMutableString alloc] init];
		language =[[NSMutableString alloc] init];
		musiclikes =[[NSMutableString alloc] init];
		
	}	
	
	
	
	DUBUG_LOG(@"Now you are completed didStartElement method in JiwokUserdetailsXmlParser class");
}


/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	////NSLog(@"parser didEndElement");
	DUBUG_LOG(@"Now you are in didEndElement method in JiwokUserdetailsXmlParser class");
	if ([elementName isEqualToString:@"root"]) {
		
		DUBUG_LOG(@"entering");
		[entity setObject:validuser forKey:@"validuser"];
		[entity setObject:user_id forKey:@"user_id"];
		[entity setObject:user_type forKey:@"user_type"];
		[entity setObject:username forKey:@"username"];
		[entity setObject:password forKey:@"password"];
		[entity setObject:payment_status forKey:@"payment_status"];
		[entity setObject:tag_login_status forKey:@"tag_login_status"];
		[entity setObject:language forKey:@"language"];
		[entity setObject:musiclikes forKey:@"musiclikes"];
		
		[entities addObject:[[entity copy] autorelease]];
		//[entity release];
         NSLog(@"entities NSMutabledictionary==%@",entities);
		[validuser release];
		[user_id release];
		[user_type release];
		[username release];
		[password release];
		[payment_status release];
		[tag_login_status release];
		[language release];
		[musiclikes release];
		//[entity release];
	}
	DUBUG_LOG(@"Now you are completed didEndElement method in JiwokUserdetailsXmlParser class");
}	



/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    DUBUG_LOG(@"Now you are in foundCharacters method in JiwokUserdetailsXmlParser class");
	if ([string isEqualToString:@"\n"])
	{
		return;
	}
	if ([currentElement isEqualToString:@"validuser"]) 
	{
		[validuser appendString:string];
	}
	if ([currentElement isEqualToString:@"user_id"]) 
	{
		[user_id appendString:string];
	}
	if ([currentElement isEqualToString:@"user_type"]) 
	{
		[user_type appendString:string];
	}
	if ([currentElement isEqualToString:@"username"]) 
	{
		[username appendString:string];
	}
	if ([currentElement isEqualToString:@"password"]) 
	{
		[password appendString:string];
	}
	if ([currentElement isEqualToString:@"payment_status"]) 
	{
		[payment_status appendString:string];
	}
	if ([currentElement isEqualToString:@"tag_login_status"]) 
	{
		[tag_login_status appendString:string];
	}

	if ([currentElement isEqualToString:@"language"]) {
		[language appendString:string];
	}
	
	if ([currentElement isEqualToString:@"musiclikes"]) 
	{
		[musiclikes appendString:string];
	}
     DUBUG_LOG(@"Now you are completed foundCharacters method in JiwokUserdetailsXmlParser class");
}	



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
	DUBUG_LOG(@"Now you are in parseErrorOccurred method in JiwokUserdetailsXmlParser class");
	//NSLog(@"parser error");
	entities = nil;
	//dataParser = nil;
     DUBUG_LOG(@"Now you are completed parseErrorOccurred method in JiwokUserdetailsXmlParser class");
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{	
     DUBUG_LOG(@"Now you are in parserDidEndDocument method in JiwokUserdetailsXmlParser class");
	DUBUG_LOG(@"parsing ended");
	if(entities.count == 0)
	{
		entities = nil;
	}
	//[dataParser release];
//	dataParser = nil;
   DUBUG_LOG(@"Now you are completed parserDidEndDocument method in JiwokUserdetailsXmlParser class");
}

/*
 * returns data 
 */
-(NSMutableArray *) getData{
   DUBUG_LOG(@"Now you are in getData method in JiwokUserdetailsXmlParser class");
	return entities;
     DUBUG_LOG(@"Now you are completed getData method in JiwokUserdetailsXmlParser class");
}




/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
//    [super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];

}


@end
