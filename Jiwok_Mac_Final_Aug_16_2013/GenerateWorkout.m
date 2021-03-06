//
//  IntroVocalsDownload.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 12/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GenerateWorkout.h"
#import "JiwokAPIHelper.h"
#import "JiwokMusicProcessor.h"
#import "JiwokFTPDownloader.h"
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "JiwokAppDelegate.h"
#import "JiwokUtil.h"
#import "JiwokSettingPlistReader.h"
#import "Common.h"
#import "LoggerClass.h"
#import "Variable.h"
#import "JiwokCurlFtpClient.h"

// For testing purpose
#define shouldDeleteTempFiles 1


@implementation GenerateWorkout
@synthesize workoutDictionary;
@synthesize delegate;

- (NSString *)getFileSize:(NSString *)filePath{	
	DUBUG_LOG(@"Now you are in getFileSize method in GenerateWorkout class");
	DUBUG_LOG(@"filepath is %@",filePath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:filePath])
		{

			NSDictionary *attributes= [fileManager attributesOfItemAtPath:filePath error:NULL];
				//DUBUG_LOG(@"dictionary isii  %@",attributes);
			return([attributes objectForKey:NSFileSize]); 
		}
	else return (@"0");
   // NSLog(@"Now you are in getFileSize method in GenerateWorkout class");
}

-(void)introDownload:(NSMutableDictionary *)workoutDict
{
DUBUG_LOG(@"Now you are in introDownload method in GenerateWorkout class");	
	
if(!runningPreviousUserWorkout)
{
	
	
	DUBUG_LOG(@"\n \n \n xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  starting workout generation  workoutDict is %@",workoutDict);
	
	[delegate changeStatus:@"INFO-FOR_PROCESS_VOCALS"];
	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
	
	//workoutDictionary =[[NSMutableDictionary alloc] init];
	
	if(!forceFullygeneratedWorkout)
		{
			DUBUG_LOG(@" invoke from queue ");
			//Getting workout xml for forcefully generated workout
			workoutDictionary = workoutDict;
			[workoutDictionary retain];

			DUBUG_LOG(@"dictionary iisisiis %@",workoutDictionary);
			
		
		}
	else
		{ //Getting workout xml from queue
			
			workoutDictionary = [apiHelper InvokeGetWorkoutByQueueIdAPI:appdelegate.workoutQueueID];
			[workoutDictionary retain];
			DUBUG_LOG(@" queid is %@",appdelegate.workoutQueueID);
			
		}
	

	
	[[NSUserDefaults standardUserDefaults] setObject:workoutDictionary forKey:@"workoutDictionary"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	
	
	[apiHelper release];
	
	
		
	if([workoutDictionary count]>0)
	{
		
		
		
		queue_id =[[workoutDictionary objectForKey:@"queue_id"] intValue];
		
	}
	
	
	if(queue_id>0)
	{
		
	
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		//NSString *localVocalPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp"];
		
		
		CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
															 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
		NSString *localVocalPath = [workOutDirectory stringByAppendingPathComponent:@"Temp"];
		
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:localVocalPath])
			{
				[fileManager createDirectoryAtPath:localVocalPath attributes:nil];
			}
	
	
		if(downloadedPathArray)
			{
				[downloadedPathArray removeAllObjects];
				[downloadedPathArray release];
			}
		if(introArray)
			{
				[introArray removeAllObjects];
				[introArray release];
			}
		if(vocalsArray)
			{
				[vocalsArray removeAllObjects];
				[vocalsArray release];
			}
		if(startPosArray)
			{
				[startPosArray removeAllObjects];
				[startPosArray release];
			}
		if(vocalsDownloadedPathArray)
			{
				[vocalsDownloadedPathArray removeAllObjects];
				[vocalsDownloadedPathArray release];
			}
		if(vocalIdArray)
			{
				[vocalIdArray removeAllObjects];
				[vocalIdArray release];
			}
	
		if(songsElementsArray)
			{
				[songsElementsArray removeAllObjects];
				[songsElementsArray release];
			}
	
		if(allVocalsArray)
			{
				[allVocalsArray removeAllObjects];
				[allVocalsArray release];
			}
		
		if(outroArray)
		{
			[outroArray removeAllObjects];
			[outroArray release];
			
		}
		
		if(outroDownloadPathArray) {
			
			[outroDownloadPathArray removeAllObjects];
			[outroDownloadPathArray release];
		}
		
		
	
	
		downloadedPathArray =[[NSMutableArray alloc] init];
		vocalIdArray =[[NSMutableArray alloc] init];
		introArray =[[NSMutableArray alloc] init];
		vocalsArray =[[NSMutableArray alloc] init];
		startPosArray =[[NSMutableArray alloc] init];
		vocalsDownloadedPathArray  =[[NSMutableArray alloc] init];
		allVocalsArray =[[NSMutableArray alloc] init];
		songsElementsArray =[[NSMutableArray alloc] init];
		outroArray =[[NSMutableArray alloc] init];
		[introArray addObject:@"Jingle.mp3"];
		if([workoutDictionary count]>0)
			{
				NSString *musicFile =[NSString stringWithFormat:@"workout%d.mp3",[[workoutDictionary objectForKey:@"order"] intValue]];
				[introArray addObject:musicFile];
				
			}
	
		NSString *workoutId =[[workoutDictionary objectForKey:@"workoutDictionary"] objectForKey:@"workoutId"];
		NSString * workoutIdMathchFile =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] getWorkoutMp3: workoutId];
	
		if(workoutIdMathchFile.length)
		[introArray  addObject:workoutIdMathchFile];
	    NSLog(@"introArray NSMutableArray==%@",introArray);
		NSString *pgmId =[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"pgmId"];
		DUBUG_LOG(@"pgm id %@",pgmId);
		NSString * pgmIdMatchFile =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] getTraingingMp3:pgmId];
		DUBUG_LOG(@"pgm match file %@",pgmIdMatchFile);
		
		if(pgmIdMatchFile.length)
		[introArray  addObject:pgmIdMatchFile];
		
		[introArray addObject:@"walking.mp3"];
		[introArray addObject:@"Ending.mp3"];
        NSLog(@"introArray NSMutableArray==%@",introArray);    
	
		JiwokCurlFtpClient * fileDownloader = [[JiwokCurlFtpClient alloc] init];
		//NSString *vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/french/"];
		
		NSString *vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/"];
		
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/"];
	
	//	if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
//			vocalPath=[NSString stringWithFormat:@"%@french/",vocalPath];
//		else		
//			vocalPath=[NSString stringWithFormat:@"%@english/",vocalPath];
		
		
		if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
			vocalPath=[NSString stringWithFormat:@"%@french/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"])	
			vocalPath=[NSString stringWithFormat:@"%@english/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])	
			vocalPath=[NSString stringWithFormat:@"%@spanish/",vocalPath];
		
		else //if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])	
			vocalPath=[NSString stringWithFormat:@"%@italian/",vocalPath];
		
		
		NSString *finalPath = [[NSString alloc] initWithFormat:@"%@",vocalPath];
	
		DUBUG_LOG(@"intro array count isiis %@",introArray);
		//NSString *VocalPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Vocals"];
	
		NSString *VocalPath = [bundlePath  stringByAppendingPathComponent:@"Vocals"];
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			VocalPath = [bundlePath  stringByAppendingPathComponent:@"color_vocals"];


		if(![fileManager fileExistsAtPath:VocalPath])
		{
			[fileManager createDirectoryAtPath:VocalPath attributes:nil];
		}
		
		DUBUG_LOG(@"array count is %d",[introArray count]);
		
		
		// Download Intro Vocals
		int count=0;
		float carryOver =0.0,startPos=0.0;
		for (NSString *vocalName in introArray)
			{
		
				if(!runningPreviousUserWorkout)
				{
					if(count ==2 || count ==3)
				{
					//NSString *introVocalPath =[NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/public/introvocals/workouts/french/"];
					
					NSString *introVocalPath =[NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/introvocals/workouts/"];					
								
//					
//					if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
//						introVocalPath=[NSString stringWithFormat:@"%@french/",introVocalPath];
//					else		
//						introVocalPath=[NSString stringWithFormat:@"%@english/",introVocalPath];
					
					
					
					if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
						introVocalPath=[NSString stringWithFormat:@"%@french/",vocalPath];
					
					else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"])	
						introVocalPath=[NSString stringWithFormat:@"%@english/",vocalPath];
					
					else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])	
						introVocalPath=[NSString stringWithFormat:@"%@spanish/",vocalPath];
					
					else //if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])	
						introVocalPath=[NSString stringWithFormat:@"%@italian/",vocalPath];
					
					
					finalPath =[[NSString alloc] initWithFormat:@"%@",introVocalPath];
				}
				
				else
				{
				//	if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
//					vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/french/"];
//					else 
//						vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/english/"];

					
					NSString *baseString = @"ftp://jiwok-wbdd.najman.lbn.fr/vocals/";
					
					if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
						baseString = @"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/";
					
					
					if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
						vocalPath =  [NSString stringWithFormat:@"%@french/",baseString];
					
					else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"])	
						vocalPath =  [NSString stringWithFormat:@"%@english/",baseString];
					
					else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])	
						vocalPath =  [NSString stringWithFormat:@"%@spanish/",baseString];
					
					else //if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])	
						vocalPath =  [NSString stringWithFormat:@"%@italian/",baseString];
					
					//[finalPath release];
					finalPath = [[NSString alloc] initWithFormat:@"%@",vocalPath];
				}
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				DUBUG_LOG(@"vocal path isisis %@",vocalsPath);
				if(![fileManager fileExistsAtPath:vocalsPath])
					{
						
						
			
						NSString *newVocalPath = [[NSString alloc] initWithFormat:@"%@%@",finalPath,vocalName];
						DUBUG_LOG(@"downloadable path isisi %@",newVocalPath);
						NSString *newLocalVocalPath = [[NSString alloc] initWithFormat:@"%@",vocalsPath];
						DUBUG_LOG(@"new vocal path isisi %@",newLocalVocalPath);
						//if(![fileManager fileExistsAtPath:newVocalPath])
						[fileDownloader DownloadFromFTP:newVocalPath:newLocalVocalPath];
						[newVocalPath release];
						[newLocalVocalPath release];
			
					}
		
				NSString *fileSize =[self getFileSize:vocalsPath];
				if([fileSize intValue] ==0)
			
				{
			
					DUBUG_LOG(@"A count value is %d-----%@",count,vocalName);
					DUBUG_LOG(@"file size isisisiis %d",[fileSize intValue] );
				[[NSFileManager defaultManager] removeFileAtPath:vocalsPath handler: nil];
			
			
				
				}
				else
					{
						if(count ==0 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
						{
							NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
							NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/introTemp1.wav",localVocalPath];
							NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp1_BitRate.wav",localVocalPath];
							NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/introTemp1_Volume.wav",localVocalPath];
							JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
							[musicProcessor PadSilence:vocalsPath:tempPath:@"5.00":@"0.00"];
							[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
							[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
							[musicProcessor release];
							[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
							[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				
							[vocalsPath release];
							if(([fileManager fileExistsAtPath:tempPath2]))
								[downloadedPathArray addObject:tempPath2];
							NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
							float dur =[sound duration];
							carryOver =(dur*1000)-((round(dur))*1000);
							carryOver =carryOver/1000;
							DUBUG_LOG(@"first introvocal durtion is %f  %f",dur*1000,(round(dur))	*1000);
							startPos =startPos+dur+carryOver;
							[sound release];
							[tempPath release];
							[tempPath1 release];
				
						}
			
			
						if(count ==1 && ([fileManager fileExistsAtPath:vocalsPath])  && [vocalName length] !=0)
						{
							//DUBUG_LOG(@"coming to second index");
							float tempDur =10-startPos;
							carryOver =0.0;
							NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
							NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/introTemp2.wav",localVocalPath];
							NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp2_BitRate.wav",localVocalPath];
							NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/introTemp2_Volume.wav",localVocalPath];
							JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
							[musicProcessor PadSilence:vocalsPath:tempPath:[NSString stringWithFormat:@"%f",tempDur]:@"0.00"];
							[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
							[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
							[musicProcessor release];
							[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
							[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				//[tempPath release];
							[vocalsPath release];
				//NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp2.mp3",localVocalPath];
							if(([fileManager fileExistsAtPath:tempPath2]))
								[downloadedPathArray addObject:tempPath2];
							NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
							float dur =[sound duration];
							carryOver =(dur*1000)-((round(dur))*1000);
							carryOver =carryOver/1000;
							DUBUG_LOG(@"duration isiisi %f",dur);
							startPos =startPos+dur+carryOver;
							[sound release];
							[tempPath release];
							[tempPath1 release];
				
						}
			
			
			
						if(count ==2 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
							{
								//DUBUG_LOG(@"coming to second index");
								carryOver =0.0;
								NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
								NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/introTemp3.wav",localVocalPath];
								NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp3_BitRate.wav",localVocalPath];
								NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/introTemp3_Volume.wav",localVocalPath];
								JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
								[musicProcessor PadSilence:vocalsPath:tempPath:@"0.00":@"0.00"];
								[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
								[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
								[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
								[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
								[musicProcessor release];
								[vocalsPath release];
								if(([fileManager fileExistsAtPath:tempPath2]))
									[downloadedPathArray addObject:tempPath2];
								NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
								float dur =[sound duration];
								carryOver =(dur*1000)-((round(dur))*1000);
								carryOver =carryOver/1000;
								startPos =startPos+dur+carryOver;
								[sound release];
								[tempPath release];
								[tempPath1 release];
				
							}
			
			
			if(count ==3 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				DUBUG_LOG(@"coming to second index --%@",vocalsPath);
				carryOver =0.0;
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/introTemp4.wav",localVocalPath];
				NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp4_BitRate.wav",localVocalPath];
				NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/introTemp4_Volume.wav",localVocalPath];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				[musicProcessor PadSilence:vocalsPath:tempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
				[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				[musicProcessor release];
				
				[vocalsPath release];
				//NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp4.mp3",localVocalPath];
				if(([fileManager fileExistsAtPath:tempPath2]))
				 [downloadedPathArray addObject:tempPath2];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
				float dur =[sound duration];
				carryOver =(dur*1000)-((round(dur))*1000);
				carryOver =carryOver/1000;
				startPos =startPos+dur+carryOver;
				[sound release];
				[tempPath release];
				[tempPath1 release];
				
			}
			
			
			if(count ==4 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				DUBUG_LOG(@"coming to 4th index");
				carryOver =0.0;
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/introTemp5.wav",localVocalPath];
				NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp5_BitRate.wav",localVocalPath];
				NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/introTemp5_Volume.wav",localVocalPath];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				[musicProcessor PadSilence:vocalsPath:tempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
				[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				[musicProcessor release];
				
				[vocalsPath release];
				//NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp5.mp3",localVocalPath];
				if(([fileManager fileExistsAtPath:tempPath2]))
					[downloadedPathArray addObject:tempPath2];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
				float dur =[sound duration];
				carryOver =(dur*1000)-((round(dur))*1000);
				carryOver =carryOver/1000;
				startPos =startPos+dur+carryOver;
				[sound release];
				[tempPath release];
				[tempPath1 release];
				
			}
			
			if(count ==5 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				//DUBUG_LOG(@"coming to second index");
				float tempDur =57-startPos;
				carryOver =0;
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/introTemp6.wav",localVocalPath];
				NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp6_BitRate.wav",localVocalPath];
				NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/introTemp6_Volume.wav",localVocalPath];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				[musicProcessor PadSilence:vocalsPath:tempPath:[NSString stringWithFormat:@"%f",tempDur]:@"0.00"];
				[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
				[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				[musicProcessor release];
				
				[vocalsPath release];
				//NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/introTemp6.mp3",localVocalPath];
				
				if(([fileManager fileExistsAtPath:tempPath2]))
					[downloadedPathArray addObject:tempPath2];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
				float dur =[sound duration];
				carryOver =(dur*1000)-((round(dur))*1000);
				carryOver =carryOver/1000;
				startPos =startPos+dur+carryOver;
				[sound release];
				[tempPath release];
				[tempPath1 release];
				
			}
		}
		count++;	
			}	
		else
			{
				return;
			}
				
	}
	[fileDownloader release];
	[finalPath release];
		
		
		
		
	
	DUBUG_LOG(@"intro path array count is %d",[downloadedPathArray count]);
		
//		[downloadedPathArray removeAllObjects];		
//		DUBUG_LOG(@"intro path array count is %d",[downloadedPathArray count]);

		
		
		
		//Concatenate Intro Vocals
		JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
		NSString *introFinalPath = [[NSString alloc] initWithFormat:@"%@/finalIntro.wav",localVocalPath];
		[musicProcessor Concatenate:downloadedPathArray:introFinalPath];
		[musicProcessor release];
		//[allVocalsArray addObject:introFinalPath];
		
		
		
		NSSound *sound=[[NSSound alloc] initWithContentsOfFile:introFinalPath byReference:YES];
		float IntroDur =[sound duration];
		[sound release];
		float introDurDifference =60-IntroDur;
		
		
		if(IntroDur<60)
		{
			NSString *introFinalCorrected = [[NSString alloc] initWithFormat:@"%@/finalIntroCorrected.wav",localVocalPath];
			musicProcessor =[[JiwokMusicProcessor alloc] init];
			[musicProcessor PadSilence:introFinalPath:introFinalCorrected:@"0.00":[NSString stringWithFormat:@"%f",introDurDifference]];
			[musicProcessor release];
			[[NSFileManager defaultManager] removeFileAtPath:introFinalPath handler: nil];
			if(([fileManager fileExistsAtPath:introFinalCorrected]))
				[allVocalsArray addObject:introFinalCorrected];
			[introFinalCorrected release];
		}
		else {
			
			if(([fileManager fileExistsAtPath:introFinalPath]))
				[allVocalsArray addObject:introFinalPath];
		}
		[introFinalPath release];
		
		
		
		
		
		
	
		
		
	//Creating vocal mp3 from vocal elements from the Workout.xml
	
		apiHelper = [[JiwokAPIHelper alloc]init];
		//NSMutableArray *vocalInfoArray = [apiHelper InvokeGetVocalInfoAPI];
		
		NSMutableArray *vocalInfoArray;// = [apiHelper InvokeGetVocalInfoAPI];

		NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
		if (jiwokURL)
		{
			if (![JiwokUtil checkForInternetConnection:jiwokURL])
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
				[delegate generationFailed];
				runningPreviousUserWorkout=YES;

				return;
			}
			else
			{
		vocalInfoArray = [apiHelper InvokeGetVocalInfoAPI];
			}
			
		}
		[apiHelper release];
		
			
	if([vocalInfoArray count]>0)
	{
		//DUBUG_LOG(@"vocal api is %@----%d",vocalInfoArray,[vocalInfoArray count]);
		
	}
	NSString *vocalType;
		
		if(workoutDictionary)
	if([workoutDictionary count]>0)
	{
		vocalType =[workoutDictionary objectForKey:@"workout_lang_selected"];
		
	}
	if([vocalType isEqualToString:@"1"])
	{
		DUBUG_LOG(@"vocal type is 1");
		
		vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/english/"];
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/english/"];


		
		for(int i=0; i<[[workoutDictionary objectForKey:@"vocalElementsArray"] count];i++)
		{
			if(!runningPreviousUserWorkout)
			{
				for(int j=0; j<[vocalInfoArray count];j++)
			{
				
				if([[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"] isEqualToString:[[vocalInfoArray objectAtIndex:j] objectForKey:@"id"]])
				{
					[vocalsArray addObject:[NSString stringWithFormat:@"EN_%@.mp3",[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]]];
					
					if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"])
					[startPosArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"]];
					
					if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
					[vocalIdArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]];
				}
			}
			
		}
			else
			{
				return;
			}
	}
	}
	else if([vocalType isEqualToString:@"2"])
	{
		DUBUG_LOG(@"vocal type is 2");
		
		vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/french/"];
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/french/"];


		
		for(int i=0; i<[[workoutDictionary objectForKey:@"vocalElementsArray"] count];i++)
		{
			if(!runningPreviousUserWorkout)
			{
			if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
			[vocalsArray addObject:[NSString stringWithFormat:@"FR_%@.mp3",[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]]];
		
			if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"])
			[startPosArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"]];
			
			if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
			[vocalIdArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]];
				
			}
			else
			{
				return;
			}
		}
	}
	else if([vocalType isEqualToString:@"3"])
	{
		DUBUG_LOG(@"vocal type is 3");
		
		vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/spanish/"];
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/spanish/"];


		
		for(int i=0; i<[[workoutDictionary objectForKey:@"vocalElementsArray"] count];i++)
		{
			if(!runningPreviousUserWorkout)
			{
				if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
					[vocalsArray addObject:[NSString stringWithFormat:@"ESP_%@.mp3",[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]]];
				
				if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"])
					[startPosArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"]];
				
				if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
					[vocalIdArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]];
				
			}
			else
			{
				return;
			}
		}
	}
	else //if([vocalType isEqualToString:@"2"])
	{
		DUBUG_LOG(@"vocal type is 4");
		
		vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/italian/"];
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			vocalPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/italian/"];


		
		for(int i=0; i<[[workoutDictionary objectForKey:@"vocalElementsArray"] count];i++)
		{
			if(!runningPreviousUserWorkout)
			{
				if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
					[vocalsArray addObject:[NSString stringWithFormat:@"IT_%@.mp3",[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]]];
				
				if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"])
					[startPosArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"startpos"]];
				
				if([[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"])
					[vocalIdArray addObject:[[[workoutDictionary objectForKey:@"vocalElementsArray"] objectAtIndex:i] objectForKey:@"vocid"]];
				
			}
			else
			{
				return;
			}
		}
	}
	
	
	DUBUG_LOG(@"vocalsArray %@",vocalsArray);
	
	//NSString *localVocalPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Vocals"];
	fileDownloader = [[JiwokCurlFtpClient alloc] init];
	fileManager = [NSFileManager defaultManager];
	finalPath = [[NSString alloc] initWithFormat:@"%@",vocalPath];
		int s=0;
		float vocalCarryOver =0.0,startPosition=0.0;
	for (NSString *vocalName in vocalsArray)
	{
		if(!runningPreviousUserWorkout)
		{
		//if(p<10){
		NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
		DUBUG_LOG(@"vocal path isisis %@",vocalsPath);
		if(![fileManager fileExistsAtPath:vocalsPath])
		{
			
			NSString *newVocalPath = [[NSString alloc] initWithFormat:@"%@%@",finalPath,vocalName];
			NSString *newLocalVocalPath = [[NSString alloc] initWithFormat:@"%@",vocalsPath];
			DUBUG_LOG(@"new vocal path isisi %@ newVocalPath is %@ vocalPath is %@",newLocalVocalPath,newVocalPath,vocalPath);
			//if([fileManager fileExistsAtPath:newVocalPath])
			[fileDownloader DownloadFromFTP:newVocalPath:newLocalVocalPath];
			[newVocalPath release];
			[newLocalVocalPath release];
			
		}
		
		
		
		NSString *fileSize =[self getFileSize:vocalsPath];
		if([fileSize intValue] ==0)
			
		{
			
			DUBUG_LOG(@"count value is %d-----%@",count,vocalName);
			DUBUG_LOG(@"file size isisisiis %d",[fileSize intValue] );
			[[NSFileManager defaultManager] removeFileAtPath:vocalsPath handler: nil];
		}
		
		
		else
		{
			//int vocId=[[vocalIdArray objectAtIndex:s] intValue];
			DUBUG_LOG(@"vocals frm xml %@",vocalsPath);
			
			if([[startPosArray objectAtIndex:s] intValue]==-1 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				
				vocalCarryOver =0.0;
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/vocalTemp%d.wav",localVocalPath,s];
				NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/vocalTemp_Bitrate%d.wav",localVocalPath,s];
				NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/vocalTemp_Volume%d.wav",localVocalPath,s];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				[musicProcessor PadSilence:vocalsPath:tempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
				[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
				[musicProcessor release];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				[vocalsPath release];
				//NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/vocalTemp%d.mp3",localVocalPath,vocId];
				if(([fileManager fileExistsAtPath:tempPath2]))
					[vocalsDownloadedPathArray addObject:tempPath2];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
				float dur =[sound duration];
				vocalCarryOver =dur*1000-(round(dur))*1000 ;
				DUBUG_LOG(@"vocal carry over siisiis %f",vocalCarryOver);
				vocalCarryOver =vocalCarryOver/1000;
				startPosition =startPosition+dur;
				[sound release];
				[tempPath release];
				[tempPath1 release];
				
				
			}
			
			else if(([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				float secondsValue =[[startPosArray objectAtIndex:s] intValue];
				DUBUG_LOG(@"secondsValue isiisi %d---startPosition isisisii %d",secondsValue,startPosition);
				float difference =secondsValue-startPosition+vocalCarryOver;
				vocalCarryOver =0.0;
				
				DUBUG_LOG(@"difference difference difference %f",difference);
				
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				NSString *tempPath = [[NSString alloc] initWithFormat:@"%@/vocalTemp%d.wav",localVocalPath,s];
				NSString *tempPath1 = [[NSString alloc] initWithFormat:@"%@/vocalTemp_Bitrate%d.wav",localVocalPath,s];
				NSString *tempPath2 = [[NSString alloc] initWithFormat:@"%@/vocalTemp_Volume%d.wav",localVocalPath,s];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				[musicProcessor PadSilence:vocalsPath:tempPath:[NSString stringWithFormat:@"%f",difference]:@"0.00"];
				[musicProcessor convertBitRate:tempPath:@"44100":tempPath1];
				[musicProcessor IncreaseVolumeUsingSox:tempPath1:tempPath2];
				[musicProcessor release];
 
				[[NSFileManager defaultManager] removeFileAtPath:tempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:tempPath1 handler: nil];
				[vocalsPath release];
				
				if(([fileManager fileExistsAtPath:tempPath2]))
					[vocalsDownloadedPathArray addObject:tempPath2];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:tempPath2 byReference:YES];
				float dur =[sound duration];
				vocalCarryOver =(dur*1000)-((round(dur))*1000) ;
				DUBUG_LOG(@"tempPath2 %@",tempPath2);
				vocalCarryOver =vocalCarryOver/1000;
				startPosition =startPosition+dur;
				[sound release];
				[tempPath release];
				[tempPath1 release];

				
			}
			
			
			
		}
		
		
		s++;
			//p++;
	//}
	}	
	}
	[fileDownloader release];
	[finalPath release];
	DUBUG_LOG(@"vocalsPading path is %d",[vocalsDownloadedPathArray count]);
	
	//NSString *initialPathVocal =[[NSString alloc] initWithFormat:[vocalsDownloadedPathArray objectAtIndex:0]];
	
	
		for(int n=0;n<[vocalsDownloadedPathArray count];n++)
		{
			
			[allVocalsArray addObject:[vocalsDownloadedPathArray objectAtIndex:n]];
		}
		
	
	//******************** Outro download*************************************************************************
	
	
	//wrorkoutInfo =[[JiwokAPIHelper alloc] init];
	//workoutDictionary = [wrorkoutInfo JiwokGetWorkoutdetails];
	
	if([workoutDictionary count]>0)
	{
		
		
	}
	//[wrorkoutInfo release];
	
	outroDownloadPathArray =[[NSMutableArray alloc] init];
	[outroArray addObject:@"Jingle_End.mp3"];
	[outroArray addObject:@"Jingle_End2.mp3"];
	[outroArray addObject:@"Jingle_End3.mp3"];
	if([workoutDictionary count]>0)
	{
		int orderValue =[[workoutDictionary objectForKey:@"order"] intValue] +1;
		NSString *musicFile =[NSString stringWithFormat:@"workout%d.mp3",orderValue];
		[outroArray addObject:musicFile];
		//[outroArray addObject:musicFile];
	}
	
	
	NSString *nextWorkoutId =[[workoutDictionary objectForKey:@"nextWorkoutDictionary"] objectForKey:@"netWorkoutId"];
	NSString *nextWorkoutIdMatchFile =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] getWorkoutMp3:nextWorkoutId];
	if(nextWorkoutIdMatchFile.length)
	[outroArray addObject:nextWorkoutIdMatchFile];
	[outroArray addObject:@"Ending_Next.mp3"];
		
		
		DUBUG_LOG(@"outro array is %@",outroArray);
	
	fileDownloader = [[JiwokCurlFtpClient alloc] init];
	
		//NSString *serverPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/french/"];
		
		
		NSString *serverPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/vocals/"];
		
		if([[workoutDictionary objectForKey:@"color_flag"] isEqualToString:@"1"])
			serverPath =  [NSString stringWithString:@"ftp://jiwok-wbdd.najman.lbn.fr/color_vocals/"];

		
		
//		if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
//			serverPath=[NSString stringWithFormat:@"%@french/",serverPath];
//		else		
//			serverPath=[NSString stringWithFormat:@"%@english/",serverPath];
		
		
		if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
			serverPath=[NSString stringWithFormat:@"%@french/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"])	
			serverPath=[NSString stringWithFormat:@"%@english/",vocalPath];
		
		else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])	
			serverPath=[NSString stringWithFormat:@"%@spanish/",vocalPath];
		
		else //if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])	
			serverPath=[NSString stringWithFormat:@"%@italian/",vocalPath];
		
	
		float workoutTime =[[[workoutDictionary objectForKey:@"workoutDictionary"] objectForKey:@"time"] floatValue];
		float lastCarryOver =workoutTime*60 -startPosition;
		DUBUG_LOG(@"startPos is %f--%f ",startPosition,lastCarryOver);
			
	int m=0;
	float startPos1=0.0;
	
	
	for (NSString *vocalName in outroArray)
	{
		if(!runningPreviousUserWorkout)
		{
		NSString *newLocalVocalPath;
		NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
		DUBUG_LOG(@"vocal path isisis %@",vocalsPath);
		if(![fileManager fileExistsAtPath:vocalsPath])
		{
			
			NSString *newVocalPath = [[NSString alloc] initWithFormat:@"%@%@",serverPath,vocalName];
			newLocalVocalPath = [[NSString alloc] initWithFormat:@"%@",vocalsPath];
			
			DUBUG_LOG(@"new vocal path isisi %@",newLocalVocalPath);
			//if([fileManager fileExistsAtPath:newVocalPath])
			[fileDownloader DownloadFromFTP:newVocalPath:newLocalVocalPath];
			[newVocalPath release];
			[newLocalVocalPath release];
			
		}
		
		DUBUG_LOG(@"path isisi %@",vocalsPath);
		NSString *fileSize =[self getFileSize:vocalsPath];
		
		if([fileSize intValue] ==0)
			
		{
			
			DUBUG_LOG(@"file size isisisiis %d",[fileSize intValue] );
			[[NSFileManager defaultManager] removeFileAtPath:vocalsPath handler: nil];
			
		}
		
		else
		{
			if([vocalName isEqualToString:@"Jingle_End.mp3"] && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
				
			{
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/outroTemp1.wav",localVocalPath];
				NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp1_BitRate.wav",localVocalPath];
				NSString *outroTempPath2 = [[NSString alloc] initWithFormat:@"%@/outroTemp1_Volume.wav",localVocalPath];
				
				
					
				
				DUBUG_LOG(@"temp path and processing path are %@ ,%@",outroTempPath,vocalsPath);
				[musicProcessor PadSilence:vocalsPath:outroTempPath:@"5.00":@"0.00"];
				[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
				[musicProcessor IncreaseVolumeUsingSox:outroTempPath1:outroTempPath2];
				
				//NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp1.mp3",localVocalPath];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:outroTempPath2 byReference:YES];
				float dur =[sound duration];
				startPos1 =startPos1+dur;
				[sound release];
				[musicProcessor release];
 
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath1 handler: nil];
				
				if(([fileManager fileExistsAtPath:outroTempPath2]))
					[outroDownloadPathArray addObject:outroTempPath2];
				[outroTempPath release];
				[outroTempPath1 release];
			}
			
			
			if([vocalName isEqualToString:@"Jingle_End2.mp3"] && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0 )
			{
				
				//float tempDuration =startPos+1;
				//float tempDuration =startPos1;
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/outroTemp2.wav",localVocalPath];
 NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp2_BitRate.wav",localVocalPath];
 NSString *outroTempPath2 = [[NSString alloc] initWithFormat:@"%@/outroTemp2_Volume.wav",localVocalPath];
				DUBUG_LOG(@"temp path and processing path are %@ ,%@",outroTempPath,vocalsPath);
				[musicProcessor PadSilence:vocalsPath:outroTempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
				[musicProcessor IncreaseVolumeUsingSox:outroTempPath1:outroTempPath2];
				//[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath];
				//[musicProcessor PadSilence:vocalsPath:outroTempPath:[NSString stringWithFormat:@"%f",tempDuration]:@"0.00"];
				//NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp2.mp3",localVocalPath];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:outroTempPath2 byReference:YES];
				float dur =[sound duration];
				startPos1 =startPos1+dur;
				[sound release];
				[musicProcessor release];
				
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath1 handler: nil];
				if(([fileManager fileExistsAtPath:outroTempPath2]))
					[outroDownloadPathArray addObject:outroTempPath2];
				[outroTempPath release];
				[outroTempPath1 release];
				
			}
			
			
			if([vocalName isEqualToString:@"Jingle_End3.mp3"] && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				
				float tempDuration =startPos1;
				
				DUBUG_LOG(@"tempDuration tempDuration is %f",tempDuration);
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/outroTemp3.wav",localVocalPath];
				NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp3_BitRate.wav",localVocalPath];
				NSString *outroTempPath2 = [[NSString alloc] initWithFormat:@"%@/outroTemp3_Volume.wav",localVocalPath];
				DUBUG_LOG(@"temp path and processing path are %@ ,%@",outroTempPath,vocalsPath);
				[musicProcessor PadSilence:vocalsPath:outroTempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
				[musicProcessor IncreaseVolumeUsingSox:outroTempPath1:outroTempPath2];
				//[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath];
				//NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp3.mp3",localVocalPath];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:outroTempPath2 byReference:YES];
				float dur =[sound duration];
				startPos1 =startPos1+dur;
				[sound release];
				[musicProcessor release];
				
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath1 handler: nil];
				if(([fileManager fileExistsAtPath:outroTempPath2]))
				 [outroDownloadPathArray addObject:outroTempPath2];
				[outroTempPath release];
				[outroTempPath1 release];
				
				
				
				
			}
			if(m==3 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				
				float tempDuration =startPos1;
				DUBUG_LOG(@"tempDuration tempDuration is %f",tempDuration);
				
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/outroTemp4.wav",localVocalPath];
				NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp4_BitRate.wav",localVocalPath];
				NSString *outroTempPath2 = [[NSString alloc] initWithFormat:@"%@/outroTemp4_Volume.wav",localVocalPath];
				DUBUG_LOG(@"temp path and processing path are %@ ,%@",outroTempPath,vocalsPath);
				[musicProcessor PadSilence:vocalsPath:outroTempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
				[musicProcessor IncreaseVolumeUsingSox:outroTempPath1:outroTempPath2];
				//[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath];
				//NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp4.mp3",localVocalPath];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:outroTempPath2 byReference:YES];
				float dur =[sound duration];
				startPos1 =startPos1+dur;
				[sound release];
				[musicProcessor release];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath1 handler: nil];
				if(([fileManager fileExistsAtPath:outroTempPath2]))
					[outroDownloadPathArray addObject:outroTempPath2];
				[outroTempPath release];
				[outroTempPath1 release];
				
			}
			
			if(m==4 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				
				float tempDuration =startPos1;
				DUBUG_LOG(@"tempDuration tempDuration is %f",tempDuration);
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/outroTemp5.wav",localVocalPath];
				NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp5_BitRate.wav",localVocalPath];
				NSString *outroTempPath2 = [[NSString alloc] initWithFormat:@"%@/outroTemp5_Volume.wav",localVocalPath];
				DUBUG_LOG(@"temp path and processing path are %@ ,%@",outroTempPath,vocalsPath);
				[musicProcessor PadSilence:vocalsPath:outroTempPath:@"0.00":@"0.00"];
				[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
				[musicProcessor IncreaseVolumeUsingSox:outroTempPath1:outroTempPath2];
				//[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath];
				//NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp5.mp3",localVocalPath];
				NSSound *sound=[[NSSound alloc] initWithContentsOfFile:outroTempPath2 byReference:YES];
				float dur =[sound duration];
				startPos1 =startPos1+dur;
				
				DUBUG_LOG(@"startposition isis %f",startPos);
				[sound release];
				[musicProcessor release];
				
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath1 handler: nil];
				if(([fileManager fileExistsAtPath:outroTempPath2]))
					[outroDownloadPathArray addObject:outroTempPath2];
				[outroTempPath release];
				[outroTempPath2 release];	
			}
			
			if(m==5 && ([fileManager fileExistsAtPath:vocalsPath]) && [vocalName length] !=0)
			{
				
				DUBUG_LOG(@"entering to last outro vocal");
				float tempDuration =(57-startPos1);
				DUBUG_LOG(@"tempDuration tempDuration is %f startPos %f",tempDuration,startPos1);
				
				NSString *vocalsPath = [[NSString alloc] initWithFormat:@"%@/%@",VocalPath,vocalName];
				JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
				NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/outroTemp6.wav",localVocalPath];
				NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/outroTemp6_BitRate.wav",localVocalPath];
				NSString *outroTempPath2 = [[NSString alloc] initWithFormat:@"%@/outroTemp6_Volume.wav",localVocalPath];
				[musicProcessor PadSilence:vocalsPath:outroTempPath:[NSString stringWithFormat:@"%f",tempDuration]:@"0.00"];
				[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
				[musicProcessor IncreaseVolumeUsingSox:outroTempPath1:outroTempPath2];
				[musicProcessor release];
				
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
				[[NSFileManager defaultManager] removeFileAtPath:outroTempPath1 handler: nil];
				if(([fileManager fileExistsAtPath:outroTempPath2]))
					[outroDownloadPathArray addObject:outroTempPath2];
				[outroTempPath release];
				[outroTempPath1 release];
				
				
			}
			
			
			
		}
			
			DUBUG_LOG(@"VALUE OF m is %d",m);
			
		m++;
	}	
	}
	[fileDownloader release];
		
	DUBUG_LOG(@"download array isiis %@",outroDownloadPathArray);
		
	//	[outroDownloadPathArray removeAllObjects];
//		DUBUG_LOG(@"download array isiis %@",outroDownloadPathArray);

		
	
		//Concatenate Outro Vocals
		musicProcessor =[[JiwokMusicProcessor alloc] init];
		NSString *outroFinalPath = [[NSString alloc] initWithFormat:@"%@/finalOutro.wav",localVocalPath];
		[musicProcessor Concatenate:outroDownloadPathArray:outroFinalPath];
		[musicProcessor release];
		
		
		//Checking the duration of outro is matching to required duration or not (Adding silence at the end of the vocal)
		sound=[[NSSound alloc] initWithContentsOfFile:outroFinalPath byReference:YES];
		float dur =[sound duration];
		[sound release];
		float durDifference =60-dur;
		if(dur<60)
			{
				NSString *outroFinalCorrected = [[NSString alloc] initWithFormat:@"%@/finalOutroCorrected.wav",localVocalPath];
				musicProcessor =[[JiwokMusicProcessor alloc] init];
				[musicProcessor PadSilence:outroFinalPath:outroFinalCorrected:@"0.00":[NSString stringWithFormat:@"%f",durDifference]];
				[musicProcessor release];
				[[NSFileManager defaultManager] removeFileAtPath:outroFinalPath handler: nil];
				if(([fileManager fileExistsAtPath:outroFinalCorrected]))
					[allVocalsArray addObject:outroFinalCorrected];
				[outroFinalCorrected release];
			}
		else {
			
			if(([fileManager fileExistsAtPath:outroFinalPath]))
				[allVocalsArray addObject:outroFinalPath];
			}
		[outroFinalPath release];
		
		// Padding silence for the vocals ,if its missed the actual duration at the end.(adding silence prior to outro)
		float Pos;
		DUBUG_LOG(@"last carry over isiisissi %f",lastCarryOver);
		if(lastCarryOver > 0)
		{
			Pos =lastCarryOver; 					
		}
		else
			Pos = 0.00;
		NSString *initialStartPos =[NSString stringWithFormat:@"%f",Pos];
		DUBUG_LOG(@"initial start pos isisisisisi %@",initialStartPos);
		NSString *correctedVocal = [[NSString alloc] initWithFormat:@"%@/finalOutroPadding.wav",localVocalPath];
		musicProcessor =[[JiwokMusicProcessor alloc] init];
		
		
		
		if([allVocalsArray lastObject])
		[musicProcessor PadSilence:[allVocalsArray lastObject]:correctedVocal:initialStartPos:@"0.00"];
		[musicProcessor release];
		if([allVocalsArray lastObject])
		{
		[[NSFileManager defaultManager] removeFileAtPath:[allVocalsArray lastObject] handler: nil];
		[allVocalsArray removeLastObject];
		}
		
		if(([fileManager fileExistsAtPath:correctedVocal]))
			[allVocalsArray addObject:correctedVocal];
		[correctedVocal release];
	
	
	
	DUBUG_LOG(@"all vocals array are %@",allVocalsArray);
		
		
		if(!runningPreviousUserWorkout)
		{
			//Concatnate All vocals
			musicProcessor =[[JiwokMusicProcessor alloc] init];
			finalVocalPath= [[NSString alloc] initWithFormat:@"%@/finalVocals.wav",localVocalPath];
			[musicProcessor Concatenate:allVocalsArray:finalVocalPath];
			[musicProcessor release];
		}
		else
		{
			return;
		}
	
	
		if(!runningPreviousUserWorkout)
		{  
		[self BgSongsCreation];
		}
		else
		{
			return;
		}
	
	
	
	
	}
	
}	
	else
	{
		return;
	}
	
	DUBUG_LOG(@"Now you are completed introDownload method in GenerateWorkout class");	
}

-(void)BgSongsCreation
{
	DUBUG_LOG(@"Now you are in BgSongsCreation method in GenerateWorkout class");
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
																   kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	
	[[LoggerClass getInstance] logData:@"Destination path for final mp3 %@",workOutDirectory];
	
	NSString *workoutFolder = [NSString stringWithFormat:@"%@/Seance_Jiwok",workOutDirectory];
	if(![fileManager fileExistsAtPath:workoutFolder])
	{
		[fileManager createDirectoryAtPath:workoutFolder attributes:nil];
	}
		
	
	JiwokCurlFtpClient * curlDownloader = [[JiwokCurlFtpClient alloc] init];
	if(!runningPreviousUserWorkout)
	{
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		//NSString *SpeceficSongPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SpecificSongs"];
	
		NSString *SpeceficSongPath = [bundlePath  stringByAppendingPathComponent:@"SpecificSongs"];

		NSString *AmbiantPath=[SpeceficSongPath stringByAppendingPathComponent:@"Ambiant"];
		NSString *SpeedPath=[SpeceficSongPath stringByAppendingPathComponent:@"Speed"];
		NSString *superSpeedPath=[SpeceficSongPath stringByAppendingPathComponent:@"Superspeed"];


		
		
		
		
		
		BOOL shouldDownloadSpecificSongs=NO; 
		BOOL shouldDownloadAmbiant=NO;
		BOOL shouldDownloadSpeed=NO;
		BOOL shouldDownloadSuperSpeed=NO;

		
		if(![fileManager fileExistsAtPath:SpeceficSongPath])
		{
			shouldDownloadSpecificSongs=YES;
			shouldDownloadAmbiant=YES;
			shouldDownloadSpeed=YES;
			shouldDownloadSuperSpeed=YES;


			
		}
		if([fileManager fileExistsAtPath:AmbiantPath])
		{
		NSArray *contentsOfAmbiant=[fileManager contentsOfDirectoryAtPath:AmbiantPath error:NULL];
		if(![contentsOfAmbiant count])
		{
			shouldDownloadSpecificSongs=YES;
			shouldDownloadAmbiant=YES;
		}

		}
		else {
			shouldDownloadSpecificSongs=YES;
			
		}
		
		
		if([fileManager fileExistsAtPath:SpeedPath])
		{
			NSArray *contentsOfSpeed=[fileManager contentsOfDirectoryAtPath:SpeedPath error:NULL];
			if(![contentsOfSpeed count])
			{
				shouldDownloadSpecificSongs=YES;
				shouldDownloadSpeed=YES;
			}
			
		}
		else {
			shouldDownloadSpecificSongs=YES;
			
		}
		
		if([fileManager fileExistsAtPath:superSpeedPath])
		{
			NSArray *contentsOfSuperSpeed=[fileManager contentsOfDirectoryAtPath:superSpeedPath error:NULL];
			if(![contentsOfSuperSpeed count])
			{
				shouldDownloadSpecificSongs=YES;
				shouldDownloadSuperSpeed=YES;
			}
			
		}
		else {
			shouldDownloadSpecificSongs=YES;
			
		}
		
		

		
		
		
		//if(![fileManager fileExistsAtPath:SpeceficSongPath])
			
		
		NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];

		
		
		if(shouldDownloadSpecificSongs)
		{
			//if (![JiwokUtil checkForInternetConnection:jiwokURL])
//			{
//				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
//				runningPreviousUserWorkout=YES;
//				[delegate generationFailed];
//
//				return;
//			}
			
		//	else{
			
			NSString * spSongPath = [JiwokSettingPlistReader GetDownLoadSpSongsPath];
			NSString *finalspSongPath = [[NSString alloc] initWithFormat:@"%@/",spSongPath];
			
			if (![JiwokUtil checkForInternetConnection:jiwokURL])
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
				runningPreviousUserWorkout=YES;
				[delegate generationFailed];
				
				return;
			}
			
			
			NSMutableArray *listoffilesSpSongFolders = [curlDownloader ListDirectoriesFromFTP:finalspSongPath];
			if ([listoffilesSpSongFolders count] > 0)
			{
				[[LoggerClass getInstance] logData:@"Listing specific songs path %@",spSongPath];
				
				for (NSString *spFolderName in listoffilesSpSongFolders)
				{
					if(!runningPreviousUserWorkout)
					{
					NSString *newSPFolder = [[NSString alloc] initWithFormat:@"%@%@/",finalspSongPath,spFolderName];
					NSMutableArray *listoffilesInSPFolder = [curlDownloader ListDirectoriesFromFTP:newSPFolder];
					[[LoggerClass getInstance] logData:@"File count %d, at path %@",[listoffilesInSPFolder count],newSPFolder];
					[newSPFolder release];
					}
					else
					{
						return;
					}
				}
			}
			
			for (NSString *spSongFolderName in listoffilesSpSongFolders)
			{
				if (![JiwokUtil checkForInternetConnection:jiwokURL])
			{
				[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
				runningPreviousUserWorkout=YES;
				[delegate generationFailed];
				
				return;
			}
				if(!runningPreviousUserWorkout)
				{
				NSString *newSPPath = [[NSString alloc] initWithFormat:@"%@%@/",finalspSongPath,spSongFolderName];
				NSString *newLocalSPPath = [[NSString alloc] initWithFormat:@"%@/%@",SpeceficSongPath,spSongFolderName];
				NSMutableArray *listoffilesInSPFolder = [curlDownloader ListDirectoriesFromFTP:newSPPath];
				//NSLog(@"Array content  isisisiisi%@",listoffilesInSPFolder);
				[[LoggerClass getInstance] logData:@"downloading special songs pack from %@",newSPPath];
				
				// create the spsongs subfolder if it does not exist
				if(![fileManager fileExistsAtPath:newLocalSPPath])
				{
					if(![fileManager createDirectoryAtPath:newLocalSPPath attributes:nil])
					{
						[[LoggerClass getInstance] logData:@"local Specific songs folder creation failed for folder %@",newLocalSPPath];
						return;
					}
				}
					BOOL shouldDownloadCurrentFolder=YES;
					
					if(([spSongFolderName isEqualToString:@"Ambiant"]&&!shouldDownloadAmbiant)||([spSongFolderName isEqualToString:@"Speed"]&&!shouldDownloadSpeed)||([spSongFolderName isEqualToString:@"Superspeed"]&&!shouldDownloadSuperSpeed))
						shouldDownloadCurrentFolder=NO;
					
				if(shouldDownloadCurrentFolder)
				for (NSString *spsongName in listoffilesInSPFolder)
				{
					if(!runningPreviousUserWorkout)
					{
					NSString *newSPSongFilePath = [[NSString alloc] initWithFormat:@"%@%@",newSPPath,spsongName];
					NSString *newLocalSPSongFilePath = [[NSString alloc] initWithFormat:@"%@/%@",newLocalSPPath,spsongName];
					
					[[LoggerClass getInstance] logData:@"downloading specialsong file %@ to local path %@",newSPSongFilePath,newLocalSPSongFilePath];
					//if([fileManager fileExistsAtPath:newSPSongFilePath])
					//{
						if(![fileManager fileExistsAtPath:newLocalSPSongFilePath])
							[curlDownloader DownloadFromFTP:newSPSongFilePath:newLocalSPSongFilePath];
					//}
					[newSPSongFilePath release];
					[newLocalSPSongFilePath release];
				}
					
				}
			}
			}
			[finalspSongPath release];
			[curlDownloader release];
		//}
		}
		
	JiwokMusicProcessor *musicProcessor ;
	//[self introDownload];
	introBgSelected = NO;
	songsArray =[[NSMutableArray alloc] init] ;       
	[self getIntroOutroBg];
	
	//[NSThread detachNewThreadSelector:@selector(createBackgroundMusic) toTarget:self withObject:nil];
	[self createBackgroundMusics];
	
	DUBUG_LOG(@"finished the bg songs");

	[self getIntroOutroBg];
	
		NSString *finalWav;
	bundlePath = [[NSBundle mainBundle] bundlePath];
	//NSString *localVocalPath = [[bundlePath  stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Temp"];
		
		
		CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
															 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
			NSString *localVocalPath=[workOutDirectory stringByAppendingPathComponent:@"Temp"];
		
		
		if(![fileManager fileExistsAtPath:localVocalPath])
	{
		[fileManager createDirectoryAtPath:localVocalPath attributes:nil];
	}
		
		NSString *FinalMP3Name;
		if(!runningPreviousUserWorkout)
		{
	musicProcessor =[[JiwokMusicProcessor alloc] init];
	NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/finalBgSong.wav",localVocalPath];
	[musicProcessor Concatenate:songsArray:outroTempPath];
	[musicProcessor release];
			
			NSString *finalWorkoutTitle;

			
		//	if([[JiwokUtil GetCurrentLocale] isEqualToString:@"english"]	)
//			{
//				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"engTitle"];
//				
//				if([[workoutDictionary objectForKey:@"vocal_type"] isEqualToString:@"1"])
//				{
//				FinalMP3Name =[NSString stringWithFormat:@"Workout%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"engTitle"]];
//				}
//				else
//				{
//					
//					FinalMP3Name =[NSString stringWithFormat:@"Workout_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"engTitle"]];
//				}
//			}
//			else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"french"])
//			{
//				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"frenchTitle"];
//
//				
//				if([[workoutDictionary objectForKey:@"vocal_type"] isEqualToString:@"1"])
//				{
//				
//				FinalMP3Name =[NSString stringWithFormat:@"Séance%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"frenchTitle"]];
//				}
//				else
//				{
//					FinalMP3Name =[NSString stringWithFormat:@"Séance_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"frenchTitle"]];
//
//				}
//			}
//			else if([[JiwokUtil GetCurrentLocale] isEqualToString:@"spanish"])
//			{
//				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"spanishTitle"];
//				
//				
//				if([[workoutDictionary objectForKey:@"vocal_type"] isEqualToString:@"1"])
//				{
//					
//					FinalMP3Name =[NSString stringWithFormat:@"Sesión%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"spanishTitle"]];
//				}
//				else
//				{
//					FinalMP3Name =[NSString stringWithFormat:@"Sesión_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"spanishTitle"]];
//					
//				}
//			}
//			else //if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])
//			{
//				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"italianTitle"];
//				
//				
//				if([[workoutDictionary objectForKey:@"vocal_type"] isEqualToString:@"1"])
//				{
//					
//					FinalMP3Name =[NSString stringWithFormat:@"Seduta%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"italianTitle"]];
//				}
//				else
//				{
//					FinalMP3Name =[NSString stringWithFormat:@"Seduta_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"italianTitle"]];
//					
//				}
//			}
//			
//			
			
			
			
			if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"1"])
			{
				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"engTitle"];
				
				if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"1"])
				{
					FinalMP3Name =[NSString stringWithFormat:@"Workout%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"engTitle"]];
				}
				else
				{
					
					FinalMP3Name =[NSString stringWithFormat:@"Workout_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"engTitle"]];
				}
			}
			else if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"2"])
			{
				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"frenchTitle"];
				
				
				if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"2"])
				{
					
					FinalMP3Name =[NSString stringWithFormat:@"Séance%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"frenchTitle"]];
				}
				else
				{
					FinalMP3Name =[NSString stringWithFormat:@"Séance_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"frenchTitle"]];
					
				}
			}
			else if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"3"])
			{
				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"spanishTitle"];
				
				
				if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"3"])
				{
					
					FinalMP3Name =[NSString stringWithFormat:@"Sesión%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"spanishTitle"]];
				}
				else
				{
					FinalMP3Name =[NSString stringWithFormat:@"Sesión_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"spanishTitle"]];
					
				}
			}
			else //if([[JiwokUtil GetCurrentLocale] isEqualToString:@"italian"])
			{
				finalWorkoutTitle=[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"italianTitle"];
				
				
				if([[workoutDictionary objectForKey:@"workout_lang_selected"] isEqualToString:@"4"])
				{
					
					FinalMP3Name =[NSString stringWithFormat:@"Seduta%d_%@_no_comments.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"italianTitle"]];
				}
				else
				{
					FinalMP3Name =[NSString stringWithFormat:@"Seduta_%d_%@.wav",[[workoutDictionary objectForKey:@"order"] intValue],[[workoutDictionary objectForKey:@"pgmDictionary"] objectForKey:@"italianTitle"]];
					
				}
			}
			
			
			
			
			
			
			
			
	[delegate changeStatus:@"INFO-FOR_MIX"];
			
			
	DUBUG_LOG(@"FinalMP3Name FinalMP3Name is %@",FinalMP3Name);
			
	musicProcessor =[[JiwokMusicProcessor alloc] init];
	finalWav= [[NSString alloc] initWithFormat:@"%@/%@",workoutFolder,FinalMP3Name];
	[musicProcessor MixAudio:outroTempPath:finalVocalPath:finalWav];
	[musicProcessor release];
	
		
			musicProcessor =[[JiwokMusicProcessor alloc] init];
			[musicProcessor ChangeOutputFormatForFinalMp3:finalWav:@"mp3":finalWorkoutTitle];
			[musicProcessor release];
			
		}
	
		if(shouldDeleteTempFiles)
		{
			
		[fileManager removeItemAtPath:finalWav error:nil];			
		//[fileManager removeItemAtPath:[[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp" ] error:nil];	
			
			
			CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
			NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
																		   kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
			
			NSString *localVocalPath=[workOutDirectory stringByAppendingPathComponent:@"Temp"];
			
			[fileManager removeItemAtPath:localVocalPath error:nil];
		
		}
		
		
		
		[delegate generationCompleted];
		
		
		
		
		
		DUBUG_LOG(@"WORKOUT ");
		
		
		
	//[fileManager removeItemAtPath:localVocalPath error:nil];
	
		/*NSString *mp3File =[finalWav substringToIndex:([finalWav length]-4)];
		
		NSString *mp3NameFile =[NSString stringWithFormat:@"%@.mp3",mp3File];
		
		//NSLog(@"final mp3 file path name %@",mp3NameFile);
		NSString *workoutName =[FinalMP3Name substringToIndex:([FinalMP3Name length]-4)];
		NSString *mp3Name =[NSString stringWithFormat:@"%@.mp3",workoutName];
		//NSLog(@"final mp3 file name %@",mp3Name);
		[finalWav release];
	
	NSString *finalMp3= [[NSString alloc] initWithFormat:@"%@/%@",localVocalPath,mp3Name];
	if([fileManager fileExistsAtPath:finalMp3])
		[fileManager moveItemAtPath:finalMp3 toPath:[NSString stringWithFormat:@"%@/%@",workoutFolder,mp3Name] error:nil];
	//[fileManager removeItemAtPath:localVocalPath error:nil];*/
	}
	else
	{
		return;
	}
DUBUG_LOG(@"Now you are completed BgSongsCreation method in GenerateWorkout class");
}

-(void)createBackgroundMusics
{
	
	DUBUG_LOG(@"Now you are in createBackgroundMusics method in GenerateWorkout class");
	
	//JiwokAPIHelper *wrorkoutInfo =[[JiwokAPIHelper alloc] init];
	//workoutDictionary = [wrorkoutInfo JiwokGetWorkoutdetails];
	//[wrorkoutInfo release];
	
	songsElementsArray =[[NSMutableArray alloc]initWithArray:[workoutDictionary objectForKey:@"songElementsArray"]];
	genreArray =[[NSMutableArray alloc]initWithArray:[workoutDictionary objectForKey:@"genre"]];
	
	NSMutableArray *FinalMp3Array=[[[NSMutableArray alloc]init]autorelease];
	
	float bpmMin ,bpmMax,RequiredDuration,TotalDuration;
	for(int l=0;l<[songsElementsArray count];l++)
	{
		if(!runningPreviousUserWorkout)
		{
			
			[delegate changeStatus:@"INFO-FOR_PROCESS_SPECIFIC_SONGS"];
			fromSpecificSongs =FALSE;
			bpmMin=[[[songsElementsArray objectAtIndex:l]objectForKey:@"bpmmin"] floatValue];
			bpmMax=[[[songsElementsArray objectAtIndex:l]objectForKey:@"bpmmax"] floatValue];		
			RequiredDuration=[[[songsElementsArray objectAtIndex:l]objectForKey:@"duration"] floatValue];
			TotalDuration=0.0;
			//NSArray *musicFilesForSingleSongArray;
			NSMutableArray *musicFilesForSingleSongArray =[[NSMutableArray alloc]init];
			DUBUG_LOG(@"bpm min is %f------bpm max is %f",bpmMin,bpmMax);
			
			BOOL shouldTakeFromDb=TRUE;
			
			if((bpmMin>=40&&bpmMax<=40)||(bpmMin>=93&&bpmMax<=100))
				shouldTakeFromDb=FALSE;
			
			BOOL enoughDurationachieved=NO;
			
			
			NSMutableArray *musicFilesForSingleSongFinalArray=[[NSMutableArray alloc]init];
			NSCharacterSet *charSet =[NSCharacterSet characterSetWithCharactersInString:@"}{"];
			while(TotalDuration<RequiredDuration)
			{
				
				DUBUG_LOG(@"455555656 while loop total duration is %f======required duration is ======%f",TotalDuration,RequiredDuration);
				
				if(shouldTakeFromDb)
				musicFilesForSingleSongArray =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:[[songsElementsArray objectAtIndex:l]objectForKey:@"bpmmin"]:[[songsElementsArray objectAtIndex:l]objectForKey:@"bpmmax"]:genreArray:@"False"];		
				
				//NSArray *tmpMusicGenres=[NSArray arrayWithObjects:@"house-electro",@"funk-disco-soul",@"techno_rave",nil];
				//DUBUG_LOG(@"music array is %@",musicFilesForSingleSongArray);
				
				for(int i=0;i<[musicFilesForSingleSongArray count];i++)
				{
					if(TotalDuration<=RequiredDuration)
					{
						
						DUBUG_LOG(@"actual duration isi %f",[[[musicFilesForSingleSongArray objectAtIndex:i]objectForKey:@"Duration"] floatValue]);
						if([[[musicFilesForSingleSongArray objectAtIndex:i]objectForKey:@"Duration"] floatValue]>0 && ([musicFilesForSingleSongArray objectAtIndex:i]) && [[[musicFilesForSingleSongArray objectAtIndex:i] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
						{
							TotalDuration+=[[[musicFilesForSingleSongArray objectAtIndex:i]objectForKey:@"Duration"] floatValue];
							[musicFilesForSingleSongFinalArray addObject:[musicFilesForSingleSongArray objectAtIndex:i]];
							
							
							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[musicFilesForSingleSongArray objectAtIndex:i]objectForKey:@"FilePath"]:@"True"];

						}
						
					}
					
					
					
				}
				
				//
//				for(int i=0;i<[musicFilesForSingleSongArray count];i++)
//				{
//					[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[musicFilesForSingleSongArray objectAtIndex:i]objectForKey:@"FilePath"]:@"True"];
//					
//					[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[musicFilesForSingleSongArray objectAtIndex:i]objectForKey:@"FilePath"]:@"0"];
//					
//				}
//				
				
				
				DUBUG_LOG(@"TESTING VALUES ARE TotalDuration=====%f  RequiredDuration===%f bpmMin=====%f bpmMax=====%f",TotalDuration,RequiredDuration,bpmMin,bpmMax);
				
				if(TotalDuration>=RequiredDuration)
				{		
					
					DUBUG_LOG(@"OBJECT ADDED TO DB INSIDE IF IS %d",l);
					
					
				}
				
				else
				{	
					
					
					DUBUG_LOG(@"inside while loop total duration is %f======required duration is ======%f bpmmin===%f bpmmax===%f",TotalDuration,RequiredDuration,bpmMin,bpmMax);
					
					if((bpmMin>=41)&&(bpmMax<=60))
					{	
						DUBUG_LOG(@"else	if((bpmMin>=41)&&(bpmMax<=60))");

						
						NSMutableArray *tmpArray1 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"80":@"119":genreArray:@"False"];			
						
						tmpArray1=[self arrangeSongs:tmpArray1];
						
						
						if(!enoughDurationachieved)
						for(int count=0;count<[tmpArray1 count];count++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray1 objectAtIndex:count]) && [[[tmpArray1 objectAtIndex:count] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray1 objectAtIndex:count]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"True"];
								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}		
							
							
						}
						
					//	
//						for(int count=0;count<[tmpArray1 count];count++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"0"];
//						}
						
						
						
						
						NSMutableArray *tmpArray2 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"120":@"130":genreArray:@"False"];				
						tmpArray2=[self arrangeSongs:tmpArray2];

						if(!enoughDurationachieved)
						for(int count2=0;count2<[tmpArray2 count];count2++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray2 objectAtIndex:count2]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray2 objectAtIndex:count2]) && [[[tmpArray2 objectAtIndex:count2] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray2 objectAtIndex:count2]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray2 objectAtIndex:count2]];
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
							
						}
						
						
						//
//						for(int count2=0;count2<[tmpArray2 count];count2++)
//						{
//							
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"0"];
//						}
//						
//						
						
						NSMutableArray *tmpArray3 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"131":@"150":genreArray:@"False"];				
						tmpArray3=[self arrangeSongs:tmpArray3];

						if(!enoughDurationachieved)
						for(int count3=0;count3<[tmpArray3 count];count3++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray3 objectAtIndex:count3]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray3 objectAtIndex:count3]) && [[[tmpArray3 objectAtIndex:count3] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray3 objectAtIndex:count3]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray3 objectAtIndex:count3]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						//
//						for(int count3=0;count3<[tmpArray3 count];count3++)
//						{
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"0"];
//						}
						
						
						
						
						
						
				////////////////////////Nov 2012 EDIT ////////////////////////////////////////////////////////////////////////////
                        
                        NSMutableArray *tmpArray5 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"150":@"250":genreArray:@"False"];				
						tmpArray5=[self arrangeSongs:tmpArray5];
                        
						//if(!enoughDurationachieved)
                           // [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"150":@"250":genreArray];
						
						if(!enoughDurationachieved)
                            for(int count5=0;count5<[tmpArray5 count];count5++)
                            {
                                if(TotalDuration<=RequiredDuration)
                                {
                                    
                                    if([[[tmpArray5 objectAtIndex:count5]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray5 objectAtIndex:count5]) && [[[tmpArray5 objectAtIndex:count5] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
                                    {
                                        TotalDuration+=[[[tmpArray5 objectAtIndex:count5]objectForKey:@"Duration"] floatValue];
                                        [musicFilesForSingleSongFinalArray addObject:[tmpArray5 objectAtIndex:count5]];
                                        
                                        [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray5 objectAtIndex:count5]objectForKey:@"FilePath"]:@"True"];
                                        
                                    }
                                }
                                
                                
                                else
                                {
                                    
                                    enoughDurationachieved=YES;
                                    
                                }
                            }	

                        
               ////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
                        
                        
                        
                        
                        NSMutableArray *tmpArray4 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"80":@"150":genreArray:@"True"];				
						tmpArray4=[self arrangeSongs:tmpArray4];
                        
						if(!enoughDurationachieved)
                            [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"80":@"150":genreArray];
						
						if(!enoughDurationachieved)
                            for(int count4=0;count4<[tmpArray4 count];count4++)
                            {
                                if(TotalDuration<=RequiredDuration)
                                {
                                    
                                    if([[[tmpArray4 objectAtIndex:count4]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray4 objectAtIndex:count4]) && [[[tmpArray4 objectAtIndex:count4] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
                                    {
                                        TotalDuration+=[[[tmpArray4 objectAtIndex:count4]objectForKey:@"Duration"] floatValue];
                                        [musicFilesForSingleSongFinalArray addObject:[tmpArray4 objectAtIndex:count4]];
                                        
                                        [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray4 objectAtIndex:count4]objectForKey:@"FilePath"]:@"True"];
                                        
                                    }
                                }
                                
                                
                                else
                                {
                                    
                                    enoughDurationachieved=YES;
                                    
                                }
                            }	
                        
						
						//for(int count4=0;count4<[tmpArray4 count];count4++)
						//{
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray4 objectAtIndex:count4]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray4 objectAtIndex:count4]objectForKey:@"FilePath"]:@"0"];
//						}
						
					}
					
					
					
					else	if((bpmMin>=61)&&(bpmMax<=75))						
					{	
						DUBUG_LOG(@"else	if((bpmMin>=61)&&(bpmMax<=75))");

						
						NSMutableArray *tmpArray1 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"85":@"119":genreArray:@"False"];	
						tmpArray1=[self arrangeSongs:tmpArray1];

						if(!enoughDurationachieved)
						for(int count=0;count<[tmpArray1 count];count++)
						{
							
							//DUBUG_LOG(@"Entering to for loop");
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray1 objectAtIndex:count]) && [[[tmpArray1 objectAtIndex:count] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray1 objectAtIndex:count]];
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
							
						}
						
						//
//						
//						for(int count=0;count<[tmpArray1 count];count++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"0"];
//							
//						}
//						
						
						
						
						NSMutableArray *tmpArray2 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"120":@"130":genreArray:@"False"];				
						tmpArray2=[self arrangeSongs:tmpArray2];

						if(!enoughDurationachieved)
						for(int count2=0;count2<[tmpArray2 count];count2++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray2 objectAtIndex:count2]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray2 objectAtIndex:count2]) && [[[tmpArray2 objectAtIndex:count2] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray2 objectAtIndex:count2]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray2 objectAtIndex:count2]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
							
						}
						
						//
//						for(int count2=0;count2<[tmpArray2 count];count2++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"0"];
//						}
//						
//						
						
						NSMutableArray *tmpArray3 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"131":@"140":genreArray:@"False"];				
						tmpArray3=[self arrangeSongs:tmpArray3];

						if(!enoughDurationachieved)
						for(int count3=0;count3<[tmpArray3 count];count3++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray3 objectAtIndex:count3]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray3 objectAtIndex:count3]) && [[[tmpArray3 objectAtIndex:count3] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray3 objectAtIndex:count3]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray3 objectAtIndex:count3]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						//
//						for(int count3=0;count3<[tmpArray3 count];count3++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"0"];
//						}
						
						
						
						NSMutableArray *tmpArray4 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"141":@"150":genreArray:@"False"];				
						tmpArray4=[self arrangeSongs:tmpArray4];

						if(!enoughDurationachieved)
						for(int count4=0;count4<[tmpArray4 count];count4++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray4 objectAtIndex:count4]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray4 objectAtIndex:count4]) && [[[tmpArray4 objectAtIndex:count4] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray4 objectAtIndex:count4]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray4 objectAtIndex:count4]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray4 objectAtIndex:count4]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}	
						
						
						//
//						for(int count4=0;count4<[tmpArray4 count];count4++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray4 objectAtIndex:count4]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray4 objectAtIndex:count4]objectForKey:@"FilePath"]:@"0"];
//						}
//						
						
						
						
                        ////////////////////////////////  Nov 2012 EDIT ///////////////////////////////////////////////
                        
                        
                        NSMutableArray *tmpArray6 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"150":@"250":genreArray:@"False"];				
						tmpArray6=[self arrangeSongs:tmpArray6];
                        
						//if(!enoughDurationachieved)
                           // [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"150":@"250":genreArray];
						
						
						if(!enoughDurationachieved)
                            for(int count6=0;count6<[tmpArray6 count];count6++)
                            {
                                if(TotalDuration<=RequiredDuration)
                                {
                                    
                                    if([[[tmpArray6 objectAtIndex:count6]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray6 objectAtIndex:count6]) && [[[tmpArray6 objectAtIndex:count6] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
                                    {
                                        TotalDuration+=[[[tmpArray6 objectAtIndex:count6]objectForKey:@"Duration"] floatValue];
                                        [musicFilesForSingleSongFinalArray addObject:[tmpArray6 objectAtIndex:count6]];	
                                        
                                        [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray6 objectAtIndex:count6]objectForKey:@"FilePath"]:@"True"];
                                        
                                    }
                                }
                                
                                else
                                {
                                    
                                    enoughDurationachieved=YES;
                                    
                                }
                            }	

                        
                        
                        
                        
                        //////////////////////////////////////////////////////////////////////////////////////////
                        
                        
                        
                        
                        NSMutableArray *tmpArray5 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"85":@"150":genreArray:@"True"];				
						tmpArray5=[self arrangeSongs:tmpArray5];
                        
						if(!enoughDurationachieved)
                            [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"85":@"150":genreArray];
						
						
						if(!enoughDurationachieved)
                            for(int count5=0;count5<[tmpArray5 count];count5++)
                            {
                                if(TotalDuration<=RequiredDuration)
                                {
                                    
                                    if([[[tmpArray5 objectAtIndex:count5]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray5 objectAtIndex:count5]) && [[[tmpArray5 objectAtIndex:count5] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
                                    {
                                        TotalDuration+=[[[tmpArray5 objectAtIndex:count5]objectForKey:@"Duration"] floatValue];
                                        [musicFilesForSingleSongFinalArray addObject:[tmpArray5 objectAtIndex:count5]];	
                                        
                                        [[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray5 objectAtIndex:count5]objectForKey:@"FilePath"]:@"True"];
                                        
                                    }
                                }
                                
                                else
                                {
                                    
                                    enoughDurationachieved=YES;
                                    
                                }
                            }	
						
                        
                        
                        
						//
//						for(int count5=0;count5<[tmpArray5 count];count5++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray5 objectAtIndex:count5]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray5 objectAtIndex:count5]objectForKey:@"FilePath"]:@"0"];
//						}
						DUBUG_LOG(@"total duration isisi %f",TotalDuration);
						
					}
					
					
					
					
					else	if((bpmMin>=76)&&(bpmMax<=92))
					{	
						
						DUBUG_LOG(@"else	if((bpmMin>=76)&&(bpmMax<=92))");

						
						NSArray *tmpMusicGenres=[NSArray arrayWithObjects:@"house-electro",@"funk-disco-soul",@"techno_rave",nil];
						
						NSMutableArray *tmpArray1 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"120":@"140":tmpMusicGenres:@"False"];			
						tmpArray1=[self arrangeSongs:tmpArray1];

						
						if(!enoughDurationachieved)
						for(int count=0;count<[tmpArray1 count];count++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray1 objectAtIndex:count]) && [[[tmpArray1 objectAtIndex:count] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray1 objectAtIndex:count]];
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						//for(int count=0;count<[tmpArray1 count];count++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray1 objectAtIndex:count]objectForKey:@"FilePath"]:@"0"];
//						}
//						
						
						
						NSMutableArray *tmpArray2 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"120":@"140":tmpMusicGenres:@"True"];			
						tmpArray2=[self arrangeSongs:tmpArray2];

						if(!enoughDurationachieved)
						[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"120":@"140":tmpMusicGenres];
						
						
						if(!enoughDurationachieved)
						for(int count1=0;count1<[tmpArray2 count];count1++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray2 objectAtIndex:count1]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray2 objectAtIndex:count1]) && [[[tmpArray2 objectAtIndex:count1] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray2 objectAtIndex:count1]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray2 objectAtIndex:count1]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count1]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						
						//for(int count1=0;count1<[tmpArray2 count];count1++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count1]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray2 objectAtIndex:count1]objectForKey:@"FilePath"]:@"0"];
//						}
						
						
						NSArray *tmpArray3a =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"141":@"150":genreArray:@"False"];				
						NSMutableArray *tmpArray3=[NSMutableArray arrayWithArray:tmpArray3a];
						tmpArray3=[self arrangeSongs:tmpArray3];

						
						if(!enoughDurationachieved)
						for(int count2=0;count2<[tmpArray3 count];count2++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray3 objectAtIndex:count2]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray3 objectAtIndex:count2]) && [[[tmpArray3 objectAtIndex:count2] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray3 objectAtIndex:count2]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray3 objectAtIndex:count2]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						//
//						for(int count2=0;count2<[tmpArray3 count];count2++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray3 objectAtIndex:count2]objectForKey:@"FilePath"]:@"0"];
//						}
						
						
						NSMutableArray *tmpArray4 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"141":@"150":genreArray:@"True"];				
						tmpArray4=[self arrangeSongs:tmpArray4];

						if(!enoughDurationachieved)
						[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"141":@"150":genreArray];
						
						if(!enoughDurationachieved)
						for(int count3=0;count3<[tmpArray4 count];count3++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray4 objectAtIndex:count3]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray4 objectAtIndex:count3]) && [[[tmpArray4 objectAtIndex:count3] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray4 objectAtIndex:count3]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray4 objectAtIndex:count3]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray4 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						//for(int count3=0;count3<[tmpArray4 count];count3++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray4 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray4 objectAtIndex:count3]objectForKey:@"FilePath"]:@"0"];
//						}
						
						
						NSFileManager *fileManager = [NSFileManager defaultManager];
						NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
						NSString *SpecificsongsPath = [bundlePath stringByAppendingPathComponent:@"Specificsongs"];
						if(![fileManager fileExistsAtPath:SpecificsongsPath])
						{
							if(![fileManager createDirectoryAtPath:SpecificsongsPath attributes:nil])
							{
								[[LoggerClass getInstance] logData:@"local Specific songs folder creation for workout generation failed"];
								return;
							}
						}
						
						NSString *SpeedsongsPath=[SpecificsongsPath stringByAppendingPathComponent:@"Speed"];
						
						if(![fileManager fileExistsAtPath:SpeedsongsPath])
						{
							if(![fileManager createDirectoryAtPath:SpeedsongsPath attributes:nil])
							{
								[[LoggerClass getInstance] logData:@"local Speed folder creation for workout generation failed"];
								return;
							}
						}
						
						//NSString * spSongPath = [JiwokSettingPlistReader GetDownLoadSpSongsPath];
						//NSString *finalspSongPath = [[NSString alloc] initWithFormat:@"%@/Speed/",spSongPath];
						
						
						//NSArray *contentsOfSpeedFolder=[fileManager contentsOfDirectoryAtPath:finalspSongPath error:NULL];
						
						
						//NSFileManager *fileManager = [NSFileManager defaultManager];			
						
						NSArray *contentsOfSpecificsongs=[fileManager contentsOfDirectoryAtPath:SpeedsongsPath error:NULL];
						
						DUBUG_LOG(@"contentsOfSpecificsongs=== %d",[contentsOfSpecificsongs count]);
						/*if([contentsOfSpecificsongs count]<1)
						 {
						 
						 for (NSString *spsongName in contentsOfSpeedFolder)
						 {
						 NSString *newSPSongFilePath = [[NSString alloc] initWithFormat:@"%@%@",finalspSongPath,spsongName];
						 NSString *newLocalSPSongFilePath = [[NSString alloc] initWithFormat:@"%@/%@",SpeedsongsPath,spsongName];
						 
						 DUBUG_LOG(@"newSPSongFilePath====%@ ,newLocalSPSongFilePath=== %@",newSPSongFilePath,newLocalSPSongFilePath);
						 [[LoggerClass getInstance] logData:@"downloading specialsong file %@ to local path %@",newSPSongFilePath,newLocalSPSongFilePath];
						 [fileDownloader DownloadFromFTP:newSPSongFilePath:newLocalSPSongFilePath];
						 [newSPSongFilePath release];
						 [newLocalSPSongFilePath release];
						 
						 }
						 
						 
						 }*/
						NSString *songPath;
						float dur;
						int randomindex;					
						int contentsOfSpecificsongsCount=[contentsOfSpecificsongs count];			
						//int loopCount=contentsOfSpecificsongsCount;			
						//while(loopCount>=1)
						//{
						//if(TotalDuration<=RequiredDuration)
						//NSMutableArray *InsertedArray =[[NSMutableArray alloc] init];
						
						while((TotalDuration<=RequiredDuration)&&(contentsOfSpecificsongsCount>0))
						{				
							randomindex=(arc4random()%[contentsOfSpecificsongs count]);
							
							
							songPath =[SpeedsongsPath stringByAppendingPathComponent:[contentsOfSpecificsongs objectAtIndex:randomindex]];
							NSSound *sound=[[NSSound alloc] initWithContentsOfFile:songPath byReference:YES];
							dur =[sound duration];
							dur*=1000;
							TotalDuration+=dur;
							if(dur>0)
							{
								
								NSMutableDictionary *tmpDictionary =[[NSMutableDictionary alloc] init];
								[tmpDictionary setObject:songPath forKey:@"FilePath"];
								[tmpDictionary setObject:[NSString stringWithFormat:@"%f",dur] forKey:@"Duration"];
								if(tmpDictionary)
									[musicFilesForSingleSongFinalArray addObject:tmpDictionary];
								//[InsertedArray addObject:tmpDictionary];
								[tmpDictionary release];
								//[musicFilesForSingleSongFinalArray addObject:tmpDictionary];
								//loopCount--;}		
							}
							[sound release];
							
							//if([InsertedArray count]>0)
							//[musicFilesForSingleSongFinalArray addObject:InsertedArray];
							//[InsertedArray release];
							
						}
						//}
						
						
						NSMutableArray *tmpArray5 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"120":@"150":genreArray:@"True"];				
						tmpArray5=[self arrangeSongs:tmpArray5];

						if(!enoughDurationachieved)
						[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldFalse:@"120":@"150":genreArray];

						if(!enoughDurationachieved)
						for(int count4=0;count4<[tmpArray5 count];count4++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray5 objectAtIndex:count4]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray5 objectAtIndex:count4]) && [[[tmpArray5 objectAtIndex:count4] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray5 objectAtIndex:count4]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray5 objectAtIndex:count4]];
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray5 objectAtIndex:count4]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
							
						}
						
						//for(int count4=0;count4<[tmpArray5 count];count4++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray5 objectAtIndex:count4]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray5 objectAtIndex:count4]objectForKey:@"FilePath"]:@"0"];
//						}
											
					}
					
					
					
					else	if((bpmMin>=93)&&(bpmMax<=100))
					{
						DUBUG_LOG(@"else	if((bpmMin>=93)&&(bpmMax<=100))");

						
						fromSpecificSongs =TRUE;
						NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
						NSString *SpecificsongsPath = [bundlePath stringByAppendingPathComponent:@"Specificsongs"];
						NSString *SuperspeedPath=[SpecificsongsPath stringByAppendingPathComponent:@"Superspeed"];
						NSFileManager *fileManager = [NSFileManager defaultManager];			
						NSString *songPath;
						NSArray *contentsOfSuperspeed=[fileManager contentsOfDirectoryAtPath:SuperspeedPath error:NULL];
						float dur;
						int randomindex;					
						int contentsOfSuperspeedCount=[contentsOfSuperspeed count];		
						//	NSMutableArray *InsertedArray =[[NSMutableArray alloc] init];
						while((TotalDuration<=RequiredDuration)&&(contentsOfSuperspeedCount>0))
							
						{				
							randomindex=(arc4random()%[contentsOfSuperspeed count]);
							
							
							songPath =[SuperspeedPath stringByAppendingPathComponent:[contentsOfSuperspeed objectAtIndex:randomindex]];
							NSSound *sound=[[NSSound alloc] initWithContentsOfFile:songPath byReference:YES];
							dur =[sound duration];
							dur*=1000;
							TotalDuration+=dur;		
							if(dur>0)
							{
								
								
								NSMutableDictionary *tmpDictionary =[[NSMutableDictionary alloc] init];
								[tmpDictionary setObject:songPath forKey:@"FilePath"];
								[tmpDictionary setObject:[NSString stringWithFormat:@"%f",dur] forKey:@"Duration"];
								
								if(tmpDictionary)
									[musicFilesForSingleSongFinalArray addObject:tmpDictionary];
								//[InsertedArray addObject:tmpDictionary];
								[tmpDictionary release];
								//[musicFilesForSingleSongFinalArray addObject:tmpDictionary];
								//loopCount--;}		
								
							}
							//if([InsertedArray count]>0)
							//[musicFilesForSingleSongFinalArray addObject:InsertedArray];
							//[InsertedArray release];
							[sound release];
							
						}	
						
					}
					
					else	if((bpmMin>=40)&&(bpmMax<=40))
					{	
						
						fromSpecificSongs =TRUE;
						DUBUG_LOG(@"else	if((bpmMin>=40)&&(bpmMax<=40))");
						NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
						NSString *SpecificsongsPath = [bundlePath stringByAppendingPathComponent:@"Specificsongs"];
						NSString *AmbiantPath=[SpecificsongsPath stringByAppendingPathComponent:@"Ambiant"];
						NSFileManager *fileManager = [NSFileManager defaultManager];			
						
						
						NSString *songPath;// =[AmbiantPath stringByAppendingPathComponent:[contentsOfAmbiant objectAtIndex:randomindex]]
						NSArray *contentsOfAmbiant=[fileManager contentsOfDirectoryAtPath:AmbiantPath error:NULL];
						
						
						if(![fileManager fileExistsAtPath:AmbiantPath])
						{
							if(![fileManager createDirectoryAtPath:AmbiantPath attributes:nil])
							{
								[[LoggerClass getInstance] logData:@"local Specific songs folder creation failed for folder %@",AmbiantPath];
								return;
							}
						}
						
						
						float dur;
						int randomindex;					
						int contentsOfAmbiantCount=[contentsOfAmbiant count];	
						
						
						//NSMutableArray *InsertedArray =[[NSMutableArray alloc] init];
						DUBUG_LOG(@"RequiredDuration %f ",RequiredDuration);
						
						while((TotalDuration<=RequiredDuration)&&(contentsOfAmbiantCount>0))
							
						{				
							DUBUG_LOG(@"inside while loop  ==TotalDuration %f",TotalDuration);
							
							
							randomindex=(arc4random()%[contentsOfAmbiant count]);
							
							
							DUBUG_LOG(@"randomindex==== %d  [contentsOfAmbiant objectAtIndex:randomindex]  %@",randomindex,[contentsOfAmbiant objectAtIndex:randomindex]);
							
							songPath =[AmbiantPath stringByAppendingPathComponent:[contentsOfAmbiant objectAtIndex:randomindex]];
							DUBUG_LOG(@"song path is %@",songPath);
							
							
							NSSound *sound=[[NSSound alloc] initWithContentsOfFile:songPath byReference:YES];
							dur =[sound duration];
							dur*=1000;
							TotalDuration+=dur;	
							
							if(dur>0)
							{
								
								
								NSMutableDictionary *tmpDictionary =[[NSMutableDictionary alloc] init];
								[tmpDictionary setObject:songPath forKey:@"FilePath"];
								[tmpDictionary setObject:[NSString stringWithFormat:@"%f",dur] forKey:@"Duration"];
								if(tmpDictionary)
									[musicFilesForSingleSongFinalArray addObject:tmpDictionary];
								//[InsertedArray addObject:tmpDictionary];
								[tmpDictionary release];
								//[musicFilesForSingleSongFinalArray addObject:tmpDictionary];
								//loopCount--;}		
								
							}
							//if([InsertedArray count]>0)
							//[musicFilesForSingleSongFinalArray addObject:InsertedArray];	
							//	[InsertedArray release];
							[sound release];
							
						}			
						
						
						DUBUG_LOG(@"after while ");
						
					}
					DUBUG_LOG(@" b4 first condition total %f Required %f bool %d" ,TotalDuration,RequiredDuration,fromSpecificSongs);
					
					if((TotalDuration<RequiredDuration) && (!fromSpecificSongs))						
					{
						DUBUG_LOG(@"entering to last loop");
						NSMutableArray *tmpArray1 =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"40":@"180":genreArray:@"False"];	
						tmpArray1=[self arrangeSongs:tmpArray1];

						if(!enoughDurationachieved)

						for(int count1=0;count1<[tmpArray1 count];count1++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray1 objectAtIndex:count1]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray1 objectAtIndex:count1]) && [[[tmpArray1 objectAtIndex:count1] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray1 objectAtIndex:count1]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray1 objectAtIndex:count1]];		
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count1]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
							
						}
					//	
//						for(int count1=0;count1<[tmpArray1 count];count1++)
//						{
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray1 objectAtIndex:count1]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray1 objectAtIndex:count1]objectForKey:@"FilePath"]:@"0"];
//						}
//						
						
						
						
						NSArray *tmpArray2a =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTable:@"40":@"180":@"False"];	
						NSMutableArray *tmpArray2=[NSMutableArray arrayWithArray:tmpArray2a];
						tmpArray2=[self arrangeSongs:tmpArray2];

						if(!enoughDurationachieved)
						for(int count2=0;count2<[tmpArray2 count];count2++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								if([[[tmpArray2 objectAtIndex:count2]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray2 objectAtIndex:count2]) && [[[tmpArray2 objectAtIndex:count2] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray2 objectAtIndex:count2]objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray2 objectAtIndex:count2]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						
						//for(int count2=0;count2<[tmpArray2 count];count2++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray2 objectAtIndex:count2]objectForKey:@"FilePath"]:@"0"];
//						}
						
						NSArray *tmpArray3a =[[JiwokMusicSystemDBMgrWrapper sharedWrapper] SelectFromMusicTableWithoutArguments];	

						NSMutableArray *tmpArray3=[NSMutableArray arrayWithArray:tmpArray3a];
						tmpArray3=[self arrangeSongs:tmpArray3];

						if(!enoughDurationachieved)
						for(int count3=0;count3<[tmpArray3 count];count3++)
						{
							if(TotalDuration<=RequiredDuration)
							{
								
								DUBUG_LOG(@"last condition");
								
								
								DUBUG_LOG(@"total duration iss %@",[tmpArray3 objectAtIndex:count3]);
								if([[[tmpArray3 objectAtIndex:count3]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray3 objectAtIndex:count3]) && [[[tmpArray3 objectAtIndex:count3] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
								{
									TotalDuration+=[[[tmpArray3 objectAtIndex:count3] objectForKey:@"Duration"] floatValue];
									[musicFilesForSingleSongFinalArray addObject:[tmpArray3 objectAtIndex:count3]];	
									
									[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];

								}
							}
							
							
							else
							{
								
								enoughDurationachieved=YES;
								
							}
						}
						
						
						//
//						for(int count3=0;count3<[tmpArray3 count];count3++)
//						{
//							
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setSelectedFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"True"];
//							[[JiwokMusicSystemDBMgrWrapper sharedWrapper] setUsageFieldInTable:[[tmpArray3 objectAtIndex:count3]objectForKey:@"FilePath"]:@"0"];
//						}
//						
						
					}
					
					
					
				}
				
				if([musicFilesForSingleSongArray count]>0)
					[musicFilesForSingleSongArray removeAllObjects];	
				
				
			}
			
			
			//NSLog(@"musicFilesForSingleSongFinalArray musicFilesForSingleSongFinalArray is %@",musicFilesForSingleSongFinalArray);
			
			
			
			if(musicFilesForSingleSongFinalArray)
				[FinalMp3Array addObject:musicFilesForSingleSongFinalArray];
			//[musicFilesForSingleSongArray release];
			[musicFilesForSingleSongFinalArray release];
			//[musicFilesForSingleSongArray release];
			
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] IncrementUsage];
			//
			DUBUG_LOG(@"total duration isiisis66666 %f",TotalDuration);
		}	
		else
		{
			return;
		}
	}
	
	DUBUG_LOG(@"FinalMp3Array FinalMp3Array is %@   ",FinalMp3Array);
	
	
	//DUBUG_LOG(@"FinalMp3Array FinalMp3Array is %d  songsElementsArray count is %d ",[FinalMp3Array count] ,[songsElementsArray count] );
	[genreArray release];
	
	
	//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	//NSString *tempPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp"];
	
	
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
																   kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	
	NSString *tempPath = [workOutDirectory stringByAppendingPathComponent:@"Temp"];
	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:tempPath])
	{
		[fileManager createDirectoryAtPath:tempPath attributes:nil];
	}
	
	
	
	
	
	int m=0;
	for(int p =0;p<[FinalMp3Array count];p++)
	{
		if(!runningPreviousUserWorkout)
		{
			DUBUG_LOG(@"final===%d",p);
			float differennce =0.0;
			for(int q=0;q<[[FinalMp3Array objectAtIndex:p] count];q++)
			{
				m++;
				float dur =0.0;
				if([[[FinalMp3Array objectAtIndex:p] objectAtIndex:q] count]==0)
					DUBUG_LOG(@"ARRAY COUNT IS %d",[[[FinalMp3Array objectAtIndex:p] objectAtIndex:q] count]);
				
				DUBUG_LOG(@"file path are %@",[[[FinalMp3Array objectAtIndex:p] objectAtIndex:q] objectForKey:@"FilePath"]);//[[[FinalMp3Array objectAtIndex:p] objectAtIndex:q] objectForKey:@"FilePath"]
				NSString *musicPath =[[[FinalMp3Array objectAtIndex:p] objectAtIndex:q] objectForKey:@"FilePath"];
				NSString *firstInputExtension=[musicPath substringFromIndex:([musicPath length]-3)];
				
				DUBUG_LOG(@"count is %d===%d ,%f===%d",p,q,differennce,[[FinalMp3Array objectAtIndex:p] count]);
				if([fileManager fileExistsAtPath:musicPath] && ([firstInputExtension isEqualToString:@"mp3"] || [firstInputExtension isEqualToString:@"m4a"]))
				{
					DUBUG_LOG(@"m value iisisisi %d",m);
					dur= [[[[FinalMp3Array objectAtIndex:p] objectAtIndex:q] objectForKey:@"Duration"] floatValue];
					DUBUG_LOG(@"music name is >>>>> %@",musicPath);
					
					DUBUG_LOG(@"duration isiis %f-----%f",dur,differennce);
					
					if(dur<([[[songsElementsArray objectAtIndex:p]objectForKey:@"duration"] floatValue]-differennce))
					{
						DUBUG_LOG(@"if condition");
						differennce =differennce+dur;
						JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
						NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/trimBgSong_BitRate%d.wav",tempPath,m];
						[musicProcessor convertBitRate:musicPath:@"44100":outroTempPath];
						
						[musicProcessor ChangeMp3gain:@"5":outroTempPath];
						
						NSString *mainPath =[outroTempPath substringToIndex:([outroTempPath length]-4)];
						NSString *mp3path=[NSString stringWithFormat:@"%@.mp3",mainPath];
						[musicProcessor ConvertToWave:mp3path];
						
						if([fileManager fileExistsAtPath:outroTempPath])
							[songsArray addObject:outroTempPath];
						[outroTempPath release];
						[musicProcessor release];
					}
					
					else
					{	
						DUBUG_LOG(@"else condition dur  is %f====%f",dur,[[[songsElementsArray objectAtIndex:p]objectForKey:@"duration"] floatValue]-differennce);
						
						JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
						NSString *outroTempPath = [[NSString alloc] initWithFormat:@"%@/trimBgSong%d.wav",tempPath,m];
						NSString *outroTempPath1 = [[NSString alloc] initWithFormat:@"%@/trimBgSong_BitRate%d.wav",tempPath,m];
						
						DUBUG_LOG(@"music path==%@ outroTempPath %@ initial point==%@ length==%@",musicPath,outroTempPath,[NSString stringWithFormat:@"%f",0.00],[NSString stringWithFormat:@"%f",([[[songsElementsArray objectAtIndex:p]objectForKey:@"duration"] floatValue]-differennce)]);
					
						float secondValue =([[[songsElementsArray objectAtIndex:p]objectForKey:@"duration"] floatValue]-differennce)/1000;
						
						//secondValue=-1;
						
						[musicProcessor TrimAudio:musicPath:outroTempPath:[NSString stringWithFormat:@"%f",0.00]:[NSString stringWithFormat:@"%f",secondValue]];
						[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
						[musicProcessor ChangeMp3gain:@"5":outroTempPath1];
						
						NSString *mainPath =[outroTempPath1 substringToIndex:([outroTempPath1 length]-4)];
						NSString *mp3path=[NSString stringWithFormat:@"%@.mp3",mainPath];
						[musicProcessor ConvertToWave:mp3path];
						
						
						DUBUG_LOG(@"mp3path mp3path mp3path is %@ outroTempPath1 outroTempPath1 is %@",mp3path,outroTempPath1);
						
						DUBUG_LOG(@"staart pos--- %@ length---%@",[NSString stringWithFormat:@"%f",0.00],[NSString stringWithFormat:@"%f",([[[songsElementsArray objectAtIndex:p]objectForKey:@"duration"] floatValue]-differennce)]);
						
						
						if([fileManager fileExistsAtPath:outroTempPath1])
							[songsArray addObject:outroTempPath1];
						[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
						[outroTempPath release];
						[musicProcessor release];
						
						
						
						
					}
					//m++;
				}
				else {
					DUBUG_LOG(@" ############# Music File not found %@ ##########",musicPath);
				}

				
			}
		}
		else
		{
			return;
		}
	}
	
	DUBUG_LOG(@"songs array is %@",songsArray);
	
	//[songsElementsArray release];
	DUBUG_LOG(@"Now you are completed createBackgroundMusics method in GenerateWorkout class");
}








-(void)getIntroOutroBg
{
    DUBUG_LOG(@"Now you are in getIntroOutroBg method in GenerateWorkout class");
	if(!runningPreviousUserWorkout)
	{

	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	//NSString *tempPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp"];
	
		
		
		
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	NSString *workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
																	   kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
	NSString *tempPath=[workOutDirectory stringByAppendingPathComponent:@"Temp"];
		
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:tempPath])
	{
		[fileManager createDirectoryAtPath:tempPath attributes:nil];
	}
	
	
	
	NSString *localVocalPath =[bundlePath stringByAppendingPathComponent:@"Specificsongs"];
	NSString *folderPath =[[NSString alloc] initWithFormat:@"%@/Ambiant/",localVocalPath];	
	
	NSMutableArray *musicArray;
	
	
	musicArray=(NSMutableArray *)[fileManager contentsOfDirectoryAtPath:folderPath error:nil];
		
	float differennce =0;
	int m=1;
	DUBUG_LOG(@"music array is %@",musicArray);
	for(NSString * musicName in musicArray)
	{
		if(!runningPreviousUserWorkout)
		{
		NSString *musicPath =[[NSString alloc] initWithFormat:@"%@%@",folderPath,musicName];
		 NSString *firstInputExtension=[musicPath substringFromIndex:([musicPath length]-3)];
			//NSString *musicPath =[NSString stringWithFormat:@"%@%@",folderPath,musicName];
		if([fileManager fileExistsAtPath:musicPath] && ([firstInputExtension isEqualToString:@"mp3"] || [firstInputExtension isEqualToString:@"m4a"]))
		{
			DUBUG_LOG(@"m value iisisisi %d",m);
		
		DUBUG_LOG(@"music name is %@",musicPath);
		NSSound *sound=[[NSSound alloc] initWithContentsOfFile:musicPath byReference:YES];
		float dur =[sound duration];
		[sound release];
			DUBUG_LOG(@"duration isiis %f",dur);
		if(dur<(60-differennce))
		{
			DUBUG_LOG(@"getIntroOutroBg if condition");
			differennce =differennce+dur;
			NSString *outroTempPath;
			if(introBgSelected)
				outroTempPath = [[NSString alloc] initWithFormat:@"%@/trimOutroBg%d.wav",tempPath,m];
			else {
				outroTempPath = [[NSString alloc] initWithFormat:@"%@/trimIntroBg%d.wav",tempPath,m];
				introBgSelected =YES;
			}
			
			JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
			[musicProcessor convertBitRate:musicPath:@"44100":outroTempPath];
			[musicProcessor ChangeMp3gain:@"5":outroTempPath];
			
			NSString *mainPath =[outroTempPath substringToIndex:([outroTempPath length]-4)];
			NSString *mp3path=[NSString stringWithFormat:@"%@.mp3",mainPath];
			[musicProcessor ConvertToWave:mp3path];
			
			if([fileManager fileExistsAtPath:outroTempPath])
				[songsArray addObject:outroTempPath];
			[outroTempPath release];
			[musicProcessor release];
			
		}
		
		else
		{	
			DUBUG_LOG(@"getIntroOutroBg else condition");

			
			JiwokMusicProcessor *musicProcessor =[[JiwokMusicProcessor alloc] init];
			NSString *outroTempPath,*outroTempPath1;
			if(introBgSelected)
			{
				outroTempPath = [[NSString alloc] initWithFormat:@"%@/trimOutroBg%d.wav",tempPath,m];
			outroTempPath1 =[[NSString alloc] initWithFormat:@"%@/trimOutroBg_Bitrate%d.wav",tempPath,m];
			}
			else {
				outroTempPath = [[NSString alloc] initWithFormat:@"%@/trimIntroBg%d.wav",tempPath,m];
				outroTempPath1 =[[NSString alloc] initWithFormat:@"%@/trimIntroBg_Bitrate%d.wav",tempPath,m];
				introBgSelected =YES;
			}
			
			DUBUG_LOG(@"DIFFERENCE IS %f",(60-differennce));
			
			float inputValue=(60-differennce);
			
			[musicProcessor TrimAudio:musicPath:outroTempPath:[NSString stringWithFormat:@"%f",0.00]:[NSString stringWithFormat:@"%f",inputValue]];
			
			//[musicProcessor TrimAudio:musicPath:outroTempPath:[NSString stringWithFormat:@"%f",0.00]:[NSString stringWithFormat:@"%f",(60-differennce)]];
			[musicProcessor convertBitRate:outroTempPath:@"44100":outroTempPath1];
			[musicProcessor ChangeMp3gain:@"5":outroTempPath1];
			
			
			NSString *mainPath =[outroTempPath1 substringToIndex:([outroTempPath1 length]-4)];
			NSString *mp3path=[NSString stringWithFormat:@"%@.mp3",mainPath];
			[musicProcessor ConvertToWave:mp3path];
			
			DUBUG_LOG(@"staart pos >>> --- %@ length---%@",[NSString stringWithFormat:@"%f",0.00],[NSString stringWithFormat:@"%f",(60-differennce)]);
			
			
			DUBUG_LOG(@"outroTempPath1 outroTempPath1 is %@",outroTempPath1);
			
			if([fileManager fileExistsAtPath:outroTempPath1])
				[songsArray addObject:outroTempPath1];
			[[NSFileManager defaultManager] removeFileAtPath:outroTempPath handler: nil];
			[outroTempPath release];
			[musicProcessor release];
			break;
	
		}
	}
		
		m++;
	}
		else{
			return;
		}
	}
	
	[folderPath release];
		
		
		// Added for testing
		//[songsArray removeAllObjects];
		
	DUBUG_LOG(@"songs array isisi %@",songsArray);
	//return [songsArray autorelease];
}
	else
	{
		
	}
	 DUBUG_LOG(@"Now you are completed getIntroOutroBg method in GenerateWorkout class");
}

-(NSMutableArray*)arrangeSongs:(NSMutableArray *)tmpArray{			
	 DUBUG_LOG(@"Now you are in arrangeSongs method in GenerateWorkout class");
	NSCharacterSet *charSet =[NSCharacterSet characterSetWithCharactersInString:@"}{"];
	
	NSMutableArray *tmpArray1Holder, *sortedArray,*tmpArray1;	
	tmpArray1=[[NSMutableArray alloc]initWithArray:tmpArray];
	tmpArray1Holder=[[NSMutableArray alloc]initWithArray:tmpArray];	
	sortedArray=[[[NSMutableArray alloc]init] autorelease];	
	
	for(int count=0;count<[tmpArray1 count];count++)
	{		
		if([[[tmpArray1 objectAtIndex:count]objectForKey:@"Duration"] floatValue]>0 && ([tmpArray1 objectAtIndex:count]) && [[[tmpArray1 objectAtIndex:count] objectForKey:@"FilePath"] rangeOfCharacterFromSet:charSet].location == NSNotFound)
		{				
			NSString *previousArtist,*currentArtist;
			
			if(count==0)
			{						
				[sortedArray addObject:[tmpArray1 objectAtIndex:count]];				
				[tmpArray1Holder removeObject:[tmpArray1 objectAtIndex:count]];		
				[tmpArray1 removeObject:[tmpArray1 objectAtIndex:count]];				
			}			
			else {				
				previousArtist=[[sortedArray lastObject]objectForKey:@"Artist"];
				currentArtist=[[tmpArray1 objectAtIndex:count]objectForKey:@"Artist"];
				
				if(![previousArtist isEqualToString:currentArtist])
				{						
					[sortedArray addObject:[tmpArray1 objectAtIndex:count]];
					[tmpArray1Holder removeObject:[tmpArray1 objectAtIndex:count]];
					[tmpArray1 removeObject:[tmpArray1 objectAtIndex:count]];									
				}					
			}
			
			for(int countHold=1;countHold<[tmpArray1Holder count];countHold++){
				
				previousArtist=[[sortedArray lastObject]objectForKey:@"Artist"];
				currentArtist=[[tmpArray1Holder objectAtIndex:countHold] objectForKey:@"Artist"];
				if(![previousArtist isEqualToString:currentArtist])
				{					
					[sortedArray addObject:[tmpArray1 objectAtIndex:countHold]];
					
					[tmpArray1Holder removeObject:[tmpArray1 objectAtIndex:countHold]];
					[tmpArray1 removeObject:[tmpArray1 objectAtIndex:countHold]];										
				}				
			}			
		}		
	}			
	
	for(int remaining=0;remaining<[tmpArray1Holder count];remaining++)
	{
		if(([sortedArray indexOfObject:[tmpArray1Holder objectAtIndex:remaining]]>0))
		{
			[sortedArray addObject:[tmpArray1Holder objectAtIndex:remaining]];
			
		}
	}	
	[tmpArray1 release];
	[tmpArray1Holder release];
	DUBUG_LOG(@"Now you are completed arrangeSongs method in GenerateWorkout class");
	return (sortedArray);	
     
}


@end
