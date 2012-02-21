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


#import "QTouchposeApplication.h"
#import <QuartzCore/QuartzCore.h>

@interface QTouchposeApplication ()

- (void)updateTouches:(NSSet *)touches;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)screenDidConnectNotification:(NSNotification *)notification;
- (void)screenDidDisonnectNotification:(NSNotification *)notification;
- (BOOL)hasMirroredScreen;
- (void)bringTouchViewToFront;

@end

@implementation QTouchposeWindow

- (void)didAddSubview:(UIView *)subview
{
    // Move the touch view to the front
    QTouchposeApplication *application = (QTouchposeApplication *)[UIApplication sharedApplication];
    [application bringTouchViewToFront];
}

@end

@implementation QTouchposeApplication
{
    // Dictionary of touches being displayed. Keys are UITouch pointers and values are UIView pointers.
    CFMutableDictionaryRef _touchDictionary;
    UIView *_touchView;
    CGFloat _touchHue;
    BOOL _showTouches;
    BOOL _alwaysShowTouches;
}

#pragma mark - NSObject

- (id)init
{
    if ((self = [super init]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnectNotification:) name:UIScreenDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidDisonnectNotification:) name:UIScreenDidDisconnectNotification object:nil];
        _touchDictionary = CFDictionaryCreateMutable(NULL, 10, NULL, NULL);
        _touchHue = 0.55f;
        _alwaysShowTouches = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFRelease(_touchDictionary);
    [_touchView release];
    [super dealloc];
}


#pragma mark - UIApplication

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    if (_showTouches)
        [self updateTouches:[event allTouches]];
}

#pragma mark - QApplication

@synthesize touchHue = _touchHue;
@synthesize showTouches = _showTouches;
@synthesize alwaysShowTouches = _alwaysShowTouches;

- (UIView *)fingerViewAtPoint:(CGPoint)point
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(point.x-22.0f, point.y-22.0f, 44.0f, 44.0f)];
    view.opaque = NO;
    view.layer.borderColor = [UIColor colorWithHue:_touchHue saturation:0.5f brightness:0.5f alpha:0.6f].CGColor;
    view.layer.cornerRadius = 22.0f;
    view.layer.borderWidth = 2.0f;
    view.layer.backgroundColor = [UIColor colorWithHue:_touchHue saturation:0.5f brightness:0.5f alpha:0.4f].CGColor;
    return [view autorelease];
}

- (void)updateTouches:(NSSet *)touches
{
    NSMutableSet *activeTouches = [[NSMutableSet alloc] init];

    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:_touchView];

        if (!(touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded))
        {
            UIView *fingerView = (UIView *)CFDictionaryGetValue(_touchDictionary, touch);

            if (fingerView == NULL)
            {
                fingerView = [self fingerViewAtPoint:point];
                [_touchView addSubview:fingerView];
                [touch retain];
                CFDictionarySetValue(_touchDictionary, touch, fingerView);
            }
            else
            {
                fingerView.center = point;
            }
            [activeTouches addObject:touch];
        }

    }

    // Remove inactive finger views
    CFIndex count = CFDictionaryGetCount(_touchDictionary);
    if (count != [activeTouches count])
    {
        UITouch **keys = alloca(sizeof(UITouch *)*count);
        UIView **values = alloca(sizeof(UIView *)*count);
        CFDictionaryGetKeysAndValues(_touchDictionary, (const void **)keys, (const void **)values);
        NSUInteger itemCount = CFDictionaryGetCount(_touchDictionary);
        for (NSUInteger i = 0; i < itemCount; ++i)
        {
            if (![activeTouches containsObject:keys[i]])
            {
                UITouch *touch = keys[i];
                UIView *view = values[i];

                [touch release];
                CFDictionaryRemoveValue(_touchDictionary, touch);
                [UIView animateWithDuration:0.5f animations:^{ view.alpha = 0.0f; } completion:^(BOOL completed){ [view removeFromSuperview]; }];
            }
        }
    }
    [activeTouches release];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)screenDidConnectNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)screenDidDisonnectNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)bringTouchViewToFront
{
    UIWindow *window = [self.windows objectAtIndex:0];
    [window bringSubviewToFront:_touchView];
}

- (BOOL)hasMirroredScreen
{
    BOOL hasMirroredScreen = NO;
    NSArray *screens = [UIScreen screens];

    if ([screens count] > 1)
    {
        for (UIScreen *screen in screens)
        {
            if (screen.mirroredScreen != nil)
            {
                hasMirroredScreen = YES;
                break;
            }
        }
    }
    return hasMirroredScreen;
}

- (void)setShowTouches:(BOOL)showTouches
{
    if (showTouches)
    {
        if (_touchView == nil)
        {
            UIWindow *window = [self.windows objectAtIndex:0];
            _touchView = [[UIView alloc] initWithFrame:window.bounds];
            _touchView.backgroundColor = [UIColor clearColor];
            _touchView.opaque = NO;
            _touchView.userInteractionEnabled = NO;
            [window addSubview:_touchView];
        }
    }
    else
    {
        if (_touchView)
        {
            [_touchView removeFromSuperview];
            [_touchView release];
            _touchView = nil;
        }
    }
    _showTouches = showTouches;
}

@end
