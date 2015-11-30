//
//  logClass.m
//  Jiwok_Coredata_Trial
//
//  Created by reubro R on 02/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "LoggerClass.h"


@implementation LoggerClass

static LoggerClass *LogFileInstance = nil;


//Gets Shared Instance
+ (LoggerClass *)getInstance {
    // NSLog(@"Now you are in getInstance  method in LoggerClass class");
	if (LogFileInstance == nil) {
		
        LogFileInstance = [[super allocWithZone:NULL] init];
		
    }	
    return LogFileInstance;
     //NSLog(@"Now you are completed getInstance  method in LoggerClass class");
}



+ (id)allocWithZone:(NSZone *)zone

{
	 //NSLog(@"Now you are in allocWithZone method in LoggerClass class");
    return [[self getInstance] retain];
	//NSLog(@"Now you are completed allocWithZone method in LoggerClass class");
}

- (id) retain { 
	//NSLog(@"Now you are in retain method in LoggerClass class");
	return self;
    //NSLog(@"Now you are completed retain method in LoggerClass class");
}

- (id)copyWithZone:(NSZone *)zone {
	//////NSLog(@"Now you are in copyWithZone method in LoggerClass class");
    return self;
	//NSLog(@"Now you are completed copyWithZone method in LoggerClass class");
}
- (id) copy {
	//NSLog(@"Now you are in copy method in LoggerClass class");
	return self;
    //NSLog(@"Now you are completed copy method in LoggerClass class");
}

- (unsigned int) retainCount { 
	//NSLog(@"Now you are in retainCount method in LoggerClass class");
	return UINT_MAX; 
    //NSLog(@"Now you are completed retainCount method in LoggerClass class");
}

- (void) release{ 
}

- (id)autorelease {
    //NSLog(@"Now you are in autorelease method in LoggerClass class");
	return self;
    //NSLog(@"Now you are completed autorelease method in LoggerClass class");
}

//open a file
-(void)Open:(NSString*)inFilePath withAppName:(NSString*)inAppName
{
    //NSLog(@"Now you are in Open method in LoggerClass class");
	NSCalendarDate *calenderDate;
	NSString *initialString,*fileName;
	NSFileHandle *fileHandler;
	
    if(LogFileInstance==nil)
		LogFileInstance = [[LoggerClass alloc] init];
	
	calenderDate=[NSCalendarDate calendarDate];//@"%@/%@-%d-%d-%d.log"
	fileName=[[NSString alloc]initWithFormat:@"%@/%@log.txt",inFilePath,inAppName];//,[calenderDate monthOfYear],[calenderDate dayOfMonth],[calenderDate yearOfCommonEra]];
	NSLog(@"class file is %@" ,fileName);
	if ( ![[NSFileManager defaultManager] fileExistsAtPath: fileName] )
	{
		if([[NSFileManager defaultManager]createFileAtPath:fileName contents:nil attributes:nil]==NO)
		{
			NSLog(@"Couldnot create Log file");
		}
	}
	fileHandler = [NSFileHandle  
				   fileHandleForWritingAtPath:fileName];
	[fileHandler truncateFileAtOffset:[fileHandler seekToEndOfFile]];
	
	[fileName release];
	initialString= [NSString stringWithFormat:@"\n\n-----------------Starting New Session: ----------------"];
	[fileHandler writeData:[initialString
							dataUsingEncoding:NSUTF8StringEncoding]];
	[LogFileInstance setFileHandler:fileHandler];
	//NSLog(@"Now you are completed Open method in LoggerClass class");
}

//sets filehandler
-(void)setFileHandler:(NSFileHandle *)inHandler
{
    //NSLog(@"Now you are in setFileHandler inHandler method in LoggerClass class");
	if(mFileHandler !=inHandler)
	{  
		[inHandler retain];
		[mFileHandler release];
		mFileHandler =inHandler;
	}
   // NSLog(@"Now you are completed setFileHandler inHandler method in LoggerClass class");
}

//Return filehandler
-(NSFileHandle*)getFileHandler
{
   // NSLog(@"Now you are in getFileHandler method in LoggerClass class");
	return mFileHandler;
    // NSLog(@"Now you are completed setFileHandler method in LoggerClass class");
}

//Write Data
-(void )logData:(NSString*)format, ...
{
     //NSLog(@"Now you are in logData:(NSString*)format, ... method in LoggerClass class");
	NSString *textString,*writeString;
	NSCalendarDate *calenderDate;
	
	calenderDate=[NSCalendarDate calendarDate];
	va_list		l_argptr;
	va_start(l_argptr,format);
	//textString=[[NSString alloc] initWithFormat:format arguments:l_argptr];
	//NSLog(@"%@",textString); //to send contents to console
    //va_end(l_argptr);
	
	@try {
		
		textString=[[NSString alloc] initWithFormat:format arguments:l_argptr];
		va_end(l_argptr);
		
		NSDate *date=[[NSDate date] retain];
	
	//writeString =[[NSString alloc]initWithFormat:@"\n%@:- \t%@",[[NSDate date]description], textString];
	
		
	writeString =[[NSString alloc]initWithFormat:@"\n%@:- \t%@",[date description], textString];

	[date release];
	[textString release];
	[[LogFileInstance getFileHandler] writeData:[writeString
												 dataUsingEncoding:NSUTF8StringEncoding]];
	
	//@try {
		
		NSLog(@"%@",writeString);

	}
	@catch (NSException * e) {
		
	}
	@finally {
		
	}

	[writeString release];
 //NSLog(@"Now you are completed logData:(NSString*)format, ... method in LoggerClass class");
}


@end
