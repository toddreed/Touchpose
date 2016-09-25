//
//  QTouchposeImageTouchView.h
//  Touchpose
//
//  Created by Todd Reed on 2014-11-02.
//  Copyright (c) 2014 Reaction Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTouchposeTouchView.h"


@interface QTouchposeImageTouchViewFactory: NSObject <QTouchposeTouchViewFactory>

@property (nonatomic) UIImage *touchImage;
@property (nonatomic) CGPoint offset;
@property (nonatomic) CGFloat touchEndAnimationDuration;

@end


@interface QTouchposeImageTouchView : UIView <QTouchposeTouchView>

- (instancetype)initWithPoint:(CGPoint)point
                   touchImage:(UIImage *)touchImage
                       offset:(CGPoint)offset;

@property (nonatomic) CGFloat touchEndAnimationDuration;

@end
