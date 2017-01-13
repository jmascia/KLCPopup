PopupKit
========

PopupKit is a simple and flexible iOS framework for presenting any custom view as a popup. It includes a variety of options for controlling how your popup appears and behaves.

<p align="center"><img src="http://i.imgur.com/BEmRGb5.gif"/></p>

##Installation

###CocoaPods
You can install PopupKit easily with Cocoapods

```
pod 'PopupKit'
```

###CocoaPods
You can install PopupKit easily with Carthage too

```
github 'rynecheow/PopupKit'
```

##Usage

To import the framework you can either:

####In Swift,

```
import PopupKit
```

####In Objective-C,

```
@import PopupKit;
```

or

```
#import <PopupKit/PopupView.h>
```

### Creating a Popup

Create a popup for displaying a UIView using default animations and behaviors (similar to a UIAlertView):
```objc
+ (instancetype)popupWithContentView:(UIView*)contentView;
```

or similarly in Swift:
```swift
convenience init(contentView: UIView)
```

Or create a popup with custom animations and behaviors. Customizations can also be accessed via properties on the popup instance:
```objc
+ (instancetype)popupViewWithContentView:(UIView *)contentView
                                showType:(PopupViewShowType)showType
                             dismissType:(PopupViewDismissType)dismissType
                                maskType:(PopupViewMaskType)maskType
          shouldDismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
             shouldDismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;
```

or similarly in Swift:
```swift
convenience init(contentView: UIView, showType: PopupView.ShowType, dismissType: PopupView.DismissType, maskType: PopupView.MaskType, shouldDismissOnBackgroundTouch: Bool, shouldDismissOnContentTouch: Bool)
```

Also **you must give your `contentView` a size** before showing it (by setting its frame), or **it must size itself with AutoLayout**.


### Showing a Popup


Show popup in middle of screen.
```objc
- (void)show;
```

or similarly in Swift:
```swift
func show()
```

There are two ways to control where your popup is displayed:

1. Relative layout presets (see `PopupView.h` for options).

```objc
- (void)showWithLayout:(PopupViewLayout)layout;
```

or similarly in Swift:
```swift
func show(with layout: PopupView.Layout)
```

2. Explicit center point relative to a view's coordinate system.
```objc
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view;
```

or similarly in Swift:
```swift
func show(at center: CGPoint, in view: UIView)
```


If you want your popup to dismiss automatically (like a toast in Android) you can set an explicit `duration`:
```objc
- (void)showWithDuration:(NSTimeInterval)duration;
```
or similarly in Swift:
```swift
func show(with duration: TimeInterval)
```

### Dismissing a Popup

There are a few ways to dismiss a popup:

If you have a reference to the popup instance, you can send this message to it. If `animated`, then it will use the animation specified in `dismissType`. Otherwise it will just disappear:
```objc
- (void)dismiss:(BOOL)animated;
```

or similarly in Swift:
```swift
func dismiss(animated: Bool)
```

If you lost your reference to a popup or you want to make sure no popups are showing, this class method dismisses any and all popups in your app:

```objc
+ (void)dismissAllPopups;
```

or similarly in Swift:
```swift
class func dismissAllPopups()
```

Also you can call this category method from `UIView(PopupView)` on your contentView, or any of its subviews, to dismiss its parent popup:
```objc
- (void)dismissPresentingPopup; // UIView category
```

or similarly in Swift:
```swift
func dismissPresentingPopup()
```

### Customization


Animation used to show your popup:
```objc
@property (nonatomic, assign) PopupViewShowType showType;
```

Animation used to dismiss your popup:
```objc
@property (nonatomic, assign) PopupViewDismissType dismissType;
```

Mask prevents touches to the background from passing through to views below:
```objc
@property (nonatomic, assign) PopupViewMaskType maskType;
```

Popup will automatically dismiss if the background is touched:
```objc
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;
```

Popup will automatically dismiss if the contentView is touched:
```objc
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;
```

Override alpha value for dimmed background mask:
```objc
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;
```

### Blocks

Use these blocks to synchronize other actions with popup events:
```objc
@property (nonatomic, copy) void (^didFinishShowingCompletion)();

@property (nonatomic, copy) void (^willStartDismissingCompletion)();

@property (nonatomic, copy) void (^didFinishDismissingCompletion)();
```

### Example
```objc
UIView* contentView = [[UIView alloc] init];
contentView.backgroundColor = [UIColor orangeColor];
contentView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);

PopupView* popup = [PopupView popupWithContentView:contentView];
[popup show];
```

## Notes

* Xcode 8.0 / Swift 3.0
* iOS >= 9.0 (Use as an **Embedded** Framework)
* tvOS >= 9.0

### TODO
- Add support for drag-to-dismiss.

##Credits
KLCPopup was created by Jeff Mascia and the team at Kullect, where it's used in the [Shout Photo Messenger](http://tryshout.com) app. Aspects of KLCPopup were inspired by Sam Vermette's [SVProgressHUD](https://github.com/samvermette/SVProgressHUD). PopupKit is a modernised version of
KLCPopup ported by Ryne Cheow.
