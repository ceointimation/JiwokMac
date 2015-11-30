//
//  JiwokUtil.h
//  Jiwok
//
//  Created by reubro R on 10/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Common.h"
@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end
@interface JiwokUtil : NSObject {

}
+ (BOOL)isNetworkMountAtPath:(NSString*)path;
+(NSInteger )showAlert:(NSString *)message:(JIWOK_ALERT_TYPE) alertType;
+(BOOL)checkForInternetConnection:(NSString *) strURL;
+(NSString *)ReplaceSpecialCharactersInURL:(NSString *)urlPath;
+(NSString *)GetCurrentLocale;
+(NSString *)GetShortCurrentLocale;
+ (BOOL)isStringFoundInTargetString:(NSString *)searchString:(NSString *)targetString;
+ (BOOL) isvalidFolder :(NSString *)itemPath;
+ (BOOL)isSkipItemPackage:(NSString *)itemPath ;
@end
