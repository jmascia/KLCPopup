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

static NSInteger const kMaskPickerTag = 1001;
static NSInteger const kShowPickerTag = 1002;
static NSInteger const kHidePickerTag = 1003;
static NSInteger const kHorizontalPickerTag = 1004;
static NSInteger const kVerticalPickerTag = 1005;

static NSInteger const kFieldTitleTag = 1101;
static NSInteger const kFieldDetailTag = 1102;

static void *kFieldButtonObservingContext = &kFieldButtonObservingContext;


@interface ViewController () {
  
  KLCPopupHorizontalLayout _selectedHorizontalLayout;
  KLCPopupVerticalLayout _selectedVerticalLayout;
  KLCPopupMaskType _selectedMaskType;
  KLCPopupShowType _selectedShowType;
  KLCPopupHideType _selectedHideType;
  
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
  
  NSArray* _horizontalLayouts;
  NSArray* _verticalLayouts;
  NSArray* _maskTypes;
  NSArray* _showTypes;
  NSArray* _hideTypes;
}

- (void)updateLabelsForState;
- (NSInteger)valueForRow:(NSInteger)row inList:(NSArray*)list;
- (NSString*)nameForHorizontalLayout:(KLCPopupHorizontalLayout)horizontalLayout;
- (NSString*)nameForVerticalLayout:(KLCPopupVerticalLayout)verticalLayout;
- (NSString*)nameForMaskType:(KLCPopupMaskType)maskType;
- (NSString*)nameForShowType:(KLCPopupShowType)showType;
- (NSString*)nameForHideType:(KLCPopupHideType)hideType;

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
    
    _selectedMaskType = KLCPopupMaskTypeClear;
    _selectedHorizontalLayout = KLCPopupHorizontalLayoutCenter;
    _selectedVerticalLayout = KLCPopupVerticalLayoutCenter;
    _selectedShowType = KLCPopupShowTypeBounceInFromTop;
    _selectedHideType = KLCPopupHideTypeBounceOutToBottom;
    
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
                   @(KLCPopupHideTypeBounceOutToTop),
                   @(KLCPopupHideTypeBounceOutToBottom),
                   @(KLCPopupHideTypeBounceOutToLeft),
                   @(KLCPopupHideTypeBounceOutToRight)];
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
  [horizontalButton addObserver:self forKeyPath:@"highlighted" options:0 context:kFieldButtonObservingContext];
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
  [verticalButton addObserver:self forKeyPath:@"highlighted" options:0 context:kFieldButtonObservingContext];
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
  [maskTypeButton addObserver:self forKeyPath:@"highlighted" options:0 context:kFieldButtonObservingContext];
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
  [showTypeButton addObserver:self forKeyPath:@"highlighted" options:0 context:kFieldButtonObservingContext];
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
  [hideTypeButton addObserver:self forKeyPath:@"highlighted" options:0 context:kFieldButtonObservingContext];
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
  
  // PRESENT
  UIButton* showButton = [UIButton buttonWithType:UIButtonTypeCustom];
  showButton.translatesAutoresizingMaskIntoConstraints = NO;
  showButton.contentEdgeInsets = UIEdgeInsetsMake(9, 24, 9, 24);
  [showButton setTitle:@"Show" forState:UIControlStateNormal];
  showButton.backgroundColor = [UIColor lightGrayColor];
  [showButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [showButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  showButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  [showButton.layer setCornerRadius:6.0];
  [showButton addTarget:self action:@selector(showButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  // View hierarchy
  [self.view addSubview:spacer1];
  [self.view addSubview:spacer2];
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
  [self.view addSubview:showButton];
  
  // Set high level AutoLayout constraints
  NSDictionary* views = NSDictionaryOfVariableBindings(spacer1,
                                                       spacer2,
                                                       horizontalButton,
                                                       verticalButton,
                                                       maskTypeButton,
                                                       showTypeButton,
                                                       hideTypeButton,
                                                       backgroundContainer,
                                                       contentContainer,
                                                       showButton);
  NSDictionary* metrics = @{@"minHSpacing" : @20.0,
                            @"fieldVSpacing" : @10.0};
  
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spacer1][horizontalButton]-(fieldVSpacing)-[verticalButton]-(fieldVSpacing)-[maskTypeButton]-(fieldVSpacing)-[showTypeButton]-(fieldVSpacing)-[hideTypeButton]-(fieldVSpacing)-[backgroundContainer]-(fieldVSpacing)-[contentContainer]"
                                           options:(NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight)
                                           metrics:metrics
                                             views:views]];
  
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentContainer]-(20)-[showButton][spacer2(==spacer1)]|"
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
  if (sender == _horizontalButton) {
    _pickerView.tag = kHorizontalPickerTag;
    rowToSelect = [_horizontalLayouts indexOfObject:@(_selectedHorizontalLayout)];
    
  } else if (sender == _verticalButton) {
    _pickerView.tag = kVerticalPickerTag;
    rowToSelect = [_verticalLayouts indexOfObject:@(_selectedVerticalLayout)];
    
  } else if (sender == _maskTypeButton) {
    _pickerView.tag = kMaskPickerTag;
    rowToSelect = [_maskTypes indexOfObject:@(_selectedMaskType)];
    
  } else if (sender == _showTypeButton) {
    _pickerView.tag = kShowPickerTag;
    rowToSelect = [_showTypes indexOfObject:@(_selectedShowType)];
    
  } else if (sender == _hideTypeButton) {
    _pickerView.tag = kHidePickerTag;
    rowToSelect = [_showTypes indexOfObject:@(_selectedHideType)];
  }
  [_pickerView reloadAllComponents];
  [_pickerView selectRow:rowToSelect inComponent:0 animated:NO];
  
  // Show field's title text
  if ([sender isKindOfClass:[UIView class]]) {
    UIView* view = [(UIView*)sender viewWithTag:kFieldTitleTag];
    if ([view isKindOfClass:[UILabel class]]) {
      _pickerLabel.text = ((UILabel*)view).text;
    }
  }
  
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

- (void)showButtonPressed:(id)sender {
  
  UIView* contentView = [[UIView alloc] init];
  contentView.backgroundColor = [UIColor purpleColor];
  contentView.frame = CGRectMake(0, 0, 100, 100);
  
  KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                          showType:_selectedShowType
                                          hideType:_selectedHideType
                                          maskType:_selectedMaskType];
  
  popup.horizontalLayout = _selectedHorizontalLayout;
  popup.verticalLayout = _selectedVerticalLayout;
  popup.shouldHideOnBackgroundTouch = _backgroundSwitch.on;
  popup.shouldHideOnContentTouch = _contentSwitch.on;
  [popup show];
  //[popup showWithDuration:0.5];
}

- (void)pickerDoneButtonPressed:(id)sender {
  [_pickerView hidePresentingPopup];
}

#pragma mark - Private

- (void)updateLabelsForState {
  [(UILabel*)[_horizontalButton viewWithTag:kFieldDetailTag] setText:[self nameForHorizontalLayout:_selectedHorizontalLayout]];
  [(UILabel*)[_verticalButton viewWithTag:kFieldDetailTag] setText:[self nameForVerticalLayout:_selectedVerticalLayout]];
  [(UILabel*)[_maskTypeButton viewWithTag:kFieldDetailTag] setText:[self nameForMaskType:_selectedMaskType]];
  [(UILabel*)[_showTypeButton viewWithTag:kFieldDetailTag] setText:[self nameForShowType:_selectedShowType]];
  [(UILabel*)[_hideTypeButton viewWithTag:kFieldDetailTag] setText:[self nameForHideType:_selectedHideType]];
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


- (NSString*)nameForHorizontalLayout:(KLCPopupHorizontalLayout)horizontalLayout {
  NSString* name = nil;
  switch (horizontalLayout) {
    case KLCPopupHorizontalLayoutLeft:
      name = @"Left";
      break;
    case KLCPopupHorizontalLayoutLeftOfCenter:
      name = @"Left of Center";
      break;
    case KLCPopupHorizontalLayoutCenter:
      name = @"Center";
      break;
    case KLCPopupHorizontalLayoutRightOfCenter:
      name = @"Right of Center";
      break;
    case KLCPopupHorizontalLayoutRight:
      name = @"Right";
      break;
    default:
      break;
  }
  return name;
}

- (NSString*)nameForVerticalLayout:(KLCPopupVerticalLayout)verticalLayout {
  NSString* name = nil;
  switch (verticalLayout) {
    case KLCPopupVerticalLayoutTop:
      name = @"Top";
      break;
    case KLCPopupVerticalLayoutAboveCenter:
      name = @"Above Center";
      break;
    case KLCPopupVerticalLayoutCenter:
      name = @"Center";
      break;
    case KLCPopupVerticalLayoutBelowCenter:
      name = @"Below Center";
      break;
    case KLCPopupVerticalLayoutBottom:
      name = @"Bottom";
      break;
    default:
      break;
  }
  return name;
}

- (NSString*)nameForMaskType:(KLCPopupMaskType)maskType {
  NSString* name = nil;
  switch (maskType) {
    case KLCPopupMaskTypeNone:
      name = @"None";
      break;
    case KLCPopupMaskTypeClear:
      name = @"Clear";
      break;
    case KLCPopupMaskTypeDimmed:
      name = @"Dimmed";
      break;
    default:
      break;
  }
  return name;
}

- (NSString*)nameForShowType:(KLCPopupShowType)showType {
  NSString* name = nil;
  switch (showType) {
    case KLCPopupShowTypeNone:
      name = @"None";
      break;
    case KLCPopupShowTypeFadeIn:
      name = @"Fade in";
      break;
    case KLCPopupShowTypeGrowIn:
      name = @"Grow in";
      break;
    case KLCPopupShowTypeShrinkIn:
      name = @"Shrink in";
      break;
    case KLCPopupShowTypeSlideInFromTop:
      name = @"Slide from Top";
      break;
    case KLCPopupShowTypeSlideInFromBottom:
      name = @"Slide from Bottom";
      break;
    case KLCPopupShowTypeSlideInFromLeft:
      name = @"Slide from Left";
      break;
    case KLCPopupShowTypeSlideInFromRight:
      name = @"Slide from Right";
      break;
    case KLCPopupShowTypeBounceInFromTop:
      name = @"Bounce from Top";
      break;
    case KLCPopupShowTypeBounceInFromBottom:
      name = @"Bounce from Bottom";
      break;
    case KLCPopupShowTypeBounceInFromLeft:
      name = @"Bounce from Left";
      break;
    case KLCPopupShowTypeBounceInFromRight:
      name = @"Bounce from Right";
    default:
      break;
  }
  return name;
}

- (NSString*)nameForHideType:(KLCPopupHideType)hideType {
  NSString* name = nil;
  switch (hideType) {
    case KLCPopupHideTypeNone:
      name = @"None";
      break;
    case KLCPopupHideTypeFadeOut:
      name = @"Fade out";
      break;
    case KLCPopupHideTypeGrowOut:
      name = @"Grow out";
      break;
    case KLCPopupHideTypeShrinkOut:
      name = @"Shrink out";
      break;
    case KLCPopupHideTypeSlideOutToTop:
      name = @"Slide to Top";
      break;
    case KLCPopupHideTypeSlideOutToBottom:
      name = @"Slide to Bottom";
      break;
    case KLCPopupHideTypeSlideOutToLeft:
      name = @"Slide to Left";
      break;
    case KLCPopupHideTypeSlideOutToRight:
      name = @"Slide to Right";
      break;
    case KLCPopupHideTypeBounceOutToTop:
      name = @"Bounce to Top";
      break;
    case KLCPopupHideTypeBounceOutToBottom:
      name = @"Bounce to Bottom";
      break;
    case KLCPopupHideTypeBounceOutToLeft:
      name = @"Bounce to Left";
      break;
    case KLCPopupHideTypeBounceOutToRight:
      name = @"Bounce to Right";
    default:
      break;
  }
  return name;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  
  if (component == 0) {
    
    if (pickerView.tag == kHorizontalPickerTag) {
      return _horizontalLayouts.count;
      
    } else if (pickerView.tag == kVerticalPickerTag) {
      return _verticalLayouts.count;
      
    } else if (pickerView.tag == kMaskPickerTag) {
      return _maskTypes.count;
      
    } else if (pickerView.tag == kShowPickerTag) {
      return _showTypes.count;
      
    } else if (pickerView.tag == kHidePickerTag) {
      return _hideTypes.count;
    }
  }
  return 0;
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  
  if (pickerView.tag == kHorizontalPickerTag) {
    return [self nameForHorizontalLayout:[self valueForRow:row inList:_horizontalLayouts]];
    
  } else if (pickerView.tag == kVerticalPickerTag) {
    return [self nameForVerticalLayout:[self valueForRow:row inList:_verticalLayouts]];
    
  } else if (pickerView.tag == kMaskPickerTag) {
    return [self nameForMaskType:[self valueForRow:row inList:_maskTypes]];
    
  } else if (pickerView.tag == kShowPickerTag) {
    return [self nameForShowType:[self valueForRow:row inList:_showTypes]];
    
  } else if (pickerView.tag == kHidePickerTag) {
    return [self nameForHideType:[self valueForRow:row inList:_hideTypes]];
  }
  return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  
  if (pickerView.tag == kHorizontalPickerTag) {
    _selectedHorizontalLayout = [self valueForRow:row inList:_horizontalLayouts];
    
  } else if (pickerView.tag == kVerticalPickerTag) {
    _selectedVerticalLayout = [self valueForRow:row inList:_verticalLayouts];
    
  } else if (pickerView.tag == kMaskPickerTag) {
    _selectedMaskType = [self valueForRow:row inList:_maskTypes];
    
  } else if (pickerView.tag == kShowPickerTag) {
    _selectedShowType = [self valueForRow:row inList:_showTypes];
    
  } else if (pickerView.tag == kHidePickerTag) {
    _selectedHideType = [self valueForRow:row inList:_hideTypes];
  }
}

#pragma mark - <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == kFieldButtonObservingContext ) {

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
  }
}

@end
