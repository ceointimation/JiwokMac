//
//  IntroVocalsDownload.h
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 12/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "Delegates.h"


@interface GenerateWorkout : NSObject {
	
	NSMutableArray *introArray,*downloadedPathArray,*outroArray,*outroDownloadPathArray,*vocalsArray,*startPosArray,*vocalsDownloadedPathArray,*vocalIdArray,*songsElementsArray,*genreArray,*allVocalsArray;
	NSMutableDictionary *workoutDictionary;
	NSMutableArray *songsArray;
	NSString *orderOfTrainingPgm;
	int queue_id;
	bool fromSpecificSongs,introBgSelected;
	NSString *finalVocalPath;
	id<WorkoutGenerationDelegate>delegate;

}
@property(nonatomic,retain) NSMutableDictionary *workoutDictionary; 

@property(nonatomic,retain) id<WorkoutGenerationDelegate>delegate;

-(void)introDownload:(NSMutableDictionary *)workoutDict;
-(void) BgSongsCreation;
- (NSString *)getFileSize:(NSString*)filePath;
-(void)getIntroOutroBg;

-(void)createBackgroundMusics;

-(NSMutableArray*)arrangeSongs:(NSMutableArray *)tmpArray;

@end
