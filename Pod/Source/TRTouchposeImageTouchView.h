//
//  TRTouchposeImageTouchView.h
//  Touchpose
//
//  Created by Todd Reed on 2014-11-02.
//  Copyright (c) 2014 Reaction Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTouchposeTouchView.h"


@interface TRTouchposeImageTouchViewFactory: NSObject <TRTouchposeTouchViewFactory>

@property (nonatomic, strong) UIImage *touchImage;
@property (nonatomic) CGPoint offset;
@property (nonatomic) CGFloat touchEndAnimationDuration;

@end


@interface TRTouchposeImageTouchView : UIView <TRTouchposeTouchView>

- (instancetype)initWithPoint:(CGPoint)point
                   touchImage:(UIImage *)touchImage
                       offset:(CGPoint)offset;

@property (nonatomic) CGFloat touchEndAnimationDuration;

@end
