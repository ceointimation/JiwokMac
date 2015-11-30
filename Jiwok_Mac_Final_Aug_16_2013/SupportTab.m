//
//  SupportTab.m
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 16/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SupportTab.h"
#import "JiwokFTPDownloader.h"
#import "GetSupportMailDetailsXmlParser.h"
//#import "S7FTPRequest.h"
#import "JiwokCurlFtpClient.h"
#import "JiwokAppDelegate.h"
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "Common.h"
#import "LoggerClass.h"



@implementation SupportTab


-(void)parseMailDetails:(NSString*)ticketNo{
	DUBUG_LOG(@"Now you are in parseMailDetails method in SupportTab class");
	ticketKey=ticketNo;	
			
	NSString *post =@"http://www.jiwok.com/webservices/GetMailDetails.php";
	NSURL *url = [NSURL URLWithString:post];
	NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	GetSupportMailDetailsXmlParser *getSupportMailParser = [[GetSupportMailDetailsXmlParser alloc] init];
	
	mailDetailsArrary = [getSupportMailParser startDataParsing:data];
	[getSupportMailParser release];
	
	[self CreateFtpDirectory:ticketKey];	
	[self uploadToFtp];		
	[self sendSupportMail];
	DUBUG_LOG(@"Now you are completed parseMailDetails method in SupportTab class");
}

- (NSAttributedString *)attributedStringWithLink:(NSString *)link:(NSString *)text {
   DUBUG_LOG(@"Now you are in attributedStringWithLink method in SupportTab class");
	NSDictionary *attrsDict;
	attrsDict = [NSDictionary dictionaryWithObject:link
											forKey:NSLinkAttributeName];
	return[[[NSAttributedString alloc] initWithString:text
										   attributes:attrsDict] autorelease];
    NSLog(@"attrsDict NSDictionary==%@",attrsDict);
     DUBUG_LOG(@"Now you are completed attributedStringWithLink method in SupportTab class");
}



- (NSMutableDictionary*)GetSystemInfo
{ 	
	DUBUG_LOG(@"Now you are in GetSystemInfo method in SupportTab class");
	NSString * toolPath;	
	toolPath = @"/usr/sbin/system_profiler";
	
	NSMutableArray *mArray = [[NSMutableArray alloc] init];
	[mArray addObject:@"-detailLevel"];	
	[mArray addObject:@"mini"];	
			
	task = [[NSTask alloc] init]; 	
	[task setLaunchPath: toolPath];
	[task setArguments: mArray];	
	NSLog(@"mArray NSArray==%@",mArray);
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
	
    NSMutableString *string;
    string = [[NSMutableString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		
	////NSLog(@"string string is %@",string);
	
	NSArray *pathArray=[string componentsSeparatedByString:@"\n"];
	
	NSMutableArray *pathArrayM=[[NSMutableArray alloc]init];	
	[pathArrayM addObjectsFromArray:pathArray];	
		
	profileDictionary=[[[NSMutableDictionary alloc]init] autorelease];
		
	for (NSString *line in pathArray)
	{
		if ([line isEqualToString:@""] || [line isEqual:nil])
		{
			continue;
		}
		NSArray *fields = [line componentsSeparatedByString:@":"];
		NSLog(@"fields NSArray==%@",fields);		
		if([fields count]>1)
		{
			[profileDictionary setObject:[fields objectAtIndex:1] forKey:[fields objectAtIndex:0]];
		NSLog(@"profileDictionary NSMutableDictionary==%@",profileDictionary);
		
		}			 
		 
	}
	
	//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];	
//	NSString *installationPath=[bundlePath stringByDeletingLastPathComponent];
//	
//	
//	NSString *msgbody=[NSString stringWithFormat:@"######################## User Info ######################### User Email :username ########################### User details ######################## ######################## Software Info ######################### Version :1.2.5 Installation Date :31/05/2010 22:36:34 Installated Location :%@ ########################### Software Info ######################## ##################### System Info ######################### CPU :%@ Speed:%@  No. of processors :%@ Total Number Of Cores:%@ Memory :%@ Monitor resolution :%@ System Version :%@  System Directory : Username : User Domain Name : ######################## System Info ########################### ######################## Antivirus Info ######################### Antivirus Installation status:False ########################### Antivirus ######################## ######################## Comments ######################### AT00001172 ########################### Comments ######################## Jiwok_Maclog.txt Download TAGOfflineDB.db Download",installationPath,[profileDictionary objectForKey:@"      Processor Name"],[profileDictionary objectForKey:@"      Processor Speed"],[profileDictionary objectForKey:@"      Number Of Processors"],[profileDictionary objectForKey:@"      Total Number Of Cores"],[profileDictionary objectForKey:@"      Memory"],[profileDictionary objectForKey:@"          Resolution"],[profileDictionary objectForKey:@"      System Version"]];
//	
    DUBUG_LOG(@"Now you are completed GetSystemInfo method in SupportTab class");
	return(profileDictionary);
	 
} 



-(void)CreateFtpDirectory:(NSString*)ticketNo{	
	 DUBUG_LOG(@"Now you are in CreateFtpDirectory method in SupportTab class");
	//NSLog(@"CreateFtpDirectory CreateFtpDirectory");
	
	//ticketKey=ticketNo;
	
	//NSURL *url=[NSURL URLWithString:@"ftp://jiwok_com:Thaezae7@ftp.jiwok-wbdd.najman.lbn.fr/www.jiwok.com/uploads/public/tickets/Jiwok_Mac/"];
	
	
	//NSURL *url=[NSURL URLWithString:@"ftp://jiwok_upload:zYdtGDHFZu@ftp.jiwok-wbdd.najman.lbn.fr/tickets/Jiwok_Mac/"];

	
	
	uploadLink=[NSString stringWithFormat:@"ftp://jiwok_upload:zYdtGDHFZu@ftp.jiwok-wbdd.najman.lbn.fr/tickets/Jiwok_Mac/%@/",ticketNo];
	
	//ftpRequest=[[S7FTPRequest alloc]initWithURL:url toCreateDirectory:ticketKey];
	//[ftpRequest startRequest];
	
	
	
	JiwokCurlFtpClient *ftpCreator=[[JiwokCurlFtpClient alloc]init];	
	NSString* result=[ftpCreator CreateDirectory:uploadLink];		
	
	DUBUG_LOG(@"CreateDirectory CreateDirectory result  %@  ",result);
	
	[ftpCreator release];	
    DUBUG_LOG(@"Now you are completed CreateFtpDirectory method in SupportTab class");
}


-(void)uploadToFtp{

	DUBUG_LOG(@"Now you are in uploadToFtp method in SupportTab class");
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	
	NSString *dbPath=[bundlePath stringByAppendingPathComponent:@"TAGOfflineDB.sqlite"];
	NSString *logPath=[bundlePath stringByAppendingPathComponent:@"Jiwok_Maclog.txt"];
	
	JiwokCurlFtpClient *ftpUploader=[[JiwokCurlFtpClient alloc]init];	
	NSString* result=[ftpUploader UploadToFTP:uploadLink:dbPath];	
	NSString *result1=[ftpUploader UploadToFTP:uploadLink:logPath];
 
 
	NSLog(@"uploadToFtp uploadToFtp results are %@  and \n/n%@",result,result1);
	
	[ftpUploader release];
   DUBUG_LOG(@"Now you are completed uploadToFtp method in SupportTab class");
}

-(void)sendSupportMail{
    DUBUG_LOG(@"Now you are in sendSupportMail method in SupportTab class");
    CTCoreMessage *msg = [[CTCoreMessage alloc] init];
    
    //NSString *toValue1=@"darsang@gmail.com";
    
    NSString *toValue=[[mailDetailsArrary objectAtIndex:0] objectForKey:@"from"];
    NSString *toValue1=[toValue substringToIndex:([toValue length]-2)];
    
    
    CTCoreAddress *toAddr = [CTCoreAddress address];
    [toAddr setEmail:toValue1];
    [msg setTo:[NSSet setWithObject:toAddr]];
    
    NSString *fromValue=[[mailDetailsArrary objectAtIndex:0] objectForKey:@"from"];
    NSString *fromValue1=[fromValue substringToIndex:([fromValue length]-2)];
    CTCoreAddress *fromAddr = [CTCoreAddress address];
    [fromAddr setEmail:fromValue1];
    [msg setFrom:[NSSet setWithObject:fromAddr]];
    
    NSMutableDictionary *profileDictionary1= [self GetSystemInfo];
    NSLog(@"profileDictionary1 NSMutableDictionary==%@",profileDictionary1);
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *installationPath=[bundlePath stringByDeletingLastPathComponent];
    
    JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
    NSString *userEmail=appdelegate.loggedusername;
    
    NSString *version,*installationDate;
    NSArray *appInfo=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] getApplicationDetails];
    NSLog(@"appInfo NSArray==%@",appInfo);
    if([appInfo count]>0)
    {
        version=[[appInfo objectAtIndex:0] objectForKey:@"CurrentVersion"];
        installationDate=[[appInfo objectAtIndex:0] objectForKey:@"DownloadDate"];
    }
    
    
    NSString *logLink=[NSString stringWithFormat:@"http://www.jiwok.com/uploads/public/tickets/Jiwok_Mac/%@/Jiwok_Maclog.txt",ticketKey];
    NSString *dbLink=[NSString stringWithFormat:@"http://www.jiwok.com/uploads/public/tickets/Jiwok_Mac/%@/TAGOfflineDB.sqlite",ticketKey];
    
    
    logLink=[logLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dbLink=[dbLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    
    NSString *user=NSUserName();
    NSString *user1=NSFullUserName();
    NSString *msgbody=[NSString stringWithFormat:@"######################## User Info ######################### User Email :%@ ########################### User details ######################## ######################## Software Info ######################### Version :%@ Installation Date :%@  Installated Location :%@ ########################### Software Info ######################## ##################### System Info ######################### CPU :%@ Speed:%@  No. of processors :%@ Total Number Of Cores:%@  Memory :%@ Monitor resolution :%@ System Version :%@  System Directory :/System  Username :%@ User Domain Name :%@ ######################## System Info ########################### ######################## Antivirus Info ######################### Antivirus Installation status:False ########################### Antivirus ######################## ######################## Comments ######################### %@ ########################### Comments ######################## \n Jiwok_Maclog.txt(%@) \n TAGOfflineDB.sqlite(%@)",userEmail,version,installationDate,installationPath,[profileDictionary1 objectForKey:@"      Processor Name"],[profileDictionary1 objectForKey:@"      Processor Speed"],[profileDictionary objectForKey:@"      Number Of Processors"],[profileDictionary1 objectForKey:@"      Total Number Of Cores"],[profileDictionary1 objectForKey:@"      Memory"],[profileDictionary objectForKey:@"          Resolution"],[profileDictionary1 objectForKey:@"      System Version"],user,user1,ticketKey,logLink,dbLink];
    
    NSLog(@"msgbody NSString==%@",msgbody);
    //	NSString *msgbody=[NSString stringWithFormat:@"######################## User Info ######################### User Email : ########################### User details ######################## ######################## Software Info ######################### Version : Installation Date :  Installated Location :%@ ########################### Software Info ######################## ##################### System Info ######################### CPU :%@ Speed:%@  No. of processors :%@ Total Number Of Cores:%@  Memory :%@ Monitor resolution :%@ System Version :%@  System Directory :C:\Windows\system32 Username :Les Petits Cailloux User Domain Name : ######################## System Info ########################### ######################## Antivirus Info ######################### Antivirus Installation status:False ########################### Antivirus ######################## ######################## Comments ######################### AT00001172 ########################### Comments ######################## Log.txt Download TAGOfflineDB.sqlite <a rel=\"nofollow\" href =\"/http://www.jiwok.com/uploads/public/tickets/AT00001172/log.txt\">Download</a>",installationPath,[profileDictionary objectForKey:@"      Processor Name"],[profileDictionary objectForKey:@"      Processor Speed"],[profileDictionary objectForKey:@"      Number Of Processors"],[profileDictionary objectForKey:@"      Total Number Of Cores"],[profileDictionary objectForKey:@"      Memory"],[profileDictionary objectForKey:@"          Resolution"],[profileDictionary objectForKey:@"      System Version"]];
    
    
    /*
     NSString *msgbody=[NSString stringWithFormat:@"######################## User Info ######################### User Email :1fanny@voila.fr ########################### User details ######################## ######################## Software Info ######################### Version :1.2.5 Installation Date :31/05/2010 22:36:34 Installated Location :%@ ########################### Software Info ######################## ##################### System Info ######################### CPU :%@ Speed:%@  No. of processors :%@ Total Number Of Cores:%@  Memory :%@ Monitor resolution :%@ System Version :%@  System Directory :C:\Windows\system32 Username :Les Petits Cailloux User Domain Name :Spiron ######################## System Info ########################### ######################## Antivirus Info ######################### Antivirus Installation status:False ########################### Antivirus ######################## ######################## Comments ######################### AT00001172 ########################### Comments ######################## Log.txt %@ TAGOfflineDB.db <a href =\"/http://www.jiwok.com/uploads/public/tickets/AT00001172/log.txt\">Download</a>",installationPath,[profileDictionary objectForKey:@"      Processor Name"],[profileDictionary objectForKey:@"      Processor Speed"],[profileDictionary objectForKey:@"      Number Of Processors"],[profileDictionary objectForKey:@"      Total Number Of Cores"],[profileDictionary objectForKey:@"      Memory"],[profileDictionary objectForKey:@"          Resolution"],[profileDictionary objectForKey:@"      System Version"],linkStr];
     
     */
    
    
    ////NSLog(@"msgbody msgbody is %@",msgbody);
    
    NSString *msgBody=[[NSString alloc]initWithString:msgbody];
    
    [msg setBody:msgBody];
    [msg setSubject:ticketKey];
    
    NSString *server1=[[mailDetailsArrary objectAtIndex:0] objectForKey:@"host"];
    NSString *username1=[[mailDetailsArrary objectAtIndex:0] objectForKey:@"username"];
    NSString *password1=[[mailDetailsArrary objectAtIndex:0] objectForKey:@"password"];
    NSString *port1=[[mailDetailsArrary objectAtIndex:0] objectForKey:@"port"];
    
    NSString *server=[server1 substringToIndex:([server1 length]-2)];
    NSString *username=[username1 substringToIndex:([username1 length]-2)];
    NSString *password=[password1 substringToIndex:([password1 length]-2)];
    NSString *port=[port1 substringToIndex:([port1 length]-1)];
    
    BOOL auth = YES;
    BOOL tls = YES;
    [CTSMTPConnection sendMessage:msg server:server username:username 
                         password:password port:[port intValue] useTLS:tls useAuth:auth];
    [msg release];
    DUBUG_LOG(@"Now you are completed sendSupportMail method in SupportTab class");
}





- (void)dealloc {
    [super dealloc];
	[ftpRequest release];
}







@end
