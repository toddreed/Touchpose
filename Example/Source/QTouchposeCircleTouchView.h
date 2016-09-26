//
//  QTouchposeCircleTouchView.h
//  Touchpose
//
//  Created by Todd Reed on 2014-11-02.
//  Copyright (c) 2014 Reaction Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTouchposeTouchView.h"


@interface QTouchposeCircleTouchViewFactory: NSObject <QTouchposeTouchViewFactory>

@property (nonatomic) CGFloat touchEndAnimationDuration;
@property (nonatomic) CATransform3D touchEndTransform;
@property (nonatomic, strong) UIColor *touchColor;

@end


/// QTouchposeCircleTouchView renders a touch as circular dot.
@interface QTouchposeCircleTouchView : UIView <QTouchposeTouchView>

- (instancetype)initWithPoint:(CGPoint)point
                        color:(UIColor *)color
    touchEndAnimationDuration:(NSTimeInterval)touchEndAnimationDuration
            touchEndTransform:(CATransform3D)touchEndTransform;

@property (nonatomic) CGFloat touchEndAnimationDuration;
@property (nonatomic) CATransform3D touchEndTransform;
@property (nonatomic, strong) UIColor *touchColor;

@end
