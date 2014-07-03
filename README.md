KLCPopup
========

KLCPopup is a simple and flexible iOS class for presenting any custom view as a popup. It includes a variety of options controlling how your popup appears and behaves.

#Installation

- Drag the `KLCPopup/KLCPopup` folder into your project.
- `#import "KLCPopup.h"` where appropriate. 

#Usage

(see sample Xcode project in `/KLCPopupExample`)

## Creating a Popup

This method creates a popup for displaying a UIView, using the default layouts, animations, and behaviors (similar to a UIAlertView)

	+ (KLCPopup*)popupWithContentView:(UIView*)contentView;
	
This method creates a popup with custom layouts, animations, and behaviors. These customizations can also be accessed via properties on the popup instance.

	+ (KLCPopup*)popupWithContentView:(UIView*)contentView
					 horizontalLayout:(KLCPopupHorizontalLayout)horizontalLayout
					   verticalLayout:(KLCPopupVerticalLayout)verticalLayout
							 showType:(KLCPopupShowType)showType
						  dismissType:(KLCPopupDismissType)dismissType
							 maskType:(KLCPopupMaskType)maskType
			 dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
				dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

Note: You may pass `nil` for `contentView` when creating the popup, but **you must assign a `contentView` to the popup before showing it!**

Also **you must give your `contentView` a size** before showing it (by setting its frame), or **it must size itself with AutoLayout**.
					

## Showing a Popup
	
	- (void)show;
	
Or if you want your popup to dismiss automatically (like a toast in Android) you can set an explicit duration.
	
	- (void)showWithDuration:(NSTimeInterval)duration;

		
## Dismissing a Popup
		
There are a few ways to dismiss a popup:

If you have a reference to the popup instance, you can send this message to it. If `animated`, then it will use the animation specified in `dismissType`. Otherwise it will just disappear. 

	- (void)dismiss:(BOOL)animated;

If you lost your reference to a popup or you want to make sure no popups are showing, this class method dismisses any and all popups in your app.

	+ (void)dismissAllPopups;

Also you can call this category method from `UIView(KLCPopup)` on your contentView, or any of its subviews, to dismiss its parent popup.
	
	- (void)dismissPresentingPopup; // UIView category


## Customization


The final horizontal position of your popup when shown:

	@property (nonatomic, assign) KLCPopupHorizontalLayout horizontalLayout;

The final vertical position of your popup when shown:
	
	@property (nonatomic, assign) KLCPopupVerticalLayout verticalLayout;

The animation used to show your popup:

	@property (nonatomic, assign) KLCPopupShowType showType;
	
The animation used to dismiss your popup:

	@property (nonatomic, assign) KLCPopupDismissType dismissType;
	
Masking prevents touches to the background from passing through to views below:
	
	@property (nonatomic, assign) KLCPopupMaskType maskType;

The popup will automatically dismiss if the background is touched:
	
	@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;
	
The popup will automatically dismiss if the contentView is touched:

	@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;


## Blocks

You can use these blocks to synchronize other actions with popup events:

	@property (nonatomic, copy) void (^didFinishShowingCompletion)();

	@property (nonatomic, copy) void (^willStartDismissingCompletion)();

	@property (nonatomic, copy) void (^didFinishDismissingCompletion)();


## Example

	UIView* contentView = [[UIView alloc] init];
	contentView.backgroundColor = [UIColor orangeColor];
	contentView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		
	KLCPopup* popup = [KLCPopup popupWithContentView:contentView];
	[popup show];

# Notes

### Interface Orientation
`KLCPopup` supports **Portrait** and **Landscape** by default.

### Deployment
`KLCPopup` supports **iOS 7**. It has not been tested on iOS 8 yet.

### Devices
`KLCPopup` is compatible with both **iPhone** and **iPad**.

### ARC
`KLCPopup` was made with ARC enabled by default.


#Credits
KLCPopup was created by Jeff Mascia at Kullect, where we use it in our [Shout Photo Messenger](http://tryshout.com) app for iPhone. Some aspects of this library were inspired by Sam Vermette's [SVProgressHUD](https://github.com/samvermette/SVProgressHUD).