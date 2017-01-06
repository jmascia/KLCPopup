// PopupView.m
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


#import "PopupView.h"

static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);

PopupViewLayout PopupViewLayoutMake(PopupViewHorizontalLayout horizontal, PopupViewVerticalLayout vertical) {
    PopupViewLayout layout;
    layout.horizontal = horizontal;
    layout.vertical = vertical;
    return layout;
}

static const PopupViewLayout PopupViewLayoutCenter = {PopupViewHorizontalLayoutCenter, PopupViewVerticalLayoutCenter};


@interface NSValue (PopupViewLayout)
+ (NSValue *)valueWithPopupViewLayout:(PopupViewLayout)layout;

- (PopupViewLayout)PopupViewLayoutValue;
@end


@interface PopupView () {
    // views
    UIView *_backgroundView;
    UIView *_containerView;

    // state flags
    BOOL _isBeingShown;
    BOOL _isShowing;
    BOOL _isBeingDismissed;
    CGRect _keyboardRect;
}

@property UIVisualEffectView *_blurEffectView;

- (void)updateForInterfaceOrientation;

- (void)didChangeStatusBarOrientation:(NSNotification *)notification;

// Used for calling dismiss:YES from selector because you can't pass primitives, thanks objc
- (void)dismiss;

@end


@implementation PopupView

@synthesize backgroundView = _backgroundView;
@synthesize containerView = _containerView;
@synthesize isBeingShown = _isBeingShown;
@synthesize isShowing = _isShowing;
@synthesize isBeingDismissed = _isBeingDismissed;


- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    // stop listening to notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;

        self.shouldDismissOnBackgroundTouch = YES;
        self.shouldDismissOnContentTouch = NO;

        self.showType = PopupViewShowTypeShrinkIn;
        self.dismissType = PopupViewDismissTypeShrinkOut;
        self.maskType = PopupViewMaskTypeDimmed;
        self.dimmedMaskAlpha = 0.5;

        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = NO;

        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;

        _containerView = [[UIView alloc] init];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = [UIColor clearColor];

        [self addSubview:_backgroundView];
        [self addSubview:_containerView];
#if !TARGET_OS_TV
        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
#endif
    }
    return self;
}

#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    if (CGRectContainsPoint(_keyboardRect, point)) {
        return nil;
    }

    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || [NSStringFromClass([hitView class]) isEqualToString:@"_UIVisualEffectContentView"]) {

        // Try to dismiss if backgroundTouch flag set.
        if (_shouldDismissOnBackgroundTouch) {
            [self dismiss:YES];
        }

        // If no mask, then return nil so touch passes through to underlying views.
        if (_maskType == PopupViewMaskTypeNone) {
            return nil;
        } else {
            return hitView;
        }

    } else {

        // If view is within containerView and contentTouch flag set, then try to hide.
        if ([hitView isDescendantOfView:_containerView]) {
            if (_shouldDismissOnContentTouch) {
                [self dismiss:YES];
            }
        }
        return hitView;
    }
}


#pragma mark - Class Public

+ (instancetype)popupViewWithContentView:(UIView *)contentView {
    PopupView *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    return popup;
}


+ (instancetype)popupViewWithContentView:(UIView *)contentView
                                showType:(PopupViewShowType)showType
                             dismissType:(PopupViewDismissType)dismissType
                                maskType:(PopupViewMaskType)maskType
          shouldDismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
             shouldDismissOnContentTouch:(BOOL)shouldDismissOnContentTouch {
    PopupView *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = maskType;
    popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
    popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
    return popup;
}


+ (void)dismissAllPopups {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        [window forEachPopupDoBlock:^(PopupView *popup) {
            [popup dismiss:NO];
        }];
    }
}


#pragma mark - Public

- (void)show {
    [self showWithLayout:PopupViewLayoutCenter];
}


- (void)showWithLayout:(PopupViewLayout)layout {
    [self showWithLayout:layout duration:0.0];
}


- (void)showWithDuration:(NSTimeInterval)duration {
    [self showWithLayout:PopupViewLayoutCenter duration:duration];
}

- (void)showWithLayout:(PopupViewLayout)layout
                inView:(UIView*) view {
    NSDictionary *parameters = @{@"layout" : [NSValue valueWithPopupViewLayout:layout],
                                 @"view": view};
    [self showWithParameters:parameters];
}

- (void)showWithLayout:(PopupViewLayout)layout duration:(NSTimeInterval)duration {
    NSDictionary *parameters = @{@"layout" : [NSValue valueWithPopupViewLayout:layout],
            @"duration" : @(duration)};
    [self showWithParameters:parameters];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView *)view {
    [self showAtCenter:center inView:view withDuration:0.0];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSValue valueWithCGPoint:center] forKey:@"center"];
    [parameters setValue:@(duration) forKey:@"duration"];
    [parameters setValue:view forKey:@"view"];
    [self showWithParameters:[NSDictionary dictionaryWithDictionary:parameters]];
}


- (void)dismiss:(BOOL)animated {

    if (_isShowing && !_isBeingDismissed) {
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = YES;

        // cancel previous dismiss requests (i.e. the dismiss after duration call).
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];

        [self willStartDismissing];

        if (self.willStartDismissingCompletion != nil) {
            self.willStartDismissingCompletion();
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            // Animate background if needed
            void (^backgroundAnimationBlock)(void) = ^(void) {
                _backgroundView.alpha = 0.0;
            };

            if (animated && (_showType != PopupViewShowTypeNone)) {
                // Make fade happen faster than motion. Use linear for fades.
                [UIView animateWithDuration:0.15
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }

            // Setup completion block
            void (^completionBlock)(BOOL) = ^(BOOL finished) {

                [self removeFromSuperview];

                _isBeingShown = NO;
                _isShowing = NO;
                _isBeingDismissed = NO;

                [self didFinishDismissing];

                if (self.didFinishDismissingCompletion != nil) {
                    self.didFinishDismissingCompletion();
                }
            };

            NSTimeInterval bounce1Duration = 0.13;
            NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);

            // Animate content if needed
            if (animated) {
                switch (_dismissType) {
                    case PopupViewDismissTypeFadeOut: {
                        [UIView animateWithDuration:0.15
                                              delay:0
                                            options:UIViewAnimationOptionCurveLinear
                                         animations:^{
                                             _containerView.alpha = 0.0;
                                         } completion:completionBlock];
                        break;
                    }

                    case PopupViewDismissTypeGrowOut: {
                        [UIView animateWithDuration:0.15
                                              delay:0
                                            options:(UIViewAnimationOptions) kAnimationOptionCurveIOS7
                                         animations:^{
                                             _containerView.alpha = 0.0;
                                             _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                         } completion:completionBlock];
                        break;
                    }

                    case PopupViewDismissTypeShrinkOut: {
                        [UIView animateWithDuration:0.15
                                              delay:0
                                            options:(UIViewAnimationOptions) kAnimationOptionCurveIOS7
                                         animations:^{
                                             _containerView.alpha = 0.0;
                                             _containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                         } completion:completionBlock];
                        break;
                    }

                    case PopupViewDismissTypeSlideOutToTop: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:(UIViewAnimationOptions) kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        break;
                    }

                    case PopupViewDismissTypeSlideOutToBottom: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:(UIViewAnimationOptions) kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        break;
                    }

                    case PopupViewDismissTypeSlideOutToLeft: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:(UIViewAnimationOptions) kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];
                        break;
                    }

                    case PopupViewDismissTypeSlideOutToRight: {
                        [UIView animateWithDuration:0.30
                                              delay:0
                                            options:(UIViewAnimationOptions) kAnimationOptionCurveIOS7
                                         animations:^{
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:completionBlock];

                        break;
                    }

                    case PopupViewDismissTypeBounceOut: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void) {
                                             _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                         }
                                         completion:^(BOOL finished) {

                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void) {
                                                                  _containerView.alpha = 0.0;
                                                                  _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                              }
                                                              completion:completionBlock];
                                         }];

                        break;
                    }

                    case PopupViewDismissTypeBounceOutToTop: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void) {
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y += 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished) {

                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void) {
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];

                        break;
                    }

                    case PopupViewDismissTypeBounceOutToBottom: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void) {
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.y -= 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished) {

                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void) {
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];

                        break;
                    }

                    case PopupViewDismissTypeBounceOutToLeft: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void) {
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x += 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished) {

                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void) {
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];
                        break;
                    }

                    case PopupViewDismissTypeBounceOutToRight: {
                        [UIView animateWithDuration:bounce1Duration
                                              delay:0
                                            options:UIViewAnimationOptionCurveEaseOut
                                         animations:^(void) {
                                             CGRect finalFrame = _containerView.frame;
                                             finalFrame.origin.x -= 40.0;
                                             _containerView.frame = finalFrame;
                                         }
                                         completion:^(BOOL finished) {

                                             [UIView animateWithDuration:bounce2Duration
                                                                   delay:0
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^(void) {
                                                                  CGRect finalFrame = _containerView.frame;
                                                                  finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                                                  _containerView.frame = finalFrame;
                                                              }
                                                              completion:completionBlock];
                                         }];
                        break;
                    }

                    default: {
                        self.containerView.alpha = 0.0;
                        completionBlock(YES);
                        break;
                    }
                }
            } else {
                self.containerView.alpha = 0.0;
                completionBlock(YES);
            }

        });
    }
}


#pragma mark - Private

- (void)showWithParameters:(NSDictionary *)parameters {

    // If popup can be shown
    if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
        _isBeingShown = YES;
        _isShowing = NO;
        _isBeingDismissed = NO;

        [self willStartShowing];

        dispatch_async(dispatch_get_main_queue(), ^{

            // Prepare by adding to the top window.
            UIView *destView;
            if (!self.superview) {
                destView = [parameters valueForKey:@"view"];
                if (destView == nil) {
                    // Prepare by adding to the top window.
                    NSEnumerator *frontToBackWindows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];

                    for (UIWindow *window in frontToBackWindows)
                        if (window.windowLevel == UIWindowLevelNormal) {
                            destView = window;
                            break;
                        }
                }
                [destView addSubview:self];
                [destView bringSubviewToFront:self];
            }

            // Before we calculate layout for containerView, make sure we are transformed for current orientation.
            [self updateForInterfaceOrientation];

            // Make sure we're not hidden
            self.hidden = NO;
            self.alpha = 1.0;

            // Setup background view
            _backgroundView.alpha = 0.0;
            _backgroundView.alpha = 0.0;
            void (^backgroundAnimationBlock)(void) = ^(void) {
                _backgroundView.alpha = 1.0;
            };

            switch (_maskType) {
                case PopupViewMaskTypeDimmed: {
                    _backgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat) (0.0 / 255.0f) green:(CGFloat) (0.0 / 255.0f) blue:(CGFloat) (0.0 / 255.0f) alpha:self.dimmedMaskAlpha];
                    backgroundAnimationBlock();

                }
                    break;
                case PopupViewMaskTypeNone: {
                    [UIView animateWithDuration:0.15
                                          delay:0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:backgroundAnimationBlock
                                     completion:NULL];

                }
                    break;
                case PopupViewMaskTypeClear: {
                    _backgroundView.backgroundColor = [UIColor clearColor];
                }
                    break;
                case PopupViewMaskTypeLightBlur: {
                    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                    UIVisualEffectView *visualBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                    visualBlur.frame = _backgroundView.frame;
                    [visualBlur.contentView addSubview:_backgroundView];
                    [self insertSubview:visualBlur belowSubview:_containerView];
                    //_backgroundView = visualBlur;
                    //[self addSubview:visualBlur];
                }
                    break;
                case PopupViewMaskTypeDarkBlur: {
                    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                    UIVisualEffectView *visualBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                    visualBlur.frame = _backgroundView.frame;
                    [visualBlur.contentView addSubview:_backgroundView];
                    [self insertSubview:visualBlur belowSubview:_containerView];
                    //_backgroundView = visualBlur;
                    //[self addSubview:visualBlur];
                }
                    break;

                default:
                    backgroundAnimationBlock();
                    break;
            }

            // Determine duration. Default to 0 if none provided.
            NSTimeInterval duration;
            NSNumber *durationNumber = [parameters valueForKey:@"duration"];
            if (durationNumber != nil) {
                duration = durationNumber.doubleValue;
            } else {
                duration = 0.0;
            }

            // Setup completion block
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                _isBeingShown = NO;
                _isShowing = YES;
                _isBeingDismissed = NO;

                [self didFinishShowing];

                if (self.didFinishShowingCompletion != nil) {
                    self.didFinishShowingCompletion();
                }

                // Set to hide after duration if greater than zero.
                if (duration > 0.0) {
                    [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
                }
            };

            // Add contentView to container
            if (self.contentView.superview != _containerView) {
                [_containerView addSubview:self.contentView];
            }

            // Re-layout (this is needed if the contentView is using autoLayout)
            [self.contentView layoutIfNeeded];

            // Size container to match contentView
            CGRect containerFrame = _containerView.frame;
            containerFrame.size = self.contentView.frame.size;
            _containerView.frame = containerFrame;
            // Position contentView to fill it
            CGRect contentViewFrame = self.contentView.frame;
            contentViewFrame.origin = CGPointZero;
            self.contentView.frame = contentViewFrame;

            // Reset _containerView's constraints in case contentView is uaing autolayout.
            UIView *contentView = _contentView;
            NSDictionary *views = NSDictionaryOfVariableBindings(contentView);

            [_containerView removeConstraints:_containerView.constraints];
            [_containerView addConstraints:
                    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                            options:0
                                                            metrics:nil
                                                              views:views]];

            [_containerView addConstraints:
                    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                            options:0
                                                            metrics:nil
                                                              views:views]];

            // Determine final position and necessary autoresizingMask for container.
            CGRect finalContainerFrame = containerFrame;
            UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;

            // Use explicit center coordinates if provided.
            NSValue *centerValue = [parameters valueForKey:@"center"];
            if (centerValue != nil) {

                CGPoint centerInView = [centerValue CGPointValue];
                CGPoint centerInSelf;

                if (destView != nil) {
                    centerInSelf = [self convertPoint:centerInView fromView:destView];
                } else {
                    centerInSelf = centerInView;
                }

                finalContainerFrame.origin.x = (CGFloat) (centerInSelf.x - CGRectGetWidth(finalContainerFrame) / 2.0);
                finalContainerFrame.origin.y = (CGFloat) (centerInSelf.y - CGRectGetHeight(finalContainerFrame) / 2.0);
                containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            }

                // Otherwise use relative layout. Default to center if none provided.
            else {

                NSValue *layoutValue = [parameters valueForKey:@"layout"];
                PopupViewLayout layout;
                if (layoutValue != nil) {
                    layout = [layoutValue PopupViewLayoutValue];
                } else {
                    layout = PopupViewLayoutCenter;
                }

                switch (layout.horizontal) {

                    case PopupViewHorizontalLayoutLeft: {
                        finalContainerFrame.origin.x = 0.0;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    }

                    case PopupViewHorizontalLayoutLeftOfCenter: {
                        finalContainerFrame.origin.x = floorf((float) (CGRectGetWidth(self.bounds) / 3.0 - CGRectGetWidth(containerFrame) / 2.0));
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    }

                    case PopupViewHorizontalLayoutCenter: {
                        finalContainerFrame.origin.x = floorf((float) ((CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame)) / 2.0));
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    }

                    case PopupViewHorizontalLayoutRightOfCenter: {
                        finalContainerFrame.origin.x = floorf((float) (CGRectGetWidth(self.bounds) * 2.0 / 3.0 - CGRectGetWidth(containerFrame) / 2.0));
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    }

                    case PopupViewHorizontalLayoutRight: {
                        finalContainerFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
                        break;
                    }

                    default:
                        break;
                }

                // Vertical
                switch (layout.vertical) {

                    case PopupViewVerticalLayoutTop: {
                        finalContainerFrame.origin.y = 0;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    }

                    case PopupViewVerticalLayoutAboveCenter: {
                        finalContainerFrame.origin.y = floorf((float) CGRectGetHeight(self.bounds) / 3.0 - CGRectGetHeight(containerFrame) / 2.0);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    }

                    case PopupViewVerticalLayoutCenter: {
                        finalContainerFrame.origin.y = floorf((float) (CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame)) / 2.0);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    }

                    case PopupViewVerticalLayoutBelowCenter: {
                        finalContainerFrame.origin.y = floorf((float) CGRectGetHeight(self.bounds) * 2.0 / 3.0 - CGRectGetHeight(containerFrame) / 2.0);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    }

                    case PopupViewVerticalLayoutBottom: {
                        finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
                        break;
                    }

                    default:
                        break;
                }
            }

            _containerView.autoresizingMask = containerAutoresizingMask;

            // Animate content if needed
            switch (_showType) {
                case PopupViewShowTypeFadeIn: {

                    _containerView.alpha = 0.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.15
                                          delay:0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         _containerView.alpha = 1.0;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeGrowIn: {

                    _containerView.alpha = 0.0;
                    // set frame before transform here...
                    CGRect startFrame = finalContainerFrame;
                    _containerView.frame = startFrame;
                    _containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);

                    [UIView animateWithDuration:0.15
                                          delay:0
                                        options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                     animations:^{
                                         _containerView.alpha = 1.0;
                                         // set transform before frame here...
                                         _containerView.transform = CGAffineTransformIdentity;
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];

                    break;
                }

                case PopupViewShowTypeShrinkIn: {
                    _containerView.alpha = 0.0;
                    // set frame before transform here...
                    CGRect startFrame = finalContainerFrame;
                    _containerView.frame = startFrame;
                    _containerView.transform = CGAffineTransformMakeScale(1.25, 1.25);

                    [UIView animateWithDuration:0.15
                                          delay:0
                                        options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                     animations:^{
                                         _containerView.alpha = 1.0;
                                         // set transform before frame here...
                                         _containerView.transform = CGAffineTransformIdentity;
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeSlideInFromTop: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.30
                                          delay:0
                                        options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeSlideInFromBottom: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.30
                                          delay:0
                                        options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeSlideInFromLeft: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.30
                                          delay:0
                                        options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeSlideInFromRight: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.30
                                          delay:0
                                        options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];

                    break;
                }

                case PopupViewShowTypeBounceIn: {
                    _containerView.alpha = 0.0;
                    // set frame before transform here...
                    CGRect startFrame = finalContainerFrame;
                    _containerView.frame = startFrame;
                    _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);

                    [UIView animateWithDuration:0.6
                                          delay:0.0
                         usingSpringWithDamping:0.8
                          initialSpringVelocity:15.0
                                        options:0
                                     animations:^{
                                         _containerView.alpha = 1.0;
                                         _containerView.transform = CGAffineTransformIdentity;
                                     }
                                     completion:completionBlock];

                    break;
                }

                case PopupViewShowTypeBounceInFromTop: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.6
                                          delay:0.0
                         usingSpringWithDamping:0.8
                          initialSpringVelocity:10.0
                                        options:0
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeBounceInFromBottom: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.6
                                          delay:0.0
                         usingSpringWithDamping:0.8
                          initialSpringVelocity:10.0
                                        options:0
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeBounceInFromLeft: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.6
                                          delay:0.0
                         usingSpringWithDamping:0.8
                          initialSpringVelocity:10.0
                                        options:0
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                case PopupViewShowTypeBounceInFromRight: {
                    _containerView.alpha = 1.0;
                    _containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    _containerView.frame = startFrame;

                    [UIView animateWithDuration:0.6
                                          delay:0.0
                         usingSpringWithDamping:0.8
                          initialSpringVelocity:10.0
                                        options:0
                                     animations:^{
                                         _containerView.frame = finalContainerFrame;
                                     }
                                     completion:completionBlock];
                    break;
                }

                default: {
                    self.containerView.alpha = 1.0;
                    self.containerView.transform = CGAffineTransformIdentity;
                    self.containerView.frame = finalContainerFrame;

                    completionBlock(YES);

                    break;
                }
            }

        });
    }
}


- (void)dismiss {
    [self dismiss:YES];
}


- (void)updateForInterfaceOrientation {
#if !TARGET_OS_TV
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle;

    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        angle = M_PI;
        break;
        case UIInterfaceOrientationLandscapeLeft:
        angle = -M_PI / 2.0f;;

        break;
        case UIInterfaceOrientationLandscapeRight:
        angle = M_PI / 2.0f;

        break;
        default: // as UIInterfaceOrientationPortrait
        angle = 0.0;
        break;
    }

    self.transform = CGAffineTransformMakeRotation(angle);
    self.frame = self.window.bounds;
#endif
}


#pragma mark - Notification handlers

- (void)didChangeStatusBarOrientation:(NSNotification *)notification {
    [self updateForInterfaceOrientation];
}

#if !TARGET_OS_TV
- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardRect;
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    _keyboardRect = [self convertRect:keyboardRect fromView:nil];

}

- (void)keyboardDidHide:(NSNotification *)notification {
    _keyboardRect = CGRectZero;
}
#endif

#pragma mark - Subclassing

- (void)willStartShowing {
#if !TARGET_OS_TV
    if (_shouldHandleKeyboard) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
#endif
}


- (void)didFinishShowing {

}


- (void)willStartDismissing {

}


- (void)didFinishDismissing {
#if !TARGET_OS_TV
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
#endif
}

#pragma mark - Keyboard notification handlers

#if !TARGET_OS_TV
- (void)keyboardWillShowNotification:(NSNotification *)notification {
    [self moveContainerViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    [self moveContainerViewForKeyboard:notification up:NO];
}

- (void)moveContainerViewForKeyboard:(NSNotification *)notification up:(BOOL)up {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = (UIViewAnimationCurve) [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    _containerView.center = CGPointMake(_containerView.superview.frame.size.width / 2, _containerView.superview.frame.size.height / 2);
    CGRect frame = _containerView.frame;
    if (up) {
        frame.origin.y -= keyboardEndFrame.size.height / 2;
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    _containerView.frame = frame;
    [UIView commitAnimations];
}
#endif
@end

#pragma mark - Categories

@implementation UIView (PopupView)


- (void)forEachPopupDoBlock:(void (^)(PopupView *popup))block {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[PopupView class]]) {
            block((PopupView *) subview);
        } else {
            [subview forEachPopupDoBlock:block];
        }
    }
}


- (void)dismissPresentingPopup {

    // Iterate over superviews until you find a PopupView and dismiss it, then gtfo
    UIView *view = self;
    while (view != nil) {
        if ([view isKindOfClass:[PopupView class]]) {
            [(PopupView *) view dismiss:YES];
            break;
        }
        view = view.superview;
    }
}

@end


@implementation NSValue (PopupViewLayout)

+ (NSValue *)valueWithPopupViewLayout:(PopupViewLayout)layout {
    return [NSValue valueWithBytes:&layout objCType:@encode(PopupViewLayout)];
}

- (PopupViewLayout)PopupViewLayoutValue {
    PopupViewLayout layout;

    [self getValue:&layout];

    return layout;
}

@end
