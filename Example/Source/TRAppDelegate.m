// Copyright 2012 Todd Reed
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Touchpose/TRTouchposeApplication.h>
#import <Touchpose/TRTouchposeImageTouchView.h>

#import "TRAppDelegate.h"
#import "TRViewController.h"

@implementation TRAppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[TRViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    // For demo purposes, show the touches even when not mirroring to an external display.
    TRTouchposeApplication *touchposeApplication = (TRTouchposeApplication *)application;
    touchposeApplication.showTouches = YES;

#if 0
    // Example of customizing the "touch"

    TRTouchposeImageTouchViewFactory *touchViewFactory = [[TRTouchposeImageTouchViewFactory alloc] init];
    touchViewFactory.touchImage = [UIImage imageNamed:@"Finger"];
    touchViewFactory.offset = CGPointMake(52, 43);
    touchposeApplication.touchViewFactory = touchViewFactory;
#endif

    return YES;

}

@end
