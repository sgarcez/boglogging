//
//  BogLoggingAppDelegate.h
//  BogLogging
//
//  Created by James Beith on 17/11/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	BOOL engaged;
	BOOL useBlackIcons;

	NSMenu *menu;
	NSStatusItem *statusItem;
	
	NSURLConnection *urlConnection;
	NSMutableData *urlData;
	int connectionError;
}

@property (assign) IBOutlet NSWindow *window;

- (void)updateMenu;
- (void)startConnection;
- (void)killConnection;
- (void)connectionError:(NSError *)parseError;
- (void)_runAppleScriptWithCommand:(NSString *)commandName inScriptNamed:(NSString *)scriptName withParameterString:(NSString *)paramString;

@end
