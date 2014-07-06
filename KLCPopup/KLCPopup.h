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

// KLCPopupDismissType: Controls how the popup will be dismissed.
typedef NS_ENUM(NSInteger, KLCPopupDismissType) {
	KLCPopupDismissTypeNone = 0,
	KLCPopupDismissTypeFadeOut,
  KLCPopupDismissTypeGrowOut,
  KLCPopupDismissTypeShrinkOut,
  KLCPopupDismissTypeSlideOutToTop,
  KLCPopupDismissTypeSlideOutToBottom,
  KLCPopupDismissTypeSlideOutToLeft,
  KLCPopupDismissTypeSlideOutToRight,
  KLCPopupDismissTypeBounceOut,
  KLCPopupDismissTypeBounceOutToTop,
  KLCPopupDismissTypeBounceOutToBottom,
  KLCPopupDismissTypeBounceOutToLeft,
  KLCPopupDismissTypeBounceOutToRight,
};



// KLCPopupHorizontalLayout: Controls where the popup will come to rest horizontally.
typedef NS_ENUM(NSInteger, KLCPopupHorizontalLayout) {
  KLCPopupHorizontalLayoutCustom = 0,
  KLCPopupHorizontalLayoutLeft,
  KLCPopupHorizontalLayoutLeftOfCenter,
  KLCPopupHorizontalLayoutCenter,
  KLCPopupHorizontalLayoutRightOfCenter,
  KLCPopupHorizontalLayoutRight,
};

// KLCPopupVerticalLayout: Controls where the popup will come to rest vertically.
typedef NS_ENUM(NSInteger, KLCPopupVerticalLayout) {
  KLCPopupVerticalLayoutCustom = 0,
	KLCPopupVerticalLayoutTop,
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

// KLCPopupLayout structure and maker functions
struct KLCPopupLayout {
  KLCPopupHorizontalLayout horizontal;
  KLCPopupVerticalLayout vertical;
};
typedef struct KLCPopupLayout KLCPopupLayout;

extern KLCPopupLayout KLCPopupLayoutMake(KLCPopupHorizontalLayout horizontal, KLCPopupVerticalLayout vertical);

extern const KLCPopupLayout KLCPopupLayoutCenter;



@interface KLCPopup : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or in willStartShowing.
// - Must set desired size of contentView before or in willStartShowing.
@property (nonatomic, strong) UIView* contentView;

// Animation transition for presenting contentView. default = shrink in
@property (nonatomic, assign) KLCPopupShowType showType;

// Animation transition for dismissing contentView. default = shrink out
@property (nonatomic, assign) KLCPopupDismissType dismissType;

// Mask prevents background touches from passing to underlying views. default = dimmed.
@property (nonatomic, assign) KLCPopupMaskType maskType;

// Overrides alpha value for dimmed background mask. default = 0.5
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;

// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishShowingCompletion)();

// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartDismissingCompletion)();

// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishDismissingCompletion)();

// Convenience method for creating popup with default values (mimics UIAlertView).
+ (KLCPopup*)popupWithContentView:(UIView*)contentView;

// Convenience method for creating popup with custom values.
+ (KLCPopup*)popupWithContentView:(UIView*)contentView
                         showType:(KLCPopupShowType)showType
                      dismissType:(KLCPopupDismissType)dismissType
                         maskType:(KLCPopupMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
+ (void)dismissAllPopups;

// Show popup with center layout. Animation determined by showType.
- (void)show;

// Show with specified layout.
- (void)showWithLayout:(KLCPopupLayout)layout;

// Show and then dismiss after duration. 0.0 or less will be considered infinity.
- (void)showWithDuration:(NSTimeInterval)duration;

// Show with layout and dismiss after duration.
- (void)showWithLayout:(KLCPopupLayout)layout duration:(NSTimeInterval)duration;

// Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
- (void)showAtCenter:(CGPoint)center inView:(UIView*)view;

// Show centered at point in view's coordinate system, then dismiss after duration.
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration;

// Dismiss popup. Uses dismissType if animated is YES.
- (void)dismiss:(BOOL)animated;


#pragma mark Subclassing
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;

- (void)willStartShowing;
- (void)didFinishShowing;
- (void)willStartDismissing;
- (void)didFinishDismissing;

@end


#pragma mark - UIView Category
@interface UIView(KLCPopup)
- (void)forEachPopupDoBlock:(void (^)(KLCPopup* popup))block;
- (void)dismissPresentingPopup;
@end

