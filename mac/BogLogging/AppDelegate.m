//
//  BogLoggingAppDelegate.m
//  BogLogging
//
//  Created by James Beith on 17/11/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import "AppDelegate.h"
#import "PFMoveApplication.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	
	
	// Prompt user to move app to Applications folder if it's not already.
	PFMoveToApplicationsFolderIfNecessary();
	
	// Add the app to system login items.
	[self _runAppleScriptWithCommand:@"AddLoginItem" inScriptNamed:@"LoginItem" withParameterString:[[NSBundle mainBundle] bundlePath]];
	
	// Retrieve the preference of whether to use coloured icons or black icons.
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUseColourUserDefaults] intValue] == 1)
		useBlackIcons = YES;

	// Setup the drop down menu.
	menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
	[menu addItemWithTitle:kMenuFreeString action:NULL keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	if (useBlackIcons)
		[menu addItemWithTitle:@"Use Colour Icon" action:@selector(toggleIconColour:) keyEquivalent:@""];
	else
		[menu addItemWithTitle:@"Use Black Icon" action:@selector(toggleIconColour:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Quit" action:@selector(appQuit:) keyEquivalent:@""];
	
	// Setup the status bar item.
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:-1] retain];
	if (useBlackIcons)
		[statusItem setImage:[NSImage imageNamed:@"status-black-free.png"]];
	else
		[statusItem setImage:[NSImage imageNamed:@"status-colour-free.png"]];
	//[statusItem setTitle:kStatusItemEngagedString];
	[statusItem setTarget:self];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:menu];
	
	// The fetch connection preparation.
	urlData = [[NSMutableData alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(startConnection) userInfo:nil repeats:YES];

}

- (void)dealloc {
	[menu release];
	[statusItem release];
	[super dealloc];
}

- (void)updateMenu {
	if (connectionError > 2) {
		[[menu itemAtIndex:0] setTitle:kMenuErrorString];
		if (useBlackIcons)
			[statusItem setImage:[NSImage imageNamed:@"status-black-error.png"]];
		else
			[statusItem setImage:[NSImage imageNamed:@"status-colour-error.png"]];
	}
	else {
		if (engaged) {
			[[menu itemAtIndex:0] setTitle:kMenuEngagedString];
			if (useBlackIcons)
				[statusItem setImage:[NSImage imageNamed:@"status-black-engadged.png"]];
			else
				[statusItem setImage:[NSImage imageNamed:@"status-colour-engadged.png"]];
			//[statusItem setTitle:kStatusItemEngagedString];
		}
		else {
			[[menu itemAtIndex:0] setTitle:kMenuFreeString];
			if (useBlackIcons)
				[statusItem setImage:[NSImage imageNamed:@"status-black-free.png"]];		
			else
				[statusItem setImage:[NSImage imageNamed:@"status-colour-free.png"]];
			//[statusItem setTitle:kStatusItemFreeString];
		}		
	}
}

- (void)toggleIconColour:(id)sender {
	/*
	if (![NSApp isActive]) {
		[NSApp activateIgnoringOtherApps:YES];
	}
	[window center];
	[window makeKeyAndOrderFront:self];
	*/
	
	if (useBlackIcons) {
		useBlackIcons = NO;
		[self updateMenu];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kUseColourUserDefaults];
		[[menu itemAtIndex:2] setTitle:@"Use Black Icon"];
	}
	else {
		useBlackIcons = YES;
		[self updateMenu];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kUseColourUserDefaults];
		[[menu itemAtIndex:2] setTitle:@"Use Colour Icon"];
	}
}

- (void)appQuit:(id)sender {
	[NSApp terminate:sender];
}

#pragma mark -
#pragma mark NSURLConnection data download

- (void)startConnection {
	NSLog(@"fetching");
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kStateURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (!urlConnection)
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
	//[urlConnection cancel];
	[urlConnection release];
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

#pragma mark -
#pragma mark Execute AppleScript

- (void)_runAppleScriptWithCommand:(NSString *)commandName inScriptNamed:(NSString *)scriptName withParameterString:(NSString *)paramString {
	NSDictionary *errors = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:scriptName ofType:@"scpt"];
	if ([path hasPrefix:@"/Volumes"])
		return;
	NSURL *url = [NSURL fileURLWithPath:path];
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
	
	/* See if there were any errors loading the script */
	if (!appleScript || errors) {
		NSLog(@"error creating applescript:%@ errors:%@", appleScript, [errors description]);
		[appleScript release];
		return;
	}
	
	NSAppleEventDescriptor *firstParameter = [NSAppleEventDescriptor descriptorWithString:paramString];
	NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
	[parameters insertDescriptor:firstParameter atIndex:1];
	
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
	NSAppleEventDescriptor *methodName = [NSAppleEventDescriptor descriptorWithString:[commandName lowercaseString]];
	NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:'ascr'
																			 eventID:'psbr'
																	targetDescriptor:target
																			returnID:kAutoGenerateReturnID
																	   transactionID:kAnyTransactionID];
	[event setParamDescriptor:methodName forKeyword:'snam'];
	[event setParamDescriptor:parameters forKeyword:keyDirectObject];
	if(	![appleScript executeAppleEvent:event error:&errors]) {
		NSLog(@"error executing applescript: errors:%@", [errors description]);
	}
	[appleScript release];
}



@end
