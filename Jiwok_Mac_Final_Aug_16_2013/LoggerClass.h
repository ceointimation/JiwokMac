//
//  logClass.h
//  Jiwok_Coredata_Trial
//
//  Created by reubro R on 02/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoggerClass : NSObject {
	
	NSFileHandle *mFileHandler;

}
//Gets Shared Instance
+ (LoggerClass *)getInstance;

//open a file
-(void)Open:(NSString*)inFilePath withAppName:(NSString*)inAppName;

//sets filehandler
-(void)setFileHandler:(NSFileHandle *)inHandler;

//Return filehandler
-(NSFileHandle*)getFileHandler;

//Write Data
-(void )logData:(NSString*)format, ...;
@end
