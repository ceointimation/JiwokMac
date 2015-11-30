//
//  JiwokID3TagReader.m
//  Sox Wrap
//
//  Created by APPLE on 29/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokID3TagReader.h"
#import "Common.h"
#import "LoggerClass.h"

@implementation JiwokID3TagReader


-(NSMutableDictionary*)getID3TagInfo:(NSString *)filePath
{

	NSString * toolPath;	
	toolPath = @"/usr/local/bin/id3v2";		
	
	//NSString *localfilename = [NSString stringWithFormat:@"'%@'", filePath];

	if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
	{
		[[LoggerClass getInstance] logData:@"getID3TagInfo --> File not found %@",toolPath];
		return nil;
	}
	
	NSString *localfilename = filePath;

	NSMutableArray *mArray = [[NSMutableArray alloc] init];	
	[mArray addObject:@"-l"];	
	[mArray addObject:localfilename];
	
	task = [[NSTask alloc] init]; 	
	[task setLaunchPath: toolPath];
	[task setArguments: mArray];
	
	NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
	
    [task launch];
    [task waitUntilExit];
	
    NSData *data;
    data = [file readDataToEndOfFile];
	
    NSMutableString *string;
    string = [[NSMutableString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	[mArray release];
	[task release];
	
	NSString * list=[string stringByReplacingOccurrencesOfString:@"                                 " withString:@"NIL "];		
	NSArray *listItems = [list componentsSeparatedByString:@"\n"];		
			
	NSMutableArray * retArray  = [NSMutableArray array];	
	
	for (NSString *line in listItems)
	{
		if ([line isEqualToString:@""] || [line isEqual:nil])
		{
			continue;
		}
		NSArray *fields = [line componentsSeparatedByString:@"             "];		
		
		int fieldCount = [fields count];
		int nIndex = 0;
		for (NSString *field in fields) 
		{
			if (nIndex == (fieldCount - 1))// last
			{ 
				NSRange range = [field rangeOfString:@"id3v1"];
				
				
				if (range.length <= 0)
				{
					[retArray addObject:field]; 
				}
			}
			nIndex++;
		}
	}
		
	
	//NSLog(@"Input file path is>%@",filePath);
	
	NSMutableDictionary *RetrievedTags=[[NSMutableDictionary alloc]init];	
	int k=0;
	for ( k=1;k<[retArray count];k++)
	{
		NSArray *TRY=[[retArray objectAtIndex:k] componentsSeparatedByString:@":"];
		
		if([TRY count]>1)
			
		{
			NSString *firstString=[[TRY objectAtIndex:0] substringToIndex:4];
			
			NSString *secondString=[TRY objectAtIndex:1];
			
			//NSLog(@"F-is>%@---S-is>%@",firstString, secondString);
			
			[RetrievedTags setObject:secondString forKey:firstString];
			
		
		}		
	}
	// set file name
	[RetrievedTags setObject:[filePath lastPathComponent] forKey:ID3_TAG_FILENAME];
	return [RetrievedTags autorelease];
	
}



@end
