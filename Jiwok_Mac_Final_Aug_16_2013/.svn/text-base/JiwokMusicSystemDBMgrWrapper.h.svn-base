//
//  JiwokMusicSystemDBMgrWrapper.h
//  Jiwok
//
//  Created by reubro.
//  Copyright 2010 Jiwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JiwokDataBaseManager.h"

@interface JiwokMusicSystemDBMgrWrapper : NSObject {
	JiwokDataBaseManager *databaseManager;
}
+ (JiwokMusicSystemDBMgrWrapper*)sharedWrapper;
- (void)initDBMgr;
- (NSArray*) findAllMusicFiles;

- (NSArray*) findAllMusicFilePaths;


- (NSArray*) findAllMusicFiles:(NSString*) theFilePath;
// userselected folders
- (void) insertUserSelectedFolders:(NSMutableDictionary *)valuesDict;
- (BOOL) updateUserSelectedFolders:(NSMutableDictionary *)valuesDict;
- (BOOL) DeleteUserSelectedFolders: (NSString *)pathtoDelete;
- (NSArray*) checkUserSelectedFolderExists: (NSString *)pathtoCheck;
- (NSArray*) checkVolumeForselection: (NSString *)pathtoCheck;
- (NSArray*) GetallUserSelectedFolders;
-(void)changeSelectionStatusOfUserSelectedFolders:(NSString *)filePath;


- (BOOL) isAnyUserFoldersSelected;
// Search selection window store
- (void) insertSearchSelectedFolders:(NSMutableDictionary *)valuesDict;
- (BOOL) DeleteSearchSelectedFolders: (NSString *)pathtoDelete;
- (BOOL) checkSearchSelectedFolderExists: (NSString *)pathtoCheck;
- (NSArray*) GetallSearchSelectedFolders;



// musicfiles table
- (void) insertOrUpdateMusicFiles:(NSMutableDictionary *)valuesDict;
- (void) insertMusicFiles:(NSMutableDictionary *)valuesDict;
- (BOOL) DeleteMusicFiles: (NSString *)pathtoDelete;
- (BOOL) DeleteMusicFilesTemp: (NSString *)pathtoDelete;
- (BOOL) checkForMusicFiles: (NSString *)pathtoCheck;

- (NSArray*) GetCountForGenreFromMusicFiles: (NSString *)GenreTocheck;


-(void)MoveTempMusicToMusic;
-(void)removeMovedFilesFromTemp;


// musicfilestemp table
- (void) insertOrUpdateMusicFilesTemp:(NSMutableDictionary *)valuesDict;
- (BOOL) updateMusicFilesTemp:(NSMutableDictionary *)valuesDict;
- (BOOL) checkForMusicFilesTemp: (NSString *)pathtoCheck;
// musical genre
- (NSString*) getJiwokMusicalGenre:(NSString *) genretoCheck;
- (NSArray*) getAllMusicalGenre;

/// work out
- (NSString*) getWorkoutMp3:(NSString *)idToCheck;
- (NSString*) getTraingingMp3:(NSString *)idToCheck;

-(void)IncrementUsage;
- (NSArray*) SelectFromMusicTableWithoutArguments;
- (NSArray*) SelectFromMusicTable:(NSString*)MinBpm:(NSString*)MaxBpm:(NSString *)selectedFlag;
- (NSMutableArray*)SelectFromMusicTable:(NSString*)MinBpm:(NSString*)MaxBpm:(NSArray*)genreArray:(NSString *)selectedFlag;
-(void)setSelectedFieldInTable:(NSString *)filePath:(NSString *)selectedFlag;
-(void)setSelectedFieldFalse:(NSString*)MinBpm:(NSString*)MaxBpm:(NSArray*)genreArray;
-(void)setUsageFieldInTable:(NSString *)filePath:(NSString *)usageIndex;

-(void)ChangeSongSelectedStatus:(NSString *)SongLocation;


//Application info
- (NSArray*) getApplicationDetails;
- (void) insertApplicationDetails:(NSMutableDictionary *)valuesDict;


// To delete music files when folder is removed from tree
-(BOOL)DeleteMusicFilesInFolder:(NSString *)folderToDelete;
-(BOOL)DeleteTempMusicFilesInFolder:(NSString *)folderToDelete;


@end
