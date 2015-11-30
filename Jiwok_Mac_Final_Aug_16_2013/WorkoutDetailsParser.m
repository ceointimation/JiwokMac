//
//  WorkoutDetailsParser.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 02/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorkoutDetailsParser.h"
#import "Variable.h"
#import "LoggerClass.h"


@implementation WorkoutDetailsParser

-(NSMutableDictionary *)parseData:(NSData *)data
{
	////NSLog(@"  START PARSING FUNCTION ");
   DUBUG_LOG(@"Now you are in parseData method in WorkoutDetailsParser class");
	[self parseXMLData:data];
	return [trainingPgmDictionary autorelease];
     DUBUG_LOG(@"Now you are completed parseData method in WorkoutDetailsParser class");
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{	
	
}



/*
 * Start data parsing
 */
- (void)parseXMLData:(NSData *)dataXml
{	
	//NSLog(@"parseXMLData parseXMLData %d",dataXml);
	 DUBUG_LOG(@"Now you are in parseXMLData method in WorkoutDetailsParser class");
	entities = [[NSMutableArray alloc] init];
	frenchTitles = [[NSMutableArray alloc] init];
	
	trainingPgmDictionary = [[NSMutableDictionary alloc] init];
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
     DUBUG_LOG(@"Now you are completed parseXMLData method in WorkoutDetailsParser class");
}



/*
 * Initializes the entity properties from the Servlet's response
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{		
    DUBUG_LOG(@"Now you are in didStartElement method in WorkoutDetailsParser class");
	currentElement = [NSString stringWithFormat:@"%@", elementName];
	
	
	if ([elementName isEqualToString:@"root"]) 
	{
		
		queue_id =[attributeDict objectForKey:@"queue_id"];
		//NSLog(@"queue id isisisi %@",queue_id);
		[trainingPgmDictionary setObject:queue_id forKey:@"queue_id"];
	}
	
	if ([elementName isEqualToString:@"training_program"]) 
	{
		pgmDictionary  = [[NSMutableDictionary alloc] init];
		pgmId =[attributeDict objectForKey:@"id"];
	}
	
	
	if ([elementName isEqualToString:@"nextworkout"]) 
	{
		
		nextWorkoutDictionary =[[NSMutableDictionary alloc] init];
		langArray =[[NSMutableArray alloc] init];
		netWorkoutId = [attributeDict objectForKey:@"id"];
	}
	
	if ([elementName isEqualToString:@"workout"]) 
	{
		trainigPgmEnded =YES;
	}
	
	if ([elementName isEqualToString:@"lang"]) 
	{
		langId =[attributeDict objectForKey:@"id"];
		langValue =[attributeDict objectForKey:@"value"];
				
	}
	if ([elementName isEqualToString:@"english"])  
	{
		engTitle =[[NSMutableString alloc] init];
		engValueId =[attributeDict objectForKey:@"id"];
	}
	
	if ([elementName isEqualToString:@"french"]) 
	{
		
		frenchTitle =[[NSMutableString alloc] init];
		frenchValueId =[attributeDict objectForKey:@"id"];
	}
	
	
	// New code for spanish and italian
	if ([elementName isEqualToString:@"spanish"]) 
	{
		
		frenchTitle =[[NSMutableString alloc] init];
		frenchValueId =[attributeDict objectForKey:@"id"];
	}
	
	if ([elementName isEqualToString:@"italian"]) 
	{
		
		frenchTitle =[[NSMutableString alloc] init];
		frenchValueId =[attributeDict objectForKey:@"id"];
	}
	
	
	
	
	if ([elementName isEqualToString:@"vocal_type"])
	{
		vocal_type =[[[NSMutableString alloc] init] autorelease];
	}
	
	if ([elementName isEqualToString:@"color_flag"])
	{
		color_flag =[[[NSMutableString alloc] init] autorelease];
	}
	
	if ([elementName isEqualToString:@"workout_lang_selected"])
	{
		workout_lang_selected =[[[NSMutableString alloc] init] autorelease];
	}
	
	
	
	
	if ([elementName isEqualToString:@"order"])
	{
		order =[[[NSMutableString alloc] init] autorelease];
	}
	
	
	
	if ([elementName isEqualToString:@"workout"])
	{
		trainigPgmEnded =YES;
		workoutDictionary =[[NSMutableDictionary alloc] init];
		workoutTitleArray =[[NSMutableArray alloc] init];
		if([attributeDict objectForKey:@"id"])
		workoutId =[attributeDict objectForKey:@"id"];
		originforce_status =[[NSMutableString alloc] init];
		originforce_file =[[NSMutableString alloc] init];
		author =[[NSMutableString alloc] init];
		validator =[[NSMutableString alloc] init];
		version =[[NSMutableString alloc] init];
		datecreation =[[NSMutableString alloc] init];
		datevalidate =[[NSMutableString alloc] init];
		status =[[NSMutableString alloc] init];
		typeW =[[NSMutableString alloc] init];
		intensity =[[NSMutableString alloc] init];
		group =[[NSMutableString alloc] init];
		sport =[[NSMutableString alloc] init];
		time =[[NSMutableString alloc] init];
	}
	
	
	if([elementName isEqualToString:@"genres"])
	{
		
		generesArray =[[NSMutableArray alloc] init];
		
		
	}
	if([elementName isEqualToString:@"genre"]) {
		
		
		genereStr =[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"song_elements"]) 
	{
		songElementsArray = [[NSMutableArray alloc] init];
		
	}
	
	if([elementName isEqualToString:@"voc_elements"]) 
	{	
		vocalElementsArray =[[NSMutableArray alloc] init];
		song_elementsEnded=YES;
		
		
	}
	if([elementName isEqualToString:@"element"]) {
		
		if(!song_elementsEnded)
		{		
			songElementsDictionary = [[NSMutableDictionary alloc] init];
			element =[attributeDict objectForKey:@"place"];
		}
		else 
		{
			vocalElementsDictionary = [[NSMutableDictionary alloc] init];
			element =[attributeDict objectForKey:@"place"];
		}
		
	}
	
	
	if([elementName isEqualToString:@"startpos"]) 
	{
		
		startpos =[attributeDict objectForKey:@"value"]; 
				
	}
	if([elementName isEqualToString:@"duration"]) 
	{
		
		duration =[attributeDict objectForKey:@"value"];
		
	}
	if([elementName isEqualToString:@"styleforce"]) 
	{
		
		styleforce =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"origineforce"]) 
	{
		
		origineforce =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"effectin"]) 
	{
		
		effectin =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"effectout"]) 
	{
		
		effectout =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"bpmmin"]) 
	{
		
		bpmmin =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"bpmmax"]) 
	{
		
		bpmmax =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"desc"])
	{
		
		desc =[attributeDict objectForKey:@"value"];
		
	}
	
	if([elementName isEqualToString:@"provide"])
	{
		
		provide =[attributeDict objectForKey:@"value"];
		
	}
	
	
	
	if([elementName isEqualToString:@"vocid"]) 
	{
		vocid = [attributeDict objectForKey:@"value"];
		
		
	}
	
	if([elementName isEqualToString:@"text2speech"]) 
	{
		text2speechValue = [attributeDict objectForKey:@"value"];
		text2speechLang = [attributeDict objectForKey:@"lang"];
		
	}
	DUBUG_LOG(@"Now you are completed didStartElement method in WorkoutDetailsParser class");
}


/*
 * Called when the element is read.
 * Used to store the read element in a structured array.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
		DUBUG_LOG(@"Now you are in didEndElement method in WorkoutDetailsParser class");
	if ([elementName isEqualToString:@"training_program"]) 
	{
		[pgmDictionary setObject:pgmId forKey:@"pgmId"];
		
		[trainingPgmDictionary setObject:pgmDictionary forKey:@"pgmDictionary"];
         DUBUG_LOG(@"pgmDictionary NSMutabledictionary==%@",pgmDictionary);
		[pgmDictionary release];
		
	}
	if ([elementName isEqualToString:@"french"]) {
		if(!trainigPgmEnded)
		{
			[pgmDictionary setObject:frenchTitle forKey:@"frenchTitle"];
			[pgmDictionary setObject:engValueId forKey:@"frenchValueId"];
             DUBUG_LOG(@"pgmDictionary NSMutabledictionary==%@",pgmDictionary);
			[frenchTitle release];
		}
		
		
		else
		{
			
			[workoutTitleArray addObject:frenchValueId];
			[workoutTitleArray addObject:frenchTitle];
            DUBUG_LOG(@"workoutTitleArray NSMutabledictionary==%@",workoutTitleArray);
			[frenchTitle release];
		}
		
		
	}
	// New code for spanish and italian
	if ([elementName isEqualToString:@"spanish"]) {
		if(!trainigPgmEnded)
		{
			[pgmDictionary setObject:frenchTitle forKey:@"spanishTitle"];
			[pgmDictionary setObject:engValueId forKey:@"spanishValueId"];
            DUBUG_LOG(@"pgmDictionary NSMutabledictionary==%@",pgmDictionary);
			[frenchTitle release];
		}
		
		
		else
		{
			
			[workoutTitleArray addObject:frenchValueId];
			[workoutTitleArray addObject:frenchTitle];
             DUBUG_LOG(@"workoutTitleArray NSMutableArray==%@",workoutTitleArray);
			[frenchTitle release];
		}
		
		
	}
	if ([elementName isEqualToString:@"italian"]) {
		if(!trainigPgmEnded)
		{
			[pgmDictionary setObject:frenchTitle forKey:@"italianTitle"];
			[pgmDictionary setObject:engValueId forKey:@"italianValueId"];
             DUBUG_LOG(@"pgmDictionary NSMutabledictionary==%@",pgmDictionary);
			[frenchTitle release];
		}
		
		
		else
		{
			
			[workoutTitleArray addObject:frenchValueId];
			[workoutTitleArray addObject:frenchTitle];
            DUBUG_LOG(@"workoutTitleArray NSMutableArray==%@",workoutTitleArray);
			[frenchTitle release];
		}
		
		
	}
	
	
	
	
	
	
	
	
	if ([elementName isEqualToString:@"english"])
	{
		
		if(!trainigPgmEnded)
		{
			//NSLog(@"english");
			
			[pgmDictionary setObject:engValueId forKey:@"engValueId"];
			[pgmDictionary setObject:engTitle forKey:@"engTitle"];
            NSLog(@"workoutTitleArray NSMutabledictionary==%@",workoutTitleArray);
			[engTitle release];
		}
		else
		{
			
			[workoutTitleArray addObject:engValueId];
			[workoutTitleArray addObject:engTitle];
            NSLog(@"workoutTitleArray NSMutableArray==%@",workoutTitleArray);	
			[engTitle release];
					
		}
	}
	
	
	if ([elementName isEqualToString:@"nextworkout"]) 
	{
		if(netWorkoutId)
		[nextWorkoutDictionary setObject:netWorkoutId forKey:@"netWorkoutId"];
		[nextWorkoutDictionary setObject:langArray forKey:@"langArray"];
		[langArray release];
		[trainingPgmDictionary setObject:nextWorkoutDictionary forKey:@"nextWorkoutDictionary"];
		[nextWorkoutDictionary release];
	}
		
	if ([elementName isEqualToString:@"lang"]) 
	{
		[langArray addObject:langId];
		[langArray addObject:langValue];
		 NSLog(@"langArray NSMutableArray==%@",langArray);		
	}
	
	if ([elementName isEqualToString:@"vocal_type"])
	{
		[trainingPgmDictionary setObject:vocal_type forKey:@"vocal_type"];
		//[vocal_type release];
		 NSLog(@"trainingPgmDictionary NSMutableDictionary==%@",trainingPgmDictionary);
	}
	
	if ([elementName isEqualToString:@"color_flag"])
	{
		
		
		NSString	*color_flag1 = [color_flag stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		
		[trainingPgmDictionary setObject:color_flag1 forKey:@"color_flag"];
		//[color_flag release];
         NSLog(@"trainingPgmDictionary NSMutableDictionary==%@",trainingPgmDictionary);
		
	}
	
	if ([elementName isEqualToString:@"workout_lang_selected"])
	{
		[trainingPgmDictionary setObject:workout_lang_selected forKey:@"workout_lang_selected"];
        NSLog(@"trainingPgmDictionary NSMutableDictionary==%@",trainingPgmDictionary);
		//[workout_lang_selected release];
		
	}
	
	
	
	
	
	if ([elementName isEqualToString:@"workout"])
	{
		if(workoutId)
		[workoutDictionary setObject:workoutId forKey:@"workoutId"];
		[workoutDictionary setObject:originforce_status forKey:@"originforce_status"];
		[workoutDictionary setObject:originforce_file forKey:@"originforce_file"];
		[workoutDictionary setObject:author forKey:@"author"];
		[workoutDictionary setObject:validator forKey:@"validator"];
		[workoutDictionary setObject:version forKey:@"version"];
		[workoutDictionary setObject:datecreation forKey:@"datecreation"];
		[workoutDictionary setObject:datevalidate forKey:@"datevalidate"];
		[workoutDictionary setObject:status forKey:@"status"];
		[workoutDictionary setObject:typeW forKey:@"typeW"];
		[workoutDictionary setObject:intensity forKey:@"intensity"];
		[workoutDictionary setObject:group forKey:@"group"];
		[workoutDictionary setObject:sport forKey:@"sport"];
		[workoutDictionary setObject:time forKey:@"time"];
		[workoutDictionary setObject:workoutTitleArray forKey:@"workoutTitleArray"];
		
		[trainingPgmDictionary setObject:workoutDictionary forKey:@"workoutDictionary"];
         NSLog(@"trainingPgmDictionary NSMutableDictionary==%@",trainingPgmDictionary);
		[workoutDictionary release];
		[time release];
		[sport release];
		[group release];
		[typeW release];
		[status release];
		[datevalidate release];
		[datecreation release];
		[version release];
		[validator release];
		[author release];
		[originforce_file release];
		[originforce_status release];
		
		
		
	}	
	
	if ([elementName isEqualToString:@"genres"]) 
	{
		
		[trainingPgmDictionary setObject:generesArray forKey:@"genre"];
		[generesArray release];
		
	}
			
	if ([elementName isEqualToString:@"genre"]) 
	{		
		[generesArray addObject:genereStr];
		[genereStr release];
	}
	
			
	if([elementName isEqualToString:@"song_elements"]) 
	{
			
		if(!song_elementsEnded)
		{
			[trainingPgmDictionary setObject:songElementsArray forKey:@"songElementsArray"];
			[songElementsArray release];
		}
	}
	
	if([elementName isEqualToString:@"voc_elements"]) 
	{
		
		if(song_elementsEnded)
		{
			[trainingPgmDictionary setObject:vocalElementsArray forKey:@"vocalElementsArray"];
			[vocalElementsArray release];
		}
	}
	
	if ([currentElement isEqualToString:@"order"])
	{
		[trainingPgmDictionary setObject:order forKey:@"order"];
		//[order release];
	}
	if([elementName isEqualToString:@"element"]) {
		
		
		if(!song_elementsEnded)
		{
		[songElementsDictionary setObject:startpos forKey:@"startpos"];
		[songElementsDictionary setObject:duration forKey:@"duration"];
		[songElementsDictionary setObject:element forKey:@"element"];
		[songElementsDictionary setObject:bpmmax forKey:@"bpmmax"];
		[songElementsDictionary setObject:desc forKey:@"desc"];
		[songElementsDictionary setObject:provide forKey:@"provide"];
		[songElementsDictionary setObject:bpmmin forKey:@"bpmmin"];
		[songElementsDictionary setObject:effectout forKey:@"effectout"];
		[songElementsDictionary setObject:effectin forKey:@"effectin"];
		[songElementsDictionary setObject:styleforce forKey:@"styleforce"];
		[songElementsDictionary setObject:origineforce forKey:@"origineforce"];
		[songElementsDictionary setObject:styleforce forKey:@"styleforce"];
		[songElementsArray addObject:songElementsDictionary];
        NSLog(@"songElementsArray NSMutableDictionary==%@",songElementsArray);
		[songElementsDictionary release];
		}
		
		else
		{
			[vocalElementsDictionary setObject:element forKey:@"element"];
			[vocalElementsDictionary setObject:text2speechValue forKey:@"text2speechValue"];
			[vocalElementsDictionary setObject:text2speechLang forKey:@"text2speechLang"];
			[vocalElementsDictionary setObject:startpos forKey:@"startpos"];
			[vocalElementsDictionary setObject:duration forKey:@"duration"];
			[vocalElementsDictionary setObject:vocid forKey:@"vocid"];
			[vocalElementsArray addObject:vocalElementsDictionary];
            NSLog(@"vocalElementsArray NSMutableDictionary==%@",vocalElementsArray);
			[vocalElementsDictionary release];
		}
		
	}
	DUBUG_LOG(@"Now you are completed didEndElement method in WorkoutDetailsParser class");
}	



/*
 * Reads the value for each entity tag property (name ,region id, application id , callcenter id)
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	DUBUG_LOG(@"Now you are in foundCharacters method in WorkoutDetailsParser class");
	if ([currentElement isEqualToString:@"english"]) 
	{
		
		[engTitle appendString:string];
		
	}
	if ([currentElement isEqualToString:@"french"]) 
	{
		[frenchTitle appendString:string];
	}
	
	// New code for spanish and italian
	
	if ([currentElement isEqualToString:@"spanish"]) 
	{
		[frenchTitle appendString:string];
	}
	
	if ([currentElement isEqualToString:@"italian"]) 
	{
		[frenchTitle appendString:string];
	}
	
	
	
	
	
	
	
	
	
	
	if ([currentElement isEqualToString:@"genre"]) 
	{
		
		[genereStr appendString:string];
	}
	
	if ([currentElement isEqualToString:@"vocal_type"])
	{
		[vocal_type appendString:string];
				
	}
	
	
	if ([currentElement isEqualToString:@"color_flag"])
	{
		[color_flag appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"workout_lang_selected"])
	{
		[workout_lang_selected appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"time"])
	{
		[time appendString:string];
		
	}
	if ([currentElement isEqualToString:@"sport"])
	{
		[sport appendString:string];
		
	}
	if ([currentElement isEqualToString:@"group"])
	{
		[group appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"typeW"])
	{
		[typeW appendString:string];
		
	}
	if ([currentElement isEqualToString:@"status"])
	{
		[status appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"datevalidate"])
	{
		[datevalidate appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"datecreation"])
	{
		[datecreation appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"version"])
	{
		[version appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"validator"])
	{
		[validator appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"author"])
	{
		[author appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"originforce_file"])
	{
		[originforce_file appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"originforce_status"])
	{
		[originforce_status appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"order"])
	{
		[order appendString:string];
	}
	DUBUG_LOG(@"Now you are completed foundCharacters method in WorkoutDetailsParser class");
}	



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{	
	//NSLog(@"parsing error isisisi ===%@",parseError);
	//NSLog(@"parser error");
    DUBUG_LOG(@"Now you are in parseErrorOccurred method in WorkoutDetailsParser class");
	ParseError=YES;
	entities = nil;
	frenchTitles = nil;
	//dataParser = nil;
    DUBUG_LOG(@"Now you are completed parseErrorOccurred method in WorkoutDetailsParser class");
}

/*
 * Finish parsing
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{	
	 DUBUG_LOG(@"Now you are in parserDidEndDocument method in WorkoutDetailsParser class");
	//NSLog(@"parsing ended");
	if(entities.count == 0)
	{
		entities = nil;
	}
	
	if(frenchTitles.count == 0)
	{
		frenchTitles = nil;
	}
	//[dataParser release];
//	dataParser = nil;
    DUBUG_LOG(@"Now you are completed parserDidEndDocument method in WorkoutDetailsParser class");
}


-(NSMutableArray *) getData{
    DUBUG_LOG(@"Now you are in getData method in WorkoutDetailsParser class");
	return entities;
     DUBUG_LOG(@"Now you are completed getData method in WorkoutDetailsParser class");
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
   // [super dealloc];
	
	[dataParser release];
	dataParser = nil;
	
	[super dealloc];

}


@end
