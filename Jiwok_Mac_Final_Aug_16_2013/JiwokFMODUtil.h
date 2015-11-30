//
//  JiwokFMODUtil.h
//  Jiwok
//
//  Created by reubro R on 04/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JiwokFMODUtil : NSObject {

}
- (unsigned int)getDuration:(NSString *)filePath;
- (float)getBPM:(NSString *)filePath;
@end
