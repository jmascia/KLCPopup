// KLCPopup.h
//
// Created by Jeff Mascia
// Copyright (c) 2013-2014 Kullect Inc. (http://kullect.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


// KLCPopupShowType: Controls how the popup will be presented.
typedef NS_ENUM(NSInteger, KLCPopupShowType) {
	KLCPopupShowTypeNone = 0,
	KLCPopupShowTypeFadeIn,
  KLCPopupShowTypeGrowIn,
  KLCPopupShowTypeShrinkIn,
  KLCPopupShowTypeSlideInFromTop,
  KLCPopupShowTypeSlideInFromBottom,
  KLCPopupShowTypeSlideInFromLeft,
  KLCPopupShowTypeSlideInFromRight,
  KLCPopupShowTypeBounceIn,
  KLCPopupShowTypeBounceInFromTop,
  KLCPopupShowTypeBounceInFromBottom,
  KLCPopupShowTypeBounceInFromLeft,
  KLCPopupShowTypeBounceInFromRight,
};

// KLCPopupHideType: Controls how the popup will be dismissed.
typedef NS_ENUM(NSInteger, KLCPopupHideType) {
	KLCPopupHideTypeNone = 0,
	KLCPopupHideTypeFadeOut,
  KLCPopupHideTypeGrowOut,
  KLCPopupHideTypeShrinkOut,
  KLCPopupHideTypeSlideOutToTop,
  KLCPopupHideTypeSlideOutToBottom,
  KLCPopupHideTypeSlideOutToLeft,
  KLCPopupHideTypeSlideOutToRight,
  KLCPopupHideTypeBounceOut,
  KLCPopupHideTypeBounceOutToTop,
  KLCPopupHideTypeBounceOutToBottom,
  KLCPopupHideTypeBounceOutToLeft,
  KLCPopupHideTypeBounceOutToRight,
};

// KLCPopupHorizontalLayout: Controls where the popup will come to rest horizontally.
typedef NS_ENUM(NSInteger, KLCPopupHorizontalLayout) {
  KLCPopupHorizontalLayoutLeft = 0,
  KLCPopupHorizontalLayoutLeftOfCenter,
  KLCPopupHorizontalLayoutCenter,
  KLCPopupHorizontalLayoutRightOfCenter,
  KLCPopupHorizontalLayoutRight,
};

// KLCPopupVerticalLayout: Controls where the popup will come to rest vertically.
typedef NS_ENUM(NSInteger, KLCPopupVerticalLayout) {
	KLCPopupVerticalLayoutTop = 0,
  KLCPopupVerticalLayoutAboveCenter,
  KLCPopupVerticalLayoutCenter,
  KLCPopupVerticalLayoutBelowCenter,
  KLCPopupVerticalLayoutBottom,
};

// KLCPopupMaskType
typedef NS_ENUM(NSInteger, KLCPopupMaskType) {
	KLCPopupMaskTypeNone = 0, // Allow interaction with underlying views.
	KLCPopupMaskTypeClear, // Don't allow interaction with underlying views.
	KLCPopupMaskTypeDimmed, // Don't allow interaction with underlying views, dim background.
};


@interface KLCPopup : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or during willStartShowing.
// - Must set desired size of contentView before or during willStartShowing.
@property (nonatomic, strong) UIView* contentView;

@property (nonatomic, assign) KLCPopupShowType showType; // default = none.
@property (nonatomic, assign) KLCPopupHideType hideType; // default = none.
@property (nonatomic, assign) KLCPopupMaskType maskType; // default = none.
@property (nonatomic, assign) KLCPopupHorizontalLayout horizontalLayout; // default = center.
@property (nonatomic, assign) KLCPopupVerticalLayout verticalLayout; // default = center.

// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldHideOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property (nonatomic, assign) BOOL shouldHideOnContentTouch;

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishShowingCompletion)();

// Block gets called when hide animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartHidingCompletion)();

// Block gets called after hide animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishHidingCompletion)();

// Convenience method for creating a popup.
+ (KLCPopup*)popupWithContentView:(UIView*)contentView
                        showType:(KLCPopupShowType)showType
                        hideType:(KLCPopupHideType)hideType
                        maskType:(KLCPopupMaskType)maskType;

// Hides all the popups in the app.
+ (void)hideAllPopups;

// Show popup. Uses showType for animation.
- (void)show;

// Show and then hide after duration. 0.0 or less will be considered infinity.
- (void)showWithDuration:(NSTimeInterval)duration;

// Hide popup. Uses hideType if animated is YES.
- (void)hide:(BOOL)animated;

#pragma mark Subclassing
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingHidden;

- (void)willStartShowing;
- (void)didFinishShowing;
- (void)willStartHiding;
- (void)didFinishHiding;

@end


#pragma mark - UIView Category
@interface UIView(KLCPopup)
- (void)forEachPopupDoBlock:(void (^)(KLCPopup* popup))block;
- (void)hidePresentingPopup;
@end

