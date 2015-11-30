//
//  JiwokAnalysisSummaryWindowController.m
//  Jiwok
//
//  Created by reubro R on 05/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokAnalysisSummaryWindowController.h"
#import "JiwokMusicSystemDBMgrWrapper.h"
#import "Common.h"
#import "LoggerClass.h"


@implementation JiwokAnalysisSummaryWindowController
@synthesize dataArray;

- (id)initWithWindowNibName:(NSString *)windowNibName andlist:(NSMutableArray *) theSongsList
{
    DUBUG_LOG(@"Now you are in initWithWindowNibName method in JiwokAnalysisSummaryWindowController class");
	self = [super initWithWindowNibName:windowNibName];
    if (self) 
	{
		
		
		////NSLog(@" tempMusicData got theSongsList--- > %@ ",theSongsList);
		
		//return nil;
		
		dataArray = [[NSMutableArray alloc]init];
		
		NSArray *genrelistTemp = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getAllMusicalGenre];
		
		NSMutableArray * genrelist = [[[NSMutableArray alloc]init] autorelease];
		for (int index = 0 ;index < [genrelistTemp count] ; index++)
		{
			
				DUBUG_LOG(@"for (int index = 0 ;index < [genrelistTemp count] ; index++)   i is %d",index);
			
			NSMutableDictionary *dicTemp = [genrelistTemp objectAtIndex:index];
			NSString * genre = [dicTemp objectForKey:DB_KEY_JIWOK_GENRE_IN_GENRELIST];
			 NSLog(@"dicTemp NSMutableDictionary==%@",dicTemp);
			if(!([genre isEqualToString:@"test"] ||[genre isEqualToString:@"Loundge"] || [genre isEqualToString:@"loundge"] || [genre isEqualToString:@"save no use"]))
			[genrelist addObject:genre];
		}
		//dataArray =  theSongsList;
		for (int index = 0 ;index < [theSongsList count] ; index++)
		{
			
			DUBUG_LOG(@"		for (int index = 0 ;index < [theSongsList count] ; index++)  i is %@",[theSongsList objectAtIndex:index]);
			
			NSMutableDictionary *dict = [theSongsList objectAtIndex:index];
			
			NSMutableDictionary *summarydic = [[NSMutableDictionary alloc]init];
			[summarydic setObject:[dict objectForKey:DB_KEY_FILENAME] forKey:DB_KEY_FILENAME];
			[summarydic setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];
			NSString * jiwok_gnre = [dict objectForKey:DB_KEY_JIWOK_GENRE];
			if ([jiwok_gnre isEqualToString:@""] || jiwok_gnre == nil)
			{
				DUBUG_LOG(@"		if ([jiwok_gnre isEqualToString:@""] < [   jiwok_gnre= %@  [genrelist objectAtIndex:0] is %@",jiwok_gnre,[genrelist objectAtIndex:0]);
				
				[summarydic setObject:[genrelist objectAtIndex:0] forKey:DB_KEY_JIWOK_GENRE];
			}
			else
			{
				
				DUBUG_LOG(@"		if ([jiwok_gnre isEqualToString:@""]  else else [   jiwok_gnre= %@",jiwok_gnre);
				[summarydic setObject:[dict objectForKey:DB_KEY_JIWOK_GENRE] forKey:DB_KEY_JIWOK_GENRE];
			}
			[summarydic setObject:genrelist forKey:COMBO_VALUES];
			
			NSLog(@"summarydic %@",summarydic);
			////NSLog(@"dataArray is %@",dataArray);
			
			[dataArray addObject:summarydic];
			[summarydic release];
			
			DUBUG_LOG(@"if ([jiwok_gnre isEqualToString:@""]  else else after releasing ");

			
		}
		
			
    }
//	[self showWindow:self];
    DUBUG_LOG(@"Now you are completed initWithWindowNibName method in JiwokAnalysisSummaryWindowController class");
   return self;
    
}
- (void)awakeFromNib
{

//	NSArray *genrelistTemp = [[JiwokMusicSystemDBMgrWrapper sharedWrapper] getAllMusicalGenre];
//
//	NSMutableArray * genrelist = [[[NSMutableArray alloc]init] autorelease];
//	for (int index = 0 ;index < [genrelistTemp count] ; index++)
//	{
//		NSMutableDictionary *dicTemp = [genrelistTemp objectAtIndex:index];
//		NSString * genre = [dicTemp objectForKey:DB_KEY_JIWOK_GENRE_IN_GENRELIST];
//		[genrelist addObject:genre];
//	}
//	[dic setObject:genrelist forKey:COMBO_VALUES];
	
//	dataArray  = [[NSMutableArray alloc]init];
//	for (int index1 = 0 ;index1 < 5 ; index1++)
//	{
//		
//	NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//	[dic setObject:@"samplefile" forKey:TABLE_COL_FILENAME];
//	[dic setObject:@"samplepath" forKey:TABLE_COL_FILEPATH];
//		
//	[dic setObject:@"Play" forKey:TABLE_COL_JIWOK_PLAY];
//	[dic setObject:[genrelist objectAtIndex:0] forKey:TABLE_COL_JIWOK_GENRE];
//	[dic setObject:genrelist forKey:COMBO_VALUES];
//	
//	[dataArray addObject:dic];
//	}
//	//NSLog(@"genrelist %@",genrelist);
	

   // NSTableColumn *checkboxColumn = 
//	[myTableView tableColumnWithIdentifier:TABLE_COL_JIWOK_PLAY]; 
//    JiwokSummaryPlayActionCell *playBox = [[JiwokSummaryPlayActionCell alloc]init]; 
//
//    [checkboxColumn setDataCell:playBox]; 
 
	NSLog(@"Now you are in awakeFromNib method in JiwokAnalysisSummaryWindowController class");
	 NSTableColumn *playColumn = 
		[myTableView tableColumnWithIdentifier:TABLE_COL_JIWOK_PLAY]; 

	NSTableColumn *stopColumn = 
	[myTableView tableColumnWithIdentifier:TABLE_COL_JIWOK_STOP]; 

	
	NSButtonCell *playBox = [NSButtonCell new]; 
 	[playBox setButtonType:NSCellHasOverlappingImage];
	[playBox setBordered:NO];
	[playBox setTarget:self];
	[playBox setImage:[NSImage imageNamed:@"playbutton.png"]];
	[playBox setAction:@selector(playButtonAction:)];
    [playBox setImagePosition:NSImageOnly]; 
    [playColumn setDataCell:playBox]; 

	
	NSButtonCell *stopBox = [NSButtonCell new]; 
 	[stopBox setButtonType:NSCellHasOverlappingImage];
	[stopBox setBordered:NO];
	[stopBox setTarget:self];
	[stopBox setImage:[NSImage imageNamed:@"stopbutton.png"]];
	[stopBox setAction:@selector(stopButtonAction:)];
    [stopBox setImagePosition:NSImageOnly]; 
    [stopColumn setDataCell:stopBox]; 
	
	currentSelection = 0;	
	
	
	[saveButton setTitle:JiwokLocalizedString(@"SAVE")];
    NSLog(@"Now you are completed awakeFromNib method in JiwokAnalysisSummaryWindowController class");
}
- (void)playButtonAction:(id)sender
{
	// if the buttonCell is clicked, this method should be invoked
    ////NSLog(@"playing! :)");
    DUBUG_LOG(@"Now you are in playButtonAction method in JiwokAnalysisSummaryWindowController class");
	int cont = [dataArray count];
	NSMutableDictionary *dict = nil;
	if (cont > 0  && currentSelection >= 0)
	{
		//NSLog(@"currentSelection! : %d",currentSelection);
		
		dict = (NSMutableDictionary *)[dataArray objectAtIndex: currentSelection];
		NSString *filePath  = [dict objectForKey:DB_KEY_FILEPATH];
		 NSLog(@"dict NSMutableDictionary==%@",dict);
		//NSLog(@"currentSelection! : %@",filePath);
		
		
		if (playController)
		{
			[playController stopMusic];
			[playController release];
		}
		playController =[[JiwokAudioPlayController alloc] init];
		[playController playMusic:filePath];
	}
    DUBUG_LOG(@"Now you are completed playButtonAction method in JiwokAnalysisSummaryWindowController class");
}

- (void)stopButtonAction:(id)sender
{
	// if the buttonCell is clicked, this method should be invoked
    //NSLog(@"stoping! :)");
   DUBUG_LOG(@"Now you are in stopButtonAction method in JiwokAnalysisSummaryWindowController class");
	[playController stopMusic];
    DUBUG_LOG(@"Now you are completed stopButtonAction method in JiwokAnalysisSummaryWindowController class");
}

- (void)saveButtonAction:(id)sender
{
    DUBUG_LOG(@"Now you are in saveButtonAction method in JiwokAnalysisSummaryWindowController class");
	for (int index = 0 ;index < [dataArray count] ; index++)
	{
		NSMutableDictionary *dict = [dataArray objectAtIndex:index];
		//NSLog(@"Dictionary of lastfm analysed object==== %@",dict);
	
		NSMutableDictionary * dbdict = [[NSMutableDictionary alloc]init];
		[dbdict setObject:[dict objectForKey:DB_KEY_FILEPATH] forKey:DB_KEY_FILEPATH];
		
		[dbdict setObject:[dict objectForKey:DB_KEY_JIWOK_GENRE] forKey:DB_KEY_JIWOK_GENRE];
		
		
		//if(!([dict objectForKey:DB_KEY_JIWOK_GENRE] ==nil || [[dict objectForKey:DB_KEY_JIWOK_GENRE] isEqualToString:@"nil"] || [[dict objectForKey:DB_KEY_ARTIST] isEqualToString:@"nil"] || [dict objectForKey:DB_KEY_ARTIST]  ==nil || [[dict objectForKey:DB_KEY_ALBUM] isEqualToString:@"nil"] || [dict objectForKey:DB_KEY_ALBUM] ==nil)){
		
		
			/*if(!([dict objectForKey:DB_KEY_JIWOK_GENRE] ==nil || [[dict objectForKey:DB_KEY_JIWOK_GENRE] isEqualToString:@"nil"])){
			
			//NSLog(@"entering to latfm loop");
			
			[[JiwokMusicSystemDBMgrWrapper sharedWrapper] insertOrUpdateMusicFiles:dict];	
		}*/		
		
		   [[JiwokMusicSystemDBMgrWrapper sharedWrapper]updateMusicFilesTemp:dbdict];

		// Newly added to update MusicFiles
		
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] MoveTempMusicToMusic];
		
		[[JiwokMusicSystemDBMgrWrapper sharedWrapper] removeMovedFilesFromTemp];
		 NSLog(@"dbdict NSMutableDictionary==%@",dbdict);
		[dbdict release];
		
	}
	
	if (playController)
	{
		[playController stopMusic];
		[playController release];
	}
	
	
	[self close];
   DUBUG_LOG(@"Now you are completed saveButtonAction method in JiwokAnalysisSummaryWindowController class");
}
#pragma mark  NSTableView data source methods


- (int)numberOfRowsInTableView: (NSTableView*)aTableView
{
    NSLog(@"Now you are in numberOfRowsInTableView method in JiwokAnalysisSummaryWindowController class");
	return [dataArray count];
     NSLog(@"Now you are completed numberOfRowsInTableView method in JiwokAnalysisSummaryWindowController class");
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
     NSLog(@"Now you are in tableViewSelectionDidChange method in JiwokAnalysisSummaryWindowController class");
	NSTableView	*tblView = [notification object];
	currentSelection = [tblView selectedRow];
    NSLog(@"Now you are completed tableViewSelectionDidChange method in JiwokAnalysisSummaryWindowController class");
//	
//	//NSLog(@"selection %@", currentSelection); 
}
- (id)tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row:(int)rowIndex
{
    NSLog(@"Now you are in objectValueForTableColumn method in JiwokAnalysisSummaryWindowController class");
	id result = nil;
	int cont = [dataArray count];
	NSMutableDictionary *dict = nil;
	if (cont > 0)
	{

		
		dict = (NSMutableDictionary *)[dataArray objectAtIndex: rowIndex];
		 NSLog(@"dict NSMutableDictionary==%@",dict);
		if (tableColumn && [[tableColumn identifier] isEqualToString:TABLE_COL_FILENAME]) 
		{
			result = [dict objectForKey:DB_KEY_FILENAME];
		} 
		else if (tableColumn && [[tableColumn identifier] isEqualToString:TABLE_COL_FILEPATH]) 
		{
			result = [dict objectForKey:DB_KEY_FILEPATH];
		} 
		
		else if ([[tableColumn identifier] isEqualToString:TABLE_COL_JIWOK_GENRE]) 
		{
			result = [dict objectForKey:DB_KEY_JIWOK_GENRE];
			////NSLog(@"tag -> object value  %@",[dict objectForKey:DB_KEY_JIWOK_GENRE]);
		}  
		
		
	}
	
	return result;
	NSLog(@"Now you are completed objectValueForTableColumn method in JiwokAnalysisSummaryWindowController class");
}
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSLog(@"Now you are in setObjectValue method in JiwokAnalysisSummaryWindowController class");
	if (tableColumn && [[tableColumn identifier] isEqualToString:TABLE_COL_JIWOK_GENRE]) 
	{
	NSMutableDictionary *dic = [dataArray objectAtIndex:row];

//	NSMutableArray *myArray = [dic objectForKey:COMBO_VALUES];
//	NSUInteger index =  ([myArray indexOfObject:object]);
//	//NSLog(@"prsenr   %@", dic);
	
	[dic setObject:object forKey:DB_KEY_JIWOK_GENRE];
		   NSLog(@"dic NSMutableDictionary==%@",dic);
	//NSLog(@"Object got after %@", object);
	}
    NSLog(@"Now you are completed setObjectValue method in JiwokAnalysisSummaryWindowController class");
}

-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)index
{
    NSLog(@"Now you are in willDisplayCell method in JiwokAnalysisSummaryWindowController class");
	if([[tableColumn identifier] isEqual:TABLE_COL_JIWOK_GENRE] && [cell isKindOfClass:[NSComboBoxCell class]])
	{
		NSMutableDictionary *dic = [dataArray objectAtIndex:index];

		
		[cell setRepresentedObject:[dic objectForKey:COMBO_VALUES]];
		[cell reloadData];
		

		
		//[cell selectItemAtIndex:[self comboBoxCell:cell indexOfItemWithStringValue:[dic objectForKey:DB_KEY_JIWOK_GENRE]]];//santhosh

		
		[cell setObjectValue:[dic objectForKey:DB_KEY_JIWOK_GENRE]];

		
		
		//	NSMutableArray *myArray = [dic objectForKey:COMBO_VALUES];
//	
//		[dic setObject:[myArray objectAtIndex:[cell indexOfSelectedItem]] forKey:TABLE_COL_JIWOK_GENRE];
	}
	NSLog(@"Now you are completed willDisplayCell method in JiwokAnalysisSummaryWindowController class");
}
#pragma mark  Combo box cell data source methods
-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(int)index
{
    NSLog(@"Now you are in comboBoxCell method in JiwokAnalysisSummaryWindowController class");
	NSArray *values = [cell representedObject];
       NSLog(@"values NSArray==%@",values);
	if(values == nil)
		return @"";
	else
		return [values objectAtIndex:index];
     NSLog(@"Now you are completed comboBoxCell method in JiwokAnalysisSummaryWindowController class");
}

-(int)numberOfItemsInComboBoxCell:(NSComboBoxCell*)cell
{
     NSLog(@"Now you are in numberOfItemsInComboBoxCell method in JiwokAnalysisSummaryWindowController class");
	NSArray *values = [cell representedObject];
       NSLog(@"values NSArray==%@",values);
	if(values == nil)
		return 0;
	else
		return [values count];
    NSLog(@"Now you are completed numberOfItemsInComboBoxCell method in JiwokAnalysisSummaryWindowController class");
}

-(NSUInteger)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)st
{
    NSLog(@"Now you are in (NSUInteger)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)st method in JiwokAnalysisSummaryWindowController class");
	NSArray *values = [cell representedObject];
     NSLog(@"values NSArray==%@",values);
	if(values == nil)
		return NSNotFound;
	else
		return [values indexOfObject:st];
    NSLog(@"Now you are completed (NSUInteger)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)st method in JiwokAnalysisSummaryWindowController class");
}


- (void)dealloc {

		
	[super dealloc];
}


@end
