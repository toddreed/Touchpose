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


#import <UIKit/UIKit.h>


@class TRTouchposeTouchView;

/// The TRTouchposeTouchView protocol must be implemented by any UIView subclass use to present a
/// touch on the screen.
@protocol TRTouchposeTouchView <NSObject>

/// The point on the screen this touch view represents. Setting this property adjusts the center
/// property of the receiver. When the touch view is centered on the touch point, setting
/// `touchPoint` simply sets the `center` property.
@property (nonatomic) CGPoint touchPoint;

@end


@protocol TRTouchposeTouchViewFactory <NSObject>

- (UIView<TRTouchposeTouchView> *)touchViewAtPoint:(CGPoint)point;

@end



