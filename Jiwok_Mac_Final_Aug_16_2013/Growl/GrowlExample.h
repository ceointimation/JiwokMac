//
//  GrowlExample.h
//  Jiwok
//
//  Created by Reubro on 2010-12-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "Growl.framework/Headers/GrowlApplicationBridge.h"

//#import <Growl-WithInstaller/GrowlApplicationBridge.h>
//#import <Growl-WithInstaller/Growl.h>

#import <Growl/Growl.h>


@interface GrowlExample : NSObject<GrowlApplicationBridgeDelegate> {

}
-(void) growlAlert:(NSString *)message title:(NSString *)title;
-(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title;
-(void) exampleClickContext;

//- (NSAttributedString *)_growlInformationForUpdate:(BOOL)isUpdate;

@end
