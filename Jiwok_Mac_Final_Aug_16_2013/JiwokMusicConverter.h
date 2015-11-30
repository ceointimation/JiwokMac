//
//  JiwokMusicConverter.h
//  Jiwok
//
//  Created by reubro R on 13/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokMusicConverter : NSObject {
	NSTask*task;
}
-(void)convertToWav:(NSString *)filePath;
-(void)convertToMp3:(NSString *)filePath;

@end
