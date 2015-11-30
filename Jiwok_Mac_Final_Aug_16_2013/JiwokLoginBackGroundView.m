//
//  JiwokLoginBackGroundView.m
//  Jiwok
//
//  Created by Reubro on 06/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JiwokLoginBackGroundView.h"


@implementation JiwokLoginBackGroundView

- (id)initWithFrame:(NSRect)frame {
    //NSLog(@"Now you are in initWithFrame method in JiwokLoginBackGroundView class");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
    //NSLog(@"Now you are in initWithFrame method in JiwokLoginBackGroundView class");
}

- (void)drawRect:(NSRect)rect {
    //NSLog(@"Now you are in drawRect method in JiwokLoginBackGroundView class");
	if (!isDrawn)
	{
		NSImage* image = [NSImage imageNamed:@"Login_Bg.png"];
		if (image)
		{
			NSColor* patColour = [NSColor colorWithPatternImage:image];
			[patColour set];
			[NSBezierPath fillRect: rect];
			isDrawn = YES;
			[image release];
		}
	}
    //NSLog(@"Now you are completed drawRect method in JiwokLoginBackGroundView class");
}

@end
