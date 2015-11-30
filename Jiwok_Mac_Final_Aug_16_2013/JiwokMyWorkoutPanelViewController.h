//
//  JiwokMyWorkoutPanelViewController.h
//  Jiwok
//
//  Created by reubro R on 15/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JiwokWorkoutPopupWndController.h"
#import "GenerateWorkout.h"


@interface JiwokMyWorkoutPanelViewController : NSViewController<WorkoutGenerationDelegate> {
	IBOutlet NSButton	*btnViewWorkout;
	IBOutlet NSButton	*btnSaveWorkout;
	IBOutlet NSTextField *txtLocation;
	IBOutlet NSProgressIndicator *progressBar;
		
	IBOutlet NSButton	*btnWorkoutInQueue;
	
	IBOutlet NSTextField *txtTitle;
	IBOutlet NSTextField *txtDescription;
	IBOutlet NSTextField *txJiwokURL;
	IBOutlet NSTextField *saveLocation;
	
	IBOutlet NSButton	*cancelWorkout;
	
	IBOutlet NSLevelIndicator *levelBar;


	NSString *workOutDirectory;
	IBOutlet NSTableView *myTableView;
	JiwokWorkoutPopupWndController *workoutPopupVC;
	NSTimer * workoutScantimer;
	
	NSString *QueueIDInProgress;
	NSMutableDictionary *currentWorkoutDictionary;
	BOOL cancelButtonPressed;
	
	//NSThread * workoutgenerationThread;
	
	
	int count;
	
	NSTimer *timer;
	
	
	BOOL generationFailed;
}
@property (nonatomic, retain) NSTimer * workoutScantimer;
@property (nonatomic, retain) NSMutableDictionary *currentWorkoutDictionary;



-(IBAction)viewWorkoutAction:(id)sender;
-(IBAction)saveWorkoutAction:(id)sender;
-(IBAction)browseWorkoutAction:(id)sender;
-(IBAction)workoutInQueueAction:(id)sender;

-(IBAction)CancelAction:(id)sender;

// class methods
-(void)generateworkoutMP3;
-(void)updateWorkoutStatus:(NSString *)status;
// timer
-(void) checnandGenerateWorkout: (NSTimer *) theTimer;



@end
