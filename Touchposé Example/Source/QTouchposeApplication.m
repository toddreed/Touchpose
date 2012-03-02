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
- (void)keyboardDidShowNotification:(NSNotification *)notification;
- (void)keyboardDidHideNotification:(NSNotification *)notification;
- (BOOL)hasMirroredScreen;
- (void)bringTouchViewToFront;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];        
        _touchDictionary = CFDictionaryCreateMutable(NULL, 10, NULL, NULL);
        _touchHue = 0.55f;
        _alwaysShowTouches = NO;
        [self bringTouchViewToFront];
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

- (void)removeTouchesActiveTouches:(NSSet *)activeTouches
{
    CFIndex count = CFDictionaryGetCount(_touchDictionary);
    UITouch **keys = alloca(sizeof(UITouch *)*count);
    UIView **values = alloca(sizeof(UIView *)*count);
    CFDictionaryGetKeysAndValues(_touchDictionary, (const void **)keys, (const void **)values);
    for (NSUInteger i = 0; i < count; ++i)
    {
        UITouch *touch = keys[i];

        if (activeTouches == nil || ![activeTouches containsObject:touch])
        {
            UIView *view = values[i];
            [touch release];
            CFDictionaryRemoveValue(_touchDictionary, touch);
            [UIView animateWithDuration:0.5f animations:^{ view.alpha = 0.0f; } completion:^(BOOL completed){ [view removeFromSuperview]; }];
        }
    }
}

- (void)updateTouches:(NSSet *)touches
{
    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:_touchView];
        UIView *fingerView = (UIView *)CFDictionaryGetValue(_touchDictionary, touch);
        
        if (touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded)
        {
            // Note that there seems to be a bug in iOS: we won't observe all UITouches
            // in the UITouchPhaseEnded phase, resulting in some finger views being left
            // on the screen when they shouldn't be. See
            // https://discussions.apple.com/thread/1507669?start=0&tstart=0 for other's
            // comments about this issue. No workaround is implemented here.
            
            
            if (fingerView != NULL)
            {
                // Remove the touch from the 
                [touch release];
                CFDictionaryRemoveValue(_touchDictionary, touch);
                [UIView animateWithDuration:0.5f animations:^{ fingerView.alpha = 0.0f; } completion:^(BOOL completed){ [fingerView removeFromSuperview]; }];
            }
        }
        else
        {
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
        }
    }

    [self removeTouchesActiveTouches:touches];
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

- (void)keyboardDidShowNotification:(NSNotification *)notification
{
    self.showTouches = NO;
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (UIView *)frontView:(UIView *)view
{
    if ([view isKindOfClass:[UIActionSheet class]] || [view isKindOfClass:[UIAlertView class]])
    {
        return view;
    }
    
    NSArray *subviews = [view subviews];
    if ([subviews count] > 0)
    {
        for (UIView *subview in subviews)
        {
            return [self frontView:subview];
        }
    }
    else
    {
        NSArray *siblings = [[view superview] subviews];
        NSUInteger viewIndex = [siblings indexOfObject:view];
        if (siblings && ((viewIndex + 1) < [siblings count]))
        {
            return [self frontView:[siblings objectAtIndex:viewIndex + 1]];
        }
    }
    
    return nil;
}

- (void)bringTouchViewToFront
{
    UIWindow *backWindow = [self.windows count] > 0 ? [self.windows objectAtIndex:0] : nil;
    UIView *frontView = [self frontView:[self.windows lastObject]];
    [frontView ?: backWindow addSubview:_touchView];
    [self performSelector:_cmd withObject:nil afterDelay:0.1];
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
        [self removeTouchesActiveTouches:nil];
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
