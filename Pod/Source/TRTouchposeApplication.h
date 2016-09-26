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


#import <UIKit/UIKit.h>
#import "TRTouchposeTouchView.h"

/// `TRTouchposeTouchesVisibleDidChange` is a notification sent when the `showTouches` property
/// from `TRTouchposeApplication` changes.
extern NSString *const TRTouchposeTouchesVisibleDidChange;

/// TRTouchposeApplication
@interface TRTouchposeApplication : UIApplication

/// Indicate whether touches are rendered. The default value is NO.
@property (nonatomic) BOOL showTouches;

/// Indicate whether the `showTouches` property should automatically be updated when the
/// device’s screen is mirrored. The default value is YES.
@property (nonatomic) BOOL automaticallyManageTouchesWhenScreenMirrored;

/// A factory for creating touch views. The default is TRTouchposeCircleTouchViewFactory. If you
/// want to customize the appearance of touches you can implement your own touch view class and
/// factory.
@property (nonatomic, strong) id<TRTouchposeTouchViewFactory> touchViewFactory;

@end
