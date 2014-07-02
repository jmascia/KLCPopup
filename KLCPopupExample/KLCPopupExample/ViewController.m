//
// ViewController.m
// KLCPopupExample
//
// Copyright (c) 2014 Jeff Mascia (http://jeffmascia.com/)
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

#import "ViewController.h"
#import "KLCPopup.h"

static NSInteger const kMaskFieldTag = 1001;
static NSInteger const kShowFieldTag = 1002;
static NSInteger const kHideFieldTag = 1003;
static NSInteger const kHorizontalFieldTag = 1004;
static NSInteger const kVerticalFieldTag = 1005;

static NSInteger const kFieldTitleTag = 1101;
static NSInteger const kFieldDetailTag = 1102;


@interface ViewController () {
  
  UIPickerView* _pickerView;
  UILabel* _pickerLabel;
  UIButton* _pickerButton;
  UIView* _pickerContainer;
  
  UIButton* _horizontalButton;
  UIButton* _verticalButton;
  UIButton* _maskTypeButton;
  UIButton* _showTypeButton;
  UIButton* _hideTypeButton;
  UISwitch* _backgroundSwitch;
  UISwitch* _contentSwitch;
  UISwitch* _delaySwitch;
  
  NSArray* _horizontalLayouts;
  NSArray* _verticalLayouts;
  NSArray* _maskTypes;
  NSArray* _showTypes;
  NSArray* _hideTypes;
  
  NSInteger _selectedRowInHorizontalField;
  NSInteger _selectedRowInVerticalField;
  NSInteger _selectedRowInMaskField;
  NSInteger _selectedRowInShowField;
  NSInteger _selectedRowInHideField;
  
  NSDictionary* _namesForHorizontalLayouts;
  NSDictionary* _namesForVerticalLayouts;
  NSDictionary* _namesForMaskTypes;
  NSDictionary* _namesForShowTypes;
  NSDictionary* _namesForHideTypes;
}

@property (nonatomic, strong) UIPopoverController* popover;

- (void)updateLabelsForState;

@end


@interface UIColor (KLCPopup)
+ (UIColor*)klcLightGreenColor;
+ (UIColor*)klcGreenColor;
@end


@implementation ViewController

- (void)dealloc {
	[_horizontalButton removeObserver:self forKeyPath:@"highlighted"];
  [_verticalButton removeObserver:self forKeyPath:@"highlighted"];
	[_maskTypeButton removeObserver:self forKeyPath:@"highlighted"];
	[_showTypeButton removeObserver:self forKeyPath:@"highlighted"];
	[_hideTypeButton removeObserver:self forKeyPath:@"highlighted"];
}


#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    _horizontalLayouts = @[@(KLCPopupHorizontalLayoutLeft),
                           @(KLCPopupHorizontalLayoutLeftOfCenter),
                           @(KLCPopupHorizontalLayoutCenter),
                           @(KLCPopupHorizontalLayoutRightOfCenter),
                           @(KLCPopupHorizontalLayoutRight)];
    
    _verticalLayouts = @[@(KLCPopupVerticalLayoutTop),
                         @(KLCPopupVerticalLayoutAboveCenter),
                         @(KLCPopupVerticalLayoutCenter),
                         @(KLCPopupVerticalLayoutBelowCenter),
                         @(KLCPopupVerticalLayoutBottom)];
    
    _maskTypes = @[@(KLCPopupMaskTypeNone),
                   @(KLCPopupMaskTypeClear),
                   @(KLCPopupMaskTypeDimmed)];
    
    _showTypes = @[@(KLCPopupShowTypeNone),
                   @(KLCPopupShowTypeFadeIn),
                   @(KLCPopupShowTypeGrowIn),
                   @(KLCPopupShowTypeShrinkIn),
                   @(KLCPopupShowTypeSlideInFromTop),
                   @(KLCPopupShowTypeSlideInFromBottom),
                   @(KLCPopupShowTypeSlideInFromLeft),
                   @(KLCPopupShowTypeSlideInFromRight),
                   @(KLCPopupShowTypeBounceIn),
                   @(KLCPopupShowTypeBounceInFromTop),
                   @(KLCPopupShowTypeBounceInFromBottom),
                   @(KLCPopupShowTypeBounceInFromLeft),
                   @(KLCPopupShowTypeBounceInFromRight)];
    
    _hideTypes = @[@(KLCPopupHideTypeNone),
                   @(KLCPopupHideTypeFadeOut),
                   @(KLCPopupHideTypeGrowOut),
                   @(KLCPopupHideTypeShrinkOut),
                   @(KLCPopupHideTypeSlideOutToTop),
                   @(KLCPopupHideTypeSlideOutToBottom),
                   @(KLCPopupHideTypeSlideOutToLeft),
                   @(KLCPopupHideTypeSlideOutToRight),
                   @(KLCPopupHideTypeBounceOut),
                   @(KLCPopupHideTypeBounceOutToTop),
                   @(KLCPopupHideTypeBounceOutToBottom),
                   @(KLCPopupHideTypeBounceOutToLeft),
                   @(KLCPopupHideTypeBounceOutToRight)];
    
    
    _namesForHorizontalLayouts = @{@(KLCPopupHorizontalLayoutLeft) : @"Left",
                                   @(KLCPopupHorizontalLayoutLeftOfCenter) : @"Left of Center",
                                   @(KLCPopupHorizontalLayoutCenter) : @"Center",
                                   @(KLCPopupHorizontalLayoutRightOfCenter) : @"Right of Center",
                                   @(KLCPopupHorizontalLayoutRight) : @"Right"};
    
    _namesForVerticalLayouts = @{@(KLCPopupVerticalLayoutTop) : @"Top",
                                 @(KLCPopupVerticalLayoutAboveCenter) : @"Above Center",
                                 @(KLCPopupVerticalLayoutCenter) : @"Center",
                                 @(KLCPopupVerticalLayoutBelowCenter) : @"Below Center",
                                 @(KLCPopupVerticalLayoutBottom) : @"Bottom"};
    
    _namesForMaskTypes = @{@(KLCPopupMaskTypeNone) : @"None",
                           @(KLCPopupMaskTypeClear) : @"Clear",
                           @(KLCPopupMaskTypeDimmed) : @"Dimmed"};
    
    _namesForShowTypes = @{@(KLCPopupShowTypeNone) : @"None",
                           @(KLCPopupShowTypeFadeIn) : @"Fade in",
                           @(KLCPopupShowTypeGrowIn) : @"Grow in",
                           @(KLCPopupShowTypeShrinkIn) : @"Shrink in",
                           @(KLCPopupShowTypeSlideInFromTop) : @"Slide from Top",
                           @(KLCPopupShowTypeSlideInFromBottom) : @"Slide from Bottom",
                           @(KLCPopupShowTypeSlideInFromLeft) : @"Slide from Left",
                           @(KLCPopupShowTypeSlideInFromRight) : @"Slide from Right",
                           @(KLCPopupShowTypeBounceIn) : @"Bounce in",
                           @(KLCPopupShowTypeBounceInFromTop) : @"Bounce from Top",
                           @(KLCPopupShowTypeBounceInFromBottom) : @"Bounce from Bottom",
                           @(KLCPopupShowTypeBounceInFromLeft) : @"Bounce from Left",
                           @(KLCPopupShowTypeBounceInFromRight) : @"Bounce from Right"};
    
    _namesForHideTypes = @{@(KLCPopupHideTypeNone) : @"None",
                           @(KLCPopupHideTypeFadeOut) : @"Fade out",
                           @(KLCPopupHideTypeGrowOut) : @"Grow out",
                           @(KLCPopupHideTypeShrinkOut) : @"Shrink out",
                           @(KLCPopupHideTypeSlideOutToTop) : @"Slide to Top",
                           @(KLCPopupHideTypeSlideOutToBottom) : @"Slide to Bottom",
                           @(KLCPopupHideTypeSlideOutToLeft) : @"Slide to Left",
                           @(KLCPopupHideTypeSlideOutToRight) : @"Slide to Right",
                           @(KLCPopupHideTypeBounceOut) : @"Bounce out",
                           @(KLCPopupHideTypeBounceOutToTop) : @"Bounce to Top",
                           @(KLCPopupHideTypeBounceOutToBottom) : @"Bounce to Bottom",
                           @(KLCPopupHideTypeBounceOutToLeft) : @"Bounce to Left",
                           @(KLCPopupHideTypeBounceOutToRight) : @"Bounce to Right"};
  
    _selectedRowInHorizontalField = [_horizontalLayouts indexOfObject:@(KLCPopupHorizontalLayoutCenter)];
    _selectedRowInVerticalField = [_verticalLayouts indexOfObject:@(KLCPopupVerticalLayoutCenter)];
    _selectedRowInMaskField = [_maskTypes indexOfObject:@(KLCPopupMaskTypeClear)];
    _selectedRowInShowField = [_showTypes indexOfObject:@(KLCPopupShowTypeBounceInFromTop)];
    _selectedRowInHideField = [_hideTypes indexOfObject:@(KLCPopupHideTypeBounceOutToBottom)];

  }
  return self;
}

- (void)loadView {
  [super loadView];
  
  UIColor* fieldTitleColor = [UIColor darkGrayColor];
  UIFont* fieldTitleFont = [UIFont systemFontOfSize:15.0];
  UIColor* fieldDetailColor = [UIColor darkGrayColor];
  UIFont* fieldDetailFont = [UIFont boldSystemFontOfSize:15.0];
  UIColor* fieldHighlightedColor = [UIColor lightGrayColor];
  NSLineBreakMode fieldLineBreakMode = NSLineBreakByTruncatingMiddle;
  
  // SPACERS
  UIView* spacer1 = [[UIView alloc] init];
  spacer1.translatesAutoresizingMaskIntoConstraints = NO;
  spacer1.backgroundColor = [UIColor clearColor];
  
  UIView* spacer2 = [[UIView alloc] init];
  spacer2.translatesAutoresizingMaskIntoConstraints = NO;
  spacer2.backgroundColor = [UIColor clearColor];
  
  // HEADER
  UILabel* header = [[UILabel alloc] init];
  header.translatesAutoresizingMaskIntoConstraints = NO;
  header.numberOfLines = 1;
  header.backgroundColor = [UIColor clearColor];
  header.textColor = [UIColor grayColor];
  header.font = [UIFont boldSystemFontOfSize:28];
  header.textAlignment = NSTextAlignmentCenter;
  header.text = @"KLCPopup";
  
  // HORIZONTAL LAYOUT
  UILabel* horizontalTitle = [[UILabel alloc] init];
  horizontalTitle.translatesAutoresizingMaskIntoConstraints = NO;
  horizontalTitle.numberOfLines = 1;
  horizontalTitle.lineBreakMode = fieldLineBreakMode;
  horizontalTitle.backgroundColor = [UIColor clearColor];
  horizontalTitle.textColor = fieldTitleColor;
  horizontalTitle.highlightedTextColor = fieldHighlightedColor;
  horizontalTitle.font = fieldTitleFont;
  horizontalTitle.tag = kFieldTitleTag;
  horizontalTitle.userInteractionEnabled = NO;
  horizontalTitle.text = @"Horizontal layout:";

  UILabel* horizontalDetail = [[UILabel alloc] init];
  horizontalDetail.translatesAutoresizingMaskIntoConstraints = NO;
  horizontalDetail.numberOfLines = 1;
  horizontalDetail.lineBreakMode = fieldLineBreakMode;
  horizontalDetail.backgroundColor = [UIColor clearColor];
  horizontalDetail.textColor = fieldDetailColor;
  horizontalDetail.highlightedTextColor = fieldHighlightedColor;
  horizontalDetail.font = fieldDetailFont;
  horizontalDetail.userInteractionEnabled = NO;
  horizontalDetail.tag = kFieldDetailTag;
  
  UIButton* horizontalButton = [UIButton buttonWithType:UIButtonTypeCustom];
  horizontalButton.translatesAutoresizingMaskIntoConstraints = NO;
  horizontalButton.backgroundColor = [UIColor clearColor];
  [horizontalButton addTarget:self action:@selector(fieldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [horizontalButton addObserver:self forKeyPath:@"highlighted" options:0 context:nil];
  _horizontalButton = horizontalButton;
  
  // VERTICAL LAYOUT
  UILabel* verticalTitle = [[UILabel alloc] init];
  verticalTitle.translatesAutoresizingMaskIntoConstraints = NO;
  verticalTitle.numberOfLines = 1;
  verticalTitle.lineBreakMode = fieldLineBreakMode;
  verticalTitle.backgroundColor = [UIColor clearColor];
  verticalTitle.textColor = fieldTitleColor;
  verticalTitle.highlightedTextColor = fieldHighlightedColor;
  verticalTitle.font = fieldTitleFont;
  verticalTitle.tag = kFieldTitleTag;
  verticalTitle.userInteractionEnabled = NO;
  verticalTitle.text = @"Vertical layout:";

  UILabel* verticalDetail = [[UILabel alloc] init];
  verticalDetail.translatesAutoresizingMaskIntoConstraints = NO;
  verticalDetail.numberOfLines = 1;
  verticalDetail.lineBreakMode = fieldLineBreakMode;
  verticalDetail.backgroundColor = [UIColor clearColor];
  verticalDetail.textColor = fieldDetailColor;
  verticalDetail.highlightedTextColor = fieldHighlightedColor;
  verticalDetail.font = fieldDetailFont;
  verticalDetail.tag = kFieldDetailTag;
  verticalDetail.userInteractionEnabled = NO;
  
  UIButton* verticalButton = [UIButton buttonWithType:UIButtonTypeCustom];
  verticalButton.translatesAutoresizingMaskIntoConstraints = NO;
  verticalButton.backgroundColor = [UIColor clearColor];
  [verticalButton addTarget:self action:@selector(fieldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [verticalButton addObserver:self forKeyPath:@"highlighted" options:0 context:nil];
  _verticalButton = verticalButton;
  
  // MASK TYPE
  UILabel* maskTypeTitle = [[UILabel alloc] init];
  maskTypeTitle.translatesAutoresizingMaskIntoConstraints = NO;
  maskTypeTitle.numberOfLines = 1;
  maskTypeTitle.lineBreakMode = fieldLineBreakMode;
  maskTypeTitle.backgroundColor = [UIColor clearColor];
  maskTypeTitle.textColor = fieldTitleColor;
  maskTypeTitle.highlightedTextColor = fieldHighlightedColor;
  maskTypeTitle.font = fieldTitleFont;
  maskTypeTitle.tag = kFieldTitleTag;
  maskTypeTitle.text = @"Background mask:";
  maskTypeTitle.userInteractionEnabled = NO;

  UILabel* maskTypeDetail = [[UILabel alloc] init];
  maskTypeDetail.translatesAutoresizingMaskIntoConstraints = NO;
  maskTypeDetail.numberOfLines = 1;
  maskTypeDetail.lineBreakMode = fieldLineBreakMode;
  maskTypeDetail.backgroundColor = [UIColor clearColor];
  maskTypeDetail.textColor = fieldDetailColor;
  maskTypeDetail.highlightedTextColor = fieldHighlightedColor;
  maskTypeDetail.font = fieldDetailFont;
  maskTypeDetail.tag = kFieldDetailTag;
  maskTypeDetail.userInteractionEnabled = NO;

  UIButton* maskTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  maskTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
  maskTypeButton.backgroundColor = [UIColor clearColor];
  [maskTypeButton addTarget:self action:@selector(fieldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [maskTypeButton addObserver:self forKeyPath:@"highlighted" options:0 context:nil];
  _maskTypeButton = maskTypeButton;
  
  // SHOW TYPE
  UILabel* showTypeTitle = [[UILabel alloc] init];
  showTypeTitle.translatesAutoresizingMaskIntoConstraints = NO;
  showTypeTitle.numberOfLines = 1;
  showTypeTitle.lineBreakMode = fieldLineBreakMode;
  showTypeTitle.backgroundColor = [UIColor clearColor];
  showTypeTitle.textColor = fieldTitleColor;
  showTypeTitle.highlightedTextColor = fieldHighlightedColor;
  showTypeTitle.font = fieldTitleFont;
  showTypeTitle.tag = kFieldTitleTag;
  showTypeTitle.userInteractionEnabled = NO;
  showTypeTitle.text = @"Show animation:";

  UILabel* showTypeDetail = [[UILabel alloc] init];
  showTypeDetail.translatesAutoresizingMaskIntoConstraints = NO;
  showTypeDetail.numberOfLines = 1;
  showTypeDetail.lineBreakMode = fieldLineBreakMode;
  showTypeDetail.backgroundColor = [UIColor clearColor];
  showTypeDetail.textColor = fieldDetailColor;
  showTypeDetail.highlightedTextColor = fieldHighlightedColor;
  showTypeDetail.font = fieldDetailFont;
  showTypeDetail.tag = kFieldDetailTag;
  showTypeDetail.userInteractionEnabled = NO;

  UIButton* showTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  showTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
  showTypeButton.backgroundColor = [UIColor clearColor];
  [showTypeButton addTarget:self action:@selector(fieldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [showTypeButton addObserver:self forKeyPath:@"highlighted" options:0 context:nil];
  _showTypeButton = showTypeButton;
  
  // HIDE TYPE
  UILabel* hideTypeTitle = [[UILabel alloc] init];
  hideTypeTitle.translatesAutoresizingMaskIntoConstraints = NO;
  hideTypeTitle.numberOfLines = 1;
  hideTypeTitle.lineBreakMode = fieldLineBreakMode;
  hideTypeTitle.backgroundColor = [UIColor clearColor];
  hideTypeTitle.textColor = fieldTitleColor;
  hideTypeTitle.highlightedTextColor = fieldHighlightedColor;
  hideTypeTitle.font = fieldTitleFont;
  hideTypeTitle.tag = kFieldTitleTag;
  hideTypeTitle.userInteractionEnabled = NO;
  hideTypeTitle.text = @"Hide animation:";

  UILabel* hideTypeDetail = [[UILabel alloc] init];
  hideTypeDetail.translatesAutoresizingMaskIntoConstraints = NO;
  hideTypeDetail.numberOfLines = 1;
  hideTypeDetail.lineBreakMode = fieldLineBreakMode;
  hideTypeDetail.backgroundColor = [UIColor clearColor];
  hideTypeDetail.textColor = fieldDetailColor;
  hideTypeDetail.highlightedTextColor = fieldHighlightedColor;
  hideTypeDetail.font = fieldDetailFont;
  hideTypeDetail.tag = kFieldDetailTag;
  hideTypeDetail.userInteractionEnabled = NO;
  
  UIButton* hideTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  hideTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
  hideTypeButton.backgroundColor = [UIColor clearColor];
  [hideTypeButton addTarget:self action:@selector(fieldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [hideTypeButton addObserver:self forKeyPath:@"highlighted" options:0 context:nil];
  _hideTypeButton = hideTypeButton;
  
  // BACKGROUND TAP
  UILabel* backgroundLabel = [[UILabel alloc] init];
  backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
  backgroundLabel.numberOfLines = 1;
  backgroundLabel.lineBreakMode = fieldLineBreakMode;
  backgroundLabel.backgroundColor = [UIColor clearColor];
  backgroundLabel.textColor = fieldTitleColor;
  backgroundLabel.font = fieldTitleFont;
  backgroundLabel.text = @"Hide on background tap:";
  
  UISwitch* backgroundSwitch = [[UISwitch alloc] init];
  backgroundSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  backgroundSwitch.on = YES;
  _backgroundSwitch = backgroundSwitch;
  
  UIView* backgroundContainer = [[UIView alloc] init];
  backgroundContainer.translatesAutoresizingMaskIntoConstraints = NO;
  backgroundContainer.backgroundColor = [UIColor clearColor];
  
  // CONTENT TAP
  UILabel* contentLabel = [[UILabel alloc] init];
  contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
  contentLabel.numberOfLines = 1;
  contentLabel.lineBreakMode = fieldLineBreakMode;
  contentLabel.backgroundColor = [UIColor clearColor];
  contentLabel.textColor = fieldTitleColor;
  contentLabel.font = fieldTitleFont;
  contentLabel.text = @"Hide on content tap:";
  
  UISwitch* contentSwitch = [[UISwitch alloc] init];
  contentSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  _contentSwitch = contentSwitch;
  
  UIView* contentContainer = [[UIView alloc] init];
  contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
  contentContainer.backgroundColor = [UIColor clearColor];
  
  // DELAY
  UILabel* delayLabel = [[UILabel alloc] init];
  delayLabel.translatesAutoresizingMaskIntoConstraints = NO;
  delayLabel.numberOfLines = 1;
  delayLabel.lineBreakMode = fieldLineBreakMode;
  delayLabel.backgroundColor = [UIColor clearColor];
  delayLabel.textColor = fieldTitleColor;
  delayLabel.font = fieldTitleFont;
  delayLabel.text = @"Hide after delay:";
  
  UISwitch* delaySwitch = [[UISwitch alloc] init];
  delaySwitch.translatesAutoresizingMaskIntoConstraints = NO;
  _delaySwitch = delaySwitch;
  
  UIView* delayContainer = [[UIView alloc] init];
  delayContainer.translatesAutoresizingMaskIntoConstraints = NO;
  delayContainer.backgroundColor = [UIColor clearColor];
  
  // PRESENT
  UIButton* showButton = [UIButton buttonWithType:UIButtonTypeCustom];
  showButton.translatesAutoresizingMaskIntoConstraints = NO;
  showButton.contentEdgeInsets = UIEdgeInsetsMake(9, 24, 9, 24);
  [showButton setTitle:@"Show" forState:UIControlStateNormal];
  showButton.backgroundColor = [UIColor lightGrayColor];
  [showButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [showButton setTitleColor:[[showButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
  showButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  [showButton.layer setCornerRadius:6.0];
  [showButton addTarget:self action:@selector(showButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  // View hierarchy
  [self.view addSubview:spacer1];
  [self.view addSubview:spacer2];
  [self.view addSubview:header];
  [horizontalButton addSubview:horizontalTitle];
  [horizontalButton addSubview:horizontalDetail];
  [self.view addSubview:horizontalButton];
  [verticalButton addSubview:verticalTitle];
  [verticalButton addSubview:verticalDetail];
  [self.view addSubview:verticalButton];
  [maskTypeButton addSubview:maskTypeTitle];
  [maskTypeButton addSubview:maskTypeDetail];
  [self.view addSubview:maskTypeButton];
  [showTypeButton addSubview:showTypeTitle];
  [showTypeButton addSubview:showTypeDetail];
  [self.view addSubview:showTypeButton];
  [hideTypeButton addSubview:hideTypeTitle];
  [hideTypeButton addSubview:hideTypeDetail];
  [self.view addSubview:hideTypeButton];
  [backgroundContainer addSubview:backgroundLabel];
  [backgroundContainer addSubview:backgroundSwitch];
  [self.view addSubview:backgroundContainer];
  [contentContainer addSubview:contentLabel];
  [contentContainer addSubview:contentSwitch];
  [self.view addSubview:contentContainer];
  [delayContainer addSubview:delayLabel];
  [delayContainer addSubview:delaySwitch];
  [self.view addSubview:delayContainer];
  [self.view addSubview:showButton];
  
  // Set high level AutoLayout constraints
  NSDictionary* views = NSDictionaryOfVariableBindings(spacer1,
                                                       spacer2,
                                                       header,
                                                       horizontalButton,
                                                       verticalButton,
                                                       maskTypeButton,
                                                       showTypeButton,
                                                       hideTypeButton,
                                                       backgroundContainer,
                                                       contentContainer,
                                                       delayContainer,
                                                       showButton);
  NSDictionary* metrics = @{@"minHSpacing" : @20.0,
                            @"fieldVSpacing" : @10.0};

  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spacer1][header]-(fieldVSpacing)-[horizontalButton]-(fieldVSpacing)-[verticalButton]-(fieldVSpacing)-[maskTypeButton]-(fieldVSpacing)-[showTypeButton]-(fieldVSpacing)-[hideTypeButton]-(fieldVSpacing)-[backgroundContainer]-(fieldVSpacing)-[contentContainer]-(fieldVSpacing)-[delayContainer]"
                                           options:(NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight)
                                           metrics:metrics
                                             views:views]];
  
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:[delayContainer]-(20)-[showButton][spacer2(==spacer1)]|"
                                           options:(NSLayoutFormatAlignAllCenterX)
                                           metrics:metrics
                                             views:views]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:backgroundContainer
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  
  // AutoLayout horizontal-layout field
  views = NSDictionaryOfVariableBindings(horizontalTitle, horizontalDetail);
  [horizontalButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[horizontalTitle]-(>=minHSpacing)-[horizontalDetail]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [horizontalButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[horizontalTitle]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  
  // AutoLayout vertical-layout field
  views = NSDictionaryOfVariableBindings(verticalTitle, verticalDetail);
  [verticalButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[verticalTitle]-(>=minHSpacing)-[verticalDetail]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [verticalButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[verticalTitle]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  // AutoLayout mask-type field
  views = NSDictionaryOfVariableBindings(maskTypeTitle, maskTypeDetail);
  [maskTypeButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[maskTypeTitle]-(>=minHSpacing)-[maskTypeDetail]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [maskTypeButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[maskTypeTitle]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  // AutoLayout show-type field
  views = NSDictionaryOfVariableBindings(showTypeTitle, showTypeDetail);
  [showTypeButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[showTypeTitle]-(>=minHSpacing)-[showTypeDetail]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [showTypeButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[showTypeTitle]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  // AutoLayout hide-type field
  views = NSDictionaryOfVariableBindings(hideTypeTitle, hideTypeDetail);
  [hideTypeButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hideTypeTitle]-(>=minHSpacing)-[hideTypeDetail]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [hideTypeButton addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hideTypeTitle]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  // AutoLayout background tap field
  views = NSDictionaryOfVariableBindings(backgroundLabel, backgroundSwitch);
  [backgroundContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundLabel]-(>=minHSpacing)-[backgroundSwitch]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [backgroundContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundSwitch]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  // Auto layout content tap field
  views = NSDictionaryOfVariableBindings(contentLabel, contentSwitch);
  [contentContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentLabel]-(>=minHSpacing)-[contentSwitch]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [contentContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentSwitch]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];

  // Auto layout after-delay field
  views = NSDictionaryOfVariableBindings(delayLabel, delaySwitch);
  [delayContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[delayLabel]-(>=minHSpacing)-[delaySwitch]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [delayContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[delaySwitch]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  
  // PICKER
  UIPickerView* pickerView = [[UIPickerView alloc] init];
  pickerView.translatesAutoresizingMaskIntoConstraints = NO;
  pickerView.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(202.0/255.0) blue:(215.0/255.0) alpha:1.0];
  pickerView.showsSelectionIndicator = YES;
  pickerView.dataSource = self;
  pickerView.delegate = self;
  _pickerView = pickerView;
  
  UILabel* pickerLabel = [[UILabel alloc] init];
  pickerLabel.translatesAutoresizingMaskIntoConstraints = NO;
  pickerLabel.numberOfLines = 1;
  pickerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  pickerLabel.backgroundColor = [UIColor clearColor];
  pickerLabel.textColor = [UIColor blackColor];
  pickerLabel.font = [UIFont systemFontOfSize:16.0];
  _pickerLabel = pickerLabel;
  
  UIButton* pickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  pickerButton.translatesAutoresizingMaskIntoConstraints = NO;
  pickerButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
  pickerButton.backgroundColor = [UIColor clearColor];
  [pickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [pickerButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  pickerButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  [pickerButton setTitle:@"Done" forState:UIControlStateNormal];
  [pickerButton addTarget:self action:@selector(pickerDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  UIView* pickerContainer = [[UIView alloc] init];
  pickerContainer.translatesAutoresizingMaskIntoConstraints = NO;
  pickerContainer.backgroundColor = [UIColor colorWithRed:(145.0/255.0) green:(150.0/255.0) blue:(155.0/255.0) alpha:1.0];
  _pickerContainer = pickerContainer;
  
  UIView* pickerBar = [[UIView alloc] init];
  pickerBar.translatesAutoresizingMaskIntoConstraints = NO;
  pickerBar.backgroundColor = [UIColor colorWithRed:(238.0/255.0) green:(240.0/255.0) blue:(242.0/255.0) alpha:1.0];
  
  [pickerContainer addSubview:pickerView];
  [pickerBar addSubview:pickerLabel];
  [pickerBar addSubview:pickerButton];
  [pickerContainer addSubview:pickerBar];
  
  // AutoLayout for Picker container
  views = NSDictionaryOfVariableBindings(pickerView, pickerLabel, pickerButton, pickerBar);
  metrics = nil;
  
  [pickerContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0.5)-[pickerBar][pickerView]|"
                                           options:(NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight)
                                           metrics:metrics
                                             views:views]];
  
  [pickerContainer addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerView]|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
  
  [pickerBar addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(12)-[pickerLabel]-(5)-[pickerButton]|"
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:metrics
                                             views:views]];
  
  [pickerBar addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[pickerButton]-(3)-|"
                                           options:0
                                           metrics:metrics
                                             views:views]];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // make sure labels reflect current state
  [self updateLabelsForState];
}


#pragma mark - Event Handlers

- (void)fieldButtonPressed:(id)sender {
  
  // Initialize picker for pressed field
  NSInteger rowToSelect = 0;
  NSInteger fieldTag = 0;
  if (sender == _horizontalButton) {
    fieldTag = kHorizontalFieldTag;
    rowToSelect = _selectedRowInHorizontalField;
    
  } else if (sender == _verticalButton) {
    fieldTag = kVerticalFieldTag;
    rowToSelect = _selectedRowInVerticalField;
    
  } else if (sender == _maskTypeButton) {
    fieldTag = kMaskFieldTag;
    rowToSelect = _selectedRowInMaskField;
    
  } else if (sender == _showTypeButton) {
    fieldTag = kShowFieldTag;
    rowToSelect = _selectedRowInShowField;
    
  } else if (sender == _hideTypeButton) {
    fieldTag = kHideFieldTag;
    rowToSelect = _selectedRowInHideField;
  }
  
  _pickerView.tag = fieldTag;
  [_pickerView reloadAllComponents];
  [_pickerView selectRow:rowToSelect inComponent:0 animated:NO];
  
  // Show field's title text
  
  if ([sender isKindOfClass:[UIView class]]) {
    UIView* view = [(UIView*)sender viewWithTag:kFieldTitleTag];
    if ([view isKindOfClass:[UILabel class]]) {
      _pickerLabel.text = ((UILabel*)view).text;
    }
  }
  
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
    UIViewController* controller = [[UIViewController alloc] init];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 200) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    tableView.tag = fieldTag;
    [tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    controller.view = tableView;
    
    UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    popover.delegate = self;
    self.popover = popover;
    
    UIView* senderView = (UIView*)sender;
    CGRect senderFrameInView = [senderView convertRect:senderView.bounds toView:self.view];
    [popover presentPopoverFromRect:senderFrameInView inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
  } else {
    KLCPopup* popup = [KLCPopup popupWithContentView:_pickerContainer
                                            showType:KLCPopupShowTypeSlideInFromBottom
                                            hideType:KLCPopupHideTypeSlideOutToBottom
                                            maskType:KLCPopupMaskTypeDimmed];
    
    popup.verticalLayout = KLCPopupVerticalLayoutBottom;
    popup.shouldHideOnBackgroundTouch = YES;
    popup.shouldHideOnContentTouch = NO;
    popup.willStartHidingCompletion = ^{
      [self updateLabelsForState];
    };
    [popup show];
  }
}

- (void)showButtonPressed:(id)sender {
  
  // Generate content view to present
  UIView* contentView = [[UIView alloc] init];
  contentView.translatesAutoresizingMaskIntoConstraints = NO;
  contentView.backgroundColor = [UIColor klcLightGreenColor];
  contentView.layer.cornerRadius = 12.0;
  
  UILabel* hideLabel = [[UILabel alloc] init];
  hideLabel.translatesAutoresizingMaskIntoConstraints = NO;
  hideLabel.backgroundColor = [UIColor clearColor];
  hideLabel.textColor = [UIColor whiteColor];
  hideLabel.font = [UIFont boldSystemFontOfSize:72.0];
  hideLabel.text = @"Hi.";
  
  UIButton* hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
  hideButton.translatesAutoresizingMaskIntoConstraints = NO;
  hideButton.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16);
  hideButton.backgroundColor = [UIColor klcGreenColor];
  [hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [hideButton setTitleColor:[[hideButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
  hideButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
  [hideButton setTitle:@"Bye" forState:UIControlStateNormal];
  hideButton.layer.cornerRadius = 6.0;
  [hideButton addTarget:self action:@selector(hideButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [contentView addSubview:hideLabel];
  [contentView addSubview:hideButton];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(contentView, hideButton, hideLabel);
  
  [contentView addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(16)-[hideLabel]-(10)-[hideButton]-(12)-|"
                                           options:NSLayoutFormatAlignAllCenterX
                                           metrics:nil
                                             views:views]];
  
  [contentView addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(36)-[hideLabel]-(36)-|"
                                           options:0
                                           metrics:nil
                                             views:views]];
  
  // Show in popup
  KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                          showType:(KLCPopupShowType)[self valueForRow:_selectedRowInShowField inFieldWithTag:kShowFieldTag]
                                          hideType:(KLCPopupHideType)[self valueForRow:_selectedRowInHideField inFieldWithTag:kHideFieldTag]
                                          maskType:(KLCPopupMaskType)[self valueForRow:_selectedRowInMaskField inFieldWithTag:kMaskFieldTag]];
  
  popup.horizontalLayout = (KLCPopupHorizontalLayout)[self valueForRow:_selectedRowInHorizontalField inFieldWithTag:kHorizontalFieldTag];
  popup.verticalLayout = (KLCPopupVerticalLayout)[self valueForRow:_selectedRowInVerticalField inFieldWithTag:kVerticalFieldTag];
  popup.shouldHideOnBackgroundTouch = _backgroundSwitch.on;
  popup.shouldHideOnContentTouch = _contentSwitch.on;
  
  if (_delaySwitch.on) {
    [popup showWithDuration:2.0];
  } else {
    [popup show];
  }
}

- (void)hideButtonPressed:(id)sender {
  if ([sender isKindOfClass:[UIView class]]) {
    [(UIView*)sender hidePresentingPopup];
  }
}

- (void)pickerDoneButtonPressed:(id)sender {
  [_pickerView hidePresentingPopup];
}

#pragma mark - Private

- (void)updateLabelsForState {
  [(UILabel*)[_horizontalButton viewWithTag:kFieldDetailTag] setText:[self nameForValue:[self valueForRow:_selectedRowInHorizontalField inFieldWithTag:kHorizontalFieldTag] inFieldWithTag:kHorizontalFieldTag]];
  [(UILabel*)[_verticalButton viewWithTag:kFieldDetailTag] setText:[self nameForValue:[self valueForRow:_selectedRowInVerticalField inFieldWithTag:kVerticalFieldTag] inFieldWithTag:kVerticalFieldTag]];
  [(UILabel*)[_maskTypeButton viewWithTag:kFieldDetailTag] setText:[self nameForValue:[self valueForRow:_selectedRowInMaskField inFieldWithTag:kMaskFieldTag] inFieldWithTag:kMaskFieldTag]];
  [(UILabel*)[_showTypeButton viewWithTag:kFieldDetailTag] setText:[self nameForValue:[self valueForRow:_selectedRowInShowField inFieldWithTag:kShowFieldTag] inFieldWithTag:kShowFieldTag]];
  [(UILabel*)[_hideTypeButton viewWithTag:kFieldDetailTag] setText:[self nameForValue:[self valueForRow:_selectedRowInHideField inFieldWithTag:kHideFieldTag] inFieldWithTag:kHideFieldTag]];
}


- (NSInteger)valueForRow:(NSInteger)row inList:(NSArray*)list {
  
  // If row is out of bounds, try using first row.
  if (row >= list.count) {
    row = 0;
  }
  
  if (row < list.count) {
    id obj = [list objectAtIndex:row];
    if ([obj isKindOfClass:[NSNumber class]]) {
      return [(NSNumber*)obj integerValue];
    }
  }
  
  return 0;
}


- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag {

  NSArray* listForField = nil;
  if (tag == kHorizontalFieldTag) {
    listForField = _horizontalLayouts;
    
  } else if (tag == kVerticalFieldTag) {
    listForField = _verticalLayouts;
    
  } else if (tag == kMaskFieldTag) {
    listForField = _maskTypes;
    
  } else if (tag == kShowFieldTag) {
    listForField = _showTypes;
    
  } else if (tag == kHideFieldTag) {
    listForField = _hideTypes;
  }
  
  // If row is out of bounds, try using first row.
  if (row >= listForField.count) {
    row = 0;
  }
  
  if (row < listForField.count) {
    id obj = [listForField objectAtIndex:row];
    if ([obj isKindOfClass:[NSNumber class]]) {
      return [(NSNumber*)obj integerValue];
    }
  }
  
  return 0;
}

- (NSInteger)selectedRowForFieldWithTag:(NSInteger)tag {
  if (tag == kHorizontalFieldTag) {
    return _selectedRowInHorizontalField;
    
  } else if (tag == kVerticalFieldTag) {
    return _selectedRowInVerticalField;
    
  } else if (tag == kMaskFieldTag) {
    return _selectedRowInMaskField;
    
  } else if (tag == kShowFieldTag) {
    return _selectedRowInShowField;
    
  } else if (tag == kHideFieldTag) {
    return _selectedRowInHideField;
  }
  return 0;
}

- (NSString*)nameForValue:(NSInteger)value inFieldWithTag:(NSInteger)tag {
  
  NSDictionary* namesForField = nil;
  if (tag == kHorizontalFieldTag) {
    namesForField = _namesForHorizontalLayouts;
    
  } else if (tag == kVerticalFieldTag) {
    namesForField = _namesForVerticalLayouts;
    
  } else if (tag == kMaskFieldTag) {
    namesForField = _namesForMaskTypes;
  
  } else if (tag == kShowFieldTag) {
    namesForField = _namesForShowTypes;
  
  } else if (tag == kHideFieldTag) {
    namesForField = _namesForHideTypes;
  }
  
  if (namesForField != nil) {
    return [namesForField objectForKey:@(value)];
  }
  return nil;
}


#pragma mark - <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  
  if (component == 0) {
    
    if (pickerView.tag == kHorizontalFieldTag) {
      return _horizontalLayouts.count;
      
    } else if (pickerView.tag == kVerticalFieldTag) {
      return _verticalLayouts.count;
      
    } else if (pickerView.tag == kMaskFieldTag) {
      return _maskTypes.count;
      
    } else if (pickerView.tag == kShowFieldTag) {
      return _showTypes.count;
      
    } else if (pickerView.tag == kHideFieldTag) {
      return _hideTypes.count;
    }
  }
  return 0;
}


#pragma mark - <UIPickerViewDelegate>

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  
  NSInteger fieldTag = pickerView.tag;
  return [self nameForValue:[self valueForRow:row inFieldWithTag:fieldTag] inFieldWithTag:fieldTag];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  
  if (pickerView.tag == kHorizontalFieldTag) {
    _selectedRowInHorizontalField = row;
    
  } else if (pickerView.tag == kVerticalFieldTag) {
    _selectedRowInVerticalField = row;
    
  } else if (pickerView.tag == kMaskFieldTag) {
    _selectedRowInMaskField = row;
    
  } else if (pickerView.tag == kShowFieldTag) {
    _selectedRowInShowField = row;
    
  } else if (pickerView.tag == kHideFieldTag) {
    _selectedRowInHideField = row;
  }
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  if (tableView.tag == kHorizontalFieldTag) {
    return _horizontalLayouts.count;
    
  } else if (tableView.tag == kVerticalFieldTag) {
    return _verticalLayouts.count;
    
  } else if (tableView.tag == kMaskFieldTag) {
    return _maskTypes.count;
    
  } else if (tableView.tag == kShowFieldTag) {
    return _showTypes.count;
    
  } else if (tableView.tag == kHideFieldTag) {
    return _hideTypes.count;
  }
  
  return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell* cell = nil;
  
  Class cellClass = [UITableViewCell class];
  NSString* identifier = NSStringFromClass(cellClass);
  
  cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  if (nil == cell) {
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    cell = [[cellClass alloc] initWithStyle:style reuseIdentifier:identifier];
  }
  
  NSInteger fieldTag = tableView.tag;
  
  cell.textLabel.text = [self nameForValue:[self valueForRow:indexPath.row inFieldWithTag:fieldTag] inFieldWithTag:fieldTag];
  
  if (indexPath.row == [self selectedRowForFieldWithTag:fieldTag]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  return cell;
}


- (void)updateTableView:(UITableView*)tableView {
  
  if (tableView != nil) {
    
    NSInteger fieldTag = tableView.tag;
    NSInteger selectedRow = [self selectedRowForFieldWithTag:fieldTag];
    
    for (NSIndexPath* indexPath in [tableView indexPathsForVisibleRows]) {
      
      UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
      if (cell != nil) {
        
        if (indexPath.row == selectedRow) {
          cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
          cell.accessoryType = UITableViewCellAccessoryNone;
        }
      }
    }
  }
}




#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (tableView.tag == kHorizontalFieldTag) {
    _selectedRowInHorizontalField = indexPath.row;
    
  } else if (tableView.tag == kVerticalFieldTag) {
    _selectedRowInVerticalField = indexPath.row;
    
  } else if (tableView.tag == kMaskFieldTag) {
    _selectedRowInMaskField = indexPath.row;
    
  } else if (tableView.tag == kShowFieldTag) {
    _selectedRowInShowField = indexPath.row;
    
  } else if (tableView.tag == kHideFieldTag) {
    _selectedRowInHideField = indexPath.row;
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  [self updateTableView:tableView];
  
  [self updateLabelsForState];
  
  [self.popover dismissPopoverAnimated:YES];
}


#pragma mark - <UIPopoverControllerDelegate>

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  
  //
  UIView* view = popoverController.contentViewController.view;
  if ([view isKindOfClass:[UITableView class]]) {
    [(UITableView*)view removeObserver:self forKeyPath:@"contentSize"];
  }
  
  //
  self.popover = nil;
}


#pragma mark - <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  //
  if ([keyPath isEqualToString:@"highlighted"]) {
    
    if ([object isKindOfClass:[UIButton class]]) {
      UIButton* button = (UIButton*)object;
      for (UIView* subview in button.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
          [(UILabel*)subview setHighlighted:button.highlighted];
        }
      }
    }
  }
  
  //
  else if ([keyPath isEqualToString:@"contentSize"]) {
   
    if ([object isKindOfClass:[UITableView class]]) {
      UITableView* tableView = (UITableView*)object;
      
      if (self.popover != nil) {
        [self.popover setPopoverContentSize:tableView.contentSize animated:NO];
      }
      
      NSInteger fieldTag = tableView.tag;
      NSInteger selectedRow = [self selectedRowForFieldWithTag:fieldTag];
      
      if ([tableView numberOfRowsInSection:0] > selectedRow) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
      }
    }
  }
}


@end




@implementation UIColor (KLCPopup)

+ (UIColor*)klcLightGreenColor {
  return [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
}

+ (UIColor*)klcGreenColor {
  return [UIColor colorWithRed:(0.0/255.0) green:(204.0/255.0) blue:(134.0/255.0) alpha:1.0];
}

@end
