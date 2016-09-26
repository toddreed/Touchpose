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

#import "TRViewController.h"
#import "TRTouchposeApplication.h"

@interface TRViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *touchposeSwitch;

@end

@implementation TRViewController

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TRTouchposeApplication *application = (TRTouchposeApplication *)[UIApplication sharedApplication];
    _touchposeSwitch.on = application.showTouches;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchposeTouchesVisibleDidChange:) name:TRTouchposeTouchesVisibleDidChange object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark - TRViewController

- (void)updateTouchposeSwitch
{
    TRTouchposeApplication *application = (TRTouchposeApplication *)[UIApplication sharedApplication];
    _touchposeSwitch.on = application.showTouches;
}

- (void)touchposeTouchesVisibleDidChange:(NSNotification *)notification
{
    [self updateTouchposeSwitch];
}

- (IBAction)touchposeSwitchValueChanged:(id)sender
{
    TRTouchposeApplication *application = (TRTouchposeApplication *)[UIApplication sharedApplication];
    application.showTouches = _touchposeSwitch.on;
}

@end
