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

#import "QAppDelegate.h"
#import "QViewController.h"
#import "QTouchposeApplication.h"

@implementation QAppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[QViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    // For demo purposes, show the touches even when not mirroring to an external display.
    QTouchposeApplication *touchposeApplication = (QTouchposeApplication *)application;
    touchposeApplication.alwaysShowTouches = YES;

    // Examples of customizing the color and touch-end animation:
    //
    // touchposeApplication.touchColor = [UIColor redColor];
    // touchposeApplication.touchEndAnimationDuration = 0.3f;
    // touchposeApplication.touchEndTransform = CATransform3DMakeScale(0.1, 0.1, 1);
    
    // Example of adding your own custom image
    // "customTouchPoint" is a point relative to the image (upper-left corner = 0,0) indicating the desired touch point of the cursor
    //
    // touchposeApplication.customTouchImage = [UIImage imageNamed:@"<my_custom_image.png>"];
    // touchposeApplication.customTouchPoint = CGPointMake(214, 148);

    return YES;
}

@end
