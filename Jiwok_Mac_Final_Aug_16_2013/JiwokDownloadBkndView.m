//
//  JiwokDownloadBkndView.m
//  Jiwok
//
//  Created by reubro R on 13/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokDownloadBkndView.h"


@implementation JiwokDownloadBkndView

- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
    
}

- (void)drawRect:(NSRect)rect {
     //NSLog(@"Now you are in drawRect method in JiwokDownloadBkndView class");
	if (!isDrawn)
	{
		NSImage* image = [NSImage imageNamed:@"download_bknd.png"];
		[image setSize:NSMakeSize(475,273)];
		if (image)
		{
			NSColor* patColour = [NSColor colorWithPatternImage:image];
			[patColour set];
			[NSBezierPath fillRect: rect];
			isDrawn = YES;
			//[image release];//santhosh
		}
	}
	//(@"Now you are completed drawRect method in JiwokDownloadBkndView class");
}

@end
