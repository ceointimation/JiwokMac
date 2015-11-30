//
//  JiwokLastfmClient.h
//  Jiwok_Coredata_Trial
//
//  Created by APPLE on 05/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMEngine.h"


@interface JiwokLastfmClient : NSObject {
	
	NSTask*task;
	FMEngine *fmEngine;

	NSMutableArray *Returned;

}


-(NSMutableArray*)getArtists:(NSString *)filePath;

-(NSMutableArray *)GetArtistTopTag:(NSString*)artist; 

-(NSMutableArray *)GetAlbumTopTag:(NSString*)artist:(NSString*)album;

@end
