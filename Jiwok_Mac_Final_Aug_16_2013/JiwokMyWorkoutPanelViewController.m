//
//  JiwokMyWorkoutPanelViewController.m
//  Jiwok
//
//  Created by reubro R on 15/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokMyWorkoutPanelViewController.h"
#import "Common.h"
#import "LoggerClass.h"
#import "JiwokUtil.h"
#import "JiwokAPIHelper.h"
#import "JiwokAppDelegate.h"
#import "JiwokSettingPlistReader.h"

#import "GrowlExample.h"


//#import "Variable.h"


@implementation JiwokMyWorkoutPanelViewController
@synthesize workoutScantimer,currentWorkoutDictionary ;




-(void)checkThem:(NSTimer *)aTimer
{	
   //DUBUG_LOG(@"Now you are in checkThem method in JiwokMyWorkoutPanelViewController class");
	if(count > 10)		
	count = 0;	
	
	count++;
	

	
//	if(count > 100)
//	{
//		count = 0;
		//[timer invalidate];
//		[timer release];
//		timer = NULL;
	//	[progressBar1 setDoubleValue:0.0];
		//[progressBar1 stopAnimation: self];
//	}
//	else
//	{
//		[progressBar1 startAnimation:self];
		
	
	
	[progressBar setDoubleValue:(10.0 * count) / 10];
		 //DUBUG_LOG(@"Now you are completed checkThem method in JiwokMyWorkoutPanelViewController class");
	//}
		 }





-(void)createTimer{
     //DUBUG_LOG(@"Now you are in createTimer method in JiwokMyWorkoutPanelViewController class");
	
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
		if(!timer)
		{
			timer = [[NSTimer scheduledTimerWithTimeInterval:0.001 
													  target:self selector:@selector(checkThem:) 
													userInfo:nil repeats:YES] retain];
		}
			
	[pool release];
 //DUBUG_LOG(@"Now you are completed createTimer method in JiwokMyWorkoutPanelViewController class");
}


- (void)awakeFromNib
{
//	NSFileManager *fm = [NSFileManager defaultManager];
//	NSDictionary *attr = [fm fileSystemAttributesAtPath:@"/"]; 
//	//NSLog(@"Attr: %@", attr);
     NSLog(@"Now you are in awakeFromNib method in JiwokMyWorkoutPanelViewController class");
	[levelBar setHidden:NO];
	bWorkOutInProgress =NO;
	
	
	DUBUG_LOG(@"awakeFromNib for workout generation ");
	
	
	
	
	//[self performSelectorInBackground:@selector(createTimer) withObject:nil];
	
	
	
		
	//NSTimer *timer;
	
	if(!timer)
	{
		timer = [[NSTimer scheduledTimerWithTimeInterval:0.001 
												  target:self selector:@selector(checkThem:) 
												userInfo:nil repeats:YES] retain];
	}
		
	
	
	
	
	
/*	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	BOOL dbCheck = [appdelegate UpdateStatusOfMusicFiles];
	if(dbCheck)
	{
		
	}
	else
	{
		
		if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"INFO-FOR_MUSIC_SELECT"):JIWOK_ALERT_YES_NO])
		{
			//currentTab = 2;
			
		}
	}*/
	
	//workoutScantimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checnandGenerateWorkout:) userInfo:nil repeats:YES];
	
	// New code to improve performance using threads
	workoutScantimer = [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(invokeTimer:) userInfo:nil repeats:YES];

	

	NSString *imageNameSave = [[NSString alloc] initWithFormat:@"Save_WorkoutLoc_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnSaveWorkout setImage:[NSImage imageNamed:imageNameSave]];
	[imageNameSave release];

	NSString *imageNameView = [[NSString alloc] initWithFormat:@"viewMyWorkout_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnViewWorkout setImage:[NSImage imageNamed:imageNameView]];	
	[imageNameView release];
	
	NSString *viewWorkoutInQueue = [[NSString alloc] initWithFormat:@"viewMyWorkoutInQueue_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[btnWorkoutInQueue setImage:[NSImage imageNamed:viewWorkoutInQueue]];	
	[viewWorkoutInQueue release];
	
		
	[txtTitle setStringValue: JiwokLocalizedString(@"WORKOUT_TITLE")];
	[txtDescription setStringValue: JiwokLocalizedString(@"WORKOUT_DESCRIPTION")];
	[saveLocation setStringValue: JiwokLocalizedString(@"WORKOUT_SAVE_LOCATION")];

	
	/*
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
												 kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
		*/
	
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	workOutDirectory = (NSString*)CFPreferencesCopyValue(CFSTR("WORKOUTDIR"), CFSTR(APPID), 
														 kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	
	
	
	//NSLog(@"workOutDirectory workOutDirectory workOutDirectory is %@",workOutDirectory);
	
	[txtLocation  setEditable:NO];
	
	if (![workOutDirectory isEqualToString:@""] && workOutDirectory != nil)
	{
		
		
		[txtLocation setStringValue:workOutDirectory];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:workOutDirectory])
		{
			DUBUG_LOG(@"The specfied workout location does not exist.%@",workOutDirectory);
		}		
	}
	else
	{
		workOutDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		[txtLocation setStringValue: workOutDirectory];
		
		
		CFPreferencesSetValue(CFSTR("WORKOUTDIR"), workOutDirectory, CFSTR(APPID), 
							  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
		CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		
		
	}
	DUBUG_LOG(@"Now you are completed awakeFromNib method in JiwokMyWorkoutPanelViewController class");
}


-(void)invokeTimer:(NSTimer *) theTimer {
    DUBUG_LOG(@"Now you are in invokeTimer method in JiwokMyWorkoutPanelViewController class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];

	[self performSelectorInBackground:@selector(checnandGenerateWorkout:) withObject:nil];

	[pool release];
    DUBUG_LOG(@"Now you are completed invokeTimer method in JiwokMyWorkoutPanelViewController class");
}

-(void)updateGenreList{
     DUBUG_LOG(@"Now you are in updateGenreList method in JiwokMyWorkoutPanelViewController class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];	
	
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];

	[appdelegate performSelectorInBackground:@selector(UpdateTagDetectedGenres) withObject:nil];
	
	
	[pool release];
  DUBUG_LOG(@"Now you are completed updateGenreList method in JiwokMyWorkoutPanelViewController class");

}



-(void) checnandGenerateWorkout:(NSTimer *) theTimer 
{
     DUBUG_LOG(@"Now you are in checnandGenerateWorkout method in JiwokMyWorkoutPanelViewController class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];	

	
	if(runningPreviousUserWorkout)
		[cancelWorkout setHidden:YES];
	
		//DUBUG_LOG(@"Checking for active work out currentWorkoutDictionary is %@",[self.currentWorkoutDictionary objectForKey:@"queue_id"]);
	//DUBUG_LOG(@"Checking for active work out currentWorkoutDictionary is %@",self.currentWorkoutDictionary);

	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSMutableArray *tempDataArray;
	
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];

	
//	[self performSelectorOnMainThread:@selector(updateGenreList) withObject:nil waitUntilDone:NO];
	
	// check work out in queue call API
	if(!bWorkOutInProgress&&appdelegate.isLogged&&([JiwokUtil checkForInternetConnection:jiwokURL]))
	{
		
		
		[self performSelectorOnMainThread:@selector(updateGenreList) withObject:nil waitUntilDone:NO];

		
		
		JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
		
		self.currentWorkoutDictionary = [apiHelper InvokeGetWorkoutInQueueAPI:appdelegate.loggedusername:appdelegate.loggedpassword];
		
		//DUBUG_LOG(@"checnandGenerateWorkout dict %@",self.currentWorkoutDictionary);		
		
		//[apiHelper release];		
		/// call API and get list
		//apiHelper= [[JiwokAPIHelper alloc]init];
		
		
		
		
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
		if([JiwokUtil checkForInternetConnection:jiwokURL])
		tempDataArray = [apiHelper InvokeGetAllWorkoutsAPI:appdelegate.loggedusername:@"2"];
         //NSLog(@"tempDataArray NSMutableArray==%@",tempDataArray);
		[apiHelper release];
	}
	
		
		if (([currentWorkoutDictionary count] > 0) &&  (!analysingInProgress) && (appdelegate.isLogged) && ([[self.currentWorkoutDictionary objectForKey:@"queue_id"] intValue] !=0))
			{
				
				DUBUG_LOG(@"workout is in queue");
				
		if(([appdelegate UpdateStatusOfMusicFiles]))
		{
				DUBUG_LOG(@"status of workout start bool %d",bWorkOutInProgress);
					if(!bWorkOutInProgress && ([[self.currentWorkoutDictionary objectForKey:@"queue_id"] intValue] != 0))
					{
			
						appdelegate.workoutQueueID = [self.currentWorkoutDictionary objectForKey:@"queue_id"];
						////start work out generation process using work out processor class
					
						//Old code
						//[NSThread detachNewThreadSelector:@selector(generateworkoutMP3) toTarget:self withObject:nil];
						
						// New code
						[self performSelectorOnMainThread:@selector(startGeneration) withObject:nil waitUntilDone:NO];
					}
			
		}
				
				else
				{
					
					DUBUG_LOG(@"No music in DB");
				}
	}
	
	[pool release];
    DUBUG_LOG(@"Now you are completed checnandGenerateWorkout method in JiwokMyWorkoutPanelViewController class");
}


-(void)startGeneration{
    DUBUG_LOG(@"Now you are in startGeneration method in JiwokMyWorkoutPanelViewController class");
	[NSThread detachNewThreadSelector:@selector(generateworkoutMP3) toTarget:self withObject:nil];

 DUBUG_LOG(@"Now you are completed startGeneration method in JiwokMyWorkoutPanelViewController class");

}



-(void)generationFailed
{
	 DUBUG_LOG(@"Now you are in generationFailed method in JiwokMyWorkoutPanelViewController class");
	generationFailed=YES;
	self.currentWorkoutDictionary=nil;
	
	
	[progressBar stopAnimation:self];
	[progressBar setHidden:YES];
   DUBUG_LOG(@"Now you are completed generationFailed method in JiwokMyWorkoutPanelViewController class");
}

// Generate work out on request . This will use currentWorkoutDictionary  for taking the work out details
-(void)generateworkoutMP3
{
	DUBUG_LOG(@"Now you are in generateworkoutMP3 method in JiwokMyWorkoutPanelViewController class");
	//BOOL generationFailed=NO;
	
	 generationFailed=NO;
	
	
	if (bWorkOutInProgress)
	{
		//return;
	}
	
	else
	{
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DUBUG_LOG(@"generateworkoutMP3 ");
	@try
	{
		// if nothing is in progress start
		if (bWorkOutInProgress)
		{
			DUBUG_LOG(@"There is an active work out in progress ");
			return;

		}
		[cancelWorkout setHidden:NO];
		bWorkOutInProgress = YES;
		runningPreviousUserWorkout =NO;

		
		[appdelegate cleanUpDisk];
		
		
		
		/// store the active work out id
		//QueueIDInProgress = appdelegate.workoutQueueID;
		QueueIDInProgress = [NSString stringWithFormat:@"%@",appdelegate.workoutQueueID];
		//NSLog(@"store the active work out id %@",QueueIDInProgress);
		
		[txtDescription setStringValue:JiwokLocalizedString(@"INFO_GENERATING_MP3")];
		[[LoggerClass getInstance] logData:@"generating workout "];
		
		//[progressBar setUsesThreadedAnimation:NO];
		[progressBar setHidden:NO];
		[progressBar startAnimation:self];
		
		workoutGenerationInProgress =YES;
		
		// Added to change dock image
		
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];		
		[appdelegate updateDockImage];
		
		
		GrowlExample *growlMsger=[[GrowlExample alloc]init];
		[growlMsger growlAlert:JiwokLocalizedString(@"GENERATION_INPROGRESS_POPUP") title:nil];
		[growlMsger release];
		

		
		GenerateWorkout *workoutGenerator = [[GenerateWorkout alloc] init];
		workoutGenerator.delegate =self;
		if(forceFullygeneratedWorkout)
		{
			
			[workoutGenerator introDownload:nil];
		}
		else
		{
			[workoutGenerator introDownload:self.currentWorkoutDictionary];
		}
			
		//[downLoader outroDownload];
		[workoutGenerator release];
		//currentWorkoutDictionary
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in generateworkoutMP3 %@",[ex description]];
		
		generationFailed=YES;
		
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
	}
	@finally 
	{
		

				
		/*if([[self.currentWorkoutDictionary objectForKey:@"queue_id"] intValue] ==0)
		{
			[txtDescription setStringValue:JiwokLocalizedString(@"INFO_GENERATING_MP3_NO_WORKOUTS")];
			[[LoggerClass getInstance] logData:@"No Workouts In Queue"];
		}*/
		
		
		if(!cancelButtonPressed )
		{
			
			if([[NSUserDefaults standardUserDefaults]integerForKey:@"WORKOUT_GENERATION_COUNT"])
			{
				int generaionCount=	[[NSUserDefaults standardUserDefaults]integerForKey:@"WORKOUT_GENERATION_COUNT"];
				[[NSUserDefaults standardUserDefaults] setInteger:(generaionCount+1) forKey:@"WORKOUT_GENERATION_COUNT"];
				
				[[LoggerClass getInstance] logData:@"WORKOUT_GENERATION_COUNT %d",generaionCount];

				
			}
				else {
					[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WORKOUT_GENERATION_COUNT"];
				}

				
			
			if(!generationFailed)
			[txtDescription setStringValue:JiwokLocalizedString(@"INFO_GENERATING_MP3_COMPLETE")];
		else		
			[txtDescription setStringValue:JiwokLocalizedString(@"INFO_GENERATING_MP3_FAILED")];

			[[LoggerClass getInstance] logData:@"workout generation complete"];
			[self updateWorkoutStatus:@"3"];
				[cancelWorkout setHidden:YES];
		}
		else
		{
			
			[txtDescription setStringValue:JiwokLocalizedString(@"INFO_CANCEL_MP3")];
			[[LoggerClass getInstance] logData:@"workout generation cancelled"];
			
			QueueIDInProgress =NULL;
			[self updateWorkoutStatus:@"2"];
			
			runningPreviousUserWorkout =YES;
			workoutGenerationInProgress =NO;
			//bWorkOutInProgress = NO;
				
		}
		
		
		bWorkOutInProgress = NO;
		workoutGenerationInProgress = NO;
		cancelButtonPressed = NO;
		//[workoutgenerationThread cancel];
		//[workoutgenerationThread release];
		
		
		//workoutScantimer = [NSTimer scheduledTimerWithTimeInterval: 0.0 target:self selector:@selector(checnandGenerateWorkout:) userInfo:nil repeats: NO];
		forceFullygeneratedWorkout =NO;
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
		
		
		JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];		
		[appdelegate updateDockImage];
		[appdelegate cleanUpDisk];

	}
	
	[pool release];
	}
    DUBUG_LOG(@"Now you are completed generateworkoutMP3 method in JiwokMyWorkoutPanelViewController class");
}

-(void)updateWorkoutStatus:(NSString *)status
{
    DUBUG_LOG(@"Now you are in updateWorkoutStatus method in JiwokMyWorkoutPanelViewController class");
	DUBUG_LOG(@"updateWorkoutStatus updateWorkoutStatus status is %@",status);
	
	NSString *queueId;
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
	//DUBUG_LOG(@"id from queue is %@ %@ ,",self.currentWorkoutDictionary ,appdelegate.workoutQueueID);
	if(!forceFullygeneratedWorkout)
	{
		queueId =[self.currentWorkoutDictionary objectForKey:@"queue_id"];
		DUBUG_LOG(@"id from queue is %@",queueId);
	}
	else
	{
		queueId =appdelegate.workoutQueueID;
	}
	
	DUBUG_LOG(@"updateWorkoutStatus updateWorkoutStatus status is %@ queueId is %@",status,queueId);
	
	int workoutNo=[[NSUserDefaults standardUserDefaults]integerForKey:@"WORKOUT_GENERATION_COUNT"];
	
	DUBUG_LOG(@"\n  xxxxxxxxxxx workout generation finished Workout No =%d And Workout Id= %@ xxxxxxxxxxxxxxxxx \n",workoutNo,queueId);
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];
	
	
	if ([JiwokUtil checkForInternetConnection:jiwokURL])
	{	
	[apiHelper InvokeUpdateMP3GenerationStatusAPI:queueId:status];
		
	}
	//DUBUG_LOG(@"checnandGenerateWorkout dict %@",self.currentWorkoutDictionary);
	[apiHelper release];
    DUBUG_LOG(@"Now you are completed updateWorkoutStatus method in JiwokMyWorkoutPanelViewController class");
}
-(IBAction)viewWorkoutAction:(id)sender
{
	DUBUG_LOG(@"Now you are in viewWorkoutAction method in JiwokMyWorkoutPanelViewController class");
	NSString *workoutFolder = [NSString stringWithFormat:@"%@/Seance_Jiwok",workOutDirectory];
	char strCommand[256] = {0};
    sprintf(strCommand,"open '%s'",[workoutFolder UTF8String]);
	////NSLog(@"cmd %s",strCommand);
	system(strCommand);
    DUBUG_LOG(@"Now you are completed viewWorkoutAction method in JiwokMyWorkoutPanelViewController class");
}
-(IBAction)saveWorkoutAction:(id)sender
{
	
	//NSLog(@"saveWorkoutAction saveWorkoutAction");
	DUBUG_LOG(@"Now you are in saveWorkoutAction method in JiwokMyWorkoutPanelViewController class");
	CFPreferencesSetValue(CFSTR("WORKOUTDIR"), workOutDirectory, CFSTR(APPID), 
						  kCFPreferencesCurrentUser, kCFPreferencesCurrentHost); 
	CFPreferencesSynchronize(CFSTR(APPID), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	
	/*NSFileManager *fileManager=[NSFileManager defaultManager];	
	NSString *bundlePath=[[NSBundle mainBundle] bundlePath];	
	NSString *MovedLocation=[[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Workouts"];
	
	NSString *finalMp3= [[NSString alloc] initWithFormat:@"%@/finalMp3.wav",MovedLocation];
	
	if(![fileManager fileExistsAtPath:MovedLocation])
	{
		[fileManager createDirectoryAtPath:MovedLocation attributes:nil];
	}
	
	//NSLog(@"MovedLocation is %@  toPath is %@",finalMp3,[[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp"]);
	
	BOOL result=[fileManager moveItemAtPath:finalMp3 toPath:[[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Temp/finalMp3.wav"] error:nil];
	
	//NSLog(@"result result is %d    workOutDirectory  %@",result,workOutDirectory);
	*/
   DUBUG_LOG(@"Now you are completed saveWorkoutAction method in JiwokMyWorkoutPanelViewController class");
}
-(IBAction)browseWorkoutAction:(id)sender
{
   DUBUG_LOG(@"Now you are in browseWorkoutAction method in JiwokMyWorkoutPanelViewController class");
	NSOpenPanel *oPanel = [[NSOpenPanel openPanel] retain];
	NSString *startDir = @"";
	
	if (![workOutDirectory isEqualToString:@""] && workOutDirectory != nil)
	{
		startDir = workOutDirectory;
	}
	else
	{
		startDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	}
	
	[oPanel setCanChooseDirectories:YES];
	[oPanel beginForDirectory:startDir file:nil types:nil modelessDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	DUBUG_LOG(@"Now you are completed browseWorkoutAction method in JiwokMyWorkoutPanelViewController class");
}
-(IBAction)workoutInQueueAction:(id)sender
{
   DUBUG_LOG(@"Now you are in workoutInQueueAction method in JiwokMyWorkoutPanelViewController class");
	NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];	
	
	if (![JiwokUtil checkForInternetConnection:jiwokURL])
	{		
		[JiwokUtil showAlert:JiwokLocalizedString(@"ERROR_INTERNET_CONNECTION"):JIWOK_ALERT_OK];
		return;
	}
	else{	
		
	workoutPopupVC = [JiwokWorkoutPopupWndController alloc];
	[workoutPopupVC initWithWindowNibName:@"JiwokWorkoutPopupWindow"];
	workoutPopupVC.delegate = self;
	[workoutPopupVC showWindow:self];
		
	}
    DUBUG_LOG(@"Now you are completed workoutInQueueAction method in JiwokMyWorkoutPanelViewController class");
}

-(IBAction)CancelAction:(id)sender{
	
	//self.currentWorkoutDictionary =NULL;
	DUBUG_LOG(@"Now you are in CancelAction method in JiwokMyWorkoutPanelViewController class");
	if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_CANCEL_WORKOUT"):JIWOK_ALERT_YES_NO])
		
	{
		
	[txtDescription setStringValue:JiwokLocalizedString(@"INFO_CANCELLING_MP3")];
		[[LoggerClass getInstance] logData:@"workout generation is cancelling"];
		[cancelWorkout setHidden:YES];
		cancelButtonPressed =YES;
		

		runningPreviousUserWorkout =YES;
			/*	workoutGenerationInProgress =NO;
		bWorkOutInProgress = NO;*/
	
	//NSLog(@"CancelAction CancelAction");
	}
DUBUG_LOG(@"Now you are completed CancelAction method in JiwokMyWorkoutPanelViewController class");

}







- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
   DUBUG_LOG(@"Now you are in openPanelDidEnd method in JiwokMyWorkoutPanelViewController class");
	if (returnCode == NSOKButton)
	{
		workOutDirectory = [panel directory];
		DUBUG_LOG(@"workOutDirectory dir %@",workOutDirectory);
		[txtLocation setStringValue:workOutDirectory];
	}
	
	[panel release];
    DUBUG_LOG(@"Now you are completed openPanelDidEnd method in JiwokMyWorkoutPanelViewController class");
}
-(void)didSelectGenerate
{
    DUBUG_LOG(@"Now you are in didSelectGenerate method in JiwokMyWorkoutPanelViewController class");
	DUBUG_LOG(@"didSelectGenerate");
	
/*	JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	self.currentWorkoutDictionary = [apiHelper InvokeGetWorkoutByQueueIdAPI:appdelegate.workoutQueueID];
	DUBUG_LOG(@"didSelectGenerate dict %@",self.currentWorkoutDictionary);
	[apiHelper release];*/
	
	////start work out generation process using work out processor class
	forceFullygeneratedWorkout =YES;
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	
	if(bWorkOutInProgress)
	{
		
		[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_WORKOUT_RUNNING_NEXT_WROKOUT"):JIWOK_ALERT_OK];
		return;
		//[txtDescription setStringValue:JiwokLocalizedString(@"WARNING_WORKOUT_RUNNING_NEXT_WROKOUT")];
		//[NSTimer scheduledTimerWithTimeInterval: 5.0 target:self selector:@selector(changeStatusToGeneration:) userInfo:nil repeats:NO];
	}
	if([appdelegate UpdateStatusOfMusicFiles])
		{
			/*if(bWorkOutInProgress)
			{
				[txtDescription setStringValue:JiwokLocalizedString(@"WARNING_WORKOUT_RUNNING_NEXT_WROKOUT")];
				[NSTimer scheduledTimerWithTimeInterval: 5.0 target:self selector:@selector(changeStatusToGeneration:) userInfo:nil repeats:NO];
			}*/
			if(analysingInProgress)
			{
				
				[JiwokUtil showAlert:JiwokLocalizedString(@"INFO-FOR_BG_ANALYSING"):JIWOK_ALERT_OK];
				return;
			}
			
						
			if(!analysingInProgress)
			[NSThread detachNewThreadSelector:@selector(generateworkoutMP3) toTarget:self withObject:nil];
		}
	else
	{
		[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_CHECKING_DB_SONGS"):JIWOK_ALERT_OK];
		return;
	}
	DUBUG_LOG(@"Now you are completed didSelectGenerate method in JiwokMyWorkoutPanelViewController class");
}
-(void)changeStatus:(NSString *)status
{
	
	//NSLog(@"changeStatus %@,",status);
	DUBUG_LOG(@"Now you are in changeStatus method in JiwokMyWorkoutPanelViewController class");
	[txtDescription setStringValue:JiwokLocalizedString(status)];
	//[txtDescription setStringValue:@"Processing Vocals"];
    DUBUG_LOG(@"Now you are completed changeStatus method in JiwokMyWorkoutPanelViewController class");
}
-(void)didSelectRemove
{
    DUBUG_LOG(@"Now you are in didSelectRemove method in JiwokMyWorkoutPanelViewController class");
	DUBUG_LOG(@"didSelectRemove");

	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	DUBUG_LOG(@"current running %@ ---selected",appdelegate.workoutQueueID);
	DUBUG_LOG(@"current QueueIDInProgress %@ ---selected",QueueIDInProgress);
	
	
	if ([appdelegate.workoutQueueID isEqualToString:QueueIDInProgress] && bWorkOutInProgress)
	{
		[JiwokUtil showAlert:JiwokLocalizedString(@"WARNING_WORKOUT_RUNNING"):JIWOK_ALERT_OK];
		return;
	}
	else
	{
		if (NSAlertFirstButtonReturn == [JiwokUtil showAlert:JiwokLocalizedString(@"QUESTION_REMOVE_WORKOUT"):JIWOK_ALERT_YES_NO])// OK selected
		{
			[[LoggerClass getInstance] logData:@"Removing workout from queue"];
			
			JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			NSString *jiwokURL = [JiwokSettingPlistReader GetJiwokURL];			
			
			if ([JiwokUtil checkForInternetConnection:jiwokURL])
			{			
			[apiHelper InvokeUpdateMP3GenerationStatusAPI:appdelegate.workoutQueueID:@"5"];
		
			}				
			[apiHelper release];	
			
			[[LoggerClass getInstance] logData:@"Removing workout from queue complete"];
			[workoutPopupVC reloadQueueData];
		}
		
	}
    DUBUG_LOG(@"Now you are completed didSelectRemove method in JiwokMyWorkoutPanelViewController class");
}


-(void)generationCompleted{
	DUBUG_LOG(@"Now you are in generationCompleted method in JiwokMyWorkoutPanelViewController class");
	DUBUG_LOG(@"generationCompleted generationCompleted");	
	
	GrowlExample *growlMsger=[[GrowlExample alloc]init];
	[growlMsger growlAlert:JiwokLocalizedString(@"GENERATION_COMPLETED_POPUP") title:nil];
	[growlMsger release];
	
	[self viewWorkoutAction:@""];
    DUBUG_LOG(@"Now you are completed generationCompleted method in JiwokMyWorkoutPanelViewController class");
}

@end
