//
//  QTouchposeTouchView.h
//  Touchpose
//
//  Created by Todd Reed on 2014-11-02.
//  Copyright (c) 2014 Reaction Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class QTouchposeTouchView;

/// The QTouchposeTouchView protocol must be implemented by any UIView subclass use to present a
/// touch on the screen.
@protocol QTouchposeTouchView <NSObject>

/// The point on the screen this touch view represents. Setting this property adjusts the center
/// property of the receiver. When the touch view is centered on the touch point, setting
/// `touchPoint` simply sets the `center` property.
@property (nonatomic) CGPoint touchPoint;

@end


@protocol QTouchposeTouchViewFactory <NSObject>

- (UIView<QTouchposeTouchView> *)touchViewAtPoint:(CGPoint)point;

@end



