


#import <Cocoa/Cocoa.h>


@interface JiwokFfmpegID3TagReader : NSObject {

	NSTask * task;

}

-(NSMutableDictionary*)getID3TagInfo:(NSString *)fileName;

-(NSMutableDictionary*)getID3TagInfoOfAac:(NSString *)fileName;

@end
