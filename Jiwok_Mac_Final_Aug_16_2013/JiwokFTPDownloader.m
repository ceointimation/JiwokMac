//
//  JiwokFTPDownloader.m
//  Jiwok
//
//  Created by reubro R on 12/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokFTPDownloader.h"
#import "LoggerClass.h"
#import "Common.h"
#import"JiwokUtil.h"

@implementation JiwokFTPDownloader

- (NSString *)DownloadFromFTP:(NSString*)Url:(NSString*)Path
{ 
    DUBUG_LOG(@"Now you are in DownloadFromFTP method in JiwokFTPDownloader class");
	if (Url == nil  || [Url isEqualToString:@""] )
	{
		return nil;
	}
	[[LoggerClass getInstance] logData:@"Downloading with URL %@ to local path %@",Url,Path];
	
	downloadLink=Url;
	destinationPath=Path;
	
	NSMutableString *string;
	
	@try
	{
		if (![[NSFileManager defaultManager] changeCurrentDirectoryPath:[Path stringByDeletingLastPathComponent]])
		{
			[[LoggerClass getInstance] logData:@"Failed to set current directory to %@",[Path stringByDeletingLastPathComponent]];
		}
		
		
		NSString * toolPath;	
		//toolPath = @"/usr/local/bin/CFFTPSample";
		
		//toolPath =@"/Jiwok/CFFTPSample";
		//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		
		toolPath=[[NSBundle mainBundle] pathForResource:@"CFFTPSample" ofType:@""];

		
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"DownloadFromFTP --> File not found %@",toolPath];
			return nil;
		}
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-d"];	
		[mArray addObject:downloadLink];
		[mArray addObject:JIWOK_USERNAME];	
		[mArray addObject:JIWOK_PWD];	
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
		
		// NSMutableString *string;
		string = [[NSMutableString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        DUBUG_LOG(@"Now you are completed DownloadFromFTP method in JiwokFTPDownloader class");
	}
	
	@catch (NSException *ex) {
		
		DUBUG_LOG(@"@catch  Exception occured in DownloadFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		return(string);
	}
	
	
} 

- (NSMutableArray*)ListDirectoriesFromFTP:(NSString*)DUrl{
	DUBUG_LOG(@"Now you are in ListDirectoriesFromFTP method in JiwokFTPDownloader class");
	if (DUrl == nil  || [DUrl isEqualToString:@""] )
	{
		return nil;
	}
	
	[[LoggerClass getInstance] logData:@"ListDirectoriesFromFTP --> list from FTP path %@",DUrl];
	
	directoryUrl=DUrl;
	
	
	//director​yUrl=@​"ftp:​//jiwok-wb​dd.najman.​lbn.fr/spe​cificsongs​/AMSupersp​eed/"​;
	
	NSMutableArray * retArray  = [NSMutableArray array];
	
	
	@try
	{
		//NSMutableArray * retArray  = [NSMutableArray array];
		NSString * toolPath;	
		// toolPath = @"/usr/local/bin/CFFTPSample";
		//toolPath =@"/Jiwok/CFFTPSample";
		//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
		toolPath=[[NSBundle mainBundle] pathForResource:@"CFFTPSample" ofType:@""];

		
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"ListDirectoriesFromFTP --> File not found %@",toolPath];
			return nil;
		}
		NSMutableArray *mArray = [[NSMutableArray alloc] init];	
		[mArray addObject:@"-l"];	
		[mArray addObject:directoryUrl];	
		[mArray addObject:JIWOK_USERNAME];	
		[mArray addObject:JIWOK_PWD];	
		NSLog(@"mArray NSMutableArray==%@",mArray);
		task = [[NSTask alloc] init]; 
		[task setLaunchPath: toolPath];
		[task setArguments: mArray];
		
		NSString *path = @"/tmp/myFile.txt";
		
		if ( [[NSFileManager defaultManager] fileExistsAtPath: path] )
		{
			[[NSFileManager defaultManager] removeFileAtPath: path handler: nil];
		}
		
		BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath: path contents: nil attributes: nil];
		if ( fileCreated )
		{
			NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: path];
			[task setStandardOutput: fileHandle];
			[task setStandardError:fileHandle ];
		}
		
		[task launch];
		[task waitUntilExit];
		NSData *data1 = [NSData dataWithContentsOfFile:path];
		
		NSString *fileContents =  [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding]; 
		
		
		//NSLog(@"file content isisisisii %@",fileContents);
		
		
		if (fileContents)
		{
			
		}
		//NSString *fileContents = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: nil];
		NSArray *components = [fileContents componentsSeparatedByString:@"\n"];
		//NSLog(@"components are %@",components);
		NSArray *fields;
		
		
		for (NSString *line in components)
		{
			if ([line isEqualToString:@""] || [line isEqual:nil])
			{
				continue;
			}
			
			if([line rangeOfString:@"AM"].location != NSNotFound)  
				
				fields = [line componentsSeparatedByString:@" AM "];
			
			else
				fields = [line componentsSeparatedByString:@" PM "];
			int fieldCount = [fields count];
			int nIndex = 0;
			for (NSString *field in fields) 
			{
				if (nIndex == (fieldCount - 1))// last
					
				{ 
					NSRange range = [field rangeOfString:@"complete"];
					if (range.length <= 0)
					{
						field =[JiwokUtil ReplaceSpecialCharactersInURL:field];
						[retArray addObject:field]; 
						//NSLog(@"Song name added--- >> %@",field);
					}
				}
				
				nIndex++;
			}
		}
        
        DUBUG_LOG(@"Now you are completed ListDirectoriesFromFTP method in JiwokFTPDownloader class");
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch  Exception occured in ListDirectoriesFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		DUBUG_LOG(@"ListDirectoriesFromFTP is return array isiis %@",retArray);
		return retArray;
	}
	
}
- (NSString *)UploadToFTP:(NSString*)Url:(NSString*)Path
{ 
	//NSLog(@"UploadToFTP Url is %@ path is %@",Url,Path);
	
	//	if (Url == nil  || [Url isEqualToString:@""] )
	//{
	//	return nil;
	//}
	//[[LoggerClass getInstance] logData:@"Uploading with URL %@ to local path %@",Url,Path];
	DUBUG_LOG(@"Now you are in UploadToFTP method in JiwokFTPDownloader class");
	uploadLink=Url;
	uploadfilePath=Path;
	
	NSString * toolPath;	
	//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
	//toolPath = @"/usr/local/bin/CFFTPSample";	
	toolPath=[[NSBundle mainBundle] pathForResource:@"CFFTPSample" ofType:@""];

	
	
	if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
	{
		[[LoggerClass getInstance] logData:@"UploadToFTP --> File not found %@",toolPath];
		return nil;
	}
	
	NSMutableString *string;
	
	@try
	{
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-u"];	
		[mArray addObject:uploadLink];	
		[mArray addObject:uploadfilePath];	
		[mArray addObject:JIWOK_USERNAME1];	
		[mArray addObject:JIWOK_PWD1];	
		NSLog(@"mArray NSMutableArray==%@",mArray);
		task = [[NSTask alloc] init]; 
		[task setLaunchPath:toolPath];
		[task setArguments:mArray];	
		
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
		
		//NSMutableString *string;
		string = [[NSMutableString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        DUBUG_LOG(@"Now you are completed UploadToFTP method in JiwokFTPDownloader class");
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch  Exception occured in ListDirectoriesFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		return(string);
		
	}
	
}

@end