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


#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "QTouchposeApplication.h"
#import "QTouchposeCircleTouchView.h"


@interface QTouchposeApplication ()

- (void)keyWindowChanged:(UIWindow *)window;
- (void)bringTouchViewToFront;

@end

/// The QTouchposeTouchesView is an overlay view that is used as the superview for
/// QTouchposeTouchView instances.
@interface QTouchposeTouchesView : UIView
@end

@implementation QTouchposeTouchesView
@end




IMP SwizzleMethod(Class c, SEL sel, IMP newImplementation)
{
    Method method = class_getInstanceMethod(c, sel);
    IMP originalImplementation = method_getImplementation(method);
    if (!class_addMethod(c, sel, newImplementation, method_getTypeEncoding(method)))
        method_setImplementation(method, newImplementation);
    return originalImplementation;
}

static void (*UIWindow_orig_becomeKeyWindow)(UIWindow *, SEL);

// This method replaces -[UIWindow becomeKeyWindow] (but calls the original -becomeKeyWindow). This
// is used to move the overlay to the current key window.
static void UIWindow_new_becomeKeyWindow(UIWindow *window, SEL _cmd)
{
    QTouchposeApplication *application = (QTouchposeApplication *)[UIApplication sharedApplication];
    [application keyWindowChanged:window];
    (*UIWindow_orig_becomeKeyWindow)(window, _cmd);
}

static void (*UIWindow_orig_didAddSubview)(UIWindow *, SEL, UIView *);

// This method replaces -[UIWindow didAddSubview:] (but calls the original -didAddSubview:). This is
// used to keep the overlay view the top-most view of the window.
static void UIWindow_new_didAddSubview(UIWindow *window, SEL _cmd, UIView *view)
{
    if (![view conformsToProtocol:@protocol(QTouchposeTouchView)])
    {
        QTouchposeApplication *application = (QTouchposeApplication *)[UIApplication sharedApplication];
        [application bringTouchViewToFront];
    }
    (*UIWindow_orig_didAddSubview)(window, _cmd, view);
}


@implementation QTouchposeApplication
{
    // Dictionary of touches being displayed. Keys are UITouch pointers and values are UIView
    // pointers that represent that visually represent the touch on-screen. (A
    // CFMutableDictionaryRef is used because NSDictionary requries its keys to conform to the
    // NSCopying protocol and UITouch doesn't. We don't need to retain either the UITouch or
    // UIView instances because UITouch objects are persistent throughout a multi-touch
    // sequence, and the UIViews are retained by their superview.)
    CFMutableDictionaryRef _touchDictionary;
    QTouchposeTouchesView *_touchesView;
}

#pragma mark - NSObject

+ (NSUInteger)majorSystemVersion
{
    NSArray *versionComponents = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    return [[versionComponents objectAtIndex:0] integerValue];
}

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
        _alwaysShowTouches = NO;

        // In my experience, the keyboard performance is crippled when showing touches on a
        // device running iOS < 5, so by default, disable touches when the keyboard is
        // present.
        _showTouchesWhenKeyboardShown = [[self class] majorSystemVersion] >= 5;

        _touchViewFactory = [[QTouchposeCircleTouchViewFactory alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFRelease(_touchDictionary);
}


#pragma mark - UIApplication

- (void)sendEvent:(UIEvent *)event
{
    if (_showTouches)
        [self updateTouches:[event allTouches]];
    [super sendEvent:event];
}

#pragma mark - QApplication

- (void)removeTouchesActiveTouches:(NSSet *)activeTouches
{
    CFIndex count = CFDictionaryGetCount(_touchDictionary);
    void const * keys[count];
    void const * values[count];
    CFDictionaryGetKeysAndValues(_touchDictionary, keys, values);
    for (CFIndex i = 0; i < count; ++i)
    {
        UITouch *touch = (__bridge UITouch *)keys[i];

        if (activeTouches == nil || ![activeTouches containsObject:touch])
        {
            UIView *view = (__bridge UIView *)values[i];
            CFDictionaryRemoveValue(_touchDictionary, (__bridge const void *)(touch));
            [view removeFromSuperview];
        }
    }
}

- (void)updateTouches:(NSSet *)touches
{
    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:_touchesView];
        UIView<QTouchposeTouchView> *fingerView = (UIView<QTouchposeTouchView> *)CFDictionaryGetValue(_touchDictionary, (__bridge const void *)(touch));
        
        if (touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded)
        {
            // Note that there seems to be a bug in iOS: we won't observe all UITouches
            // in the UITouchPhaseEnded phase, resulting in some finger views being left
            // on the screen when they shouldn't be. See
            // https://discussions.apple.com/thread/1507669?start=0&tstart=0 for other's
            // comments about this issue. No workaround is implemented here.
            
            
            if (fingerView != nil)
            {
                // Remove the touch from the 
                CFDictionaryRemoveValue(_touchDictionary, (__bridge const void *)(touch));
                [fingerView removeFromSuperview];
            }
        }
        else
        {
            if (fingerView == nil)
            {
                fingerView = [_touchViewFactory touchViewAtPoint:point];
                [_touchesView addSubview:fingerView];
                CFDictionarySetValue(_touchDictionary, (__bridge const void *)(touch), (__bridge const void *)(fingerView));
            }
            else
            {
                fingerView.touchPoint = point;
            }
        }
    }

    [self removeTouchesActiveTouches:touches];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // We intercept calls to -becomeKeyWindow and -didAddSubview of UIWindow to manage the
    // overlay view QTouchposeTouchesView and ensure it remains the top-most window.
    UIWindow_orig_didAddSubview = (void (*)(UIWindow *, SEL, UIView *))SwizzleMethod([UIWindow class], @selector(didAddSubview:), (IMP)UIWindow_new_didAddSubview);
    UIWindow_orig_becomeKeyWindow = (void (*)(UIWindow *, SEL))SwizzleMethod([UIWindow class], @selector(becomeKeyWindow), (IMP)UIWindow_new_becomeKeyWindow);

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
    self.showTouches = _showTouchesWhenKeyboardShown && (_alwaysShowTouches || [self hasMirroredScreen]);
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    self.showTouches = _alwaysShowTouches || [self hasMirroredScreen];
}

- (void)keyWindowChanged:(UIWindow *)window
{
    if (_touchesView)
        [window addSubview:_touchesView];
}

- (void)bringTouchViewToFront
{
    if (_touchesView)
        [_touchesView.window bringSubviewToFront:_touchesView];
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
        if (_touchesView == nil && self.keyWindow)
        {
            UIWindow *window = self.keyWindow;
            _touchesView = [[QTouchposeTouchesView alloc] initWithFrame:window.bounds];
            _touchesView.backgroundColor = [UIColor clearColor];
            _touchesView.opaque = NO;
            _touchesView.userInteractionEnabled = NO;
            [window addSubview:_touchesView];
        }
    }
    else
    {
        [self removeTouchesActiveTouches:nil];
        if (_touchesView)
        {
            [_touchesView removeFromSuperview];
            _touchesView = nil;
        }
    }
    _showTouches = showTouches;
}

@end
