//
//  JiwokMusicalSearchWindowController.m
//  Jiwok
//
//  Created by reubro R on 11/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokMusicalSearchWindowController.h"
#import "JiwokUtil.h"
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "LoggerClass.h"
#import"Variable.h"

@implementation JiwokMusicalSearchWindowController

@synthesize docsDir,itunesDir,delegate;



- (void)awakeFromNib
{
    DUBUG_LOG(@"Now you are in awakeFromNib method in JiwokMusicalSearchWindowController class");
	int checkboxColumnIndex; 
    NSTableColumn *checkboxColumn = 
	[outlineView tableColumnWithIdentifier:CHECK_KEY]; 
    NSButtonCell *checkbox = [NSButtonCell new]; 
    [checkbox setButtonType:NSSwitchButton]; 
    [checkbox setTitle:@""]; 
	[checkbox setState:NSOnState];
    [checkbox setImagePosition:NSImageOnly]; 
    [checkboxColumn setDataCell:checkbox]; 
    checkboxColumnIndex = [outlineView columnWithIdentifier:CHECK_KEY]; 
    [outlineView moveColumn:checkboxColumnIndex toColumn:0]; 
	[progressBar setHidden:NO];
	[progressBar startAnimation:self];

	
	NSString *imageNameSearch = [[NSString alloc] initWithFormat:@"search_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[searchButton setImage:[NSImage imageNamed:imageNameSearch]];
	////NSLog(@"imageNameSearch imageNameSearch imageNameSearch is %@",imageNameSearch);
	
	[imageNameSearch release];

	NSString *imageNameCancel = [[NSString alloc] initWithFormat:@"cancel_Normal_%@.JPG",[JiwokUtil GetShortCurrentLocale]];
	[cancelButton setImage:[NSImage imageNamed:imageNameCancel]];
	

	
	[imageNameCancel release];

	
	
	[headerTitle setStringValue: JiwokLocalizedString(@"MUSICAL_SEARCH_TITLE")];
	[myDocuments setTitle:JiwokLocalizedString(@"MY_DOCUMENTS")];
	[myItunes setTitle:JiwokLocalizedString(@"MY_ITUNES")];

	
	
	self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//self.itunesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Music/iTunes/iTunes Media/Music"];	
	self.itunesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Music/iTunes"];	
	
	
	//if ([[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkSearchSelectedFolderExists:self.docsDir])
		if ([[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:self.docsDir]count]>0)

	{
		[myDocuments setState:1];
	}
	else
	{
		[myDocuments setState:0];
	}

	//if ([[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkSearchSelectedFolderExists:self.itunesDir])
		
	NSArray *itunesArray=[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:self.itunesDir];
	NSLog(@"itunesArray==%@",itunesArray);
		if ([itunesArray count]>0)		
	{
		[myItunes setState:1];
	}
	else
	{
		[myItunes setState:0];
	}
	
	[NSThread detachNewThreadSelector:@selector(populateFolderTree) toTarget:self withObject:nil];
    DUBUG_LOG(@"Now you are completed awakeFromNib method in JiwokMusicalSearchWindowController class");
}


-(IBAction)AddOrRemoveItunes:(id)sender{
DUBUG_LOG(@"Now you are in AddOrRemoveItunes method in JiwokMusicalSearchWindowController class");
	NSButton *sendingB=(NSButton *)sender; 
	
	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:self.itunesDir];
	
	if([sendingB state]==1){
		
		NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
		[foldersDict setObject:[self.itunesDir lastPathComponent] forKey:DB_KEY_FOLDER_NAME];
		[foldersDict setObject:self.itunesDir forKey:DB_KEY_PATH];
		[foldersDict setObject:DB_VAL_TRUE forKey:DB_KEY_SELECTED];
		NSLog(@"foldersDict==%@",foldersDict);
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];
				
		[foldersDict release];
		
	
	}
DUBUG_LOG(@"Now you are completed AddOrRemoveItunes method in JiwokMusicalSearchWindowController class");
}

-(IBAction)AddOrRemoveDocuments:(id)sender{
    NSLog(@"Now you are in AddOrRemoveDocuments method in JiwokMusicalSearchWindowController class");
	NSButton *sendingB=(NSButton *)sender; 	
	
	[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:self.docsDir];	
	
	if([sendingB state]==1){		
		NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
		[foldersDict setObject:[self.docsDir lastPathComponent] forKey:DB_KEY_FOLDER_NAME];
		[foldersDict setObject:self.docsDir forKey:DB_KEY_PATH];
		[foldersDict setObject:DB_VAL_TRUE forKey:DB_KEY_SELECTED];
		NSLog(@"foldersDict==%@",foldersDict);
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];
		
		[foldersDict release];							
	}	
   DUBUG_LOG(@"Now you are completed AddOrRemoveDocuments method in JiwokMusicalSearchWindowController class");
}








-(IBAction)searchfiles:(id)sender
{
DUBUG_LOG(@"Now you are in searchfiles method in JiwokMusicalSearchWindowController class");
	if (bIterationInProgress)
	{
		return;
	}
	
	DUBUG_LOG(@"docs dir -> %@",self.docsDir);
	DUBUG_LOG(@"itunes dir -> %@",self.itunesDir );


 	if ([myDocuments state] == 1)
	{
		if (![[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkSearchSelectedFolderExists:self.docsDir])
		{

			NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
			[foldersDict setObject:[self.docsDir lastPathComponent] forKey:DB_KEY_FOLDER_NAME];
			[foldersDict setObject:self.docsDir forKey:DB_KEY_PATH];
			[foldersDict setObject:DB_VAL_FALSE forKey:DB_KEY_SELECTED];
			NSLog(@"foldersDict==%@",foldersDict);
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertSearchSelectedFolders:foldersDict];
			//[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];

			[foldersDict release];
		}

	}

	else
	{
		// delete settings from DB
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteSearchSelectedFolders:self.docsDir];
	}
	
	
	if ([myItunes state] == 1)
	{
		if (![[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkSearchSelectedFolderExists:self.itunesDir])
		{
			NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
			[foldersDict setObject:[self.itunesDir lastPathComponent] forKey:DB_KEY_FOLDER_NAME];
			[foldersDict setObject:self.itunesDir forKey:DB_KEY_PATH];
			[foldersDict setObject:DB_VAL_FALSE forKey:DB_KEY_SELECTED];
			NSLog(@"foldersDict==%@",foldersDict);
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertSearchSelectedFolders:foldersDict];
			//[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];

			
			[foldersDict release];
		}
	}
	else
	{
		// delete settings from DB
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteSearchSelectedFolders:self.itunesDir];
	}
	
	shouldAnalyzeSongs=YES;
	
	//NSLog(@"delegate delegate is>>>>> %@",delegate);

	
	
	[self setShouldCloseDocument:YES];

	//[super close]; 
	[self close];
	
	
	//[self.window performClose:self];
	
	
	[delegate didAddFolder];

	
DUBUG_LOG(@"Now you are completed searchfiles method in JiwokMusicalSearchWindowController class");
}
- (void)iterateMyFolder:(NSString *)itemPath: (NSMutableDictionary *) parent
{
 DUBUG_LOG(@"Now you are in iterateMyFolder method in JiwokMusicalSearchWindowController class");
	@try{
	
	if(bExitThread)
	{
		return;
	}
	//NSLog(@"iterateMyFolder itemPath  %@ parent %@",itemPath,parent);
	
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemPath error:nil];
        NSLog(@"files==%@",files);
	for (NSString *element in files)
	{
		// we need to reconstruct the full path of the object since 'directoryContentsAtPath' only gives us the object name
		NSString *urlStr = [itemPath stringByAppendingPathComponent:element];
		if ([JiwokUtil isvalidFolder:urlStr] )
		{
			if (![JiwokUtil isSkipItemPackage:urlStr])
			{
				// node item
				NSMutableDictionary *nodeitem = [[[NSMutableDictionary alloc] init] autorelease];
				
				NSMutableArray *children =  [parent objectForKey:CHILD_KEY]; 
                 NSLog(@"children==%@",children);
				if (children  && [children count] > 0)
				{
					////NSLog(@" adding to child array  %@",element);
					[nodeitem setObject:urlStr forKey:NAME_KEY];
					[nodeitem setObject:[[NSFileManager defaultManager] displayNameAtPath:urlStr] forKey:DESC_KEY];
				 NSLog(@"nodeitem==%@",nodeitem);
					if([[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr]count]>0)
					{
						//[nodeitem setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
						
						NSString *checkValue=[[[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr] objectAtIndex:0] objectForKey:@"Selected"];
						if([checkValue isEqualToString:@"false"])
							[nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];						
						else 
							[nodeitem setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
							
					}
					else {
						[nodeitem setObject:[parent objectForKey:CHECK_KEY] forKey:CHECK_KEY];
					}

					
					//NSLog(@"iterateMyFolder iterateMyFolder is %@",nodeitem);
					
						
						//[nodeitem setObject:[parent objectForKey:CHECK_KEY] forKey:CHECK_KEY];
					
					//[nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
					[children addObject:nodeitem];
				}
				else
				{
					////NSLog(@" creating child array  %@",itemPath);
					NSMutableArray *childArray = [[[NSMutableArray alloc] init] autorelease];
					[nodeitem setObject:urlStr forKey:NAME_KEY];
					[nodeitem setObject:[[NSFileManager defaultManager] displayNameAtPath:urlStr] forKey:DESC_KEY];
				
					NSLog(@"nodeitem==%@",nodeitem);
					
					if([[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr]count]>0)
					{
						//[nodeitem setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
						
						NSString *checkValue=[[[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlStr] objectAtIndex:0] objectForKey:@"Selected"];
						if([checkValue isEqualToString:@"false"])
							[nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];						
						else 
							[nodeitem setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
					}
					else {
						[nodeitem setObject:[parent objectForKey:CHECK_KEY] forKey:CHECK_KEY];
					}
					
					
					
					//[nodeitem setObject:[parent objectForKey:CHECK_KEY] forKey:CHECK_KEY];

					
					//[nodeitem setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
					[parent setObject:childArray forKey:CHILD_KEY];	
					[childArray addObject:nodeitem];
                    NSLog(@"parent nsmutable dictionary==%@",parent);
                    NSLog(@"childArray array==%@",parent);
				}
				
				////NSLog(@" Visbile normal items  %@",urlStr);
				//[self iterateMyFolder:urlStr:nodeitem];
			}
		}
	}
        DUBUG_LOG(@"Now you are completed iterateMyFolder method in JiwokMusicalSearchWindowController class");
 }
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in syncStatusinDB %@",[ex description]];
	}
	
	
	
}
- (void)populateFolderTree
{
     DUBUG_LOG(@"Now you are in populateFolderTree method in JiwokMusicalSearchWindowController class");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//@synchronized
	@try
	{
		bIterationInProgress = YES;
		
		[progressBar setHidden:NO];
		
		[[LoggerClass getInstance] logData:@"checking folders"];

		NSArray *drives = [[NSWorkspace sharedWorkspace]mountedLocalVolumePaths];	

		  NSLog(@"drives array==%@",drives);
		if (drives)
		{
			if (treedataStore)
			{
				[treedataStore release];
				treedataStore = nil;
			}
			treedataStore = [[NSMutableArray alloc] init];
			
			for (NSString * item in drives)
			{
				////NSLog(@" itemmm ---> %@",[[NSFileManager defaultManager] displayNameAtPath:item]);
				if ([JiwokUtil isNetworkMountAtPath:item])
				{
					[[LoggerClass getInstance] logData:@"network drive skipping"];
					continue;
				}
				
				NSMutableDictionary *parent = [[NSMutableDictionary alloc] init];
				[parent setObject:item forKey:NAME_KEY];
				[parent setObject:[[NSFileManager defaultManager] displayNameAtPath:item] forKey:DESC_KEY];
				
				if([[[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:item]count]>0)
				{
					[parent setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
	
				}
					
				else {
					[parent setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];

				}

				//[parent setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
				
				
				//parent = [self itemWithName:item description:[[NSFileManager defaultManager] displayNameAtPath:item] andChildren:nil];
				////NSLog(@" initial parent ------->>> ---- %@",parent);
				
								
				[self iterateMyFolder:item : parent];
				// [parent addObject:item9];
				[treedataStore addObject:parent];
                 NSLog(@"parent nsmutable dictionary==%@",parent);
				[parent release];
			}
		}	
		[outlineView reloadData];
		//[delegate didCompleteIteration];
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];

		bIterationInProgress = NO;
		[[LoggerClass getInstance] logData:@"checking folders complete"];
	}
	@catch(NSException *ex)
	{
		[[LoggerClass getInstance] logData:@"Exception occured in populateFolderTree %@",[ex description]];
	}
	@finally 
	{
		[progressBar stopAnimation:self];
		[progressBar setHidden:YES];
	}
	[pool release];
   DUBUG_LOG(@"Now you are completed populateFolderTree method in JiwokMusicalSearchWindowController class");
}


-(IBAction)cancel:(id)sender
{
    DUBUG_LOG(@"Now you are in cancel method in JiwokMusicalSearchWindowController class");
	bExitThread = YES;
	[progressBar stopAnimation:self];
	[progressBar setHidden:YES];
	[self close];
    DUBUG_LOG(@"Now you are completed cancel method in JiwokMusicalSearchWindowController class");
}
- (void)dealloc {

	DUBUG_LOG(@"dealloc for music search view ");
	
	[self.docsDir release];
	[self.itunesDir release];
	[super dealloc];
}

- (void) windowWillClose:(NSNotification *) notification
{
	//NSLog(@"WINDOW WILL CLOSE");
  DUBUG_LOG(@"Now you are in windowWillClose method in JiwokMusicalSearchWindowController class");
	[delegate searchWindowClosed];
    DUBUG_LOG(@"Now you are completed windowWillClose method in JiwokMusicalSearchWindowController class");
}


#pragma mark  NSOutlineView data source methods
- (void) syncStatusinDB:(id)item:( NSString *) checkValue
{
    DUBUG_LOG(@"Now you are in syncStatusinDB method in JiwokMusicalSearchWindowController class");
	@try{
	
	NSString * urlPath = [item objectForKey:NAME_KEY];
	BOOL bFoundInDB = NO;
	NSArray * selectedValuesArray = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] checkUserSelectedFolderExists:urlPath];
	if ([selectedValuesArray count] > 0)
	{
		bFoundInDB = YES;
	}
	
	//E:\FromCDs\FLASH 8
	if (bFoundInDB)
	{
		////NSLog(@" found in db ");
		if ([checkValue intValue] == 1) // 1 to 0
		{ 
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] DeleteUserSelectedFolders:urlPath];
		}
	}
	else // not found in DB, so insert
	{
		if ([checkValue intValue] == 0) // 0 to 1
		{
			////NSLog(@"not found in db ");
			NSMutableDictionary *foldersDict = [[NSMutableDictionary alloc]init];
			[foldersDict setObject:[urlPath lastPathComponent] forKey:DB_KEY_FOLDER_NAME];
			[foldersDict setObject:urlPath forKey:DB_KEY_PATH];
			[foldersDict setObject:DB_VAL_TRUE forKey:DB_KEY_SELECTED];
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertUserSelectedFolders:foldersDict];
             NSLog(@"foldersDict nsmutable dictionary==%@",foldersDict);
			[foldersDict release];
		}
	}
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in syncStatusinDB %@",[ex description]];
	}	
    DUBUG_LOG(@"Now you are completed syncStatusinDB method in JiwokMusicalSearchWindowController class");
}

- (void) checkUncheckItem:(id)item:(NSOutlineView *)ov:(id)object forTableColumn:(NSTableColumn *)tableColumn:( NSString *) checkValue
{	
    DUBUG_LOG(@"Now you are in checkUncheckItem method in JiwokMusicalSearchWindowController class");
	NSLog(@"checkUncheckItem checkUncheckItem");
	
	@try{
		
	NSString *theKey = [tableColumn identifier];
    GET_CHILDREN;
    if ((children) || ([children count] > 1)) 
	{
		////NSLog(@"selection check box for parent %@",checkValue);
		if ([theKey compare:CHECK_KEY] == NSOrderedSame) 
		{
			NSArray * children = [item objectForKey:CHILD_KEY];
			////NSLog(@"child %@",children);
			for (NSMutableDictionary *element in children)
			{
				[self checkUncheckItem:element:ov:object forTableColumn:tableColumn:checkValue];
			}
			if ([checkValue intValue] == 1)
			{
				[item setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
			}
			else
			{
				[item setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
			}
			[self syncStatusinDB:item:checkValue];
			[ov reloadItem:item reloadChildren:YES];
		} 		
	}
	else
	{
		if ([theKey compare:CHECK_KEY] == NSOrderedSame) 
		{
			
			//[self checkUncheckItem:item:ov:object forTableColumn:tableColumn];
			////NSLog(@"selection check box for node %@",checkValue);
			if ([checkValue intValue] == 1)
			{
				/// changed from 1 to 0
				[item setObject:[NSNumber numberWithBool:NO] forKey:CHECK_KEY];
			}
			else
			{
				/// changed from 0 to 1
				[item setObject:[NSNumber numberWithBool:YES] forKey:CHECK_KEY];
			}
			[self syncStatusinDB:item:checkValue];
			[ov reloadItem:item reloadChildren:YES];
			
		}
	}
	}
	
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in checkUncheckItem %@",[ex description]];
	}
	DUBUG_LOG(@"Now you are completed checkUncheckItem method in JiwokMusicalSearchWindowController class");
}


// required
- (id)outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item
{
    // item is an NSDictionary...
    DUBUG_LOG(@"Now you are in outlineView method in JiwokMusicalSearchWindowController class");
    GET_CHILDREN;
    if ((!children) || ([children count] <= index)) return nil;
    return [children objectAtIndex:index];
   
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{	
	DUBUG_LOG(@"Now you are in outlineView:(NSOutlineView *)ov isItemExpandable:(id)item method in JiwokMusicalSearchWindowController class");
    GET_CHILDREN;
    if ((!children) || ([children count] < 1)) return NO;
	else 
    return YES;
    DUBUG_LOG(@"Now you are completed outlineView:(NSOutlineView *)ov isItemExpandable:(id)item method in JiwokMusicalSearchWindowController class");
}

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
   DUBUG_LOG(@"Now you are in (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item method in JiwokMusicalSearchWindowController class");
    GET_CHILDREN;
    return [children count];
   // NSLog(@"Now you are completed (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item method in JiwokMusicalSearchWindowController class");

}
- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)ov
{
    DUBUG_LOG(@"Now you are in selectionShouldChangeInOutlineView method in JiwokMusicalSearchWindowController class");
	return YES;
    // NSLog(@"Now you are completed selectionShouldChangeInOutlineView method in JiwokMusicalSearchWindowController class");
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{	
	/*
	NSOutlineView				*outView			= [notification object];
	int							selectedRow			= [outView selectedRow];
	id							item				= [outView itemAtRow:selectedRow];

	//NSString *itemPath = [item objectForKey:NAME_KEY];
	
*/
	
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification{
/*
	NSOutlineView				*outView			= [notification object];
	int							selectedRow			= [outView rowForItem:[[notification userInfo] objectForKey:@"NSObject"]];
	id							item				= [outView itemAtRow:selectedRow];
	
	//NSString *itemPath = [item objectForKey:NAME_KEY];
	*/
	
}

- (void)outlineViewItemWillExpand:(NSNotification *)notification{

//	NSOutlineView				*outView			= [notification object];
//	int							selectedRow			= [outView rowForItem:[[notification userInfo] objectForKey:@"NSObject"]];
//	id							item				= [outView itemAtRow:selectedRow];
//	
	//NSString *itemPath = [item objectForKey:NAME_KEY];
		DUBUG_LOG(@"Now you are in outlineViewItemWillExpand method in JiwokMusicalSearchWindowController class");
	for(int i=0;i<[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] count];i++)
	{		
		
	[self iterateMyFolder:[[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i] objectForKey:@"NAME"]:[[[[notification userInfo] objectForKey:@"NSObject"] objectForKey:@"children"] objectAtIndex:i]];
	
	}	
    DUBUG_LOG(@"Now you are completed outlineViewItemWillExpand method in JiwokMusicalSearchWindowController class");
}

- (void)outlineViewColumnDidMove:(NSNotification *)notification{

	//NSOutlineView				*outView			= [notification object];
//	int							selectedRow			= [outView selectedRow];
//	id							item				= [outView itemAtRow:selectedRow];
	
	//NSString *itemPath = [item objectForKey:NAME_KEY];
	
}


- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    DUBUG_LOG(@"Now you are in objectValueForTableColumn method in JiwokMusicalSearchWindowController class");
    return [item objectForKey:[tableColumn identifier]];
    //NSLog(@"Now you are completed objectValueForTableColumn method in JiwokMusicalSearchWindowController class");
}


- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{ 
    DUBUG_LOG(@"Now you are in outlineView:(NSOutlineView *)ov setObjectValue method in JiwokMusicalSearchWindowController class");
	@try{
	[progressBar setHidden:NO];
	[progressBar startAnimation:self];	
	// This method handles changes to the items.
    NSString *theKey = [tableColumn identifier];
	NSString *oldValue = [item objectForKey:theKey];
	[self checkUncheckItem:item:ov:object forTableColumn:tableColumn:oldValue];
	[progressBar stopAnimation:self];
	[progressBar setHidden:YES];
	}
	@catch(NSException *ex)
	{
		DUBUG_LOG(@"@catch");
		[[LoggerClass getInstance] logData:@"Exception occured in setObjectValue %@",[ex description]];
	}
   DUBUG_LOG(@"Now you are completed outlineView:(NSOutlineView *)ov setObjectValue method in JiwokMusicalSearchWindowController class");
}

@end
