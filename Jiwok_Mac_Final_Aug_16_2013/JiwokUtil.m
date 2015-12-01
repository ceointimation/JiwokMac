//
//  JiwokUtil.m
//  Jiwok
//
//  Created by reubro R on 10/07/10.
//  Copyright 2010 kk. All rights reserved.
//

#import "JiwokUtil.h"
#import "LoggerClass.h"
#import <sys/param.h>
#import <sys/mount.h>

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSLog(@"Now you are in hyperlinkFromString  method in JiwokUtil class");
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
	NSRange range = NSMakeRange(0, [attrString length]);
	
	[attrString beginEditing];
	[attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
 	
	// make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
 	
	// next make the text appear with an underline
    [attrString addAttribute:
  	 NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
	[attrString endEditing];
  	
	return [attrString autorelease];
    NSLog(@"Now you are completed hyperlinkFromString  method in JiwokUtil class");
}
@end

@implementation JiwokUtil

+ (BOOL)isNetworkMountAtPath:(NSString*)path
{
    NSLog(@"Now you are in isNetworkMountAtPath  method in JiwokUtil class");
	struct statfs64 stat;
	
	int err = statfs64([path fileSystemRepresentation], &stat);
	if (err == 0)
	{
		return !(stat.f_flags & MNT_LOCAL);
	}
	return NO;
     NSLog(@"Now you are completed isNetworkMountAtPath  method in JiwokUtil class");
}


+(NSInteger )showAlert:(NSString *)message:(JIWOK_ALERT_TYPE) alertType
{
     NSLog(@"Now you are in showAlert  method in JiwokUtil class");
	if (alertType == JIWOK_ALERT_YES_NO)
	{
		
		NSAlert *alert =[[NSAlert alloc]init];
		[alert setMessageText:message];
		[alert addButtonWithTitle: @"Yes"];
		[alert addButtonWithTitle: @"No"];
		[alert setAlertStyle: NSWarningAlertStyle];
		return  [alert runModal];
	}
	NSAlert *alert =[[NSAlert alloc]init];
	[alert setMessageText:message];
	[alert addButtonWithTitle: @"OK"];
	if (alertType == JIWOK_ALERT_OK_CANCEL)
	{
		[alert addButtonWithTitle: @"Cancel"];
	}
	[alert setAlertStyle: NSWarningAlertStyle];
	return  [alert runModal];
    NSLog(@"Now you are completed showAlert  method in JiwokUtil class");
	
}
+(NSString *)ReplaceSpecialCharactersInURL:(NSString *)urlPath
{
	NSLog(@"Now you are in ReplaceSpecialCharactersInURL  method in JiwokUtil class");
	urlPath = [urlPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	urlPath = [urlPath stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	urlPath =[urlPath stringByReplacingOccurrencesOfString:@"(" withString:@"%28"]; 
	urlPath =[urlPath stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
	urlPath =[urlPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	urlPath =[urlPath stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
	urlPath =[urlPath stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
	return urlPath;
    NSLog(@"Now you are completed ReplaceSpecialCharactersInURL  method in JiwokUtil class");
}
//
+(BOOL)checkForInternetConnection:(NSString *) strURL
{	
    NSLog(@"Now you are in checkForInternetConnection  method in JiwokUtil class");
	NSRange range ;
	range.length			= 0;
	range.location			= 0;
    //strURL = @"https://www.google.co.in";//santhosh
	NSURL *url = [NSURL URLWithString:strURL];
	//	char *urlCString = [xmlRULString UTF8String];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL: url
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  
											timeoutInterval:30];
	NSURLResponse *response = nil;
	NSError		  *error	= nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];										 
										 
	if(NULL == response)
	{
		[[LoggerClass getInstance] logData:@"No response for Jiwok server"];		
		return NO;
	}
	if (!data)
	{
		[[LoggerClass getInstance] logData:@"No data from Jiwok server"];	
		return NO;
	}
	return YES;
     NSLog(@"Now you are completed checkForInternetConnection  method in JiwokUtil class");
	
}
+(NSString *)GetCurrentLocale
{
     NSLog(@"Now you are in GetCurrentLocale  method in JiwokUtil class");
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [defs objectForKey:@"AppleLanguages"];
     NSLog(@"languages NSArray==%@",languages);
	NSString *currentLocale = [languages objectAtIndex:0];
	NSLog(@"language = %@",currentLocale);
	if ([currentLocale isEqualToString:@"fr"])
	{
		currentLocale = @"french";
	}
	else if ([currentLocale isEqualToString:@"en"])
	{
		currentLocale = @"english";
	}
	else if ([currentLocale isEqualToString:@"es"])
	{
		currentLocale = @"spanish";
	}
	else if ([currentLocale isEqualToString:@"it"])
	{
		currentLocale = @"italian";
	}
	else if([currentLocale isEqualToString:@"pl"])	
    {
        currentLocale=@"polish";
    }
    else
		currentLocale = @"french";
		
	return currentLocale;
	//return @"french";
     NSLog(@"Now you are completed GetCurrentLocale  method in JiwokUtil class");
}

+(NSString *)GetShortCurrentLocale
{
     NSLog(@"Now you are in GetShortCurrentLocale  method in JiwokUtil class");
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [defs objectForKey:@"AppleLanguages"];
	NSString *currentLocale = [languages objectAtIndex:0];
	 NSLog(@"languages NSArray==%@",languages);
	//NSLog(@"languages %@",languages);	
	
	NSLog(@"language = %@",currentLocale);
	if ([currentLocale isEqualToString:@"fr"])
	{
		currentLocale = @"Fr";
	}
	else if ([currentLocale isEqualToString:@"en"])
	{
		currentLocale = @"En";
	}
	else if ([currentLocale isEqualToString:@"es"])
	{
		currentLocale = @"Es";
	}
	else if ([currentLocale isEqualToString:@"it"])
	{
		currentLocale = @"It";
	}
    else if([currentLocale isEqualToString:@"pl"])
    {
        currentLocale=@"Pl";
    }
	else 
		currentLocale = @"Fr";	
	
	return currentLocale;
	//return @"Fr";
     NSLog(@"Now you are completed GetShortCurrentLocale  method in JiwokUtil class");
}
+ (BOOL)isStringFoundInTargetString:(NSString *)searchString:(NSString *)targetString
{
     NSLog(@"Now you are in isStringFoundInTargetString  method in JiwokUtil class");
	BOOL bRet = NO;
	
	if ([targetString rangeOfString:searchString].location != NSNotFound)
	{
		bRet = YES;
	}
	return bRet;
	NSLog(@"Now you are completed isStringFoundInTargetString  method in JiwokUtil class");
}
+ (BOOL) isvalidFolder :(NSString *)itemPath
{
	NSLog(@"Now you are in isvalidFolder  method in JiwokUtil class");
	//NSLog(@" isInvisible got path %@",itemPath);
	BOOL bvalidFolder = NO;
	// examine if this object is invisible (don't include in the array)
	CFDictionaryRef values = NULL;
	CFStringRef attrs[1] = { kLSItemIsInvisible };
	CFArrayRef attrNames = CFArrayCreate(NULL, (const void **)attrs, 1, NULL);
	
	FSRef fileRef;
	Boolean isDirectory;
	
	if (FSPathMakeRef((const UInt8 *)[itemPath fileSystemRepresentation], &fileRef, &isDirectory) == noErr)
	{
		if (isDirectory == YES)
		{
			if (LSCopyItemAttributes(&fileRef, kLSRolesViewer, attrNames, &values) == noErr)
			{
				if (values != NULL)
				{
					if (CFDictionaryGetValue(values, kLSItemIsInvisible) == kCFBooleanFalse)
					{
						//if([itemPath isEqualToString:@"/Users/apple/Desktop"])
						
						bvalidFolder =  YES;
					}
				}
				CFRelease(values);
			}
		}
	}	
	CFRelease(attrNames);
	return bvalidFolder;
    NSLog(@"Now you are completed isvalidFolder  method in JiwokUtil class");
}
+ (BOOL)isSkipItemPackage:(NSString *)itemPath 
{
    NSLog(@"Now you are in isSkipItemPackage  method in JiwokUtil class");
	BOOL bSkipFolder = NO;
	LSItemInfoRecord info;
	FSRef fileRef;
	Boolean isDirectory;
	if (FSPathMakeRef((const UInt8 *)[itemPath fileSystemRepresentation], &fileRef, &isDirectory) == noErr)
	{
		if (isDirectory == YES)
		{
			//NSLog(@" isSkipItemPackage %@",itemPath);
			LSCopyItemInfoForURL((CFURLRef) [NSURL fileURLWithPath:itemPath], kLSRequestAllInfo, &info);
			
			if (info.flags & kLSItemInfoIsPackage )
			{
				bSkipFolder =  YES;
			}
			
			
			
			NSString *extension = [itemPath pathExtension];
			if ([extension isEqualToString:@"lproj"])
			{
				bSkipFolder =  YES;
			}
			if ([extension isEqualToString:@"frameworks"])
			{
				bSkipFolder =  YES;
			}
			
			
			if ([JiwokUtil isStringFoundInTargetString:@"/Developer":itemPath])
			{
				bSkipFolder =  YES;
			}
			
			if ([JiwokUtil isStringFoundInTargetString:@"/Applications":itemPath])
			{
				bSkipFolder =  YES;
			}
			
			if ([JiwokUtil isStringFoundInTargetString:@"/Library":itemPath])
			{
				bSkipFolder =  YES;
			}
			
			if ([JiwokUtil isStringFoundInTargetString:@"/System":itemPath])
			{
				bSkipFolder =  YES;
			}
			
			
			if ([itemPath isEqualToString:@"/home"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/net"])
			{
				bSkipFolder =  YES;
			}
			
			if ([itemPath isEqualToString:@"/etc"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/Network"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/mach_kernel"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/private"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/sbin"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/bin"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/tmp"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/usr"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/cores"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/var"])
			{
				bSkipFolder =  YES;
			}
			if ([itemPath isEqualToString:@"/dev"])
			{
				bSkipFolder =  YES;
			}
			
			/*
			// Newly added for testing				
			
		//	if ([JiwokUtil isStringFoundInTargetString:@"/Music":itemPath]||[JiwokUtil isStringFoundInTargetString:@"/Music1":itemPath])
			if ([JiwokUtil isStringFoundInTargetString:@"/Music1":itemPath]||[JiwokUtil isStringFoundInTargetString:@"/Music2":itemPath])

			{
				bSkipFolder =  NO;
			}
			else if ([itemPath isEqualToString:@"/"])
				bSkipFolder =  NO;
			
			else
				bSkipFolder =  YES;
		
		
		*/
		
		
		}
		
	}
	return bSkipFolder;
     NSLog(@"Now you are completed isSkipItemPackage  method in JiwokUtil class");
}


@end
