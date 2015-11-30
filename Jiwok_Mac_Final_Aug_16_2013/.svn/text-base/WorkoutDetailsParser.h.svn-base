//
//  WorkoutDetailsParser.h
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 02/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WorkoutDetailsParser : NSObject {
	
	//Xml Parser
	NSXMLParser * dataParser;
	// holds the XML entities 
	NSMutableArray * entities,*frenchTitles,*generesArray,*songElementsArray,*vocalElementsArray;
	// a temporary entity holder added to the "entities" array for each parsed entity
	NSMutableDictionary * entity,*trainingPgmDictionary,*frenchTitleDict,*songElementsDictionary,*vocalElementsDictionary;
	// Used to track each item to be added to the "entities" array
	NSString * currentElement;
		
	NSMutableString *trainingPgmId,*engId,*engTitle,*frenchTitle,*genereStr,*vocal_type,*workout_lang_selected, *color_flag;
	NSString *startpos,*element,*duration,*styleforce,*origineforce,*effectin,*effectout,*bpmmin,*bpmmax,*desc,*provide,*vocid; 
	NSString *text2speechValue,*text2speechLang;
	
	
	NSMutableDictionary *pgmDictionary,*nextWorkoutDictionary,*workoutDictionary;
	NSString *pgmId,*engValueId,*frenchValueId,*netWorkoutId,*langId,*langValue,*workoutId,*queue_id;
	NSMutableArray *langArray,*workoutTitleArray;
	NSMutableString *originforce_status,*originforce_file,*author,*validator,*version,*datecreation,*datevalidate,*status,*typeW,*intensity,*group,*sport,*time,*order;
	bool song_elementsEnded,trainigPgmEnded;
		
}
-(NSMutableDictionary *)parseData:(NSData *)data;
- (void)parseXMLData:(NSData *)dataXml;
@end
