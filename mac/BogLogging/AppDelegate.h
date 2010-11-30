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
	NSButton *launchAtLoginButton;
	NSButton *checkForUpdatesButton;
	NSTextField *versionNumberTextField;
	
	BOOL engaged;

	NSMenu *menu;
	NSStatusItem *statusItem;
	
	NSTimer *fetchTimer;
	
	NSURLConnection *urlConnection;
	NSMutableData *urlData;
	int connectionError;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) IBOutlet NSButton *launchAtLoginButton;
@property (nonatomic, retain) IBOutlet NSButton *checkForUpdatesButton;
@property (nonatomic, retain) IBOutlet NSTextField *versionNumberTextField;

- (void)toggleIconColour:(id)sender;
- (void)openSettings:(id)sender;
- (void)toggleLaunchAtLogin:(id)sender;
- (void)appQuit:(id)sender;

- (void)updateMenu;
- (void)startConnection;
- (void)killConnection;
- (void)connectionError:(NSError *)parseError;

@end
