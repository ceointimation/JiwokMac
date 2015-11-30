//
//  BpmCalculator.m
//  Jiwok
//
//  Created by APPLE on 04/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BpmCalculator.h"
#import "LoggerClass.h"


@implementation BpmCalculator
-(NSString*)GetBpm:(NSString*)fileName{
 
    
	NSLog(@"Now you are in GetBpm method in BpmCalculator class");
	DUBUG_LOG(@"GetBpm 1111");
	
	NSString * toolPath;	
	//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	//toolPath = [bundlePath  stringByAppendingPathComponent:@"soundstretch"];
	toolPath=[[NSBundle mainBundle] pathForResource:@"bpmdetect" ofType:@""];
	
	
	if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
	{
		[[LoggerClass getInstance] logData:@"GetBpm --> File not found %@",toolPath];
		return nil;
	}
	
	NSString *filename = fileName;		
	
	NSMutableArray *mArray = [[NSMutableArray alloc] init];	
	//[mArray addObject:filename];
	//[mArray addObject:@"-m schmitt  -i /Music1/02 five (mp3) {tre123wor}Faithtmp.wav"];	
	
	//[mArray addObject:@"-s"];
	[mArray addObject:@"-d"];
	[mArray addObject:@"-p"];
	[mArray addObject:filename];	
     NSLog(@"mArray==%@",mArray);
	
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
    //[task waitUntilExit];	

	
    NSData *data;
    data = [file readDataToEndOfFile];
	
    NSMutableString *string;
    string = [[NSMutableString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	[mArray release];
	[task release];
				
	NSArray *listItems = [string componentsSeparatedByString:@" "];		
	
	[string release];
	
	
	NSString *bpmString;
	
	if([listItems count]>0)
		bpmString=[listItems objectAtIndex:0];
	else {
		bpmString=@"0";
	}
		
	DUBUG_LOG(@"String String is %@  listItems is %@ data is %@",bpmString,listItems,data);
    
    DUBUG_LOG(@"Now you are completed GetBpm method in BpmCalculator class");
	
	return(bpmString);
	 
}


@end
