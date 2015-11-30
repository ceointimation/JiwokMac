//
//  InvokeUserdetailsAPI.h
//  Jiwok_Coredata_Trial
//
//  Created by reubro R on 07/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JiwokUserdetailsXmlParser.h"
#import "JiwokUpdateLoginStatusXmlParser.h"
#import "JiwokVocalInfoXMLParser.h"
#import "JiwokAllWorkoutInfoXMLParser.h"
#import "WorkoutDetailsParser.h"
#import "JiwokUpdateWorkoutStatusXmlParser.h"
//#import "JiwokAppDelegate.h"
#import "JiwokUpdateTagDetectedGenreXmlParser.h"


@interface JiwokAPIHelper : NSObject {

	JiwokUserdetailsXmlParser *fParser;
	JiwokUpdateLoginStatusXmlParser *updateParser;
	JiwokVocalInfoXMLParser *vocalInfoParser;
	JiwokAllWorkoutInfoXMLParser *allWorkoutinfoParser;
	WorkoutDetailsParser *workoutInfoParser;
	JiwokUpdateWorkoutStatusXmlParser *updateWorkoutStatus;
	JiwokUpdateTagDetectedGenreXmlParser *updateagDetectedGenre;
}
-(NSMutableDictionary *)InvokeUserdetailsAPI:(NSString *)username:(NSString *)password;
-(NSMutableDictionary *)JiwokUpdateLoginStatusAPI:(NSString *)username:(NSString *)status;
-(NSMutableArray *)InvokeGetVocalInfoAPI;
-(NSMutableArray *)InvokeGetAllWorkoutsAPI:(NSString *)username:(NSString *)language;
-(NSMutableDictionary *)InvokeGetWorkoutByQueueIdAPI:(NSString *)queueID;
-(NSMutableDictionary *)InvokeGetWorkoutInQueueAPI:(NSString *)username:(NSString *)password;
-(void)InvokeUpdateMP3GenerationStatusAPI:(NSString *)queueID:(NSString *)status;
-(void)InvokeUpdateTagDetectedGenreAPI:(NSString *)genre:(NSString *)count;
@end
