
#import <Cocoa/Cocoa.h>


@interface JiwokMusicProcessor : NSObject {

	NSTask *task;

}
- (void)Concatenate:(NSMutableArray*)inputArray:(NSString*)outputFile;

- (void)ChangeVolume:(NSString*)inputFile:(NSString*)Decibel:(NSString*)outputFile;

- (void)convertBitRate:(NSString*)inputFile:(NSString*)Bitrate:(NSString*)outputFile;

- (void)MixAudio:(NSString*)inputFile1:(NSString*)inputFile2:(NSString*)outputFile; 

- (void)PadSilence:(NSString*)inputFile:(NSString*)outputFile:(NSString*)startupPadding:(NSString*)EndPadding; 

- (void)TrimAudio:(NSString*)inputFile:(NSString*)outputFile:(NSString*)startPosition:(NSString*)Length; 

- (void)ChangeMp3gain:(NSString*)gainValue:(NSString*)inputFile;

-(void)ConvertToWave:(NSString*)inputFile;

-(void)ChangeOutputFormat:(NSString*)inputFile:(NSString*)desiredExtension;

-(void)ChangeOutputFormatForFinalMp3:(NSString*)inputFile:(NSString*)desiredExtension:(NSString*)title;

-(void)RemoveTemporaryFile:(NSString*)inputFile;

- (void)IncreaseVolumeUsingSox:(NSString*)inputFile:(NSString*)outputFile;

-(BOOL)isValidSoxFile:(NSString*)inputFile;


@end
