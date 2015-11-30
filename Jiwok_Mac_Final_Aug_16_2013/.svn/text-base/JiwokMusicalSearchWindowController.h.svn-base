//
//  JiwokMusicalSearchWindowController.h
//  Jiwok
//
//  Created by reubro R on 11/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Delegates.h"

@interface JiwokMusicalSearchWindowController : NSWindowController {

	IBOutlet NSButton *myDocuments;
	IBOutlet NSButton *myItunes;
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSProgressIndicator *progressBar;
	NSMutableArray *treedataStore;
	
	id<FolderAdditionDelegate> delegate;
	
	IBOutlet NSButton *searchButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSTextField *headerTitle;
	
	
	BOOL bIterationInProgress;
	BOOL bExitThread;
	NSString * docsDir;
	NSString * itunesDir;
}

@property(nonatomic,retain) NSString * docsDir;
@property(nonatomic,retain) NSString * itunesDir;
@property(nonatomic,retain) id<FolderAdditionDelegate> delegate;


-(IBAction)searchfiles:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)AddOrRemoveItunes:(id)sender;
-(IBAction)AddOrRemoveDocuments:(id)sender;



- (void)iterateMyFolder:(NSString *)itemPath: (NSMutableDictionary *) parent;
- (void)populateFolderTree;
- (void) checkUncheckItem:(id)item:(NSOutlineView *)ov:(id)object forTableColumn:(NSTableColumn *)tableColumn:( NSString *) checkValue;
- (void) syncStatusinDB:(id)item :( NSString *) checkValue;
@end
