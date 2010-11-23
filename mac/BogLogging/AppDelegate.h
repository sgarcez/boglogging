//
//  BogLoggingAppDelegate.h
//  BogLogging
//
//  Created by James Beith on 17/11/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface AppDelegate : NSObject
#else
@interface AppDelegate : NSObject <NSApplicationDelegate>
#endif
{
	NSWindow *window;
	
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

- (void)updateMenu;
- (void)startConnection;
- (void)killConnection;
- (void)connectionError:(NSError *)parseError;

@end
