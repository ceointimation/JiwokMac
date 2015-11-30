//
//  JiwokAPIHelper.m
//  Jiwok_Coredata_Trial
//
//  Created by reubro R on 07/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokAPIHelper.h"
#import "JiwokUserdetailsXmlParser.h"
#import "JiwokSettingPlistReader.h"
#import "LoggerClass.h"
#import "JiwokAppDelegate.h"

#import "JiwokUtil.h"


# define IS_TESTING 0

@implementation JiwokAPIHelper

-(BOOL)checkInternetForApi{
    DUBUG_LOG(@"Now you are in checkInternetForApi method in JiwokAPIHelper class");
	BOOL netAvailable=NO;
	
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
	netAvailable=[JiwokUtil checkForInternetConnection:jiwokURL];
    DUBUG_LOG(@"Now you are completed checkInternetForApi method in JiwokAPIHelper class");
	return (netAvailable);
    
}


-(NSMutableDictionary *)InvokeUserdetailsAPI:(NSString *)username:(NSString *)password
{
	
	DUBUG_LOG(@"Now you are in InvokeUserdetailsAPI method in JiwokAPIHelper class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	username = @"santhosh@reubro.com";
//	password = @"santhosh";
//		
	username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSString *userdetailAPI = [JiwokSettingPlistReader GetUserDetails_api];
	NSString *userdetailURL =[NSString stringWithFormat:@"%@?username=%@&password=%@",userdetailAPI,username,password];

	//userdetailURL=[userdetailURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	userdetailURL=[userdetailURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];

	
	
	
	DUBUG_LOG(@"calling URL ->> %@",userdetailURL);
	
	NSURL *url = [NSURL URLWithString:userdetailURL];
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	fParser = [[JiwokUserdetailsXmlParser alloc] init];
	
	NSMutableDictionary *dictionary;

	
	@try{
	
	//NSMutableDictionary *dictionary= [[fParser parseData:data] retain];
	
		dictionary= [[fParser parseData:data] retain];

		DUBUG_LOG(@"parsing finished");
	
	[fParser release];
	[data release];
	[pool release];
	if([dictionary count]>0)
	{
		DUBUG_LOG(@"parsing got response %@",[dictionary objectForKey:@"language"]);
	}
        DUBUG_LOG(@"Now you are completed InvokeUserdetailsAPI method in JiwokAPIHelper class");
	
	}
		@catch(NSException *ex)
		{
			[[LoggerClass getInstance] logData:@"Exception occured in InvokeUserdetailsAPI %@",[ex description]];
			
		}
	
	@finally 
	{
	return [dictionary autorelease];
	}
	
	
	
		
}
-(NSMutableDictionary *)JiwokUpdateLoginStatusAPI:(NSString *)username:(NSString *)status
{
    DUBUG_LOG(@"Now you are in JiwokUpdateLoginStatusAPI method in JiwokAPIHelper class");
	DUBUG_LOG(@"updating user login status");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	
	NSString *updateuserstatusAPI = [JiwokSettingPlistReader UpdateLoginStatus_api];
	NSString *updateuserstatusURL =[NSString stringWithFormat:@"%@?username=%@&status=%@",updateuserstatusAPI,username,status];
	DUBUG_LOG(@"calling URL ->> %@",updateuserstatusURL);
	
	updateuserstatusURL=[updateuserstatusURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:updateuserstatusURL];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	updateParser = [[JiwokUpdateLoginStatusXmlParser alloc] init];
	
	NSMutableDictionary *dictionary;
	
	//NSMutableDictionary *dictionary= [[updateParser parseData:data] retain];
	
	@try{
	
	dictionary= [[updateParser parseData:data] retain];
	
	[updateParser release];
	[data release];
	[pool release];
	if([dictionary count]>0)
	{
		
		
		DUBUG_LOG(@"parsing got response %@",[dictionary objectForKey:@"result"]);
	}
		
        DUBUG_LOG(@"Now you are completed JiwokUpdateLoginStatusAPI method in JiwokAPIHelper class");
	}
	
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in JiwokUpdateLoginStatusAPI %@",[ex description]];
		
	}
	
	@finally 
	{
		return [dictionary autorelease];
	}	
	 
}

-(NSMutableArray *)InvokeGetVocalInfoAPI
{
     DUBUG_LOG(@"Now you are in InvokeGetVocalInfoAPI method in JiwokAPIHelper class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *vocalInfoAPI = [JiwokSettingPlistReader GetVocalInfo_api];
	DUBUG_LOG(@"calling URL ->> %@",vocalInfoAPI);
	
	NSURL *url = [NSURL URLWithString:vocalInfoAPI];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	vocalInfoParser = [[JiwokVocalInfoXMLParser alloc] init];
	
	NSMutableArray *arrayInfo;
	
	//NSMutableArray *arrayInfo = [[vocalInfoParser parseData:data] retain];
	
	@try{
	
	arrayInfo = [[vocalInfoParser parseData:data] retain];

	[vocalInfoParser release];
	[data release];
	[pool release];
    DUBUG_LOG(@"Now you are completed InvokeGetVocalInfoAPI method in JiwokAPIHelper class");
	
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in InvokeGetVocalInfoAPI %@",[ex description]];
		
	}
	
	@finally 
	{
	return [arrayInfo autorelease];
	}
	
}

-(NSMutableArray *)InvokeGetAllWorkoutsAPI:(NSString *)username:(NSString *)language
{
   DUBUG_LOG(@"Now you are in InvokeGetAllWorkoutsAPI method in JiwokAPIHelper class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSString *allworkoutsINQueueAPI = [JiwokSettingPlistReader GetAllWorkouts_api];
	
	NSString * allworkoutURL = [NSString stringWithFormat:@"%@?username=%@&lang_id=%@",allworkoutsINQueueAPI,username,@"2"];
	
	allworkoutURL=[allworkoutURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	
	//DUBUG_LOG(@"calling URL ->> %@",allworkoutURL);
	
	NSURL *url = [NSURL URLWithString:allworkoutURL];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	
	allWorkoutinfoParser = [[JiwokAllWorkoutInfoXMLParser alloc] init];
	
	NSMutableArray *arrayInfo;
	
//	NSMutableArray *arrayInfo = [[allWorkoutinfoParser parseData:data] retain];
	
	@try{
	
	arrayInfo = [[allWorkoutinfoParser parseData:data] retain];
        
	[allWorkoutinfoParser release];
    DUBUG_LOG(@"Now you are completed InvokeGetAllWorkoutsAPI method in JiwokAPIHelper class");
	[data release];
	[pool release];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in InvokeGetAllWorkoutsAPI %@",[ex description]];
		
	}
	
	@finally 
	{
	return [arrayInfo autorelease];
	}
    
}

-(NSMutableDictionary *)InvokeGetWorkoutByQueueIdAPI:(NSString *)queueID
{
    DUBUG_LOG(@"Now you are in InvokeGetWorkoutByQueueIdAPI method in JiwokAPIHelper class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	queueID = [queueID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	
	NSString *workoutInfoByQueueIDAPI = [JiwokSettingPlistReader GetWorkOutByQueueID_api];
	
	if(IS_TESTING)
		workoutInfoByQueueIDAPI = @"http://www.jiwok.com/webservices/GetWorkoutByQueueId_Color.php";
		
	
	
	NSString * workoutInfoByQueueIDURL = [NSString stringWithFormat:@"%@?queueID=%@",workoutInfoByQueueIDAPI,queueID];
	
	workoutInfoByQueueIDURL=[workoutInfoByQueueIDURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	
	DUBUG_LOG(@"calling URL ->> %@",workoutInfoByQueueIDURL);
	
	NSURL *url = [NSURL URLWithString:workoutInfoByQueueIDURL];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	////NSLog(@"data from URL ->> %@",data);

	workoutInfoParser = [[WorkoutDetailsParser alloc] init];
	
	NSMutableDictionary *dictionary;
	
	@try{
		
//	NSMutableDictionary *dictionary = [[workoutInfoParser parseData:data] retain];
	
	dictionary = [[workoutInfoParser parseData:data] retain];

	[workoutInfoParser release];
        DUBUG_LOG(@"Now you are completed InvokeGetWorkoutByQueueIdAPI method in JiwokAPIHelper class");
	[data release];
	[pool release];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in InvokeGetWorkoutByQueueIdAPI %@",[ex description]];
		
	}
	
	@finally 
	{
	return [dictionary autorelease];
	}
    
}

-(NSMutableDictionary *)InvokeGetWorkoutInQueueAPI:(NSString *)username:(NSString *)password
{	
    DUBUG_LOG(@"Now you are in InvokeGetWorkoutInQueueAPI method in JiwokAPIHelper class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSString *workoutInfoInQueueAPI = [JiwokSettingPlistReader GetWorkoutInQueue_api];
	
	if(IS_TESTING)
		workoutInfoInQueueAPI = @"http://www.jiwok.com/webservices/GetWorkoutInQueue_Color.php";
	
	NSString * workoutInfoInQueueURL = [NSString stringWithFormat:@"%@?username=%@&password=%@",workoutInfoInQueueAPI,username,password];
	
	workoutInfoInQueueURL=[workoutInfoInQueueURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	
	///DUBUG_LOG(@"calling URL ->> %@",workoutInfoInQueueURL);
	
	NSURL *url = [NSURL URLWithString:workoutInfoInQueueURL];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	
	

	// For checking crash

//	data=[data subdataWithRange:NSMakeRange(0,119)];	
	
//	NSString * aStr; 
//	aStr = [[[NSString alloc] initWithData:data encoding : NSASCIIStringEncoding] autorelease]; 
//	DUBUG_LOG(@"data returned is %@",aStr);
//	
	
	
	
	workoutInfoParser = [[WorkoutDetailsParser alloc] init];
	
	NSMutableDictionary *dictionary;
	
	@try{
	
//	NSMutableDictionary *dictionary = [[workoutInfoParser parseData:data] retain];
	dictionary = [[workoutInfoParser parseData:data] retain];
    DUBUG_LOG(@"dictionary NSMutableDictionary==%@",dictionary);
	[workoutInfoParser release];
    DUBUG_LOG(@"Now you are completed InvokeGetWorkoutInQueueAPI method in JiwokAPIHelper class");
	[data release];
	[pool release];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in InvokeGetWorkoutInQueueAPI %@",[ex description]];
		
	}
	
	@finally 
	{
	return [dictionary autorelease];
	}
     
}

-(void)InvokeUpdateTagDetectedGenreAPI:(NSString *)genre:(NSString *)count
{
    DUBUG_LOG(@"Now you are in InvokeUpdateTagDetectedGenreAPI method in JiwokAPIHelper class");
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	genre = [genre stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	count  =[count stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSString *updateTagDetectedGenre = [JiwokSettingPlistReader updateTagDetectedGenre_api];
	NSString * updateTagDetectedGenreStatusURL = [NSString stringWithFormat:@"%@?username=%@&genre=%@&count=%@", updateTagDetectedGenre,[appdelegate loggedusername],genre,count];
	
	
	updateTagDetectedGenreStatusURL=[updateTagDetectedGenreStatusURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	DUBUG_LOG(@"calling URL ->> |%@|",updateTagDetectedGenreStatusURL);
	
	NSURL *url = [NSURL URLWithString:updateTagDetectedGenreStatusURL];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	updateagDetectedGenre =[[JiwokUpdateTagDetectedGenreXmlParser alloc] init];
	
	NSMutableDictionary *dictionary;
	
	//NSMutableDictionary *dictionary = [[updateagDetectedGenre parseData:data] retain];
	
	@try{
		
	dictionary = [[updateagDetectedGenre parseData:data] retain];
    NSLog(@"dictionary NSMutableDictionary==%@",dictionary);
	//[updateagDetectedGenre release];
		
		
	//DUBUG_LOG(@"dictionaryisiisisis %@,",dictionary);
	if([dictionary count]>0)
	{
		
		NSString *resultStr =[dictionary objectForKey:@"result"];
		if([resultStr isEqualToString:@"1"])
		{
			//DUBUG_LOG(@"updated genre status");
		}
		else
		{
			//DUBUG_LOG(@"Not updated genre status");
		}
		//DUBUG_LOG(@"Response string for InvokeUpdateTagDetectedGenreAPI is %@",resultStr);
		
	}
	else
	{
	//	DUBUG_LOG(@"No response for InvokeUpdateTagDetectedGenreAPI ");
	}
	
		[updateagDetectedGenre release];
        DUBUG_LOG(@"Now you are completed InvokeUpdateTagDetectedGenreAPI method in JiwokAPIHelper class");
	[data release];
	[pool release];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in InvokeUpdateTagDetectedGenreAPI %@",[ex description]];
		
	}
	
	@finally 
	{
	}
	 
}
-(void)InvokeUpdateMP3GenerationStatusAPI:(NSString *)queueID:(NSString *)status
{	
     DUBUG_LOG(@"Now you are in InvokeUpdateMP3GenerationStatusAPI method in JiwokAPIHelper class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	queueID = [queueID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	status  =[status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if([queueID isEqualTo:NULL])
	{
		DUBUG_LOG(@"No workout in Queue");
	}
	else {
		NSString *updateMP3GenStatusAPI = [JiwokSettingPlistReader UpdateMP3GenerationStatus_api];
	
		NSString * updateMP3GenStatusURL = [NSString stringWithFormat:@"%@?queue_id=%@&status=%@",updateMP3GenStatusAPI,queueID,status];
	
		updateMP3GenStatusURL=[updateMP3GenStatusURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		
		DUBUG_LOG(@"calling URL ->> %@",updateMP3GenStatusURL);
	
		NSURL *url = [NSURL URLWithString:updateMP3GenStatusURL];
	
		NSData *data = [[NSData alloc] initWithContentsOfURL:url];
		updateWorkoutStatus =[[JiwokUpdateWorkoutStatusXmlParser alloc] init];

		NSMutableDictionary *dictionary;
		
//		NSMutableDictionary *dictionary = [[updateWorkoutStatus parseData:data] retain];
		@try{
		
		dictionary = [[updateWorkoutStatus parseData:data] retain];
		[updateWorkoutStatus release];
	DUBUG_LOG(@"dictionary NSMutableDictionary==%@",dictionary);
		if([dictionary count]>0)
			{
		
				NSString *resultStr =[dictionary objectForKey:@"result"];
				if([resultStr isEqualToString:@"1"])
					{
						DUBUG_LOG(@"Removed work out from queue");
					}
				else
					{
						DUBUG_LOG(@"Not removed work out from queue");
					}
				DUBUG_LOG(@"Response string for InvokeUpdateMP3GenerationStatusAPI is %@",resultStr);
		
			}
		else
			{
				DUBUG_LOG(@"No response for InvokeUpdateMP3GenerationStatusAPI ");
			}
	   DUBUG_LOG(@"Now you are completed InvokeUpdateMP3GenerationStatusAPI method in JiwokAPIHelper class");
		[data release];
	//}
	
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in InvokeUpdateMP3GenerationStatusAPI %@",[ex description]];
		
	}
	
	@finally 
	{
	}
	
	}
	[pool release];
   
}
@end
