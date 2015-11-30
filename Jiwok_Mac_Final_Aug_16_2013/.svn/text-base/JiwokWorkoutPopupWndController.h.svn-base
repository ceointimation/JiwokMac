//
//  JiwokWorkoutPopupWndController.h
//  Jiwok
//
//  Created by reubro R on 19/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Delegates.h"

@interface JiwokWorkoutPopupWndController : NSWindowController {
	IBOutlet NSTableView *myTableView;
	NSMutableArray *dataArray;
	int currentSelection ;
	id<WorkoutGenerationDelegate>delegate;
	IBOutlet NSProgressIndicator *progressBar;
	bool genearteSelected,removeSelected;
	
	IBOutlet NSTextField *noWorkOutMsg;
}
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,retain) id<WorkoutGenerationDelegate>delegate;
- (void)genereateButtonAction:(id)sender;
- (void)removeButtonAction:(id)sender;
- (id)initWithWindowNibName:(NSString *)windowNibName ;
-(void)reloadQueueData;
@end
