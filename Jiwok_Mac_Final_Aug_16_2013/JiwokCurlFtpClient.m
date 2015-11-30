//
//  JiwokCurlFtpClient.m
//  Jiwok
//
//  Created by Reubro on 05/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokCurlFtpClient.h"
#import "LoggerClass.h"
#import "Common.h"
#import"JiwokUtil.h"

@implementation JiwokCurlFtpClient




- (NSString *)UploadToFTP:(NSString*)Url:(NSString*)Path
{ 
	//NSLog(@"UploadToFTP Url is %@ path is %@",Url,Path);
	
	//	if (Url == nil  || [Url isEqualToString:@""] )
	//{
	//	return nil;
	//}
	//[[LoggerClass getInstance] logData:@"Uploading with URL %@ to local path %@",Url,Path];
	DUBUG_LOG(@"Now you are in UploadToFTP method in JiwokCurlFtpClient class");
	uploadLink=Url;
	uploadfilePath=Path;
	
	NSString * toolPath=@"/usr/bin/curl";	
	
	
	//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
	//toolPath = @"/usr/local/bin/CFFTPSample";	
	//toolPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"CFFTPSample"];
	
	
	
	if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
	{
		[[LoggerClass getInstance] logData:@"UploadToFTP --> File not found %@",toolPath];
		return nil;
	}
	
	NSMutableString *string;
	
	@try
	{
				
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-Y"];	
		[mArray addObject:@"30"];	

		[mArray addObject:@"-T"];	
		[mArray addObject:uploadfilePath];	
		[mArray addObject:uploadLink];	
		
		task = [[NSTask alloc] init]; 
		[task setLaunchPath:toolPath];
		[task setArguments:mArray];	
		DUBUG_LOG(@"mArray NSMutableArray==%@",mArray);
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
        DUBUG_LOG(@"Now you are completed UploadToFTP method in JiwokCurlFtpClient class");
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch  Exception occured in ListDirectoriesFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		return(string);
		
	}
	
    
}









- (NSMutableArray*)ListDirectoriesFromFTP:(NSString*)DUrl
  {
    
	DUBUG_LOG(@"Now you are in ListDirectoriesFromFTP method in JiwokCurlFtpClient class");
	if (DUrl == nil  || [DUrl isEqualToString:@""] )
	{
		return nil;
	}
	
	[[LoggerClass getInstance] logData:@"ListDirectoriesFromFTP --> list from FTP path %@",DUrl];
	
	NSString *directoryUrl1;
	
	directoryUrl1=DUrl;
	
	
	//director​yUrl=@​"ftp:​//jiwok-wb​dd.najman.​lbn.fr/spe​cificsongs​/AMSupersp​eed/"​;
	
	NSMutableArray * retArray  = [NSMutableArray array];
	
	
	@try
	{
		//NSMutableArray * retArray  = [NSMutableArray array];
		NSString * toolPath=@"/usr/bin/curl";	
		// toolPath = @"/usr/local/bin/CFFTPSample";
		//toolPath =@"/Jiwok/CFFTPSample";
		//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		//toolPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"CFFTPSample"];
		
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"ListDirectoriesFromFTP --> File not found %@",toolPath];
			return nil;
		}
				
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		
		[mArray addObject:@"-Y"];	
		[mArray addObject:@"1024"];
		[mArray addObject:@"-y"];	
		[mArray addObject:@"10"];
		
//		[mArray addObject:@"-Y"];	
//		[mArray addObject:@"30"];
		[mArray addObject:@"-l"];
		
		
		//[mArray addObject:@"--list-only"];
		
		[mArray addObject:directoryUrl1];	
		[mArray addObject:@"--user"];
		[mArray addObject:[NSString stringWithFormat:@"%@:%@",JIWOK_USERNAME,JIWOK_PWD]];	
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
		
		//NSString *fileContents =  [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding]; 
		
		
		NSString *fileContents =  [[NSString alloc] initWithData:data1 encoding:NSASCIIStringEncoding]; 

		
		//NSLog(@"file content isisisisii %@",fileContents);
		
		
		if (fileContents)
		{
			
		}
		//NSString *fileContents = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: nil];
		NSArray *components = [fileContents componentsSeparatedByString:@"\n"];
		//NSLog(@"components are %@",components);
		NSArray *fields;
		
		
		
		//for(int i=0;i<[components count];i++)		
//			[retArray addObject:[components objectAtIndex:i]];
//		
		
		
		for (NSString *line in components)
		{
			if ([line isEqualToString:@""] || [line isEqual:nil])
			{
				continue;
			}
			
						
			fields = [line componentsSeparatedByString:@" "];			
			
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
					}
				}				
				nIndex++;
			}
		}
        DUBUG_LOG(@"Now you are completed ListDirectoriesFromFTP method in JiwokCurlFtpClient class");
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch  Exception occured in ListDirectoriesFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		DUBUG_LOG(@"ListDirectoriesFromFTP is return array isiis %@  INPUT %@",retArray,directoryUrl1);
		return retArray;
	}
	
}









//- (NSString *)DownloadFromFTP:(NSString*)Url:(NSString*)Path

- (NSString *)DownloadFromFTP:(NSArray*)input 

{ 
    DUBUG_LOG(@"Now you are in DownloadFromFTP method in JiwokCurlFtpClient class");
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	
	//if (Url == nil  || [Url isEqualToString:@""] )
		if ([input count]<2)
	{
		return nil;
	}
	
	
	downloadLink=[input objectAtIndex:0];
	destinationPath=[input objectAtIndex:1];
	
	

	NSLog(@"XXXXXXXXXXXXXXX downloadLink %@ XXXXXXXXXXXXXXXXXX",downloadLink);
	
	
	
	NSMutableString *string;
	
	@try
	{
		
		if (![[NSFileManager defaultManager] changeCurrentDirectoryPath:[destinationPath stringByDeletingLastPathComponent]])
		{
			[[LoggerClass getInstance] logData:@"Failed to set current directory to %@",[destinationPath stringByDeletingLastPathComponent]];
		}
		
		
		downloadLink=[downloadLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		destinationPath=[destinationPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		
		NSString * toolPath=@"/usr/bin/curl";	
		//toolPath = @"/usr/local/bin/CFFTPSample";		
		//toolPath =@"/Jiwok/CFFTPSample";
		//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		//toolPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"CFFTPSample"];
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"DownloadFromFTP --> File not found %@",toolPath];
			return nil;
		}
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-Y"];	
		[mArray addObject:@"1024"];
		[mArray addObject:@"-y"];	
		[mArray addObject:@"10"];
		[mArray addObject:@"--ftp-pasv"];	
		[mArray addObject:downloadLink];	
		[mArray addObject:@"--user"];
		[mArray addObject:[NSString stringWithFormat:@"%@:%@",JIWOK_USERNAME,JIWOK_PWD]];	
		[mArray addObject:@"-o"];	
		[mArray addObject:[downloadLink lastPathComponent]];
		
		//[mArray addObject:destinationPath];

		 
		//NSLog(@"mArray %@",mArray);
		
		task = [[NSTask alloc] init]; 
		[task setLaunchPath: toolPath];
		[task setArguments: mArray];	
		
		NSLog(@"mArray NSMutableArray==%@",mArray);
		
		NSPipe *pipe;
		pipe = [NSPipe pipe];
		[task setStandardOutput: pipe];
		[task setStandardError: pipe];
		
		[mArray release];
		
		NSFileHandle *file;
		file = [pipe fileHandleForReading];
		
		[task launch];
		
		// Hangs the app for indefinite time		
		//[task waitUntilExit];
		
		NSData *data;
		data = [file readDataToEndOfFile];
		
		// NSMutableString *string;
		string = [[NSMutableString alloc] initWithData: data encoding: NSASCIIStringEncoding];		
		
		//DUBUG_LOG(@"FTP-> Download result is downloadLink %@ %@",downloadLink,[string substringFromIndex:([string length]-10)]);
		
		DUBUG_LOG(@"FTP-> Download result is downloadLink %@ %@",downloadLink,string);
        DUBUG_LOG(@"Now you are completed DownloadFromFTP method in JiwokCurlFtpClient class");


	}
	
	@catch (NSException *ex) {
		
		DUBUG_LOG(@"@catch  Exception occured in DownloadFromFTP   %@",[ex description]);
		
	}
	@finally {
		
		return(string);
		
		[pool release];
	}
		
} 




- (NSString *)DownloadFromFTP:(NSString*)Url:(NSString*)Path
{ 
    DUBUG_LOG(@"Now you are in DownloadFromFTP method in JiwokCurlFtpClient class");
	if (Url == nil  || [Url isEqualToString:@""] )
	//if ([input count]<2)
	{
		return nil;
	}
	[[LoggerClass getInstance] logData:@"Downloading with URL %@ to local path %@ DownloadFromFTP using path",Url,Path];
	
	
	downloadLink=Url;
	destinationPath=Path;
		
	
	//downloadLink=[input objectAtIndex:0];
//	destinationPath=[input objectAtIndex:1];
//	
	
	NSMutableString *string;
	
	@try
	{
		if (![[NSFileManager defaultManager] changeCurrentDirectoryPath:[destinationPath stringByDeletingLastPathComponent]])
		{
			[[LoggerClass getInstance] logData:@"Failed to set current directory to %@",[destinationPath stringByDeletingLastPathComponent]];
		}
		
		
		NSString * toolPath=@"/usr/bin/curl";	
		//toolPath = @"/usr/local/bin/CFFTPSample";		
		//toolPath =@"/Jiwok/CFFTPSample";
		//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		//toolPath = [[bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"CFFTPSample"];
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"DownloadFromFTP --> File not found %@",toolPath];
			return nil;
		}
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-Y"];	
		[mArray addObject:@"4096"];
		[mArray addObject:@"-y"];	
		[mArray addObject:@"10"];
		[mArray addObject:@"--ftp-pasv"];	
		
		//[mArray addObject:@"--ftp-ssl"];
		
		[mArray addObject:downloadLink];	
		[mArray addObject:@"--user"];
		[mArray addObject:[NSString stringWithFormat:@"%@:%@",JIWOK_USERNAME,JIWOK_PWD]];	
		[mArray addObject:@"-o"];	
		[mArray addObject:[downloadLink lastPathComponent]];
		
		
		
		
		task = [[NSTask alloc] init]; 
		[task setLaunchPath: toolPath];
		[task setArguments: mArray];	
		NSLog(@"mArray NSMutableArray==%@",mArray);
		[mArray release];

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
		
		DUBUG_LOG(@"FTP-> Download result is downloadLink %@ %@",downloadLink,[string substringFromIndex:([string length]-10)]);
        DUBUG_LOG(@"Now you are completed DownloadFromFTP method in JiwokCurlFtpClient class");
	}
	
	@catch (NSException *ex) {
		
		DUBUG_LOG(@"@catch  Exception occured in DownloadFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		return(string);
	}
	 
	
} 










- (NSString *)CreateDirectory:(NSString*)Path
{ 
    DUBUG_LOG(@"Now you are in CreateDirectory method in JiwokCurlFtpClient class");
	if (Path == nil  || [Path isEqualToString:@""] )
	{
		return nil;
	}
	[[LoggerClass getInstance] logData:@"Creating with path %@",Path];
	
		
	NSMutableString *string;
	
	@try
	{
			
		
		NSString * toolPath=@"/usr/bin/curl";	
		
		
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: toolPath] )
		{
			[[LoggerClass getInstance] logData:@"DownloadFromFTP --> File not found %@",toolPath];
			return nil;
		}
		
		NSMutableArray *mArray = [[NSMutableArray alloc] init];
		[mArray addObject:@"-Y"];	
		[mArray addObject:@"30"];	
		[mArray addObject:@"--ftp-create-dirs"];	
		[mArray addObject:Path];
		
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
        DUBUG_LOG(@"Now you are completed CreateDirectory method in JiwokCurlFtpClient class");
	}
	
	@catch (NSException *ex) {
		
		DUBUG_LOG(@"@catch  Exception occured in DownloadFromFTP  %@",[ex description]);
		
	}
	@finally {
		
		return(string);
	}
	 
	
} 









@end
