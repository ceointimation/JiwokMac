//
//  JiwokMyMusicPanelViewController.h
//  Jiwok
//
//  Purpose: This class is responsible for shwowing the my music tab in the main screen of the Jiwok application.
//  Created by reubro R on 14/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Delegates.h"
#import "JiwokMusicalSearchWindowController.h"
#import "JiwokLastfmClient.h"

//@interface NSAttributedString (Hyperlink)
//+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
//@end


@interface JiwokMyMusicPanelViewController : NSViewController<FolderAdditionDelegate> {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSTableView *detailTableView;
	IBOutlet NSTextField *txtJiwokURL;
	IBOutlet NSTextField *txtStatus;	
	IBOutlet NSButton *btnAddNew;
	IBOutlet NSButton *btnCancel;
	
	IBOutlet NSTextField *selectedFoldersLabel;
	IBOutlet NSTextField *musicDetection;
	
	
	NSMutableArray *treedataStore;
	NSMutableArray *detailTableData;
	NSMutableArray *tempMusicData;

	NSMutableArray *failedMusicData;
	
	
	NSMutableDictionary *tempDict;
	//NSString *tempduration;
	//NSString * tempfilePath;
	//NSString * tempjiwok_genre;
	NSString * tempArtist;
	
	
	IBOutlet NSProgressIndicator *progressBar;
	
	IBOutlet NSLevelIndicator *analysisProgress;
	
	BOOL bExitThread;
	id<FolderIterationDelegate>delegate;
	JiwokMusicalSearchWindowController* searchloadwindow;
	BOOL bSearchingInPanel;
	BOOL bAnalyseSongs;
	
	BOOL isSearchWidowOpen;
	
	
	
	NSInteger nTempMusicFiles;
	NSInteger nFailedMusicFiles;
	NSInteger nMusicFiles;
	
	NSString * keyArtist;
	NSString * keyAlbum;
	NSString * keyTrack;
	NSString * keyTitle;
	
	JiwokLastfmClient *fpclient;
	
	NSFileManager *fileManager;
	
	unsigned long long totalSizeInSelectedFolders,processesFileSize;
	
	IBOutlet NSImageView *animationImage;
	
	int numberOfSongsAnalyzed;
	
	NSMutableArray *Roots;
	
	// Added on april 29th to prevent crashing
	BOOL canDeleteFolder;
	
}
@property(nonatomic,assign) id<FolderIterationDelegate>delegate;

// class methods
- (void)iterateMyFolder:(NSString *)itemPath: (NSMutableDictionary *) parent;
- (void)populateFolderTree;
- (void) checkUncheckItem:(id)item:(NSOutlineView *)ov:(id)object forTableColumn:(NSTableColumn *)tableColumn:( NSString *) checkValue;
- (void) syncStatusinDB:(id)item :( NSString *) checkValue;
// BMP detection and analysis
- (void)analyseSongs;
- (void) processSongFile:(NSString *) folderPath;
- (void)iterateMyFolderForBPMAnalysis:(NSMutableDictionary *)item;
- (void)iterateMyFolderForBPMAnalysisByFolder:(NSString *)folderPath;
- (NSString *) checkAndGetJiwokGenre:(NSString *) id3Genre;
- (void) doMusicFilesTemp:(NSMutableDictionary *) dict:(unsigned int) duration:(NSString *) filePath:(NSString *) jiwok_genre;
- (void) insertMusicTempAfterLastFM:(NSMutableDictionary *) dict;
- (void) insertMusicAfterLastFM:(NSMutableDictionary *) dict;
- (void)checkAndHandleItunesDirAndMydoc;
- (void)checkAndRemoveItunesDirAndMydoc:(NSString *)folderPath;
// action methods
-(IBAction)addFolderAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
-(void)didFinishAnalysis;
-(void)didFinishGetAlbumTopTag:(NSNotification*)notification;
-(void)DidFinishGetArtistTopTag:(NSNotification*)notification;

-(void)runLastFMGetAlbumTopTag;
-(void)startGetAlbumTopTag:(NSNotification*)notification;
-(void)doLastFMAnalysis;


-(void)CheckAndUpdateUserSelectedFolders;

-(BOOL)checkFileInDatabase:(NSString *)folderPath;

- (BOOL)shouldAnalyzeSongBySizeCheck:(NSString *)filePath;

@end
