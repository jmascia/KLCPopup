KLCPopup
========

KLCPopup is a simple and flexible iOS class for presenting any custom view as a popup. It includes a variety of options for controlling how your popup appears and behaves.

<p align="center"><img src="http://i.imgur.com/BEmRGb5.gif"/></p>

##Installation

- Drag the `KLCPopup/KLCPopup` folder into your project.
- `#import "KLCPopup.h"` where appropriate. 

##Usage

(see sample Xcode project in `/KLCPopupExample`)

### Creating a Popup

Create a popup for displaying a UIView using default animations and behaviors (similar to a UIAlertView):

	+ (KLCPopup*)popupWithContentView:(UIView*)contentView;
	
Or create a popup with custom animations and behaviors. Customizations can also be accessed via properties on the popup instance:

	+ (KLCPopup*)popupWithContentView:(UIView*)contentView
							 showType:(KLCPopupShowType)showType
						  dismissType:(KLCPopupDismissType)dismissType
							 maskType:(KLCPopupMaskType)maskType
			 dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
				dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

Note: You may pass `nil` for `contentView` when creating the popup, but **you must assign a `contentView` to the popup before showing it!**

Also **you must give your `contentView` a size** before showing it (by setting its frame), or **it must size itself with AutoLayout**.

					
### Showing a Popup
	

Show popup in middle of screen.
	
	- (void)show;
	
There are two ways to control where your popup is displayed:

1. Relative layout presets (see `KLCPopup.h` for options).

		- (void)showWithLayout:(KLCPopupLayout)layout;
		

2. Explicit center point relative to a view's coordinate system.

		- (void)showAtCenter:(CGPoint)center inView:(UIView*)view;

If you want your popup to dismiss automatically (like a toast in Android) you can set an explicit `duration`:
	
	- (void)showWithDuration:(NSTimeInterval)duration;

### Dismissing a Popup
		
There are a few ways to dismiss a popup:

If you have a reference to the popup instance, you can send this message to it. If `animated`, then it will use the animation specified in `dismissType`. Otherwise it will just disappear: 

	- (void)dismiss:(BOOL)animated;

If you lost your reference to a popup or you want to make sure no popups are showing, this class method dismisses any and all popups in your app:

	+ (void)dismissAllPopups;

Also you can call this category method from `UIView(KLCPopup)` on your contentView, or any of its subviews, to dismiss its parent popup:
	
	- (void)dismissPresentingPopup; // UIView category

### Customization


Animation used to show your popup:

	@property (nonatomic, assign) KLCPopupShowType showType;
	
Animation used to dismiss your popup:

	@property (nonatomic, assign) KLCPopupDismissType dismissType;
	
Mask prevents touches to the background from passing through to views below:
	
	@property (nonatomic, assign) KLCPopupMaskType maskType;

Popup will automatically dismiss if the background is touched:
	
	@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;
	
Popup will automatically dismiss if the contentView is touched:

	@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;
	
Override alpha value for dimmed background mask:

	@property (nonatomic, assign) CGFloat dimmedMaskAlpha;	


### Blocks

Use these blocks to synchronize other actions with popup events:

	@property (nonatomic, copy) void (^didFinishShowingCompletion)();

	@property (nonatomic, copy) void (^willStartDismissingCompletion)();

	@property (nonatomic, copy) void (^didFinishDismissingCompletion)();


### Example

	UIView* contentView = [[UIView alloc] init];
	contentView.backgroundColor = [UIColor orangeColor];
	contentView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		
	KLCPopup* popup = [KLCPopup popupWithContentView:contentView];
	[popup show];

## Notes

### Interface Orientation
`KLCPopup` supports **Portrait** and **Landscape** by default.

### Deployment
`KLCPopup` requires **iOS 7**. It has not been tested on iOS 8 yet.

### Devices
`KLCPopup` supports **iPhone** and **iPad**.

### ARC
`KLCPopup` requires ARC.

### TODO
- Add support for keyboard show/hide.
- Add support for drag-to-dismiss.
- Add 'blur' option for background mask

##Credits
KLCPopup was created by Jeff Mascia and the team at Kullect, where it's used in the [Shout Photo Messenger](http://tryshout.com) app. Aspects of KLCPopup were inspired by Sam Vermette's [SVProgressHUD](https://github.com/samvermette/SVProgressHUD).
