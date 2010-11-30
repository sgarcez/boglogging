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

@synthesize window, urlConnection, launchAtLoginButton, checkForUpdatesButton, versionNumberTextField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	

	// If the launch at login user default is nil, set it to the default of YES.
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kLaunchAtLoginUserDefaults] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kLaunchAtLoginUserDefaults];
		[LoginItem setStartAtLogin:YES];
	}
	
	// If the use colour icon user default for is nil, set it to the default of YES.
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] == nil)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kUseColourIconUserDefaults];

	// Setup the drop down menu.
	menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
	[menu addItemWithTitle:kMenuFreeString action:NULL keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
		[menu addItemWithTitle:@"Use Black Icon" action:@selector(toggleIconColour:) keyEquivalent:@""];	
	else
		[menu addItemWithTitle:@"Use Colour Icon" action:@selector(toggleIconColour:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Settings" action:@selector(openSettings:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Quit" action:@selector(appQuit:) keyEquivalent:@""];
	
	// Setup the status bar item.
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:-1] retain];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
		[statusItem setImage:[NSImage imageNamed:@"status-colour-free.png"]];
	else
		[statusItem setImage:[NSImage imageNamed:@"status-black-free.png"]];
	[statusItem setTarget:self];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:menu];
	
	// The fetch connection preparation.
	urlData = [[NSMutableData alloc] init];
	fetchTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(startConnection) userInfo:nil repeats:YES];
	
	// Register for system sleep/wake notifications.
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceWillSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidWakeNotification:) name:NSWorkspaceDidWakeNotification object:nil];
}

- (void)dealloc {
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	self.urlConnection = nil;
	[menu release];
	[statusItem release];
	
	self.launchAtLoginButton = nil;
	self.checkForUpdatesButton = nil;
	self.versionNumberTextField = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark IBActions

- (void)toggleIconColour:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue]) {
		[self updateMenu];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kUseColourIconUserDefaults];
		[[menu itemAtIndex:2] setTitle:@"Use Colour Icon"];
	}
	else {
		[self updateMenu];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kUseColourIconUserDefaults];
		[[menu itemAtIndex:2] setTitle:@"Use Black Icon"];
	}
}

- (void)openSettings:(id)sender {
	if (![NSApp isActive]) {
		[NSApp activateIgnoringOtherApps:YES];
	}
	
	[self.versionNumberTextField setStringValue:[NSString stringWithFormat:@"%@ %@", @"Version:", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kLaunchAtLoginUserDefaults] boolValue])
		[self.launchAtLoginButton setState:1];
	else
		[self.launchAtLoginButton setState:0];

	[window center];
	[window makeKeyAndOrderFront:self];
}

- (void)toggleLaunchAtLogin:(id)sender {
	if ([self.launchAtLoginButton state]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kLaunchAtLoginUserDefaults];
		[LoginItem setStartAtLogin:YES];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kLaunchAtLoginUserDefaults];
		[LoginItem setStartAtLogin:NO];
	}
}

- (void)appQuit:(id)sender {
	[NSApp terminate:sender];
}

#pragma mark -
#pragma mark NSNotifications

- (void)workspaceWillSleepNotification:(NSNotification *)notification {
	NSLog(@"workspaceWillSleepNotification");
	[fetchTimer invalidate];
	self.urlConnection = nil;
	[urlData setLength:0];
}

- (void)workspaceDidWakeNotification:(NSNotification *)notification {
	NSLog(@"workspaceDidWakeNotification");
}

#pragma mark -
#pragma mark Update Menu

- (void)updateMenu {
	if (connectionError > 2) {
		[[menu itemAtIndex:0] setTitle:kMenuErrorString];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
			[statusItem setImage:[NSImage imageNamed:@"status-colour-error.png"]];
		else
			[statusItem setImage:[NSImage imageNamed:@"status-black-error.png"]];
	}
	else {
		if (engaged) {
			[[menu itemAtIndex:0] setTitle:kMenuEngagedString];
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
				[statusItem setImage:[NSImage imageNamed:@"status-colour-engadged.png"]];
			else
				[statusItem setImage:[NSImage imageNamed:@"status-black-engadged.png"]];
		}
		else {
			[[menu itemAtIndex:0] setTitle:kMenuFreeString];
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourIconUserDefaults] boolValue])
				[statusItem setImage:[NSImage imageNamed:@"status-colour-free.png"]];
			else
				[statusItem setImage:[NSImage imageNamed:@"status-black-free.png"]];
		}		
	}
}

#pragma mark -
#pragma mark NSURLConnection data download

- (void)startConnection {
	NSLog(@"fetching");
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kStateURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (!self.urlConnection)
		[self connectionError:[NSError errorWithDomain:@"No URLConnection available" code:-100 userInfo:nil]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Now the request/response exchange is complete we can check the response code to ensure it is 2xx and if not kill the connection.
	if (([(NSHTTPURLResponse*)response statusCode] / 100) == 2) {
		[urlData setLength:0];
	} 
	else {
		[self killConnection];
		[self connectionError:[NSError errorWithDomain:@"URLConnection response was NOT 2xx" code:-404 userInfo:nil]]; //[(NSHTTPURLResponse*)response statusCode]
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData {
    [urlData appendData:receiveData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	connectionError = 0;
	engaged = [[NSString stringWithCString:[urlData bytes] encoding:NSUTF8StringEncoding] boolValue];
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
	[urlData setLength:0];
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
		NSLog(@"%@", parseError);
}

@end
