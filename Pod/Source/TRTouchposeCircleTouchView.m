// Copyright 2014 Todd Reed
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


#import "TRTouchposeCircleTouchView.h"


@implementation TRTouchposeCircleTouchViewFactory

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _touchColor = [UIColor colorWithRed:0.251f green:0.424f blue:0.502f alpha:1.0f];
        _touchEndAnimationDuration = 0.5f;
        _touchEndTransform = CATransform3DMakeScale(1.5, 1.5, 1);
    }
    return self;
}

#pragma mark - TRTouchposeTouchViewFactory

- (UIView<TRTouchposeTouchView> *)touchViewAtPoint:(CGPoint)point
{
    return [[TRTouchposeCircleTouchView alloc] initWithPoint:point
                                                      color:self.touchColor
                                  touchEndAnimationDuration:self.touchEndAnimationDuration
                                          touchEndTransform:self.touchEndTransform];
}

@end


@implementation TRTouchposeCircleTouchView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"-[%@ %@] not supported", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)removeFromSuperview
{
    [UIView animateWithDuration:_touchEndAnimationDuration animations:^{
        self.alpha = 0.0f;
        self.layer.transform = _touchEndTransform;
    } completion:^(BOOL completed) {
        [super removeFromSuperview];
    }];
}

#pragma mark - TRTouchposeCircleTouchView

- (instancetype)initWithPoint:(CGPoint)point
                        color:(UIColor *)color
    touchEndAnimationDuration:(NSTimeInterval)touchEndAnimationDuration
            touchEndTransform:(CATransform3D)touchEndTransform
{
    const CGFloat kFingerRadius = 22.0f;

    if ((self = [super initWithFrame:CGRectMake(point.x-kFingerRadius, point.y-kFingerRadius, 2*kFingerRadius, 2*kFingerRadius)]))
    {
        self.opaque = NO;
        self.layer.borderColor = [color colorWithAlphaComponent:0.6f].CGColor;
        self.layer.cornerRadius = kFingerRadius;
        self.layer.borderWidth = 2.0f;
        self.layer.backgroundColor = [color colorWithAlphaComponent:0.4f].CGColor;

        _touchEndAnimationDuration = touchEndAnimationDuration;
        _touchEndTransform = touchEndTransform;
    }

    return self;
}

#pragma mark TRTouchposeTouchView

- (void)setTouchPoint:(CGPoint)touchPoint
{
    self.center = touchPoint;
}

- (CGPoint)touchPoint
{
    return self.center;
}

@end
