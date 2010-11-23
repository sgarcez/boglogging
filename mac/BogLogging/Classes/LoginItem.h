//
//  LoginItem.h
//  BogLogging
//
//  Created by James Beith on 23/11/2010.
//  Copyright 2010 unit9. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoginItem : NSObject {

}

+ (BOOL)willStartAtLogin;
+ (void)setStartAtLogin:(BOOL)enabled;

@end
