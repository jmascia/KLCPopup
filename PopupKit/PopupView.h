// PopupView.h
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

@import Foundation;
@import UIKit;

@class PopupView;

NS_ASSUME_NONNULL_BEGIN

// PopupViewShowType: Controls how the popup will be presented.
typedef NS_OPTIONS(NSInteger, PopupViewShowType) {
    PopupViewShowTypeNone = 0,
    PopupViewShowTypeFadeIn,
    PopupViewShowTypeGrowIn,
    PopupViewShowTypeShrinkIn,
    PopupViewShowTypeSlideInFromTop,
    PopupViewShowTypeSlideInFromBottom,
    PopupViewShowTypeSlideInFromLeft,
    PopupViewShowTypeSlideInFromRight,
    PopupViewShowTypeBounceIn,
    PopupViewShowTypeBounceInFromTop,
    PopupViewShowTypeBounceInFromBottom,
    PopupViewShowTypeBounceInFromLeft,
    PopupViewShowTypeBounceInFromRight,
} NS_SWIFT_NAME(PopupView.ShowType);

// PopupViewDismissType: Controls how the popup will be dismissed.
typedef NS_OPTIONS(NSInteger, PopupViewDismissType) {
    PopupViewDismissTypeNone = 0,
    PopupViewDismissTypeFadeOut,
    PopupViewDismissTypeGrowOut,
    PopupViewDismissTypeShrinkOut,
    PopupViewDismissTypeSlideOutToTop,
    PopupViewDismissTypeSlideOutToBottom,
    PopupViewDismissTypeSlideOutToLeft,
    PopupViewDismissTypeSlideOutToRight,
    PopupViewDismissTypeBounceOut,
    PopupViewDismissTypeBounceOutToTop,
    PopupViewDismissTypeBounceOutToBottom,
    PopupViewDismissTypeBounceOutToLeft,
    PopupViewDismissTypeBounceOutToRight,
} NS_SWIFT_NAME(PopupView.DismissType);


// PopupViewHorizontalLayout: Controls where the popup will come to rest horizontally.
typedef NS_OPTIONS(NSInteger, PopupViewHorizontalLayout) {
    PopupViewHorizontalLayoutCustom = 0,
    PopupViewHorizontalLayoutLeft,
    PopupViewHorizontalLayoutLeftOfCenter,
    PopupViewHorizontalLayoutCenter,
    PopupViewHorizontalLayoutRightOfCenter,
    PopupViewHorizontalLayoutRight,
} NS_SWIFT_NAME(PopupView.HorizontalLayout);

// PopupViewVerticalLayout: Controls where the popup will come to rest vertically.
typedef NS_OPTIONS(NSInteger, PopupViewVerticalLayout) {
    PopupViewVerticalLayoutCustom = 0,
    PopupViewVerticalLayoutTop,
    PopupViewVerticalLayoutAboveCenter,
    PopupViewVerticalLayoutCenter,
    PopupViewVerticalLayoutBelowCenter,
    PopupViewVerticalLayoutBottom,
} NS_SWIFT_NAME(PopupView.VerticalLayout);

// PopupViewMaskType
typedef NS_OPTIONS(NSInteger, PopupViewMaskType) {
    PopupViewMaskTypeNone = 0, // Allow interaction with underlying views.
    PopupViewMaskTypeClear, // Don't allow interaction with underlying views.
    PopupViewMaskTypeDimmed, // Don't allow interaction with underlying views, dim background.
    PopupViewMaskTypeLightBlur, // Don't allow interaction with underlying views, blurs background.
    PopupViewMaskTypeDarkBlur,// Don't allow interaction with underlying views, blurs background.
} NS_SWIFT_NAME(PopupView.MaskType);

// PopupViewLayout structure and maker functions
typedef struct {
    PopupViewHorizontalLayout horizontal;
    PopupViewVerticalLayout vertical;
} PopupViewLayout NS_SWIFT_NAME(PopupView.Layout);

PopupViewLayout PopupViewLayoutMake(PopupViewHorizontalLayout horizontal, PopupViewVerticalLayout vertical) CF_SWIFT_UNAVAILABLE("Use 'PopupView.Layout.init(::)' instead");

static const PopupViewLayout PopupViewLayoutCenter;

@interface PopupView : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or in willStartShowing.
// - Must set desired size of contentView before or in willStartShowing.
@property(nonatomic, strong) UIView *contentView;

// Animation transition for presenting contentView. default = shrink in
@property(nonatomic, assign) PopupViewShowType showType;

// Animation transition for dismissing contentView. default = shrink out
@property(nonatomic, assign) PopupViewDismissType dismissType;

// Mask prevents background touches from passing to underlying views. default = dimmed.
@property(nonatomic, assign) PopupViewMaskType maskType;

// Overrides alpha value for dimmed background mask. default = 0.5
@property(nonatomic, assign) CGFloat dimmedMaskAlpha;

// If YES, then popup will get dismissed when background is touched. default = YES.
@property(nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property(nonatomic, assign) BOOL shouldDismissOnContentTouch;

// If YES, then popup will move up or down when keyboard is on or off screen. default = NO.
@property(nonatomic, assign) BOOL shouldHandleKeyboard;

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property(nonatomic, copy) void (^didFinishShowingCompletion)();

// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property(nonatomic, copy) void (^willStartDismissingCompletion)();

// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property(nonatomic, copy) void (^didFinishDismissingCompletion)();

// Convenience method for creating popup with default values (mimics UIAlertView).
+ (instancetype)popupViewWithContentView:(UIView *)contentView;

// Convenience method for creating popup with custom values.
+ (instancetype)popupViewWithContentView:(UIView *)contentView
                                showType:(PopupViewShowType)showType
                             dismissType:(PopupViewDismissType)dismissType
                                maskType:(PopupViewMaskType)maskType
          shouldDismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
             shouldDismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
+ (void)dismissAllPopups;

// Show popup with center layout. Animation determined by showType.
- (void)show;

// Show with specified layout.
- (void)showWithLayout:(PopupViewLayout)layout;

// Show with specified layout in specific view.
- (void)showWithLayout:(PopupViewLayout)layout
                inView:(UIView*) view;

// Show and then dismiss after duration. 0.0 or less will be considered infinity.
- (void)showWithDuration:(NSTimeInterval)duration NS_SWIFT_NAME(PopupView.show(with:));

// Show with layout and dismiss after duration.
- (void)showWithLayout:(PopupViewLayout)layout duration:(NSTimeInterval)duration;

// Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view NS_SWIFT_NAME(PopupView.show(at:in:));

// Show centered at point in view's coordinate system, then dismiss after duration.
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration NS_SWIFT_NAME(PopupView.show(at:in:with:));

// Dismiss popup. Uses dismissType if animated is YES.
- (void)dismiss:(BOOL)animated NS_SWIFT_NAME(PopupView.dismiss(animated:));;


#pragma mark Subclassing

@property(nonatomic, strong, readonly) UIView *backgroundView;
@property(nonatomic, strong, readonly) UIView *containerView;
@property(nonatomic, assign, readonly) BOOL isBeingShown;
@property(nonatomic, assign, readonly) BOOL isShowing;
@property(nonatomic, assign, readonly) BOOL isBeingDismissed;

- (void)willStartShowing;

- (void)didFinishShowing;

- (void)willStartDismissing;

- (void)didFinishDismissing;

@end

#pragma mark - UIView Category

@interface UIView (PopupView)
- (void)forEachPopupDoBlock:(void (^)(PopupView *popup))block NS_SWIFT_NAME(UIView.forEachPopup(handle:));

- (void)dismissPresentingPopup;
@end

NS_ASSUME_NONNULL_END
