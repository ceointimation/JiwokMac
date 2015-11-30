//
//  JiwokDataBaseManager.h
//  Jiwok
//
//  Created by reubro.
//  Copyright 2010 Jiwok. All rights reserved.
//


 #include <libkern/OSAtomic.h>

#import <sqlite3.h>

@interface JiwokDataBaseManager : NSObject {

	NSString * dbFileName;	//database file name
	sqlite3 *database;		//database pointer
	
	/** Internal lock. Must be held when mutating state. */
    OSSpinLock _lock;
}

@property (readonly) NSString *dbFileName;

+ (NSString *)createUuid; 
- (id)initDBWithFileName:(NSString *)file;
- (BOOL)open:(NSString *)file;
- (void)close;

- (NSString *)errorMsg;

- (NSInteger)executeScalar:(NSString *)sql, ...;
- (NSInteger)executeScalar:(NSString *)sql arguments:(NSArray *)args;

- (NSArray *)executeQuery:(NSString *)sql, ...;
- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)args;

- (BOOL)executeNonQuery:(NSString *)sql, ...;
- (BOOL)executeNonQuery:(NSString *)sql arguments:(NSArray *)args;
- (NSInteger) lastInsertRowId;

@end

