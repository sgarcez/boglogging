//
//  BogLoggingAppDelegate.h
//  BogLogging
//
//  Created by James Beith on 17/11/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject {
	NSWindow *window;
	NSButton *checkForUpdatesButton;
	
	BOOL engaged;
	BOOL useBlackIcons;

	NSMenu *menu;
	NSStatusItem *statusItem;
	
	NSTimer *fetchTimer;
	
	NSURLConnection *urlConnection;
	NSMutableData *urlData;
	int connectionError;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) IBOutlet NSButton *checkForUpdatesButton;

- (void)updateMenu;
- (void)startConnection;
- (void)killConnection;
- (void)connectionError:(NSError *)parseError;

@end
