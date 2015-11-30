//
//  JiwokBPMDetector.h
//  Jiwok
//
//  Created by Reubro on 23/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokBPMDetector : NSObject {

	
	NSTask * task;

	
}

-(NSString*)GetBpm:(NSString*)fileName;

@end
