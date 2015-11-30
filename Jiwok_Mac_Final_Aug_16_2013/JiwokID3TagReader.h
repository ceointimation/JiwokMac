//
//  JiwokID3TagReader.h
//  Sox Wrap
//
//  Created by APPLE on 29/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JiwokID3TagReader : NSObject {

	NSTask * task;


}

-(NSMutableDictionary*)getID3TagInfo:(NSString *)filePath;

@end
