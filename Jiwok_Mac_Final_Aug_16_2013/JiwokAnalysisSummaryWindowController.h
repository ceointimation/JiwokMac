//
//  JiwokAnalysisSummaryWindowController.h
//  Jiwok
//
//  Created by reubro R on 05/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JiwokAudioPlayController.h"

@interface JiwokAnalysisSummaryWindowController : NSWindowController {

	IBOutlet NSTableView *myTableView;
	NSMutableArray *dataArray;
	JiwokAudioPlayController *playController;
	int currentSelection;
	
	IBOutlet NSButton *saveButton;
}
@property (nonatomic,retain) NSMutableArray *dataArray;
- (void)playButtonAction:(id)sender;
- (void)stopButtonAction:(id)sender;
- (void)saveButtonAction:(id)sender;
- (id)initWithWindowNibName:(NSString *)windowNibName andlist:(NSMutableArray *) theSongsList;
@end
