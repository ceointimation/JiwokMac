//
//  JiwokSettingPlistReader.m
//  Jiwok
//
//  Created by reubro R on 10/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokSettingPlistReader.h"
#define JIWOK_PLIST_FILE_NAME @"Settings.plist"

static BOOL pListAvailable = NO;
static NSDictionary *applicationSettingsDictionary;
@implementation JiwokSettingPlistReader
+(void)initialise
{
     NSLog(@"Now you are in initialise method in JiwokSettingPlistReader class");
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *defaultPlistFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:JIWOK_PLIST_FILE_NAME];
	NSLog(@"Path----> %@",defaultPlistFilePath);
	pListAvailable = [fileManager fileExistsAtPath:defaultPlistFilePath];
	applicationSettingsDictionary = [[NSDictionary alloc]initWithContentsOfFile:defaultPlistFilePath];
    NSLog(@"Now you are completed initialise method in JiwokSettingPlistReader class");
}
+(NSString *)updateTagDetectedGenre_api
{
	NSLog(@"Now you are in updateTagDetectedGenre_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"UpdateTagDetectedGenre_api"];
	}
	return keyData;
    NSLog(@"Now you are completed updateTagDetectedGenre_api method in JiwokSettingPlistReader class");
}
+(NSString *)UpdateLoginStatus_api
{
    NSLog(@"Now you are in UpdateLoginStatus_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"UpdateLoginStatus_api"];
	}
	return keyData;
     NSLog(@"Now you are completed UpdateLoginStatus_api method in JiwokSettingPlistReader class");
}
+(NSString *)GetUserDetails_api
{
     NSLog(@"Now you are in GetUserDetails_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"GetUserDetails_api"];
	}
	return keyData;
     NSLog(@"Now you are completed GetUserDetails_api method in JiwokSettingPlistReader class");
}
+(NSString *)GetJiwokURL
{
     NSLog(@"Now you are in GetJiwokURL method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"JiwokUrl"];
	}
	return keyData;
    NSLog(@"Now you are completed GetJiwokURL method in JiwokSettingPlistReader class");
	
}
+(NSString *)GetDownLoadVocalPath
{
    NSLog(@"Now you are in GetDownLoadVocalPath method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"Download_Vocal_Path"];
	}
	return keyData;
    NSLog(@"Now you are completed GetDownLoadVocalPath method in JiwokSettingPlistReader class");
}
+(NSString *)GetDownLoadSpSongsPath
{
    NSLog(@"Now you are in GetDownLoadSpSongsPath method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"Download_SpecificSong_Path"];
	}
	return keyData;
     NSLog(@"Now you are completed GetDownLoadSpSongsPath method in JiwokSettingPlistReader class");
}

+(NSString *)GetVocalInfo_api
{
     NSLog(@"Now you are in GetVocalInfo_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"GetVocalInfo_api"];
	}
	return keyData;	
    NSLog(@"Now you are completed GetVocalInfo_api method in JiwokSettingPlistReader class");
}
+(NSString *)GetAllWorkouts_api
{
    NSLog(@"Now you are in GetAllWorkouts_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"GetAllWorkoutInQueue_api"];
	}
	return keyData;	
     NSLog(@"Now you are completed GetAllWorkouts_api method in JiwokSettingPlistReader class");
}

+(NSString *)GetWorkOutByQueueID_api
{
     NSLog(@"Now you are in GetWorkOutByQueueID_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"GetWorkoutByQueueId_api"];
	}
	return keyData;	
    NSLog(@"Now you are completed GetWorkOutByQueueID_api method in JiwokSettingPlistReader class");
}

+(NSString *)GetWorkoutInQueue_api
{
    NSLog(@"Now you are in GetWorkoutInQueue_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"GetWorkoutInQueue_api"];
	}
	return keyData;	
    NSLog(@"Now you are completed GetWorkoutInQueue_api method in JiwokSettingPlistReader class");
}

+(NSString *)UpdateMP3GenerationStatus_api
{
    NSLog(@"Now you are in UpdateMP3GenerationStatus_api method in JiwokSettingPlistReader class");
	NSString *keyData = nil;
	if (pListAvailable)
	{
		keyData = (NSString *) [applicationSettingsDictionary objectForKey:@"UpdateMP3GenerationStatus_api"];
	}
	return keyData;	
     NSLog(@"Now you are completed UpdateMP3GenerationStatus_api method in JiwokSettingPlistReader class");
}


+(BOOL)checkForTemporaryUpdates
{
     NSLog(@"Now you are in checkForTemporaryUpdates method in JiwokSettingPlistReader class");
	BOOL keyData = NO;
	if (pListAvailable)
	{
		keyData =  [[applicationSettingsDictionary objectForKey:@"ShouldCheckTemporaryUpdates"] boolValue];
	}
	return keyData;
	 NSLog(@"Now you are completed checkForTemporaryUpdates method in JiwokSettingPlistReader class");
}



- (void) dealloc
{
	[applicationSettingsDictionary release];
	[super dealloc];
}

@end
