//
//  JiwokDataBaseManager.m
//  Jiwok
//
//  Created by reubro.
//  Copyright 2010 Jiwok. All rights reserved.
//

#import "JiwokDataBaseManager.h"

//private methods
@interface JiwokDataBaseManager(PRIVATE)

- (BOOL)executeStatament:(sqlite3_stmt *)stmt;
- (BOOL)prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt;
- (void) bindObject:(id)obj toColumn:(int)idx inStatament:(sqlite3_stmt *)stmt;

- (BOOL)hasData:(sqlite3_stmt *)stmt;
- (id)columnData:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index;
- (NSString *)columnName:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index;

@end

@implementation JiwokDataBaseManager

@synthesize dbFileName;

+ (NSString *)createUuid {
    NSLog(@"Now you are in createUuid method in JiwokDataBaseManager class");
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	return([(NSString *) uuidStringRef autorelease]);
    NSLog(@"Now you are completed createUuid method in JiwokDataBaseManager class");
}
- (id)init{
    NSLog(@"Now you are in init method in JiwokDataBaseManager class");
	id tmp = [super init];
	if(tmp==nil)
		[self autorelease];
	self = tmp;
	if(self){
		dbFileName = nil;
		database = nil;
	}
	return self;
     NSLog(@"Now you are completed init method in JiwokDataBaseManager class");
}

- (id)initDBWithFileName:(NSString *)file{
     NSLog(@"Now you are in initDBWithFileName method in JiwokDataBaseManager class");
	id tmp = [super init];
	if(tmp==nil)
		[self autorelease];
	self = tmp;
	if(self){
		database = nil;
		[self open:file];
	}
	
	_lock = OS_SPINLOCK_INIT;
	
	NSLog(@"Opened file : %@",file);
	return self;
    NSLog(@"Now you are completed initDBWithFileName method in JiwokDataBaseManager class");
}

- (BOOL)open:(NSString *)file{
    NSLog(@"Now you are in open method in JiwokDataBaseManager class");

	[self close];
	
	if (sqlite3_open([file fileSystemRepresentation], &database) != SQLITE_OK) {
		NSLog(@"SQLite Opening Error: %s", sqlite3_errmsg(database));
		return NO;
	}
	
	dbFileName = [file retain];
	return YES;
    NSLog(@"Now you are completed open method in JiwokDataBaseManager class");
}

- (void)close {
    NSLog(@"Now you are in close method in JiwokDataBaseManager class");
	if (database == nil) return;
	
	int rc;
	rc = sqlite3_close(database);
	if (rc != SQLITE_OK)
		NSLog(@"SQLite %@ Closing Error: %s", dbFileName, sqlite3_errmsg(database));
	[dbFileName release];
	dbFileName = nil;
	database = nil;
    NSLog(@"Now you are completed close method in JiwokDataBaseManager class");
}

- (NSString *)errorMsg {
    NSLog(@"Now you are in errorMsg method in JiwokDataBaseManager class");
	return [NSString stringWithFormat:@"%s", sqlite3_errmsg(database)];
    NSLog(@"Now you are completed errorMsg method in JiwokDataBaseManager class");
}

//parses the number of arguments passed and calls execute
- (NSInteger)executeScalar:(NSString *)sql, ... {
    NSLog(@"Now you are in executeScalar sql method in JiwokDataBaseManager class");
	va_list args;
	va_start(args, sql);
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSUInteger i;
	for (i = 0; i < [sql length]; ++i) {
		if ([sql characterAtIndex:i] == '?')
			[argsArray addObject:va_arg(args, id)];
	}
	 NSLog(@"argsArray NSMutableArray==%@",argsArray);
	va_end(args);
	NSInteger result = [self executeScalar:sql arguments:argsArray];
	[argsArray release];
	return result;
     NSLog(@"Now you are completed executeScalar sql method in JiwokDataBaseManager class");
}

//actually executes the query passed along with the parametres to bind
- (NSInteger)executeScalar:(NSString *)sql arguments:(NSArray *)args {
	 NSLog(@"Now you are in (NSInteger)executeScalar:(NSString *)sql arguments:(NSArray *)args method in JiwokDataBaseManager class");
	sqlite3_stmt *sqlStmt;
	
	if (![self prepareSql:sql inStatament:(&sqlStmt)])	//prepare the sql query
		return 0;
	
	int i = 0;
	int queryParamCount = sqlite3_bind_parameter_count(sqlStmt);	//gives the ? count in a sql statement
	while (i++ < queryParamCount)
		[self bindObject:[args objectAtIndex:(i - 1)] toColumn:i inStatament:sqlStmt];	//bind objects to ? mark
	
	NSInteger ret = 0;
	int columnCount = sqlite3_column_count(sqlStmt);		//gives the number  of columns in an sql query statement
	if ([self hasData:sqlStmt] && columnCount > 0) 
	{	
		NSNumber *result = (NSNumber *)[self columnData:sqlStmt columnIndex:0];
		ret = [result intValue];
	}
	
	sqlite3_finalize(sqlStmt);	//free resources
	
	return ret;
     NSLog(@"Now you are completed (NSInteger)executeScalar:(NSString *)sql arguments:(NSArray *)args method in JiwokDataBaseManager class");
}


//parses the number of arguments passed and calls execute
- (NSArray *)executeQuery:(NSString *)sql, ... {
     NSLog(@"Now you are in (NSArray *)executeQuery:(NSString *)sql, ...  method in JiwokDataBaseManager class");
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSArray *result;
	
	NSString *sqlString=sql;
	[sqlString retain];
	
	@try {
		result = [self executeQuery:sqlString arguments:argsArray];
		 NSLog(@"argsArray NSMutableArray==%@",argsArray);
	}
	@catch (NSException * e) {
		NSLog(@"XXXXXXXXXCEPTION %@",[e description]);
	}
	@finally {
		//NSLog(@"FINALLY");
	}
	
	[sqlString release];
	
	[argsArray release];

	return result;

	 NSLog(@"Now you are completed (NSArray *)executeQuery:(NSString *)sql, ...  method in JiwokDataBaseManager class");
	
	//NSArray *result = [self executeQuery:sql arguments:argsArray];
//	[argsArray release];
//	return result;
}

//actually executes the query passed along with the parametres to bind
- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)args {
	sqlite3_stmt *sqlStmt;
	 NSLog(@"Now you are in ((NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)args  method in JiwokDataBaseManager class");
	
	//if (!(sqlite3_config(2) == SQLITE_OK))
//		return nil;
//		
		
	if (![self prepareSql:sql inStatament:(&sqlStmt)])	//prepare the sql query
		return nil;
	
	NSMutableArray *arrayList = [[NSMutableArray alloc] init];

	
	OSSpinLockLock(&_lock);{
	
	int i = 0;
	int queryParamCount = sqlite3_bind_parameter_count(sqlStmt);	//gives the ? count in a sql statement
	while (i++ < queryParamCount)
		[self bindObject:[args objectAtIndex:(i - 1)] toColumn:i inStatament:sqlStmt];	//bind objects to ? mark
	
	int columnCount = sqlite3_column_count(sqlStmt);		//gives the number  of columns in an sql query statement
	while ([self hasData:sqlStmt]) {	//do sql_step to fetch more row data
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		for (i = 0; i < columnCount; ++i) {
			id columnName = [self columnName:sqlStmt columnIndex:i];	//fetch column name
			id columnData = [self columnData:sqlStmt columnIndex:i];	//fetch column data
			if (columnData != NULL)
				[dictionary setObject:columnData forKey:columnName];
						
		}
		[arrayList addObject:dictionary];
         NSLog(@"arrayList NSMutableArray==%@",arrayList);
		[dictionary release];
	}
	
	}OSSpinLockUnlock(&_lock);
		
		
	sqlite3_finalize(sqlStmt);	//free resources
	
	return arrayList;
    NSLog(@"Now you are completed ((NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)args  method in JiwokDataBaseManager class");

}

- (BOOL)executeNonQuery:(NSString *)sql, ... {
    NSLog(@"Now you are in (BOOL)executeNonQuery:(NSString *)sql, ...  method in JiwokDataBaseManager class");

	va_list args;
	va_start(args, sql);
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSUInteger i;
	for (i = 0; i < [sql length]; ++i) {
		if ([sql characterAtIndex:i] == '?')
			[argsArray addObject:va_arg(args, id)];
	}
	
	va_end(args);
	
	BOOL success = [self executeNonQuery:sql arguments:argsArray];
	
	[argsArray release];
	return success;
    NSLog(@"Now you are completed (BOOL)executeNonQuery:(NSString *)sql, ...  method in JiwokDataBaseManager class");
}


- (BOOL)executeNonQuery:(NSString *)sql arguments:(NSArray *)args {
    NSLog(@"Now you are in (BOOL)executeNonQuery:(NSString *)sql arguments:(NSArray *)args   method in JiwokDataBaseManager class");

	sqlite3_stmt *sqlStmt;
	
	if (![self prepareSql:sql inStatament:(&sqlStmt)])	//first prepare the sql statement
		return NO;
	
	int i = 0;
	int queryParamCount = sqlite3_bind_parameter_count(sqlStmt);	//get the parametere count
	while (i++ < queryParamCount)
		[self bindObject:[args objectAtIndex:(i - 1)] toColumn:i inStatament:sqlStmt];	//bind parametres
	
	BOOL success = [self executeStatament:sqlStmt];	//execute the statement
	
	sqlite3_finalize(sqlStmt); //free resources
	return success;	
     NSLog(@"Now you are completed (BOOL)executeNonQuery:(NSString *)sql arguments:(NSArray *)args   method in JiwokDataBaseManager class");
}

//Returns the last inserted Row Id from the specified table
- (NSInteger) lastInsertRowId
{
     NSLog(@"Now you are in lastInsertRowId  method in JiwokDataBaseManager class");
	return sqlite3_last_insert_rowid(database);
     NSLog(@"Now you are completed lastInsertRowId  method in JiwokDataBaseManager class");
} 

- (BOOL)prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt {
     NSLog(@"Now you are in (BOOL)prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt  method in JiwokDataBaseManager class");
	int rc;
	@try { 			
		
	
		NSString *sqlString=sql;
		
		[sqlString retain];
		
	//	int safe=sqlite3_threadsafe();
//		
//		if (!(sqlite3_config(1) == SQLITE_OK))
//			return;
		
		// Earlier code
		//rc = sqlite3_prepare_v2(database, [sql UTF8String], -1, stmt, NULL);	//prepare the statement
	 
		OSSpinLockLock(&_lock);{
	
		rc = sqlite3_prepare_v2(database, [sqlString UTF8String], -1, stmt, 0);	//prepare the statement
		
		} OSSpinLockUnlock(&_lock);
		
		[sqlString release];
	}
	@catch (NSException * e) {
		NSLog(@"Exception occured in prepareSql %@",[e description]);
	}
	@finally {
		if (rc == SQLITE_OK)
			return YES;
		NSLog(@"SQLite Prepare Failed: %s", sqlite3_errmsg(database));
		NSLog(@" - Query: %@", sql);
		return NO;
	}
	
	//NSLog(@" - Query: %@", sql);
	 NSLog(@"Now you are completed (BOOL)prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt  method in JiwokDataBaseManager class");
}

- (BOOL)executeStatament:(sqlite3_stmt *)stmt {
     NSLog(@"Now you are in (BOOL)executeStatament:(sqlite3_stmt *)stm  method in JiwokDataBaseManager class");
	int rc;
	rc = sqlite3_step(stmt);	//execute the statement
	if (rc == SQLITE_OK || rc == SQLITE_DONE)
	{
		//NSLog(@"SQLite Success");
		return YES;
	}
	NSLog(@"SQLite Step Failed: %s", sqlite3_errmsg(database));
	return NO;
    NSLog(@"Now you are completed (BOOL)executeStatament:(sqlite3_stmt *)stm  method in JiwokDataBaseManager class");
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatament:(sqlite3_stmt *)stmt {
    NSLog(@"Now you are in bindObject  method in JiwokDataBaseManager class");
	if (obj == nil) {
		sqlite3_bind_null(stmt, idx);	//null object
	} else if ([obj isKindOfClass:[NSData class]]) {
		sqlite3_bind_blob(stmt, idx, [obj bytes], [obj length], SQLITE_STATIC);	//blob data
	} else if ([obj isKindOfClass:[NSDate class]]) {	
		sqlite3_bind_double(stmt, idx, [obj timeIntervalSince1970]);	//timestamp
	} else if ([obj isKindOfClass:[NSNumber class]]) {					//if integer
		if (!strcmp([obj objCType], @encode(BOOL))) {					// boolean
			sqlite3_bind_int(stmt, idx, [obj boolValue] ? 1 : 0);
		} else if (!strcmp([obj objCType], @encode(int))) {
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		} else if (!strcmp([obj objCType], @encode(long))) {
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		} else if (!strcmp([obj objCType], @encode(float))) {
			sqlite3_bind_double(stmt, idx, [obj floatValue]);
		} else if (!strcmp([obj objCType], @encode(double))) {
			sqlite3_bind_double(stmt, idx, [obj doubleValue]);
		} else {
			sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);	//sql binding
		}
	} else {
		sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
     NSLog(@"Now you are completed bindObject  method in JiwokDataBaseManager class");
}

- (BOOL)hasData:(sqlite3_stmt *)stmt {
     NSLog(@"Now you are in hasData  method in JiwokDataBaseManager class");
	int rc;
	rc = sqlite3_step(stmt);	//got data
	if (rc == SQLITE_ROW)
		return YES;
	//NSString *err = [self errorMsg];
	if (rc != SQLITE_DONE)
		NSLog(@"SQLite Prepare Failed: %s", sqlite3_errmsg(database));
	return NO;
     NSLog(@"Now you are completed hasData  method in JiwokDataBaseManager class");
}

//returns the column data given the index
- (id)columnData:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index {
     NSLog(@"Now you are in columnData  method in JiwokDataBaseManager class");
	int columnType = sqlite3_column_type(stmt, index);	//gets the coloumn type given the index
	
	if (columnType == SQLITE_INTEGER)
		return [NSNumber numberWithInt:sqlite3_column_int(stmt, index)];
	
	if (columnType == SQLITE_FLOAT)
		return [NSNumber numberWithDouble:sqlite3_column_double(stmt, index)];
	
	if (columnType == SQLITE_TEXT) {
		const unsigned char *text = sqlite3_column_text(stmt, index);
				
		NSString* str = [[NSString alloc] initWithData:[NSData dataWithBytes:text length:strlen((char*)text) ] encoding:NSUTF8StringEncoding];  
		
		//NSString* str = [[NSString alloc] initWithData:[NSData dataWithBytes:text length:strlen((char*)text) ] encoding:NSISOLatin1StringEncoding];  

		
		// Old Code
		//return [NSString stringWithFormat:@"%s", text];
		
		return [str autorelease];
		
	}
	
	if (columnType == SQLITE_BLOB) {
		int nbytes = sqlite3_column_bytes(stmt, index);
		const char *bytes = sqlite3_column_blob(stmt, index);
		return [NSData dataWithBytes:bytes length:nbytes];
	}
	
	return nil;
    NSLog(@"Now you are completed columnData  method in JiwokDataBaseManager class");
}

//returns the column name given the index
- (NSString *)columnName:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index {
    NSLog(@"Now you are in columnName  method in JiwokDataBaseManager class");
	return [NSString stringWithUTF8String:sqlite3_column_name(stmt, index)] ;
    NSLog(@"Now you are in columnName  method in JiwokDataBaseManager class");
}

- (void)dealloc {
	[self close];
	[super dealloc];
}

@end
