//
//  JiwokMusicConverter.m
//  Jiwok
//
//  Created by reubro R on 13/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokMusicConverter.h"
#import "LoggerClass.h"

@implementation JiwokMusicConverter
-(void)convertToWav:(NSString *)filePath
{
    DUBUG_LOG(@"Now you are in convertToWav method in JiwokMusicConverter class");
	@try{
	NSString *toolPath;// = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"FFMPEG"];
	toolPath=[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@""];

	
	if (![[NSFileManager defaultManager] changeCurrentDirectoryPath:[toolPath stringByDeletingLastPathComponent]])
	{
		[[LoggerClass getInstance] logData:@"convertToWav-> Failed to set current directory to %@  toolPath ===  %@",[toolPath stringByDeletingLastPathComponent],toolPath];
	}

	NSString *wavePath = [[filePath stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"];
	DUBUG_LOG(@"convertToWav toolpath --->>> %@ file path %@ --- wave file path %@",toolPath,filePath,wavePath);
	
	NSMutableArray *mArray = [[NSMutableArray alloc] init];	
	[mArray addObject:@"-i"];	
	[mArray addObject:filePath];
	[mArray addObject:@"-y"];
	//[mArray addObject:@"-ar"];	
	//[mArray addObject:@"44100"];	
	[mArray addObject:wavePath];
	
    NSLog(@"mArray NSMutableArray==%@",mArray);
	task = [[NSTask alloc] init]; 	
	[task setLaunchPath: toolPath];
	[task setArguments: mArray];
	
	NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	[task setStandardError: pipe];
	
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
	
    [task launch];
    [task waitUntilExit];
	
    NSData *data;
    data = [file readDataToEndOfFile];
	
	//return(data);		
}
	@catch (NSException *ex) {
		
	
		[[LoggerClass getInstance] logData:@"Exception occured in convertToWav %@",[ex description]];
	}
	@finally 
	{
		
	}
	DUBUG_LOG(@"Now you are completed convertToWav method in JiwokMusicConverter class");
}

-(void)convertToMp3:(NSString *)filePath
{
	DUBUG_LOG(@"Now you are in convertToMp3 method in JiwokMusicConverter class");
	@try{
	
	NSString *toolPath;// = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"FFMPEG"];
	
	toolPath=[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@""];

	
	
	if (![[NSFileManager defaultManager] changeCurrentDirectoryPath:[toolPath stringByDeletingLastPathComponent]])
	{
		[[LoggerClass getInstance] logData:@"convertFromM4AtoMP3-> Failed to set current directory to %@",[toolPath stringByDeletingLastPathComponent]];
	}
	
	NSString *mp3Path = [[filePath stringByDeletingPathExtension]stringByAppendingPathExtension:@"mp3"];
	DUBUG_LOG(@"convertToMp3 toolpath --->>> %@ file path %@ --- wave file path %@",toolPath,filePath,mp3Path);
	
	NSMutableArray *mArray = [[NSMutableArray alloc] init];	
	[mArray addObject:@"-i"];	
	[mArray addObject:filePath];
	[mArray addObject:@"-y"];
	
//	[mArray addObject:@"-ar"];	
//	[mArray addObject:@"11000"];	
		
		
	[mArray addObject:@"-ab"];	
	[mArray addObject:@"16k"];
		
	[mArray addObject:mp3Path];
	 NSLog(@"mArray NSMutableArray==%@",mArray);
	
	task = [[NSTask alloc] init]; 	
	[task setLaunchPath: toolPath];
	[task setArguments: mArray];
	
	NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	[task setStandardError: pipe];
	
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
	
    [task launch];
    [task waitUntilExit];
	
    NSData *data;
    data = [file readDataToEndOfFile];
	}
	
	//return(data);		
//}
@catch (NSException *ex)
{
	[[LoggerClass getInstance] logData:@"Exception occured in convertToMp3 %@",[ex description]];
}
@finally 
{
	
}


DUBUG_LOG(@"Now you are completed convertToMp3 method in JiwokMusicConverter class");

}



@end
