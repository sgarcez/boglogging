//
//  BogLoggingAppDelegate.m
//  BogLogging
//
//  Created by James Beith on 17/11/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginItem.h"

@implementation AppDelegate

@synthesize window, menu, statusItem, useColourIconButton, launchAtLoginButton, checkForUpdatesButton, versionNumberTextField;
@synthesize fetchTimer, urlConnection, urlData;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	
	
	// Check our user defaults for missing or inconsistencies.
	[self checkUserDefaults];

	// Setup the drop down menu.
	self.menu = [[[NSMenu allocWithZone:[NSMenu menuZone]] init] autorelease];
	[self.menu addItemWithTitle:kMenuFreeString action:NULL keyEquivalent:@""];
	[self.menu addItem:[NSMenuItem separatorItem]];
	[self.menu addItemWithTitle:@"Settings" action:@selector(openSettings:) keyEquivalent:@""];
	[self.menu addItemWithTitle:@"Quit" action:@selector(appQuit:) keyEquivalent:@""];
	
	// Setup the status bar item.
	self.statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:-1] retain];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
		[self.statusItem setImage:[NSImage imageNamed:@"status-colour-free.png"]];
	else
		[self.statusItem setImage:[NSImage imageNamed:@"status-black-free.png"]];
	[self.statusItem setTarget:self];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setMenu:self.menu];
	
	// Set up Growl.
	[GrowlApplicationBridge setGrowlDelegate:self];
		
	// Register for system sleep/wake notifications.
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceWillSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidWakeNotification:) name:NSWorkspaceDidWakeNotification object:nil];
	
	// The fetch connection preparation.
	self.urlData = [[[NSMutableData alloc] init] autorelease];
	self.fetchTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(startConnection) userInfo:nil repeats:YES];	
}

- (void)dealloc {
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

	self.menu = nil;
	self.statusItem = nil;
	self.useColourIconButton = nil;
	self.launchAtLoginButton = nil;
	self.checkForUpdatesButton = nil;
	self.versionNumberTextField = nil;
	
	self.fetchTimer = nil;
	self.urlConnection = nil;
	self.urlData = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark IBActions

- (void)openSettings:(id)sender {	
	
	/*
	// Launch Growl in the System Preferences.
	if ([GrowlApplicationBridge isGrowlInstalled]) {
		NSString *scriptStr = @"tell application \"System Preferences\"\n activate\n set current pane to pane \"com.growl.prefpanel\"\n end tell";
		NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptStr] autorelease];
		NSDictionary *errInfo;
		NSAppleEventDescriptor *res = [script executeAndReturnError:&errInfo];
	}
	*/
	
	if (![NSApp isActive]) {
		[NSApp activateIgnoringOtherApps:YES];
	}
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
		[self.useColourIconButton setState:1];
	else
		[self.useColourIconButton setState:0];
	
	if ([LoginItem willStartAtLogin])
		[self.launchAtLoginButton setState:1];
	else
		[self.launchAtLoginButton setState:0];

	[self.versionNumberTextField setStringValue:[NSString stringWithFormat:@"%@ %@", @"Version:", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];

	[window center];
	[window makeKeyAndOrderFront:self];
}

- (void)toggleIconColour:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kUseColourIconUserDefaults];
		[self updateMenu];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kUseColourIconUserDefaults];
		[self updateMenu];
	}
}

- (void)toggleLaunchAtLogin:(id)sender {
	if ([self.launchAtLoginButton state])
		[LoginItem setStartAtLogin:YES];
	else
		[LoginItem setStartAtLogin:NO];
}

- (void)appQuit:(id)sender {
	[NSApp terminate:sender];
}

#pragma mark -
#pragma mark NSNotifications

- (void)workspaceWillSleepNotification:(NSNotification *)notification {
	NSLog(@"workspaceWillSleepNotification");
	
	[self.fetchTimer invalidate];
}

- (void)workspaceDidWakeNotification:(NSNotification *)notification {
	NSLog(@"workspaceDidWakeNotification");
	
	self.urlConnection = nil;
	self.urlData = nil;
	self.fetchTimer = nil;
	
	self.urlData = [[[NSMutableData alloc] init] autorelease];
	self.fetchTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(startConnection) userInfo:nil repeats:YES];	
}

#pragma mark -
#pragma mark General Methods

- (void)checkUserDefaults {
	// If the first launch user default is nil, set our app defaults.
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kSetDefaultLoginItemUserDefaults] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kSetDefaultLoginItemUserDefaults];
		[LoginItem setStartAtLogin:YES];
	}

	// If the use colour icon user default for is nil, set it to the default of YES.
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kUseColourIconUserDefaults];
	
}

- (void)updateMenu {
	if (connectionError > 4) {
		[[self.menu itemAtIndex:0] setTitle:kMenuErrorString];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
			[self.statusItem setImage:[NSImage imageNamed:@"status-colour-error.png"]];
		else
			[self.statusItem setImage:[NSImage imageNamed:@"status-black-error.png"]];
	}
	else {
		if (engaged) {
			[[self.menu itemAtIndex:0] setTitle:kMenuEngagedString];
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
				[self.statusItem setImage:[NSImage imageNamed:@"status-colour-engadged.png"]];
			else
				[self.statusItem setImage:[NSImage imageNamed:@"status-black-engadged.png"]];
		}
		else {
			[[self.menu itemAtIndex:0] setTitle:kMenuFreeString];
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
				[self.statusItem setImage:[NSImage imageNamed:@"status-colour-free.png"]];
			else
				[self.statusItem setImage:[NSImage imageNamed:@"status-black-free.png"]];
		}		
	}
}

#pragma mark -
#pragma mark NSURLConnection data download

- (void)startConnection {
	NSLog(@"fetching");
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kStateURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
	self.urlConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	if (!self.urlConnection)
		[self connectionError:[NSError errorWithDomain:@"No URLConnection available" code:-100 userInfo:nil]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Now the request/response exchange is complete we can check the response code to ensure it is 2xx and if not kill the connection.
	if (([(NSHTTPURLResponse*)response statusCode] / 100) == 2) {
		[self.urlData setLength:0];
	} 
	else {
		[self killConnection];
		[self connectionError:[NSError errorWithDomain:@"URLConnection response was NOT 2xx" code:-404 userInfo:nil]]; //[(NSHTTPURLResponse*)response statusCode]
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData {
    [self.urlData appendData:receiveData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	connectionError = 0;
	NSString *responseString = [[NSString alloc] initWithCString:[self.urlData bytes] encoding:NSUTF8StringEncoding];
	if (engaged != [responseString boolValue]) {
		engaged = [responseString boolValue];
		if (engaged)
			[GrowlApplicationBridge notifyWithTitle:@"Bog Logging" description:@"Bog is engaged" notificationName:@"Bog is engaged" iconData:nil priority:0 isSticky:NO clickContext:nil];
		else
			[GrowlApplicationBridge notifyWithTitle:@"Bog Logging" description:@"Bog is free" notificationName:@"Bog is free" iconData:nil priority:0 isSticky:NO clickContext:nil];
	}
	[responseString release];
	[self updateMenu];
	[self killConnection];
	NSLog(@"fetched: %d", engaged);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self killConnection];
	[self connectionError:error];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	// Disable caching so that each time we run the app we are starting with a clean slate.
	return nil;
}

- (void)killConnection {
	self.urlConnection = nil;
	[self.urlData setLength:0];
}

- (void)connectionError:(NSError *)parseError {
	connectionError++;
	[self updateMenu];

	if ([parseError code] == -100)
		NSLog(@"No NSURLConnection could be allocated");
	else if ([parseError code] == -1009)
		NSLog(@"No internet connection");
	else if ([parseError code] == -404)
		NSLog(@"Server response was not 2**");
	else
		NSLog(@"connectionError %@", parseError);
}

@end
