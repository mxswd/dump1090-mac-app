//
//  AppDelegate.m
//  Dump1090 Mac Server
//
//  Created by Maxwell Swadling on 26/1/19.
//  Copyright © 2019 Maxwell Swadling. All rights reserved.
//

#import "AppDelegate.h"
#import "Dump1090API.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    dump1090_stop();
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
