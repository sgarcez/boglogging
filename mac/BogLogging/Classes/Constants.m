//
//  Constants.m
//  PhotoGallery
//
//  Created by James Beith on 25/10/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import "Constants.h"

// The API URL for the bog status.
NSString* const kStateURLString = @"http://boglogging.com/api/state/";

// Strings for the menus.
NSString* const kMenuErrorString = @"Bog connection error!";
NSString* const kMenuEngagedString = @"Bog is engaged";
NSString* const kMenuFreeString = @"Bog is free";
NSString* const kStatusItemEngagedString = @"Engaged";
NSString* const kStatusItemFreeString = @"Free";

// NSUserDefaults key for whether to use black or coloured icons.
NSString* const kUseBlackIconsUserDefaults = @"kUseBlackIconsUserDefaults";
// NSUserDefaults key used to test whether this is the first time the app is launched. If so for example set  set the default launch at login for the app to YES.
NSString* const kApplicationDidMoveUserDefaults = @"kApplicationDidMoveUserDefaults";
