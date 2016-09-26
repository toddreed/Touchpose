//
//  TRTouchposeImageTouchView.m
//  Touchpose
//
//  Created by Todd Reed on 2014-11-02.
//  Copyright (c) 2014 Reaction Software Inc. All rights reserved.
//

#import "TRTouchposeImageTouchView.h"


@implementation TRTouchposeImageTouchViewFactory

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _touchImage = nil;
        _offset = CGPointZero;
        _touchEndAnimationDuration = 0.5;
    }
    return self;
}

#pragma mark - TRTouchposeTouchViewFactory

- (UIView<TRTouchposeTouchView> *)touchViewAtPoint:(CGPoint)point
{
    TRTouchposeImageTouchView *touchView = [[TRTouchposeImageTouchView alloc] initWithPoint:point touchImage:self.touchImage offset:self.offset];
    touchView.touchEndAnimationDuration = self.touchEndAnimationDuration;
    return touchView;
}

@end


@implementation TRTouchposeImageTouchView
{
    UIImage *_touchImage;
    CGPoint _offset;
}

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
    } completion:^(BOOL completed){
        [super removeFromSuperview];
    }];
}

#pragma mark - TRTouchposeImageTouchView

- (instancetype)initWithPoint:(CGPoint)point
                   touchImage:(UIImage *)touchImage
                       offset:(CGPoint)offset
{
    CGRect frame = CGRectMake(point.x - offset.x,
                              point.y - offset.y,
                              touchImage.size.width,
                              touchImage.size.height);

    if (self = [super initWithFrame:frame])
    {
        self.opaque = NO;
        _touchImage = touchImage;
        _offset = offset;

        UIImageView *imageView = [[UIImageView alloc] initWithImage:touchImage];
        [self addSubview:imageView];
    }

    return self;
}

#pragma mark TRTouchposeTouchView

- (void)setTouchPoint:(CGPoint)touchPoint
{
    CGPoint center = touchPoint;
    center.x += (_touchImage.size.width / 2) - _offset.x;
    center.y += (_touchImage.size.height / 2) - _offset.y;
    self.center = center;
}

- (CGPoint)touchPoint
{
    CGRect frame = self.frame;
    return CGPointMake(frame.origin.x+_offset.x, frame.origin.y+_offset.y);
}

@end
