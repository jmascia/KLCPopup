// KLCPopup.m
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


#import "KLCPopup.h"

static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);


@interface KLCPopup () {
  // views
  UIView* _backgroundView;
  UIView* _containerView;
  
  // state flags
  BOOL _isBeingShown;
  BOOL _isShowing;
  BOOL _isBeingHidden;
}

- (void)updateForInterfaceOrientation;
- (void)didChangeStatusBarOrientation:(NSNotification*)notification;

// Used for calling hide:YES from selector because you can't pass primitives, thanks objc
- (void)hide;

@end


@implementation KLCPopup

@synthesize backgroundView = _backgroundView;
@synthesize containerView = _containerView;
@synthesize isBeingShown = _isBeingShown;
@synthesize isShowing = _isShowing;
@synthesize isBeingHidden = _isBeingHidden;


- (void)dealloc {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];

  // stop listening to notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init {
  return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}


- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = YES;
    
    self.shouldHideOnBackgroundTouch = YES;
    self.shouldHideOnContentTouch = NO;
    
    self.showType = KLCPopupShowTypeShrinkIn;
    self.hideType = KLCPopupHideTypeShrinkOut;
    self.maskType = KLCPopupMaskTypeDimmed;
    self.horizontalLayout = KLCPopupHorizontalLayoutCenter;
    self.verticalLayout = KLCPopupVerticalLayoutCenter;
    
    _isBeingShown = NO;
    _isShowing = NO;
    _isBeingHidden = NO;
    
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
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
  }
  return self;
}


#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  
  UIView* hitView = [super hitTest:point withEvent:event];
  if (hitView == self) {
    
    // Try to hide if backgroundTouch flag set.
    if (_shouldHideOnBackgroundTouch) {
      [self hide:YES];
    }
    
    // If no mask, then return nil so touch passes through to underlying views.
    if (_maskType == KLCPopupMaskTypeNone) {
      return nil;
    } else {
      return hitView;
    }
    
  } else {
    
    // If view is within containerView and contentTouch flag set, then try to hide.
    if ([hitView isDescendantOfView:_containerView]) {
      if (_shouldHideOnContentTouch) {
        [self hide:YES];
      }
    }
    return hitView;
  }
}


#pragma mark - Class Public

+ (KLCPopup*)popupWithContentView:(UIView*)contentView
{
  KLCPopup* popup = [[[self class] alloc] init];
  popup.contentView = contentView;
  return popup;
}


+ (KLCPopup*)popupWithContentView:(UIView*)contentView
                 horizontalLayout:(KLCPopupHorizontalLayout)horizontalLayout
                   verticalLayout:(KLCPopupVerticalLayout)verticalLayout
                         showType:(KLCPopupShowType)showType
                         hideType:(KLCPopupHideType)hideType
                         maskType:(KLCPopupMaskType)maskType
            hideOnBackgroundTouch:(BOOL)shouldHideOnBackgroundTouch
               hideOnContentTouch:(BOOL)shouldHideOnContentTouch
{
  KLCPopup* popup = [[[self class] alloc] init];
  popup.contentView = contentView;
  popup.horizontalLayout = horizontalLayout;
  popup.verticalLayout = verticalLayout;
  popup.showType = showType;
  popup.hideType = hideType;
  popup.maskType = maskType;
  popup.shouldHideOnBackgroundTouch = shouldHideOnBackgroundTouch;
  popup.shouldHideOnContentTouch = shouldHideOnContentTouch;
  return popup;
}


+ (void)hideAllPopups {
  NSArray* windows = [[UIApplication sharedApplication] windows];
  for (UIWindow* window in windows) {
    [window forEachPopupDoBlock:^(KLCPopup *popup) {
      [popup hide:NO];
    }];
  }
}


#pragma mark - Public

- (void)show {
  [self showWithDuration:0.0];
}


- (void)showWithDuration:(NSTimeInterval)duration {
  
  // If popup can be shown
  if (!_isBeingShown && !_isShowing && !_isBeingHidden) {
    _isBeingShown = YES;
    _isShowing = NO;
    _isBeingHidden = NO;
    
    [self willStartShowing];
    
    dispatch_async( dispatch_get_main_queue(), ^{
      
      // Prepare by adding to the top window.
      if(!self.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
          if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self];
            
            break;
          }
        }
      }
      
      // Before we calculate layout for containerView, make sure we are transformed for current orientation.
      [self updateForInterfaceOrientation];
      
      // Make sure we're not hidden
      self.hidden = NO;
      self.alpha = 1.0;
      
      // Setup background view
      _backgroundView.alpha = 0.0;
      if (_maskType == KLCPopupMaskTypeDimmed) {
        _backgroundView.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:0.5];
      } else {
        _backgroundView.backgroundColor = [UIColor clearColor];
      }
      
      // Animate background if needed
      void (^backgroundAnimationBlock)(void) = ^(void) {
        _backgroundView.alpha = 1.0;
      };
      
      if (_showType != KLCPopupShowTypeNone) {
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
        _isBeingShown = NO;
        _isShowing = YES;
        _isBeingHidden = NO;
        
        [self didFinishShowing];
        
        if (self.didFinishShowingCompletion != nil) {
          self.didFinishShowingCompletion();
        }
        
        // Set to hide after duration if greater than zero.
        if (duration > 0.0) {
          [self performSelector:@selector(hide) withObject:nil afterDelay:duration];
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
      
      
      // Determine final position and necessary autoresizingMask for container based on horizontal and vertical layouts.
      CGRect finalContainerFrame = containerFrame;
      UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
      switch (_horizontalLayout) {
          
        case KLCPopupHorizontalLayoutLeft: {
          finalContainerFrame.origin.x = 0.0;
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
          break;
        }
          
        case KLCPopupHorizontalLayoutLeftOfCenter: {
          finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)/3.0 - CGRectGetWidth(containerFrame)/2.0);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
          break;
        }
          
        case KLCPopupHorizontalLayoutCenter: {
          finalContainerFrame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame))/2.0);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
          break;
        }
          
        case KLCPopupHorizontalLayoutRightOfCenter: {
          finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)*2.0/3.0 - CGRectGetWidth(containerFrame)/2.0);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
          break;
        }
          
        case KLCPopupHorizontalLayoutRight: {
          finalContainerFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
          break;
        }
          
        default:
          break;
      }
      
      // Vertical
      switch (_verticalLayout) {
          
        case KLCPopupVerticalLayoutTop: {
          finalContainerFrame.origin.y = 0;
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
          break;
        }

        case KLCPopupVerticalLayoutAboveCenter: {
          finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)/3.0 - CGRectGetHeight(containerFrame)/2.0);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
          break;
        }
          
        case KLCPopupVerticalLayoutCenter: {
          finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame))/2.0);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
          break;
        }
          
        case KLCPopupVerticalLayoutBelowCenter: {
          finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)*2.0/3.0 - CGRectGetHeight(containerFrame)/2.0);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
          break;
        }
          
        case KLCPopupVerticalLayoutBottom: {
          finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
          containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
          break;
        }

        default:
          break;
      }
      _containerView.autoresizingMask = containerAutoresizingMask;
      
      
      // Animate content if needed
      switch (_showType) {
        case KLCPopupShowTypeFadeIn: {
          
          _containerView.alpha = 0.0;
          _containerView.transform = CGAffineTransformIdentity;
          _containerView.frame = finalContainerFrame;
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:UIViewAnimationOptionCurveLinear
                           animations:^{
                             _containerView.alpha = 1.0;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeGrowIn: {
          
          _containerView.alpha = 0.0;
          // set frame before transform here...
          _containerView.frame = finalContainerFrame;
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
          
        case KLCPopupShowTypeShrinkIn: {
          _containerView.alpha = 0.0;
          // set frame before transform here...
          _containerView.frame = finalContainerFrame;
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
          
        case KLCPopupShowTypeSlideInFromTop: {
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
          
        case KLCPopupShowTypeSlideInFromBottom: {
          _containerView.alpha = 1.0;
          _containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = CGRectGetHeight(self.frame);
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
        
        case KLCPopupShowTypeSlideInFromLeft: {
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
          
        case KLCPopupShowTypeSlideInFromRight: {
          _containerView.alpha = 1.0;
          _containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = CGRectGetWidth(self.frame);
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
          
        case KLCPopupShowTypeBounceIn: {
          _containerView.alpha = 0.0;
          // set frame before transform here...
          _containerView.frame = finalContainerFrame;
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
          
        case KLCPopupShowTypeBounceInFromTop: {
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
          
        case KLCPopupShowTypeBounceInFromBottom: {
          _containerView.alpha = 1.0;
          _containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = CGRectGetHeight(self.frame);
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
          
        case KLCPopupShowTypeBounceInFromLeft: {
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
          
        case KLCPopupShowTypeBounceInFromRight: {
          _containerView.alpha = 1.0;
          _containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = CGRectGetWidth(self.frame);
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


- (void)hide:(BOOL)animated {
  
  if (_isShowing && !_isBeingHidden) {
    _isBeingShown = NO;
    _isShowing = NO;
    _isBeingHidden = YES;
    
    // cancel previous hide requests (i.e. the hide after duration call).
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    [self willStartHiding];
    
    if (self.willStartHidingCompletion != nil) {
      self.willStartHidingCompletion();
    }
    
    dispatch_async( dispatch_get_main_queue(), ^{

      // Animate background if needed
      void (^backgroundAnimationBlock)(void) = ^(void) {
        _backgroundView.alpha = 0.0;
      };
      
      if (animated && (_showType != KLCPopupShowTypeNone)) {
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
        _isBeingHidden = NO;
        
        [self didFinishHiding];
        
        if (self.didFinishHidingCompletion != nil) {
          self.didFinishHidingCompletion();
        }
      };
      
      NSTimeInterval bounce1Duration = 0.13;
      NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
      
      // Animate content if needed
      if (animated) {
        switch (_hideType) {
          case KLCPopupHideTypeFadeOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                               _containerView.alpha = 0.0;
                             } completion:completionBlock];
            break;
          }
            
          case KLCPopupHideTypeGrowOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               _containerView.alpha = 0.0;
                               _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             } completion:completionBlock];
            break;
          }
            
          case KLCPopupHideTypeShrinkOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               _containerView.alpha = 0.0;
                               _containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                             } completion:completionBlock];
            break;
          }
            
          case KLCPopupHideTypeSlideOutToTop: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                               _containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case KLCPopupHideTypeSlideOutToBottom: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.y = CGRectGetHeight(self.frame);
                               _containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case KLCPopupHideTypeSlideOutToLeft: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                               _containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case KLCPopupHideTypeSlideOutToRight: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.x = CGRectGetWidth(self.frame);
                               _containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            
            break;
          }
            
          case KLCPopupHideTypeBounceOut: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  _containerView.alpha = 0.0;
                                                  _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case KLCPopupHideTypeBounceOutToTop: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.y += 40.0;
                               _containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = _containerView.frame;
                                                  finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                                  _containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case KLCPopupHideTypeBounceOutToBottom: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.y -= 40.0;
                               _containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = _containerView.frame;
                                                  finalFrame.origin.y = CGRectGetHeight(self.frame);
                                                  _containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case KLCPopupHideTypeBounceOutToLeft: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.x += 40.0;
                               _containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = _containerView.frame;
                                                  finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                                  _containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            break;
          }
            
          case KLCPopupHideTypeBounceOutToRight: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = _containerView.frame;
                               finalFrame.origin.x -= 40.0;
                               _containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = _containerView.frame;
                                                  finalFrame.origin.x = CGRectGetWidth(self.frame);
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

- (void)hide {
  [self hide:YES];
}

- (void)updateForInterfaceOrientation {
  
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  CGFloat angle;
  
  switch (orientation) {
    case UIInterfaceOrientationPortraitUpsideDown:
      angle = M_PI;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      angle = -M_PI/2.0f;;
      
      break;
    case UIInterfaceOrientationLandscapeRight:
      angle = M_PI/2.0f;
      
      break;
    default: // as UIInterfaceOrientationPortrait
      angle = 0.0;
      break;
  }
  
  self.transform = CGAffineTransformMakeRotation(angle);
  self.frame = self.window.bounds;
}


#pragma mark - Notification handlers

- (void)didChangeStatusBarOrientation:(NSNotification*)notification {
  [self updateForInterfaceOrientation];
}


#pragma mark - Subclassing

- (void)willStartShowing {
  
}


- (void)didFinishShowing {
  
}


- (void)willStartHiding {
  
}


- (void)didFinishHiding {
  
}

@end




#pragma mark - Categories

@implementation UIView(KLCPopup)


- (void)forEachPopupDoBlock:(void (^)(KLCPopup* popup))block {
  for (UIView *subview in self.subviews)
  {
    if ([subview isKindOfClass:[KLCPopup class]])
    {
      block((KLCPopup *)subview);
    } else {
      [subview forEachPopupDoBlock:block];
    }
  }
}


- (void)hidePresentingPopup {
  
  // Iterate over superviews until you find a KLCPopup and hide it, then gtfo
  UIView* view = self;
  while (view != nil) {
    if ([view isKindOfClass:[KLCPopup class]]) {
      [(KLCPopup*)view hide:YES];
      break;
    }
    view = [view superview];
  }
}


@end
