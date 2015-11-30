//
//  BpmCalculator.h
//  Jiwok
//
//  Created by APPLE on 04/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BpmCalculator : NSObject {

	NSTask * task;

	
}

-(NSString*)GetBpm:(NSString*)fileName;


@end
