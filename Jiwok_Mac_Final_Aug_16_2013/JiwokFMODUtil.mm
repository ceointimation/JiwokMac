//
//  JiwokFMODUtil.mm
//  Jiwok
//
//  Created by reubro R on 04/08/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokFMODUtil.h"
#include "JiwokFMODWrapper.h"

@implementation JiwokFMODUtil

- (unsigned int)getDuration:(NSString *)filePath
{
	
	
	// Get duration of the song
	const char* mewFilePath = [filePath UTF8String];
	JiwokFMODWrapper *fmodObject = new JiwokFMODWrapper();
	unsigned int duration = fmodObject->GetLength(mewFilePath);
	////NSLog(@" ===duration using FMOD for file %@ is == %d \n",filePath, duration);
	delete fmodObject;
	
	

	
	return duration;
}
- (float)getBPM:(NSString *)filePath
{
	// Get getBPM of the song
   
	const char* mewFilePath = [filePath UTF8String];
	JiwokFMODWrapper *fmodObject = new JiwokFMODWrapper();
	
	float bpm;
	
	try {
		 bpm = fmodObject->GetBPM(mewFilePath);
	}
	catch (NSException *ex) {
		
	}
	
	//float bpm = fmodObject->GetBPM(mewFilePath);
	//NSLog(@" ===bpm using bpm for file %@ is == %f \n",filePath, bpm);
	delete fmodObject;
	return bpm;
    
}
@end
