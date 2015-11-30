//
//  JiwokMusicSystemDBMgrWrapper.m
//  Jiwok
//
//  Created by reubro.
//  Copyright 2010 Jiwok. All rights reserved.
//

#import "JiwokMusicSystemDBMgrWrapper.h"
#import "Common.h"
#import "LoggerClass.h"


#include <pthread.h>


static JiwokMusicSystemDBMgrWrapper *sharedGlobalWrapper = nil;

@implementation JiwokMusicSystemDBMgrWrapper

-(id)init
{
    NSLog(@"Now you are in init method in JiwokMusicSystemDBMgrWrapper class");
	if(self = [super init])
	{
		[self initDBMgr];
	}
	return self;
    NSLog(@"Now you are completed init method in JiwokMusicSystemDBMgrWrapper class");
}



//	Function	:   initDBMgr
//	Purpose		:	SQLIte
//	Parameter	:	nil
//	Return      :	nil
- (void)initDBMgr
{
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString *theDatabasePath = [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
//	
//	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
//	NSString *theDatabasePath = [bundlePath stringByAppendingPathComponent:JIWOK_DB_NAME];

	//NSString *theDatabasePath = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:JIWOK_DB_NAME];

	NSLog(@"Now you are in initDBMgr method in JiwokMusicSystemDBMgrWrapper class");
	NSString *theDatabasePath = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:JIWOK_DB_NAME];

		
	if(!databaseManager)
	{
		// Opens connection to the specified sqlite database
		databaseManager = [[JiwokDataBaseManager alloc]initDBWithFileName:theDatabasePath];
	}
    NSLog(@"Now you are completed initDBMgr method in JiwokMusicSystemDBMgrWrapper class");
}
//	Function	:   sharedWrapper
//	Purpose		:	return shared wrapper instance
//	Parameter	:	nil
//	Return      :	sharedWrapper
+ (JiwokMusicSystemDBMgrWrapper*)sharedWrapper
{
    NSLog(@"Now you are in (JiwokMusicSystemDBMgrWrapper*)sharedWrapper method in JiwokMusicSystemDBMgrWrapper class");
	static pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
	if (pthread_mutex_lock(&mtx)) {
		DUBUG_LOG(@"lock failed sigh...");
		exit(-1);
	}
	
	//@synchronized(self) 
	//{
        if (sharedGlobalWrapper == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
   // }
	
	if (pthread_mutex_unlock(&mtx) != 0) {
		DUBUG_LOG(@"unlock failed sigh...");
		exit(-1);
	}
	
    return sharedGlobalWrapper;
	 NSLog(@"Now you are completed (JiwokMusicSystemDBMgrWrapper*)sharedWrapper method in JiwokMusicSystemDBMgrWrapper class");
}
+ (id)allocWithZone:(NSZone *)zone
{
	 NSLog(@"Now you are in allocWithZoner method in JiwokMusicSystemDBMgrWrapper class");
	static pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
	if (pthread_mutex_lock(&mtx)) {
		DUBUG_LOG(@"lock failed sigh...");
		exit(-1);
	}
	
	if (sharedGlobalWrapper == nil) 
	{
		sharedGlobalWrapper = [super allocWithZone:zone];
		return sharedGlobalWrapper;  // assignment and return on first allocation
	}
	
	if (pthread_mutex_unlock(&mtx) != 0) {
		DUBUG_LOG(@"unlock failed sigh...");
		exit(-1);
	}
//	
	
   // @synchronized(self) 
	//{
       // if (sharedGlobalWrapper == nil) 
//		{
//            sharedGlobalWrapper = [super allocWithZone:zone];
//            return sharedGlobalWrapper;  // assignment and return on first allocation
//        }
  //  }
    return nil; //on subsequent allocation attempts return nil
     NSLog(@"Now you are completed allocWithZoner method in JiwokMusicSystemDBMgrWrapper class");
}

- (id)copyWithZone:(NSZone *)zone
{
     NSLog(@"Now you are in copyWithZone method in JiwokMusicSystemDBMgrWrapper class");
    return self;
     NSLog(@"Now you are completed copyWithZone method in JiwokMusicSystemDBMgrWrapper class");
}

- (id)retain
{
    NSLog(@"Now you are in retain method in JiwokMusicSystemDBMgrWrapper class");
    return self;
    NSLog(@"Now you are completed retain method in JiwokMusicSystemDBMgrWrapper class");
}

- (unsigned)retainCount
{
     NSLog(@"Now you are in retainCount method in JiwokMusicSystemDBMgrWrapper class");
    return UINT_MAX;  //denotes an object that cannot be released
     NSLog(@"Now you are completed retainCount method in JiwokMusicSystemDBMgrWrapper class");
}

- (void)release
{
     NSLog(@"Now you are in release method in JiwokMusicSystemDBMgrWrapper class");
	if(databaseManager)
	{
		[databaseManager close];
		[databaseManager  release];
		databaseManager = nil;
	}
     NSLog(@"Now you are completed release method in JiwokMusicSystemDBMgrWrapper class");
}

- (id)autorelease
{
     NSLog(@"Now you are in autorelease method in JiwokMusicSystemDBMgrWrapper class");
    return self;
     NSLog(@"Now you are completed autorelease method in JiwokMusicSystemDBMgrWrapper class");
}

- (void) insertSearchSelectedFolders:(NSMutableDictionary *)valuesDict
{	
     NSLog(@"Now you are in insertSearchSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	@try{
	DUBUG_LOG(@"insertSearchSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSString *cmd = @"Insert into SearchSelectedFolders (FolderName,Path,Selected) VALUES (?,?,?)";
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FOLDER_NAME]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_PATH]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_SELECTED]];
	// Execute the insert query with array of values as parameter
        NSLog(@"argsArray NSMutableArray==%@",argsArray);
	[ databaseManager executeNonQuery:cmd arguments:argsArray];
        
        [[LoggerClass getInstance] logData:@"AV// SearchSelectedFolders Inserted into DB"];
	[argsArray release];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"AV// Exception occured in insertSearchSelectedFolders %@",[ex description]];
	}
    NSLog(@"Now you are completed insertSearchSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
DUBUG_LOG(@"End of insertSearchSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
}


- (BOOL) DeleteSearchSelectedFolders: (NSString *)pathtoDelete
{	
	NSLog(@"Now you are in DeleteSearchSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"DeleteSearchSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
	
	BOOL success = NO;
	NSString *sql = [NSString stringWithFormat: @"delete from SearchSelectedFolders where  Path = \"%@\"",pathtoDelete];
	@try{
	success = [databaseManager executeNonQuery:sql arguments:nil];
	//return success;
	
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in DeleteSearchSelectedFolders %@",[ex description]];
	}
	
	@finally {
		return success;
	}
    NSLog(@"Now you are completed DeleteSearchSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"End of DeleteSearchSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
}
- (BOOL) checkSearchSelectedFolderExists: (NSString *)pathtoCheck
{	
	NSLog(@"Now you are in checkSearchSelectedFolderExists method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"checkSearchSelectedFolderExists JiwokMusicSystemDBMgrWrapper //AV");
	
	BOOL bRet = NO;
	NSArray *UserSelectedFoldersArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM SearchSelectedFolders where Path  = \""];
	[sql appendFormat:@"%@",pathtoCheck];
	[sql appendFormat:@"\""];
	@try{
	UserSelectedFoldersArray = [databaseManager executeQuery:sql];
	//	//NSLog(@"databaseManager - >>> %@",databaseManager);
	if ([UserSelectedFoldersArray count] > 0)
	{
		bRet = YES;
	}
	[UserSelectedFoldersArray autorelease];
	//return bRet;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkSearchSelectedFolderExists %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"End of checkSearchSelectedFolderExists JiwokMusicSystemDBMgrWrapper //AV");
		return bRet;
	}
    NSLog(@"Now you are completed checkSearchSelectedFolderExists method in JiwokMusicSystemDBMgrWrapper class");
DUBUG_LOG(@"End of checkSearchSelectedFolderExists JiwokMusicSystemDBMgrWrapper //AV");
}



- (NSArray*) GetallSearchSelectedFolders
{	
    NSLog(@"Now you are in GetallSearchSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *UserSelectedFoldersArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT Path FROM SearchSelectedFolders"];
	NSMutableArray *selectedPaths=[[NSMutableArray alloc]init];	
	
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper  - GetallSearchSelectedFolders sql iszzzzz  %@",sql);	
	@try{
		UserSelectedFoldersArray = [databaseManager executeQuery:sql];	
		
		
		for( int i=0;i<[UserSelectedFoldersArray count];i++)
		{		
			[selectedPaths addObject:[[UserSelectedFoldersArray objectAtIndex:i]objectForKey:@"Path"]];	
		}
		
		//return [selectedPaths autorelease];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in GetallSearchSelectedFolders %@",[ex description]];
	}
	
	@finally { DUBUG_LOG(@"AV// End of JiwokMusicSystemDBMgrWrapper  - GetallSearchSelectedFolders sql iszzzzz  %@",sql);
		return [selectedPaths autorelease];
	}
	 NSLog(@"Now you are completed GetallSearchSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// End of JiwokMusicSystemDBMgrWrapper  - GetallSearchSelectedFolders sql iszzzzz  %@",sql);	
}

- (void) insertUserSelectedFolders:(NSMutableDictionary *)valuesDict
{
	@try{
		 NSLog(@"Now you are in insertUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"//AV insertUserSelectedFolders JiwokMusicSystemDBMgrWrapper");
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSString *cmd = @"Insert into  UserSelectedFolders (FolderName,Path,Selected) VALUES (?,?,?)";
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FOLDER_NAME]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_PATH]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_SELECTED]];
	// Execute the insert query with array of values as parameter
	[ databaseManager executeNonQuery:cmd arguments:argsArray];
         NSLog(@"argsArray NSMutableArray==%@",argsArray);
	[argsArray release];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in insertUserSelectedFolders %@",[ex description]];
	}
    NSLog(@"Now you are completed insertUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"End of insertUserSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
}

- (BOOL) updateUserSelectedFolders:(NSMutableDictionary *)valuesDict
{   
    NSLog(@"Now you are in updateUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"updateUserSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
	
	BOOL success = NO;
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSString *cmd = @"UPDATE UserSelectedFolders SET Selected = ?  WHERE Path = ?";
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_SELECTED]];
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_PATH]];

@try{
	// Execute the update query with array of values as parameter
	[ databaseManager executeNonQuery:cmd arguments:argsArray];
     NSLog(@"argsArray NSMutableArray==%@",argsArray);
	[argsArray release];
	//return success;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in updateUserSelectedFolders %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"End of updateUserSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
		return success;
	}
     NSLog(@"Now you are completed updateUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"End of updateUserSelectedFolders JiwokMusicSystemDBMgrWrapper //AV");
}


-(void)changeSelectionStatusOfUserSelectedFolders:(NSString *)filePath{

     NSLog(@"Now you are in changeSelectionStatusOfUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - changeSelectionStatusOfUserSelectedFolders filePath %@",filePath);
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSString *cmd = [NSString stringWithFormat:@"UPDATE UserSelectedFolders SET Selected ='false' Where Path=\"%@\"",filePath];
	
	
	@try{
		// Execute the update query with array of values as parameter
		[ databaseManager executeNonQuery:cmd arguments:nil];
		[argsArray release];
		//return success;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in changeSelectionStatusOfUserSelectedFolders %@",[ex description]];
	}
	@finally {
		
	}
	
	 NSLog(@"Now you are completed changeSelectionStatusOfUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of changeSelectionStatusOfUserSelectedFolders filePath %@",filePath);
}



- (NSArray*) checkUserSelectedFolderExists: (NSString *)pathtoCheck
{		
	//DUBUG_LOG(@"checkUserSelectedFolderExists pathtoCheck iszzzzz  %@",pathtoCheck);	
	//BOOL bRet = NO;
     NSLog(@"Now you are in checkUserSelectedFolderExists method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *UserSelectedFoldersArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM UserSelectedFolders where Path  = \""];
	[sql appendFormat:@"%@",pathtoCheck];
	[sql appendFormat:@"\""];
	
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - checkUserSelectedFolderExists sql iszzzzz  %@",sql);

	@try{
	UserSelectedFoldersArray = [databaseManager executeQuery:sql];
		
		
	//	//NSLog(@"databaseManager - >>> %@",databaseManager);
	//if ([UserSelectedFoldersArray count] > 0)
//	{
//		bRet = YES;
//	}
	
	//return [UserSelectedFoldersArray autorelease];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkUserSelectedFolderExists %@",[ex description]];
	}
	@finally {
		DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of checkUserSelectedFolderExists sql iszzzzz  %@",sql);
		return [UserSelectedFoldersArray autorelease];

	}
     NSLog(@"Now you are completed checkUserSelectedFolderExists method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of checkUserSelectedFolderExists sql iszzzzz  %@",sql);
}



- (NSArray*) GetallUserSelectedFolders
{	
     NSLog(@"Now you are in GetallUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *UserSelectedFoldersArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT Path FROM UserSelectedFolders"];
	NSMutableArray *selectedPaths=[[NSMutableArray alloc]init];	
	
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - GetallUserSelectedFolders sql iszzzzz  %@",sql);	
	@try{
	UserSelectedFoldersArray = [databaseManager executeQuery:sql];	
	
	
	for( int i=0;i<[UserSelectedFoldersArray count];i++)
	{		
		[selectedPaths addObject:[[UserSelectedFoldersArray objectAtIndex:i]objectForKey:@"Path"]];	
	}
		
	//return [selectedPaths autorelease];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in GetallUserSelectedFolders %@",[ex description]];
	}
	
	@finally {DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of GetallUserSelectedFolders sql iszzzzz  %@",sql);
		return [selectedPaths autorelease];
	}
 NSLog(@"Now you are completed GetallUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of GetallUserSelectedFolders sql iszzzzz  %@",sql);
}


- (NSArray*) checkVolumeForselection: (NSString *)pathtoCheck;
{	
     NSLog(@"Now you are in checkVolumeForselection method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - checkVolumeForselection pathtoCheck iszzzzz  %@",pathtoCheck);
			
	NSString *tmpString;
	tmpString=[NSString stringWithFormat:@"%%%@%%",pathtoCheck];	
	
	NSArray *UserSelectedFoldersArray;	
	
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM UserSelectedFolders where Path  LIKE \""];
	//[sql appendFormat:@"%"];
	[sql appendFormat:@"%@",tmpString];
	//[sql appendFormat:@"%"];
	[sql appendFormat:@"\""];
		@try{
	UserSelectedFoldersArray = [databaseManager executeQuery:sql];	
	DUBUG_LOG(@"checkVolumeForselection sql iszzzzz  %@",tmpString);
		
	//return [UserSelectedFoldersArray autorelease];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkVolumeForselection %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of checkVolumeForselection pathtoCheck iszzzzz  %@",pathtoCheck);
		return [UserSelectedFoldersArray autorelease];
	}
    NSLog(@"Now you are completed checkVolumeForselection method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of checkVolumeForselection pathtoCheck iszzzzz  %@",pathtoCheck);
}

- (BOOL) DeleteUserSelectedFolders: (NSString *)pathtoDelete
{	
	NSLog(@"Now you are in DeleteUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
	BOOL success = NO;
	NSString *sql = [NSString stringWithFormat: @"delete from UserSelectedFolders where  Path LIKE \"%@\"",[NSString stringWithFormat:@"%%%@%%", pathtoDelete]];
	@try{
	success = [databaseManager executeNonQuery:sql arguments:nil];
	
	DUBUG_LOG(@"AV// DeleteUserSelectedFolders  pathtoDelete pathtoDelete is %@   sql >>>>>>>%@ <<<<<<<<<<success is %d",pathtoDelete,sql,success);
	
	//return success;
}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in DeleteUserSelectedFolders %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"AV// End of DeleteUserSelectedFolders");
		return success;
	}
    NSLog(@"Now you are completed DeleteUserSelectedFolders method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// End of DeleteUserSelectedFolders");
}

- (BOOL) isAnyUserFoldersSelected
{	
    NSLog(@"Now you are in isAnyUserFoldersSelected method in JiwokMusicSystemDBMgrWrapper class");
	
    DUBUG_LOG(@"isAnyUserFoldersSelected JiwokMusicSystemDBMgrWrapper //AV");
	
	BOOL bRet = NO;
	NSArray *UserSelectedFoldersArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM UserSelectedFolders"];
	@try{	
	UserSelectedFoldersArray = [databaseManager executeQuery:sql];

	if ([UserSelectedFoldersArray count] > 0)
	{
		bRet = YES;
	}
	[UserSelectedFoldersArray autorelease];
	//return bRet;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in isAnyUserFoldersSelected %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"End of isAnyUserFoldersSelected JiwokMusicSystemDBMgrWrapper //AV");
		return bRet;
	}
	NSLog(@"Now you are completed isAnyUserFoldersSelected method in JiwokMusicSystemDBMgrWrapper class");
    
    DUBUG_LOG(@"End of isAnyUserFoldersSelected JiwokMusicSystemDBMgrWrapper //AV");
}
- (BOOL) checkForMusicFilesTemp: (NSString *)pathtoCheck
{	
    NSLog(@"Now you are in checkForMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
	
    DUBUG_LOG(@"checkForMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
	
	BOOL bRet = NO;
	NSArray *MusicFilesArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM MusicFilesTemp where FilePath  = \""];
	[sql appendFormat:@"%@",pathtoCheck];
	[sql appendFormat:@"\""];
	@try{
	MusicFilesArray = [databaseManager executeQuery:sql];
	//	//NSLog(@"databaseManager - >>> %@",databaseManager);
         NSLog(@"MusicFilesArray NSArray==%@",MusicFilesArray);
	if ([MusicFilesArray count] > 0)
	{
		bRet = YES;
	}
	[MusicFilesArray autorelease];
	//return bRet;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkForMusicFilesTemp %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"checkForMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
		return bRet;
	}
     NSLog(@"Now you are completed checkForMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"checkForMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
}

- (BOOL) checkForMusicFiles: (NSString *)pathtoCheck
{	
     NSLog(@"Now you are in checkForMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	
    DUBUG_LOG(@"checkForMusicFiles JiwokMusicSystemDBMgrWrapper //AV");
	BOOL bRet = NO;
	NSArray *MusicFilesArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM MusicFiles where FilePath  = \""];
	[sql appendFormat:@"%@",pathtoCheck];
	[sql appendFormat:@"\""];
	@try{
	MusicFilesArray = [databaseManager executeQuery:sql];
	//	//NSLog(@"databaseManager - >>> %@",databaseManager);
           NSLog(@"MusicFilesArray NSArray==%@",MusicFilesArray);
	if ([MusicFilesArray count] > 0)
	{
		bRet = YES;
	}
	[MusicFilesArray autorelease];
	//return bRet;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkForMusicFiles %@",[ex description]];
	}
	@finally { DUBUG_LOG(@"End of checkForMusicFiles JiwokMusicSystemDBMgrWrapper //AV");
		return bRet;
	}
     NSLog(@"Now you are completed checkForMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"End of checkForMusicFiles JiwokMusicSystemDBMgrWrapper //AV");
}
- (void) insertOrUpdateMusicFilesTemp:(NSMutableDictionary *)valuesDict
{	
	 NSLog(@"Now you are in insertOrUpdateMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"insertOrUpdateMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	
	NSMutableString *cmd;
	if ([self checkForMusicFilesTemp:[valuesDict objectForKey:DB_KEY_FILEPATH]])
	{
		cmd = [NSMutableString stringWithFormat:@"update MusicFilesTemp set Active = ? ,Album = ? ,Artist = ? , BPM = ? ,Duration = ? , \
			   FileName = ?,FilePath = ?, Genre = ?,JiwokGenre = ? ,Selected = ? ,Title = ?,TrackNo = ? ,Usage = ? where FilePath = ? "];
	}
	else
	{
		cmd = [NSMutableString stringWithFormat:@"Insert into  MusicFilesTemp (Active,Album,Artist,BPM,Duration, \
			   FileName,FilePath,Genre,JiwokGenre,Selected,Title,TrackNo,Usage) \
			   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"];
	}
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ACTIVE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ALBUM]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ARTIST]];
	
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_BPM]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_DURATION]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILENAME]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_GENRE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_JIWOK_GENRE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_SELECTED]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_TITLE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_TRACK]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_USAGE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]] ;
		@try{
	DUBUG_LOG(@"insertOrUpdateMusicFilesTemp  cmd is %@ argsArray is %@",cmd,argsArray);	
	// Execute the insert query with array of values as parameter
	[ databaseManager executeNonQuery:cmd arguments:argsArray];
               NSLog(@"argsArray NSMutableArray==%@",argsArray);
	[argsArray release];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in insertOrUpdateMusicFilesTemp %@",[ex description]];
	}
    NSLog(@"Now you are completed insertOrUpdateMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
    
    DUBUG_LOG(@"End of insertOrUpdateMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
}



- (void) insertMusicFiles:(NSMutableDictionary *)valuesDict
{	
	NSLog(@"Now you are in insertMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	
    DUBUG_LOG(@"insertMusicFiles JiwokMusicSystemDBMgrWrapper // AV - Music Files Insertion");
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	
	NSMutableString *cmd;	
	
		cmd = [NSMutableString stringWithFormat:@"Insert into  MusicFiles (Active,Album,Artist,BPM,Duration, \
			   FileName,FilePath,Genre,JiwokGenre,Selected,Title,TrackNo,Usage) \
			   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"];
	
	@try{
	if([valuesDict objectForKey:DB_KEY_ACTIVE])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ACTIVE]] ;
		if([valuesDict objectForKey:DB_KEY_ALBUM])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ALBUM]] ;
		if([valuesDict objectForKey:DB_KEY_ARTIST])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ARTIST]];
	if([valuesDict objectForKey:DB_KEY_BPM])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_BPM]] ;
		if([valuesDict objectForKey:DB_KEY_DURATION])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_DURATION]] ;
		if([valuesDict objectForKey:DB_KEY_FILENAME])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILENAME]] ;
		if([valuesDict objectForKey:DB_KEY_FILEPATH])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]] ;
		if([valuesDict objectForKey:DB_KEY_GENRE])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_GENRE]] ;
		if([valuesDict objectForKey:DB_KEY_JIWOK_GENRE])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_JIWOK_GENRE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_SELECTED]] ;
		if([valuesDict objectForKey:DB_KEY_TITLE])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_TITLE]] ;
		if([valuesDict objectForKey:DB_KEY_TRACK])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_TRACK]] ;
		if([valuesDict objectForKey:DB_KEY_USAGE])
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_USAGE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]] ;
	
		DUBUG_LOG(@"insertMusicFilesTemp  cmd is %@ argsArray is %@",cmd,argsArray);	
		// Execute the insert query with array of values as parameter
		[ databaseManager executeNonQuery:cmd arguments:argsArray];
         NSLog(@"argsArray NSMutableArray==%@",argsArray);
		[argsArray release];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in insertMusicFilesTemp %@",[ex description]];
	}
    NSLog(@"Now you are completed insertMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
    
     DUBUG_LOG(@"End of insertMusicFiles JiwokMusicSystemDBMgrWrapper // AV - Music Files Insertion");
}



- (BOOL) updateMusicFilesTemp:(NSMutableDictionary *)valuesDict
{
	NSLog(@"Now you are in updateMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
	
    DUBUG_LOG(@"updateMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
	
	BOOL success = NO;
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSString *cmd = @"UPDATE MusicFilesTemp SET JiwokGenre = ?  WHERE FilePath = ?";
	
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_JIWOK_GENRE]];
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]];
@try{
	// Execute the update query with array of values as parameter
	[ databaseManager executeNonQuery:cmd arguments:argsArray];	
	
	DUBUG_LOG(@"updateMusicFilesTemp  argsArray is %@  ",argsArray);	
	 NSLog(@"argsArray NSMutableArray==%@",argsArray);
	[argsArray release];	
	//return success;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in updateMusicFilesTemp %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"End of updateMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
		return success;
	}
    NSLog(@"Now you are completed updateMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"End of updateMusicFilesTemp JiwokMusicSystemDBMgrWrapper //AV");
}

- (void) insertOrUpdateMusicFiles:(NSMutableDictionary *)valuesDict
{
    NSLog(@"Now you are in insertOrUpdateMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	@try{
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - insertOrUpdateMusicFiles valuesDict is %@",valuesDict);
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSMutableString *cmd;
	// if FilePath found update
	if ([self checkForMusicFiles:[valuesDict objectForKey:DB_KEY_FILEPATH]])
	{
		cmd = [NSMutableString stringWithFormat:@"update MusicFiles set Active = ? ,Album = ? ,Artist = ? , BPM = ? ,Duration = ? , \
			   FileName = ?,FilePath = ?, Genre = ?,JiwokGenre = ? ,Selected = ? ,Title = ?,TrackNo = ? ,Usage = ? where FilePath = ? "];
	}
	else // if file path not found insert
	{
		cmd = [NSMutableString stringWithFormat:@"Insert into  MusicFiles (Active,Album,Artist,BPM,Duration, \
			   FileName,FilePath,Genre,JiwokGenre,Selected,Title,TrackNo,Usage) \
				VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"];
	}
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ACTIVE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ALBUM]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_ARTIST]];
	
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_BPM]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_DURATION]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILENAME]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_GENRE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_JIWOK_GENRE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_SELECTED]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_TITLE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_TRACK]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_USAGE]] ;
	[argsArray addObject:[valuesDict objectForKey:DB_KEY_FILEPATH]] ;
	
	// Execute the insert query with array of values as parameter
	[ databaseManager executeNonQuery:cmd arguments:argsArray];
         NSLog(@"argsArray NSMutableArray==%@",argsArray);
	[argsArray release];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in insertOrUpdateMusicFiles %@",[ex description]];
	}
    NSLog(@"Now you are completed insertOrUpdateMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of insertOrUpdateMusicFiles valuesDict is %@",valuesDict);
}


-(BOOL)DeleteMusicFilesInFolder:(NSString *)folderToDelete{
    NSLog(@"Now you are in DeleteMusicFilesInFolder method in JiwokMusicSystemDBMgrWrapper class");
	[[LoggerClass getInstance] logData:@"DeleteMusicFilesInFolder"];
DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - DeleteMusicFilesInFolder");
	
	BOOL success = NO;
	NSString *sql = [NSString stringWithFormat: @"delete from MusicFiles where  FilePath LIKE \"%@\"",[NSString stringWithFormat:@"%@%%", folderToDelete]];

	@try{
		success = [databaseManager executeNonQuery:sql arguments:nil];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in DeleteMusicFilesInFolder %@",[ex description]];
	}
	@finally { DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteMusicFilesInFolder");
		return success;
	}
	NSLog(@"Now you are completed DeleteMusicFilesInFolder method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteMusicFilesInFolder");
}


-(BOOL)DeleteTempMusicFilesInFolder:(NSString *)folderToDelete{

    NSLog(@"Now you are in DeleteTempMusicFilesInFolder method in JiwokMusicSystemDBMgrWrapper class");
	[[LoggerClass getInstance] logData:@"DeleteTempMusicFilesInFolder"];
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - DeleteTempMusicFilesInFolder");
    
	BOOL success = NO;
	NSString *sql = [NSString stringWithFormat: @"delete from MusicFilesTemp where  FilePath LIKE \"%@\"",[NSString stringWithFormat:@"%@%%", folderToDelete]];
	
	@try{
		success = [databaseManager executeNonQuery:sql arguments:nil];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in DeleteTempMusicFilesInFolder %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteTempMusicFilesInFolder");
		return success;
	}	
    NSLog(@"Now you are completed DeleteTempMusicFilesInFolder method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteTempMusicFilesInFolder");
}


-(BOOL) DeleteMusicFiles: (NSString *)pathtoDelete
{	
    NSLog(@"Now you are in DeleteMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - DeleteMusicFiles ");
	
	BOOL success = NO;
	NSString *sql = [NSString stringWithFormat: @"delete from MusicFiles where  FilePath = \"%@\"",pathtoDelete];
	@try{
	success = [databaseManager executeNonQuery:sql arguments:nil];
	//return success;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in DeleteMusicFiles %@",[ex description]];
	}
	@finally { DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteMusicFiles ");
		return success;
	}
    NSLog(@"Now you are completed DeleteMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteMusicFiles ");
}

- (BOOL) DeleteMusicFilesTemp: (NSString *)pathtoDelete
{	
	NSLog(@"Now you are in DeleteMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - DeleteMusicFilesTemp ");
	
	BOOL success = NO;
	NSString *sql = [NSString stringWithFormat: @"delete from MusicFilesTemp where  FilePath = \"%@\"",pathtoDelete];
	@try{
	success = [databaseManager executeNonQuery:sql arguments:nil];
	//return success;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in DeleteMusicFilesTemp %@",[ex description]];
	}
	@finally { DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteMusicFilesTemp ");
		return success;
	}
    NSLog(@"Now you are completed DeleteMusicFilesTemp method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of DeleteMusicFilesTemp ");
}

//- (NSInteger)getNextRowId
//{	
//	NSInteger nextId = 0;
//	NSString *query = @"SELECT MAX(rowid) as NextId from UserSelectedFolders";
//	NSArray *mismatches = [NSArray arrayWithArray:[databaseManager executeQuery:query ]];
//	NSDictionary *dict = [mismatches objectAtIndex:0];
//	nextId = [[dict objectForKey:@"NextId"]intValue];
//	nextId++;
//	return nextId;
//	
//	
//}
- (NSArray*) getAllMusicalGenre
{	
	NSLog(@"Now you are in getAllMusicalGenre method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *MusicGenreArray;
	@try{
	MusicGenreArray = [databaseManager executeQuery:@"SELECT DISTINCT jiwok_genre FROM MusicalGenreTab"];
	 NSLog(@"MusicGenreArray NSArray==%@",MusicGenreArray);
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - getAllMusicalGenre  ");
	//return [MusicGenreArray autorelease];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in getAllMusicalGenre %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of getAllMusicalGenre  ");
		return [MusicGenreArray autorelease];
	}
    NSLog(@"Now you are completed getAllMusicalGenre method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of getAllMusicalGenre  ");	
}

- (NSString*) getJiwokMusicalGenre:(NSString *) genretoCheck
{	
    NSLog(@"Now you are in getJiwokMusicalGenre method in JiwokMusicSystemDBMgrWrapper class");
	genretoCheck=[genretoCheck stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	DUBUG_LOG(@"AV// getJiwokMusicalGenre genretoCheck 1 is |%@|",genretoCheck);
	
	NSString * jiwok_genre = @"";
	
	//NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM MusicalGenreTab where genre_name  = \""];
	
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM MusicalGenreTab where genre_name  LIKE \""];

	
	[sql appendFormat:@"%@",genretoCheck];
	[sql appendFormat:@"\""];

	DUBUG_LOG(@"AV// getJiwokMusicalGenre genretoCheck is 22 %@  sql is %@",genretoCheck,sql);	
	
	NSArray *MusicGenreArray;
	@try{
	MusicGenreArray = [databaseManager executeQuery:sql];
	if ([MusicGenreArray count] > 0)
	{
		NSDictionary *dict = [MusicGenreArray objectAtIndex:0];
		jiwok_genre = [dict objectForKey:@"jiwok_genre"];
		
		DUBUG_LOG(@"getJiwokMusicalGenre jiwok_genre is %@  dict is   =====  %@",jiwok_genre,dict);		
	}
         NSLog(@"MusicGenreArray NSArray==%@",MusicGenreArray);
	[MusicGenreArray autorelease];	
	//return jiwok_genre;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in getJiwokMusicalGenre %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"AV// End of getJiwokMusicalGenre genretoCheck is 22 %@  sql is %@",genretoCheck,sql);
		return jiwok_genre;
	}
    NSLog(@"Now you are completed getJiwokMusicalGenre method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// End of getJiwokMusicalGenre genretoCheck is 22 %@  sql is %@",genretoCheck,sql);
}
- (NSArray*) findAllMusicFiles
{	
    NSLog(@"Now you are in findAllMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - findAllMusicFiles ");
	NSArray *MusicFilesArray;
	@try{
	MusicFilesArray = [databaseManager executeQuery:@"SELECT * FROM MusicFiles"];
    NSLog(@"MusicFilesArray NSArray==%@",MusicFilesArray);
	//return [MusicFilesArray autorelease];
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in findAllMusicFiles %@",[ex description]];
	}
	@finally { DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of findAllMusicFiles ");
		return [MusicFilesArray autorelease];
	}
    NSLog(@"Now you are completed findAllMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of findAllMusicFiles ");
}



- (NSArray*) findAllMusicFiles:(NSString*) theFilePath
{
	NSLog(@"Now you are in findAllMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// findAllMusicFiles with path ");
	
	NSArray *classArray;
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM MusicFiles where FilePath  = \"%@\"",theFilePath];				
	@try{
	classArray = [databaseManager executeQuery:query];
	//return [classArray autorelease];
        NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in findAllMusicFiles %@",[ex description]];
	}
	@finally {DUBUG_LOG(@"AV// End of findAllMusicFiles with path ");
		return [classArray autorelease];
	}
    NSLog(@"Now you are completed findAllMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// End of findAllMusicFiles with path ");
}

- (NSArray*) findAllMusicFilePaths{
	NSLog(@"Now you are in findAllMusicFilePaths method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - findAllMusicFilePaths ");
	NSArray *MusicFilepathsArray;
	
	NSString *query = @"SELECT FilePath FROM MusicFiles";				
	[query retain];
	
	@try{

		MusicFilepathsArray = [databaseManager executeQuery:query];
	//return [MusicFilepathsArray autorelease];
        NSLog(@"MusicFilepathsArray NSArray==%@",MusicFilepathsArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in findAllMusicFilePaths %@",[ex description]];
	}
	@finally {
		DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of findAllMusicFilePaths ");
		[query release];
		
		return [MusicFilepathsArray autorelease];
	}
    NSLog(@"Now you are completed findAllMusicFilePaths method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"AV// JiwokMusicSystemDBMgrWrapper - End of findAllMusicFilePaths ");
}


- (NSArray*) GetCountForGenreFromMusicFiles: (NSString *)GenreTocheck{
	NSLog(@"Now you are in GetCountForGenreFromMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *UserSelectedFoldersArray;	
	
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT COUNT(*) FROM MusicFiles Where jiwokGenre = \""];
	[sql appendFormat:@"%@",GenreTocheck];
	[sql appendFormat:@"\""];
	@try{
	UserSelectedFoldersArray = [databaseManager executeQuery:sql];
	 NSLog(@"UserSelectedFoldersArray NSArray==%@",UserSelectedFoldersArray);
	DUBUG_LOG(@"AV// GetCountForGenreFromMusicFiles sql iszzzzz  %@  UserSelectedFoldersArray is %@",GenreTocheck,UserSelectedFoldersArray);
		
	//return UserSelectedFoldersArray;	
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in GetCountForGenreFromMusicFiles %@",[ex description]];
	}
	@finally {
        DUBUG_LOG(@"AV// End of GetCountForGenreFromMusicFiles sql iszzzzz  %@  UserSelectedFoldersArray is %@",GenreTocheck,UserSelectedFoldersArray);
		return UserSelectedFoldersArray;
	}
    NSLog(@"Now you are completed GetCountForGenreFromMusicFiles method in JiwokMusicSystemDBMgrWrapper class");
}


-(void)MoveTempMusicToMusic{
NSLog(@"Now you are in MoveTempMusicToMusic method in JiwokMusicSystemDBMgrWrapper class");
	@try{
		
		DUBUG_LOG(@"MoveTempMusicToMusic MoveTempMusicToMusic");
		
	NSString *nullString=@"\"nil\"";	
	//NSString *nullString1=@"\"\"";
	
	NSArray *ResultArray;
	//NSMutableString *sql = [NSMutableString stringWithFormat:@" Insert into MusicFiles select * FROM MusicfilesTemp   WHERE  ((Album != %@) AND (Artist!=%@) AND (BPM!=%@) AND(JiwokGenre!=%@)AND (FilePath NOT IN (Select FilePath from Musicfiles)) )",nullString,nullString,nullString,nullString];

	NSMutableString *sql = [NSMutableString stringWithFormat:@" Insert into MusicFiles select * FROM MusicfilesTemp   WHERE  ((BPM!=%@) AND(JiwokGenre!=%@)AND (FilePath NOT IN (Select FilePath from Musicfiles)) )",nullString,nullString];
	
		
	ResultArray=[databaseManager executeQuery:sql];
         NSLog(@"ResultArray NSArray==%@",ResultArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in MoveTempMusicToMusic %@",[ex description]];
	}
    NSLog(@"Now you are completed MoveTempMusicToMusic method in JiwokMusicSystemDBMgrWrapper class");
}

-(void)removeMovedFilesFromTemp{
    NSLog(@"Now you are in removeMovedFilesFromTemp method in JiwokMusicSystemDBMgrWrapper class");
@try {
	
	DUBUG_LOG(@"removeMovedFilesFromTemp removeMovedFilesFromTemp");
	
	NSArray *ResultArray;
	NSMutableString *sql = [NSMutableString stringWithFormat:@" delete from MusicfilesTemp  where FilePath  IN (select FilePath FROM  MusicFiles)"];
	ResultArray=[databaseManager executeQuery:sql];
     NSLog(@"ResultArray NSArray==%@",ResultArray);
}
@catch (NSException * ex) {
    
	DUBUG_LOG(@"@catch");
	[[LoggerClass getInstance] logData:@"Exception occured in removeMovedFilesFromTemp %@",[ex description]];
}
 NSLog(@"Now you are completed removeMovedFilesFromTemp method in JiwokMusicSystemDBMgrWrapper class");
}



/////// work out related 
- (NSString*) getWorkoutMp3:(NSString *)idToCheck
{	
     NSLog(@"Now you are in getWorkoutMp3 method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"AV - Problem Area// getWorkoutMp3 ");
	NSString * mp3FileName = @"";
	NSString *uppercaseID =  [idToCheck uppercaseString];
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM Workout where upper(id)  = \""];
	[sql appendFormat:@"%@",uppercaseID];
	[sql appendFormat:@"\""];
	
	NSArray *workOutArray;
	@try{
	workOutArray = [databaseManager executeQuery:sql];
	if ([workOutArray count] > 0)
	{
		NSDictionary *dict = [workOutArray objectAtIndex:0];
		mp3FileName = [dict objectForKey:@"mp3File"];
	}
         NSLog(@"workOutArray NSArray==%@",workOutArray);
	[workOutArray autorelease];
	
	//return mp3FileName;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in getWorkoutMp3 %@",[ex description]];
	}
	@finally {
        DUBUG_LOG(@"AV - Problem Area// getWorkoutMp3 ");
		return mp3FileName;
	}
     NSLog(@"Now you are completed getWorkoutMp3 method in JiwokMusicSystemDBMgrWrapper class");
}
- (NSString*) getTraingingMp3:(NSString *)idToCheck
{
	 NSLog(@"Now you are in getTraingingMp3 method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"problem area - AV// getTraingingMp3 ");
	NSString * mp3FileName = @"";
	NSString *uppercaseID =  [idToCheck uppercaseString];
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM Training where UPPER(id)  = \""];
	[sql appendFormat:@"%@",uppercaseID];
	[sql appendFormat:@"\""];
	
	NSArray *trainingArray;
	@try{
	trainingArray = [databaseManager executeQuery:sql];
	if ([trainingArray count] > 0)
	{
		NSDictionary *dict = [trainingArray objectAtIndex:0];
		mp3FileName = [dict objectForKey:@"mp3File"];
	}
        NSLog(@"trainingArray NSArray==%@",trainingArray);
	[trainingArray autorelease];
	
	//return mp3FileName;
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in getTraingingMp3 %@",[ex description]];
	}
	@finally {
        DUBUG_LOG(@"problem area - AV// End of getTraingingMp3 ");
		return mp3FileName;
	}
     NSLog(@"Now you are completed getTraingingMp3 method in JiwokMusicSystemDBMgrWrapper class");
}


-(void)IncrementUsage
{
     NSLog(@"Now you are in IncrementUsage method in JiwokMusicSystemDBMgrWrapper class");
	@try{
	NSArray *classArray;		
	NSString *query=@"UPDATE MusicFiles SET Usage = (CAST (Usage AS INT) +1) Where selected='True'";	
	classArray = [databaseManager executeQuery:query];	
        NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in IncrementUsage %@",[ex description]];
	}
    NSLog(@"Now you are completed IncrementUsage method in JiwokMusicSystemDBMgrWrapper class");
}

- (NSMutableArray*)SelectFromMusicTable:(NSString*)MinBpm:(NSString*)MaxBpm:(NSArray*)genreArray:(NSString *)selectedFlag
{	
	NSLog(@"Now you are in SelectFromMusicTable method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *classArray;	
	NSMutableString *genreString=[[NSMutableString alloc]init]; 
	DUBUG_LOG(@"Problem Area AV// SelectFromMusicTable");
	for(int i=0;i<[genreArray count];i++)
	{
		NSString* tmp=[[genreArray objectAtIndex:i] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		[genreString appendString:[NSString stringWithFormat:@"'%@',",tmp]];		
	}
	NSString* genreString1=[genreString substringToIndex:([genreString length]-1)];	
	[genreString release];
		@try{
	NSString *query = [NSString stringWithFormat:@" SELECT FilePath , Duration , Artist , jiwokGenre  FROM MusicFiles WHERE( (CAST( BPM AS INT) BETWEEN %@ AND %@ )  AND  JiwokGenre  IN  (%@) AND Selected LIKE '%@') ORDER BY Usage ASC",MinBpm,MaxBpm,genreString1,selectedFlag];
		
	classArray = [databaseManager executeQuery:query];	
	//return [classArray autorelease];
            NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in SelectFromMusicTable %@",[ex description]];
	}
	@finally {
        DUBUG_LOG(@"Problem Area AV// End of SelectFromMusicTable");
		return [classArray autorelease];
	}
    NSLog(@"Now you are completed SelectFromMusicTable method in JiwokMusicSystemDBMgrWrapper class");
}
-(void)setUsageFieldInTable:(NSString *)filePath:(NSString *)usageIndex
{
    NSLog(@"Now you are in setUsageFieldInTable method in JiwokMusicSystemDBMgrWrapper class");
    @try{	
	NSArray *classArray;
	NSString *query =[NSString stringWithFormat:@" UPDATE MusicFiles SET Usage ='%@' WHERE( FilePath LIKE \"%@\")",usageIndex,filePath];
	classArray = [databaseManager executeQuery:query];
        NSLog(@"classArray NSArray==%@",classArray);
         NSLog(@"Now you are completed setUsageFieldInTable method in JiwokMusicSystemDBMgrWrapper class");
}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in setUsageFieldInTable %@",[ex description]];
	}
	 NSLog(@"Now you are completed setUsageFieldInTable method in JiwokMusicSystemDBMgrWrapper class");
}
-(void)setSelectedFieldInTable:(NSString *)filePath:(NSString *)selectedFlag
{
	 NSLog(@"Now you are in setSelectedFieldInTable method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"setSelectedFieldInTable setSelectedFieldInTable");
	
	@try{
	NSArray *classArray;
	NSString *query =[NSString stringWithFormat:@" UPDATE MusicFiles SET Selected ='%@' WHERE( FilePath LIKE \"%@\")",selectedFlag,filePath];
	classArray = [databaseManager executeQuery:query];
		
		//DUBUG_LOG(@"setSelectedFieldInTable %@",classArray);

	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in setSelectedFieldInTable %@",[ex description]];
	}
	NSLog(@"Now you are completed setSelectedFieldInTable method in JiwokMusicSystemDBMgrWrapper class");
}

-(void)setSelectedFieldFalse:(NSString*)MinBpm:(NSString*)MaxBpm:(NSArray*)genreArray
{
	NSLog(@"Now you are in setSelectedFieldFalse method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"setSelectedFieldFalse setSelectedFieldFalse");

	
	NSMutableString *genreString=[[NSMutableString alloc]init]; 
	
	for(int i=0;i<[genreArray count];i++)
	{
		NSString* tmp=[[genreArray objectAtIndex:i] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		[genreString appendString:[NSString stringWithFormat:@"'%@',",tmp]];		
	}
	NSString* genreString1=[genreString substringToIndex:([genreString length]-1)];	
	[genreString release];
	
	@try{
		NSArray *classArray;
		//NSString *query =@"UPDATE MusicFiles SET Selected ='False' WHERE (FilePath IN (SELECT FilePath MusicFiles))";
		
		NSString *query =[NSString stringWithFormat:@"UPDATE MusicFiles SET Selected ='False' WHERE( (CAST( BPM AS INT) BETWEEN %@ AND %@ )  AND  JiwokGenre  IN  (%@) ) ",MinBpm,MaxBpm,genreString1];

		
		classArray = [databaseManager executeQuery:query];
        NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in setSelectedFieldTrue %@",[ex description]];
	}
    NSLog(@"Now you are completed setSelectedFieldFalse method in JiwokMusicSystemDBMgrWrapper class");

}



/*- (NSArray*) SelectFromMusicTable:(NSString*)MinBpm:(NSString*)MaxBpm:(NSString*)genre
 {		
 NSArray *classArray;	
 NSString *query = [NSString stringWithFormat:@"SELECT FilePath FROM MusicFiles WHERE( (CAST( BPM AS INT) BETWEEN %@ AND %@ ) and JiwokGenre = '%@')",MinBpm,MaxBpm,genre];		
 classArray = [databaseManager executeQuery:query];		
 //NSLog(@"classArray classArray classArray is %@",classArray);	
 return [classArray autorelease];		
 }*/

- (NSArray*) SelectFromMusicTableWithoutArguments
{
	NSLog(@"Now you are in SelectFromMusicTableWithoutArguments method in JiwokMusicSystemDBMgrWrapper class");
    DUBUG_LOG(@"Problem Area AV // SelectFromMusicTableWithoutArguments");
	NSArray *classArray;	
	NSString *query = [NSString stringWithFormat:@"SELECT FilePath , Duration , Artist , jiwokGenre FROM MusicFiles ORDER BY Usage ASC"];	
	@try{
	classArray = [databaseManager executeQuery:query];		
	//NSLog(@"classArray classArray classArray is %@",classArray);	
	//return [classArray autorelease];
        NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in SelectFromMusicTableWithoutArguments %@",[ex description]];
	}
	@finally {
        DUBUG_LOG(@"Problem Area AV // End of SelectFromMusicTableWithoutArguments");
		return [classArray autorelease];
	}
    NSLog(@"Now you are completed SelectFromMusicTableWithoutArguments method in JiwokMusicSystemDBMgrWrapper class");
}

- (NSArray*) SelectFromMusicTable:(NSString*)MinBpm:(NSString*)MaxBpm:(NSString *)selectedFlag
{ 
    NSLog(@"Now you are in SelectFromMusicTable method in JiwokMusicSystemDBMgrWrapper class");
	DUBUG_LOG(@"Problem Area AV // SelectFromMusicTable");
    NSArray *classArray;
	NSString *query = [NSString stringWithFormat:@"SELECT FilePath , Duration , Artist , jiwokGenre FROM MusicFiles WHERE( (CAST( BPM AS INT) BETWEEN %@ AND %@ ) AND Selected LIKE '%@') ORDER BY Usage ASC",MinBpm,MaxBpm,selectedFlag];	
	@try{
	classArray = [databaseManager executeQuery:query];		
	//NSLog(@"classArray classArray classArray is %@",classArray);	
	//return [classArray autorelease];
        NSLog(@"classArray NSArray==%@",classArray);
}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in SelectFromMusicTable %@",[ex description]];
	}
	@finally {
        DUBUG_LOG(@"Problem Area AV // End of SelectFromMusicTable");
		return [classArray autorelease];
	}
    NSLog(@"Now you are completed SelectFromMusicTable method in JiwokMusicSystemDBMgrWrapper class");
}

-(void)ChangeSongSelectedStatus:(NSString *)SongLocation
{
	NSLog(@"Now you are in ChangeSongSelectedStatus method in JiwokMusicSystemDBMgrWrapper class");
    @try{
	NSString *query=[NSString stringWithFormat:@"UPDATE MusicFiles SET Selected ='True' WHERE FilePath LIKE \"%@\"",SongLocation];	
	[databaseManager executeNonQuery:query arguments:nil];	
}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in ChangeSongSelectedStatus %@",[ex description]];
	}
    NSLog(@"Now you are completed ChangeSongSelectedStatus method in JiwokMusicSystemDBMgrWrapper class");
}


- (NSArray*) getApplicationDetails{
	NSLog(@"Now you are in getApplicationDetails method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *classArray;	
	NSString *query = [NSString stringWithFormat:@"SELECT * from Applicationinfo ORDER BY CurrentVersion DESC"];	
	@try{
		classArray = [databaseManager executeQuery:query];		
		//return [classArray autorelease];	
        NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in getApplicationDetails %@",[ex description]];
	}
	@finally {
		return [classArray autorelease];
	}
NSLog(@"Now you are completed getApplicationDetails method in JiwokMusicSystemDBMgrWrapper class");
}



- (NSArray*) TRIALFN{
	NSLog(@"Now you are in TRIALFN method in JiwokMusicSystemDBMgrWrapper class");
	NSArray *classArray;	
	NSString *query = [NSString stringWithFormat:@"SELECT FilePath , Duration,Artist FROM MusicFiles WHERE( (CAST( BPM AS INT) BETWEEN 40 AND 150 )  AND  JiwokGenre  IN  ('Rap') AND Selected LIKE 'True')"];	
	@try{
		classArray = [databaseManager executeQuery:query];		
		//return [classArray autorelease];
        NSLog(@"classArray NSArray==%@",classArray);
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in TRIALFN %@",[ex description]];
	}
	@finally {
		return [classArray autorelease];
	}
	NSLog(@"Now you are completed TRIALFN method in JiwokMusicSystemDBMgrWrapper class");
}



- (void) insertApplicationDetails:(NSMutableDictionary *)valuesDict
{	
    NSLog(@"Now you are in insertApplicationDetails method in JiwokMusicSystemDBMgrWrapper class");
	@try{
		DUBUG_LOG(@"insertApplicationDetails ");
		
		NSMutableArray *argsArray = [[NSMutableArray alloc] init];
		NSString *cmd = @"Insert into Applicationinfo (CurrentVersion,DownloadDate,ReleaseDate,DownloadFrom,VersionNo) VALUES (?,?,?,?,?)";
		[argsArray addObject:[valuesDict objectForKey:DB_KEY_APP_VERSION]] ;
		[argsArray addObject:[valuesDict objectForKey:DB_KEY_UPDATE_DATE]] ;
		[argsArray addObject:[valuesDict objectForKey:DB_KEY_RELEASE_DATE]];
		[argsArray addObject:[valuesDict objectForKey:DB_KEY_UPDATE_FROM]] ;
		[argsArray addObject:[valuesDict objectForKey:DB_KEY_UPDATE_VERSION]];
		
		NSLog(@"argsArray NSMutableArray==%@",argsArray);
		// Execute the insert query with array of values as parameter
		[ databaseManager executeNonQuery:cmd arguments:argsArray];
		[argsArray release];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in insertApplicationDetails %@",[ex description]];
	}
	NSLog(@"Now you are completed insertApplicationDetails method in JiwokMusicSystemDBMgrWrapper class");
}



@end
