

#import "JiwokAudioPlayController.h"
#import "LoggerClass.h"


@implementation JiwokAudioPlayController

//Play the music
-(void)playMusic:(NSString *)path
{
   DUBUG_LOG(@"Now you are in playMusic method in JiwokAudioPlayController class");
	if(sound) 
	{
		[sound stop];
		[sound release];
	}
	
	testPlay =NO;
	sound = [[NSSound alloc] initWithContentsOfFile:path byReference:YES ];
	
	//NSLog(@"palyeiii");
	
	[sound play];
    DUBUG_LOG(@"Now you are completed playMusic method in JiwokAudioPlayController class");
}

//Pause the music
-(void)pauseMusic
{
    DUBUG_LOG(@"Now you are in pauseMusic method in JiwokAudioPlayController class");
	[sound pause];
    DUBUG_LOG(@"Now you are completed pauseMusic method in JiwokAudioPlayController class");
}
	
//Resume the music
-(void)resumeMusic 
{
     DUBUG_LOG(@"Now you are in resumeMusic method in JiwokAudioPlayController class");
	[sound resume];
    DUBUG_LOG(@"Now you are completed resumeMusic method in JiwokAudioPlayController class");
}

//Stop the music
-(void)stopMusic
{
    DUBUG_LOG(@"Now you are in stopMusic method in JiwokAudioPlayController class");
	if ([sound isPlaying])
	{
		[sound stop];
	}
   DUBUG_LOG(@"Now you are completed stopMusic method in JiwokAudioPlayController class");
}

- (void)dealloc 
{		
	[super dealloc];
}


@end
