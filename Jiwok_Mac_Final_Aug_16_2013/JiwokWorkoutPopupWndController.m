//
//  JiwokWorkoutPopupWndController.m
//  Jiwok
//
//  Created by reubro R on 19/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokWorkoutPopupWndController.h"
#import "Common.h"
#import "LoggerClass.h"
#import "JiwokAPIHelper.h"
#import "JiwokAppDelegate.h"

@implementation JiwokWorkoutPopupWndController
@synthesize dataArray,delegate;

- (id)initWithWindowNibName:(NSString *)windowNibName 
{
    //NSLog(@"Now you are in initWithWindowNibName method in JiwokWorkoutPopupWndController class");
	self = [super initWithWindowNibName:windowNibName];
    if (self) 
	{
			dataArray = [NSMutableArray arrayWithCapacity:0];
	}
	return self;
    //NSLog(@"Now you are completed initWithWindowNibName method in JiwokWorkoutPopupWndController class");
}
-(void)reloadQueueData
{
    DUBUG_LOG(@"Now you are in reloadQueueData method in JiwokWorkoutPopupWndController class");
	[progressBar setHidden:NO];
	[progressBar startAnimation:self];
	
	/// call API and get list
	JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSMutableArray *tempDataArray = [apiHelper InvokeGetAllWorkoutsAPI:appdelegate.loggedusername:@"2"];
	[apiHelper release];
	 NSLog(@"tempDataArray NSMutableArray==%@",tempDataArray);
	dataArray = [[NSMutableArray alloc]initWithArray:tempDataArray copyItems:YES];
	
	DUBUG_LOG(@"reloadQueueData apiHelper gives %@ ",dataArray);
	
	

	
	[myTableView reloadData];
	
	[progressBar setHidden:YES];
	[progressBar stopAnimation:self];
    DUBUG_LOG(@"Now you are completed reloadQueueData method in JiwokWorkoutPopupWndController class");
}
- (void)awakeFromNib
{
	
	 //NSLog(@"Now you are in awakeFromNib method in JiwokWorkoutPopupWndController class");
	//check  for generate button seected or not
	genearteSelected =NO;
	
	removeSelected =NO;
	
	/// call API and get list
	JiwokAPIHelper *apiHelper = [[JiwokAPIHelper alloc]init];
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	NSMutableArray *tempDataArray = [apiHelper InvokeGetAllWorkoutsAPI:appdelegate.loggedusername:@"2"];
	[apiHelper release];
	 NSLog(@"tempDataArray NSMutableArray==%@",tempDataArray);
	dataArray = [[NSMutableArray alloc]initWithArray:tempDataArray copyItems:YES];
		
	DUBUG_LOG(@"apiHelper gives %@ ",dataArray);
	
	if(![dataArray count])
		[noWorkOutMsg setHidden:NO];
	else 
		[noWorkOutMsg setHidden:YES];

	
	NSTableColumn *generateColumn = 
	[myTableView tableColumnWithIdentifier:TABLE_COL_GENERATE]; 
	
	NSTableColumn *removeColumn = 
	[myTableView tableColumnWithIdentifier:TABLE_COL_REMOVE]; 
	
	
	[noWorkOutMsg setStringValue: JiwokLocalizedString(@"INFO_GENERATING_MP3_NO_WORKOUTS")];
	
	
	NSButtonCell *generateBox = [NSButtonCell new]; 
 	[generateBox setButtonType:NSPushInCell];
	[generateBox setBordered:NO];
	[generateBox setTarget:self];
	[generateBox setTitle:JiwokLocalizedString(@"BTN_CAPTION_GENERATE")];
	[generateBox setAction:@selector(genereateButtonAction:)];
    [generateColumn setDataCell:generateBox]; 
	
	
	NSButtonCell *removeBox = [NSButtonCell new]; 
 	[removeBox setButtonType:NSPushInCell];
	[removeBox setBordered:NO];
	[removeBox setTarget:self];
	[removeBox setTitle:JiwokLocalizedString(@"BTN_CAPTION_REMOVE")];
	[removeBox setAction:@selector(removeButtonAction:)];
    [removeColumn setDataCell:removeBox]; 
	
	currentSelection = 0;	
	// NSLog(@"Now you are completed awakeFromNib method in JiwokWorkoutPopupWndController class");
}

#pragma mark  NSTableView data source methods


- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
     //NSLog(@"Now you are in numberOfRowsInTableView method in JiwokWorkoutPopupWndController class");
	return [dataArray count];
     //NSLog(@"Now you are completed numberOfRowsInTableView method in JiwokWorkoutPopupWndController class");
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
	//NSLog(@"Now you are in tableViewSelectionDidChange method in JiwokWorkoutPopupWndController class");
	//NSLog(@"Tabe row selection Tabe row selection");
	
	NSTableView	*tblView = [notification object];
	currentSelection = [tblView selectedRow];
	
	if(genearteSelected)
		{
			//Action for generate button
			DUBUG_LOG(@"genereateButtonAction currentSelection %d ",currentSelection);
			
			NSMutableDictionary *dict = (NSMutableDictionary *)[dataArray objectAtIndex: currentSelection];
			//NSLog(@"Queue id == %@",[dict objectForKey:@"queueId"]);
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			appdelegate.workoutQueueID = [dict objectForKey:@"queueId"];
			[delegate didSelectGenerate];
			
			[progressBar setHidden:YES];
			[progressBar stopAnimation:self];
			[self close];
			
		}
	
	if(removeSelected)
		{
			//Action for remove  button
			DUBUG_LOG(@"removeButtonAction currentSelection %d ",currentSelection);
			
			NSMutableDictionary *dict = (NSMutableDictionary *)[dataArray objectAtIndex: currentSelection];
			//NSLog(@"Queue id == %@",[dict objectForKey:@"queueId"]);
			JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
			appdelegate.workoutQueueID = [dict objectForKey:@"queueId"];
			[delegate didSelectRemove];
		}
	
	genearteSelected =NO;
	removeSelected =YES;
	//	
	//	//NSLog(@"selection %@", currentSelection); 
    //NSLog(@"Now you are completed tableViewSelectionDidChange method in JiwokWorkoutPopupWndController class");
}
- (id)tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row:(int)rowIndex
{
    //NSLog(@"Now you are in (id)tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row:(int)rowIndex method in JiwokWorkoutPopupWndController class");
	id result = nil;
	int cont = [dataArray count];
	NSMutableDictionary *dict = nil;
	if (cont > 0)
	{
		dict = (NSMutableDictionary *)[dataArray objectAtIndex: rowIndex];
		
		if (tableColumn && [[tableColumn identifier] isEqualToString:TABLE_COL_TITLE]) 
		{
			result = [dict objectForKey:@"title"];
		} 

	}
	
	return result;
	//NSLog(@"Now you are completed (id)tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row:(int)rowIndex method in JiwokWorkoutPopupWndController class");
}
- (void)genereateButtonAction:(id)sender
{
	DUBUG_LOG(@"Now you are in genereateButtonAction method in JiwokWorkoutPopupWndController class");
	[progressBar setHidden:NO];
	[progressBar startAnimation:self];
	genearteSelected =YES;
	/*DUBUG_LOG(@"genereateButtonAction currentSelection %d ",currentSelection);
	
	NSMutableDictionary *dict = (NSMutableDictionary *)[dataArray objectAtIndex: currentSelection];
	//NSLog(@"Queue id == %@",[dict objectForKey:@"queueId"]);
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	appdelegate.workoutQueueID = [dict objectForKey:@"queueId"];
	[delegate didSelectGenerate];
	[self close];*/
   DUBUG_LOG(@"Now you are completed genereateButtonAction method in JiwokWorkoutPopupWndController class");
}

- (void)removeButtonAction:(id)sender
{
	DUBUG_LOG(@"Now you are in removeButtonAction method in JiwokWorkoutPopupWndController class");
	removeSelected =YES;
	/*DUBUG_LOG(@"removeButtonAction currentSelection %d ",currentSelection);
	
	NSMutableDictionary *dict = (NSMutableDictionary *)[dataArray objectAtIndex: currentSelection];
	//NSLog(@"Queue id == %@",[dict objectForKey:@"queueId"]);
	JiwokAppDelegate * appdelegate = (JiwokAppDelegate*) [[NSApplication sharedApplication] delegate];
	appdelegate.workoutQueueID = [dict objectForKey:@"queueId"];
	[delegate didSelectRemove];*/
    DUBUG_LOG(@"Now you are completed removeButtonAction method in JiwokWorkoutPopupWndController class");
}
@end
