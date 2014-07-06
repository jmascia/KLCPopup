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
#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSInteger, FieldTag) {
  FieldTagHorizontalLayout = 1001,
  FieldTagVerticalLayout,
  FieldTagMaskType,
  FieldTagShowType,
  FieldTagDismissType,
  FieldTagBackgroundDismiss,
  FieldTagContentDismiss,
  FieldTagTimedDismiss,
};


typedef NS_ENUM(NSInteger, CellType) {
  CellTypeNormal = 0,
  CellTypeSwitch,
};


@interface ViewController () {
  
  NSArray* _fields;
  NSDictionary* _namesForFields;
  
  NSArray* _horizontalLayouts;
  NSArray* _verticalLayouts;
  NSArray* _maskTypes;
  NSArray* _showTypes;
  NSArray* _dismissTypes;
  
  NSDictionary* _namesForHorizontalLayouts;
  NSDictionary* _namesForVerticalLayouts;
  NSDictionary* _namesForMaskTypes;
  NSDictionary* _namesForShowTypes;
  NSDictionary* _namesForDismissTypes;
  
  NSInteger _selectedRowInHorizontalField;
  NSInteger _selectedRowInVerticalField;
  NSInteger _selectedRowInMaskField;
  NSInteger _selectedRowInShowField;
  NSInteger _selectedRowInDismissField;
  BOOL _shouldDismissOnBackgroundTouch;
  BOOL _shouldDismissOnContentTouch;
  BOOL _shouldDismissAfterDelay;
}

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIPopoverController* popover;

// Private
- (void)updateFieldTableView:(UITableView*)tableView;
- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag;
- (NSInteger)selectedRowForFieldWithTag:(NSInteger)tag;
- (NSString*)nameForValue:(NSInteger)value inFieldWithTag:(NSInteger)tag;
- (CellType)cellTypeForFieldWithTag:(NSInteger)tag;

// Event handlers
- (void)toggleValueDidChange:(id)sender;
- (void)showButtonPressed:(id)sender;
- (void)dismissButtonPressed:(id)sender;
- (void)fieldCancelButtonPressed:(id)sender;

@end


@interface UIColor (KLCPopupExample)
+ (UIColor*)klcLightGreenColor;
+ (UIColor*)klcGreenColor;
@end


@interface UIView (KLCPopupExample)
- (UITableViewCell*)parentCell;
@end



@implementation ViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    self.title = @"KLCPopup Example";
    
    // MAIN LIST
    _fields = @[@(FieldTagHorizontalLayout),
                @(FieldTagVerticalLayout),
                @(FieldTagMaskType),
                @(FieldTagShowType),
                @(FieldTagDismissType),
                @(FieldTagBackgroundDismiss),
                @(FieldTagContentDismiss),
                @(FieldTagTimedDismiss)];
    
    _namesForFields = @{@(FieldTagHorizontalLayout) : @"Horizontal layout",
                        @(FieldTagVerticalLayout) : @"Vertical layout",
                        @(FieldTagMaskType) : @"Background mask",
                        @(FieldTagShowType) : @"Show type",
                        @(FieldTagDismissType) : @"Dismiss type",
                        @(FieldTagBackgroundDismiss) : @"Dismiss on background touch",
                        @(FieldTagContentDismiss) : @"Dismiss on content touch",
                        @(FieldTagTimedDismiss) : @"Dismiss after delay"};
    
    // FIELD SUB-LISTS
    _horizontalLayouts = @[@(KLCPopupHorizontalLayoutLeft),
                           @(KLCPopupHorizontalLayoutLeftOfCenter),
                           @(KLCPopupHorizontalLayoutCenter),
                           @(KLCPopupHorizontalLayoutRightOfCenter),
                           @(KLCPopupHorizontalLayoutRight)];
    
    _namesForHorizontalLayouts = @{@(KLCPopupHorizontalLayoutLeft) : @"Left",
                                   @(KLCPopupHorizontalLayoutLeftOfCenter) : @"Left of Center",
                                   @(KLCPopupHorizontalLayoutCenter) : @"Center",
                                   @(KLCPopupHorizontalLayoutRightOfCenter) : @"Right of Center",
                                   @(KLCPopupHorizontalLayoutRight) : @"Right"};
    
    _verticalLayouts = @[@(KLCPopupVerticalLayoutTop),
                         @(KLCPopupVerticalLayoutAboveCenter),
                         @(KLCPopupVerticalLayoutCenter),
                         @(KLCPopupVerticalLayoutBelowCenter),
                         @(KLCPopupVerticalLayoutBottom)];
    
    _namesForVerticalLayouts = @{@(KLCPopupVerticalLayoutTop) : @"Top",
                                 @(KLCPopupVerticalLayoutAboveCenter) : @"Above Center",
                                 @(KLCPopupVerticalLayoutCenter) : @"Center",
                                 @(KLCPopupVerticalLayoutBelowCenter) : @"Below Center",
                                 @(KLCPopupVerticalLayoutBottom) : @"Bottom"};
    
    _maskTypes = @[@(KLCPopupMaskTypeNone),
                   @(KLCPopupMaskTypeClear),
                   @(KLCPopupMaskTypeDimmed)];
    
    _namesForMaskTypes = @{@(KLCPopupMaskTypeNone) : @"None",
                           @(KLCPopupMaskTypeClear) : @"Clear",
                           @(KLCPopupMaskTypeDimmed) : @"Dimmed"};
    
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
    
    _dismissTypes = @[@(KLCPopupDismissTypeNone),
                      @(KLCPopupDismissTypeFadeOut),
                      @(KLCPopupDismissTypeGrowOut),
                      @(KLCPopupDismissTypeShrinkOut),
                      @(KLCPopupDismissTypeSlideOutToTop),
                      @(KLCPopupDismissTypeSlideOutToBottom),
                      @(KLCPopupDismissTypeSlideOutToLeft),
                      @(KLCPopupDismissTypeSlideOutToRight),
                      @(KLCPopupDismissTypeBounceOut),
                      @(KLCPopupDismissTypeBounceOutToTop),
                      @(KLCPopupDismissTypeBounceOutToBottom),
                      @(KLCPopupDismissTypeBounceOutToLeft),
                      @(KLCPopupDismissTypeBounceOutToRight)];
    
    _namesForDismissTypes = @{@(KLCPopupDismissTypeNone) : @"None",
                              @(KLCPopupDismissTypeFadeOut) : @"Fade out",
                              @(KLCPopupDismissTypeGrowOut) : @"Grow out",
                              @(KLCPopupDismissTypeShrinkOut) : @"Shrink out",
                              @(KLCPopupDismissTypeSlideOutToTop) : @"Slide to Top",
                              @(KLCPopupDismissTypeSlideOutToBottom) : @"Slide to Bottom",
                              @(KLCPopupDismissTypeSlideOutToLeft) : @"Slide to Left",
                              @(KLCPopupDismissTypeSlideOutToRight) : @"Slide to Right",
                              @(KLCPopupDismissTypeBounceOut) : @"Bounce out",
                              @(KLCPopupDismissTypeBounceOutToTop) : @"Bounce to Top",
                              @(KLCPopupDismissTypeBounceOutToBottom) : @"Bounce to Bottom",
                              @(KLCPopupDismissTypeBounceOutToLeft) : @"Bounce to Left",
                              @(KLCPopupDismissTypeBounceOutToRight) : @"Bounce to Right"};
    
    // DEFAULTS
    _selectedRowInHorizontalField = [_horizontalLayouts indexOfObject:@(KLCPopupHorizontalLayoutCenter)];
    _selectedRowInVerticalField = [_verticalLayouts indexOfObject:@(KLCPopupVerticalLayoutCenter)];
    _selectedRowInMaskField = [_maskTypes indexOfObject:@(KLCPopupMaskTypeDimmed)];
    _selectedRowInShowField = [_showTypes indexOfObject:@(KLCPopupShowTypeBounceInFromTop)];
    _selectedRowInDismissField = [_dismissTypes indexOfObject:@(KLCPopupDismissTypeBounceOutToBottom)];
    _shouldDismissOnBackgroundTouch = YES;
    _shouldDismissOnContentTouch = NO;
    _shouldDismissAfterDelay = NO;
  }
  return self;
}


- (void)loadView {
  [super loadView];
  
  // TABLEVIEW
  UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  tableView.translatesAutoresizingMaskIntoConstraints = NO;
  tableView.delegate = self;
  tableView.dataSource = self;
  tableView.delaysContentTouches = NO;
  self.tableView = tableView;
  [self.view addSubview:tableView];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(tableView);
  NSDictionary* metrics = nil;
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:views]];
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|"
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:views]];
  
  // FOOTER
  UIView* footerView = [[UIView alloc] init];
  
  UIButton* showButton = [UIButton buttonWithType:UIButtonTypeCustom];
  showButton.translatesAutoresizingMaskIntoConstraints = NO;
  showButton.contentEdgeInsets = UIEdgeInsetsMake(14, 28, 14, 28);
  [showButton setTitle:@"Show it!" forState:UIControlStateNormal];
  showButton.backgroundColor = [UIColor lightGrayColor];
  [showButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [showButton setTitleColor:[[showButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
  showButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
  [showButton.layer setCornerRadius:8.0];
  [showButton addTarget:self action:@selector(showButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [footerView addSubview:showButton];
  
  CGFloat topMargin = 12.0;
  CGFloat bottomMargin = 12.0;
  
  views = NSDictionaryOfVariableBindings(showButton);
  metrics = @{@"topMargin" : @(topMargin),
              @"bottomMargin" : @(bottomMargin)};
  [footerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topMargin)-[showButton]-(bottomMargin)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
  
  [footerView addConstraint:[NSLayoutConstraint constraintWithItem:showButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:showButton.superview
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
  
  CGRect footerFrame = CGRectZero;
  footerFrame.size = [showButton systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  footerFrame.size.height += topMargin + bottomMargin;
  footerView.frame = footerFrame;
  self.tableView.tableFooterView = footerView;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.automaticallyAdjustsScrollViewInsets = YES;
  self.view.backgroundColor = [UIColor whiteColor];
}


#pragma mark - Event Handlers

- (void)toggleValueDidChange:(id)sender {
  
  if ([sender isKindOfClass:[UISwitch class]]) {
    UISwitch* toggle = (UISwitch*)sender;
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:[toggle parentCell]];
    id obj = [_fields objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSNumber class]]) {
      
      NSInteger fieldTag = [(NSNumber*)obj integerValue];
      if (fieldTag == FieldTagBackgroundDismiss) {
        _shouldDismissOnBackgroundTouch = toggle.on;
        
      } else if (fieldTag == FieldTagContentDismiss) {
        _shouldDismissOnContentTouch = toggle.on;
        
      } else if (fieldTag == FieldTagTimedDismiss) {
        _shouldDismissAfterDelay = toggle.on;
      }
    }
  }
}


- (void)showButtonPressed:(id)sender {
  
  // Generate content view to present
  UIView* contentView = [[UIView alloc] init];
  contentView.translatesAutoresizingMaskIntoConstraints = NO;
  contentView.backgroundColor = [UIColor klcLightGreenColor];
  contentView.layer.cornerRadius = 12.0;
  
  UILabel* dismissLabel = [[UILabel alloc] init];
  dismissLabel.translatesAutoresizingMaskIntoConstraints = NO;
  dismissLabel.backgroundColor = [UIColor clearColor];
  dismissLabel.textColor = [UIColor whiteColor];
  dismissLabel.font = [UIFont boldSystemFontOfSize:72.0];
  dismissLabel.text = @"Hi.";
  
  UIButton* dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
  dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
  dismissButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
  dismissButton.backgroundColor = [UIColor klcGreenColor];
  [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [dismissButton setTitleColor:[[dismissButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
  dismissButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
  [dismissButton setTitle:@"Bye" forState:UIControlStateNormal];
  dismissButton.layer.cornerRadius = 6.0;
  [dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [contentView addSubview:dismissLabel];
  [contentView addSubview:dismissButton];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(contentView, dismissButton, dismissLabel);
  
  [contentView addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(16)-[dismissLabel]-(10)-[dismissButton]-(24)-|"
                                           options:NSLayoutFormatAlignAllCenterX
                                           metrics:nil
                                             views:views]];
  
  [contentView addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(36)-[dismissLabel]-(36)-|"
                                           options:0
                                           metrics:nil
                                             views:views]];
  
  // Show in popup
  KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)[self valueForRow:_selectedRowInHorizontalField inFieldWithTag:FieldTagHorizontalLayout],
                                             (KLCPopupVerticalLayout)[self valueForRow:_selectedRowInVerticalField inFieldWithTag:FieldTagVerticalLayout]);
  
  KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                          showType:(KLCPopupShowType)[self valueForRow:_selectedRowInShowField inFieldWithTag:FieldTagShowType]
                                       dismissType:(KLCPopupDismissType)[self valueForRow:_selectedRowInDismissField inFieldWithTag:FieldTagDismissType]
                                          maskType:(KLCPopupMaskType)[self valueForRow:_selectedRowInMaskField inFieldWithTag:FieldTagMaskType]
                          dismissOnBackgroundTouch:_shouldDismissOnBackgroundTouch
                             dismissOnContentTouch:_shouldDismissOnContentTouch];
  
  if (_shouldDismissAfterDelay) {
    [popup showWithLayout:layout duration:2.0];
  } else {
    [popup showWithLayout:layout];
  }
}


- (void)dismissButtonPressed:(id)sender {
  if ([sender isKindOfClass:[UIView class]]) {
    [(UIView*)sender dismissPresentingPopup];
  }
}


- (void)fieldCancelButtonPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Private

- (void)updateFieldTableView:(UITableView*)tableView {
  
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


- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag {
  
  NSArray* listForField = nil;
  if (tag == FieldTagHorizontalLayout) {
    listForField = _horizontalLayouts;
    
  } else if (tag == FieldTagVerticalLayout) {
    listForField = _verticalLayouts;
    
  } else if (tag == FieldTagMaskType) {
    listForField = _maskTypes;
    
  } else if (tag == FieldTagShowType) {
    listForField = _showTypes;
    
  } else if (tag == FieldTagDismissType) {
    listForField = _dismissTypes;
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
  if (tag == FieldTagHorizontalLayout) {
    return _selectedRowInHorizontalField;
    
  } else if (tag == FieldTagVerticalLayout) {
    return _selectedRowInVerticalField;
    
  } else if (tag == FieldTagMaskType) {
    return _selectedRowInMaskField;
    
  } else if (tag == FieldTagShowType) {
    return _selectedRowInShowField;
    
  } else if (tag == FieldTagDismissType) {
    return _selectedRowInDismissField;
  }
  return NSNotFound;
}


- (NSString*)nameForValue:(NSInteger)value inFieldWithTag:(NSInteger)tag {
  
  NSDictionary* namesForField = nil;
  if (tag == FieldTagHorizontalLayout) {
    namesForField = _namesForHorizontalLayouts;
    
  } else if (tag == FieldTagVerticalLayout) {
    namesForField = _namesForVerticalLayouts;
    
  } else if (tag == FieldTagMaskType) {
    namesForField = _namesForMaskTypes;
    
  } else if (tag == FieldTagShowType) {
    namesForField = _namesForShowTypes;
    
  } else if (tag == FieldTagDismissType) {
    namesForField = _namesForDismissTypes;
  }
  
  if (namesForField != nil) {
    return [namesForField objectForKey:@(value)];
  }
  return nil;
}


- (CellType)cellTypeForFieldWithTag:(NSInteger)tag {
  
  CellType cellType;
  switch (tag) {
    case FieldTagHorizontalLayout:
      cellType = CellTypeNormal;
      break;
    case FieldTagVerticalLayout:
      cellType = CellTypeNormal;
      break;
    case FieldTagMaskType:
      cellType = CellTypeNormal;
      break;
    case FieldTagShowType:
      cellType = CellTypeNormal;
      break;
    case FieldTagDismissType:
      cellType = CellTypeNormal;
      break;
    case FieldTagBackgroundDismiss:
      cellType = CellTypeSwitch;
      break;
    case FieldTagContentDismiss:
      cellType = CellTypeSwitch;
      break;
    case FieldTagTimedDismiss:
      cellType = CellTypeSwitch;
      break;
    default:
      cellType = CellTypeNormal;
      break;
  }
  return cellType;
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  // MAIN TABLE
  if (tableView == self.tableView) {
    return _fields.count;
  }
  
  // FIELD TABLES
  else {
    
    if (tableView.tag == FieldTagHorizontalLayout) {
      return _horizontalLayouts.count;
      
    } else if (tableView.tag == FieldTagVerticalLayout) {
      return _verticalLayouts.count;
      
    } else if (tableView.tag == FieldTagMaskType) {
      return _maskTypes.count;
      
    } else if (tableView.tag == FieldTagShowType) {
      return _showTypes.count;
      
    } else if (tableView.tag == FieldTagDismissType) {
      return _dismissTypes.count;
    }
  }
  
  return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // MAIN TABLE
  if (tableView == self.tableView) {
    
    id obj = [_fields objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSNumber class]]) {
      FieldTag fieldTag = [(NSNumber*)obj integerValue];
      
      UITableViewCell* cell = nil;
      CellType cellType = [self cellTypeForFieldWithTag:fieldTag];
      
      NSString* identifier = @"";
      if (cellType == CellTypeNormal) {
        identifier = @"normal";
      } else if (cellType == CellTypeSwitch) {
        identifier = @"switch";
      }
      
      cell = [tableView dequeueReusableCellWithIdentifier:identifier];
      
      if (nil == cell) {
        UITableViewCellStyle style = UITableViewCellStyleValue1;
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
        UIEdgeInsets newSeparatorInset = cell.separatorInset;
        newSeparatorInset.right = newSeparatorInset.left;
        cell.separatorInset = newSeparatorInset;
        
        if (cellType == CellTypeNormal) {
          cell.selectionStyle = UITableViewCellSelectionStyleGray;
          
        } else if (cellType == CellTypeSwitch) {
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
          UISwitch* toggle = [[UISwitch alloc] init];
          toggle.onTintColor = [UIColor lightGrayColor];
          [toggle addTarget:self action:@selector(toggleValueDidChange:) forControlEvents:UIControlEventValueChanged];
          cell.accessoryView = toggle;
        }
      }
      
      cell.textLabel.text = [_namesForFields objectForKey:@(fieldTag)];
      
      // populate Normal cell
      if (cellType == CellTypeNormal) {
        NSInteger selectedRowInField = [self selectedRowForFieldWithTag:fieldTag];
        if (selectedRowInField != NSNotFound) {
          cell.detailTextLabel.text = [self nameForValue:[self valueForRow:selectedRowInField inFieldWithTag:fieldTag] inFieldWithTag:fieldTag];
        }
      }
      // populate Switch cell
      else if (cellType == CellTypeSwitch) {
        if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
          BOOL on = NO;
          if (fieldTag == FieldTagBackgroundDismiss) {
            on = _shouldDismissOnBackgroundTouch;
          } else if (fieldTag == FieldTagContentDismiss) {
            on = _shouldDismissOnContentTouch;
          } else if (fieldTag == FieldTagTimedDismiss) {
            on = _shouldDismissAfterDelay;
          }
          [(UISwitch*)cell.accessoryView setOn:on];
        }
      }
      
      return cell;
    }
  }
  
  // FIELD TABLES
  else {
    
    UITableViewCell* cell = nil;
    
    Class cellClass = [UITableViewCell class];
    NSString* identifier = NSStringFromClass(cellClass);
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (nil == cell) {
      UITableViewCellStyle style = UITableViewCellStyleDefault;
      cell = [[cellClass alloc] initWithStyle:style reuseIdentifier:identifier];
      UIEdgeInsets newSeparatorInset = cell.separatorInset;
      newSeparatorInset.right = newSeparatorInset.left;
      cell.separatorInset = newSeparatorInset;
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
  
  return nil;
}


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // MAIN TABLE
  if (tableView == self.tableView) {
    
    id obj = [_fields objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSNumber class]]) {
      NSInteger fieldTag = [(NSNumber*)obj integerValue];
      
      if ([self cellTypeForFieldWithTag:fieldTag] == CellTypeNormal) {
        
        UIViewController* fieldController = [[UIViewController alloc] init];
        
        UITableView* fieldTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        fieldTableView.delegate = self;
        fieldTableView.dataSource = self;
        fieldTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        fieldTableView.tag = fieldTag;
        fieldController.view = fieldTableView;
        
        // IPAD
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
          
          // Present in a popover
          UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:fieldController];
          popover.delegate = self;
          self.popover = popover;
          
          // Set KVO so we can adjust the popover's size to fit the table's content once it's populated.
          [fieldTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
          
          CGRect senderFrameInView = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:self.view];
          [popover presentPopoverFromRect:senderFrameInView inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
        // IPHONE
        else {
          
          // Present in a modal
          UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
          fieldController.title = cell.textLabel.text;
          UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(fieldCancelButtonPressed:)];
          fieldController.navigationItem.rightBarButtonItem = cancelButton;
          
          UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:fieldController];
          navigationController.delegate = self;
          [self presentViewController:navigationController animated:YES completion:NULL];
        }
      }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
  
  // FIELD TABLES
  else {
    
    if (tableView.tag == FieldTagHorizontalLayout) {
      _selectedRowInHorizontalField = indexPath.row;
      
    } else if (tableView.tag == FieldTagVerticalLayout) {
      _selectedRowInVerticalField = indexPath.row;
      
    } else if (tableView.tag == FieldTagMaskType) {
      _selectedRowInMaskField = indexPath.row;
      
    } else if (tableView.tag == FieldTagShowType) {
      _selectedRowInShowField = indexPath.row;
      
    } else if (tableView.tag == FieldTagDismissType) {
      _selectedRowInDismissField = indexPath.row;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateFieldTableView:tableView];
    
    [self.tableView reloadData];
    
    // IPAD
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      [self.popover dismissPopoverAnimated:YES];
    }
    // IPHONE
    else {
      [self dismissViewControllerAnimated:YES completion:NULL];
    }
  }
}

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  
  // If this is a field table, make sure the selected row is scrolled into view when it appears.
  if ((navigationController == self.presentedViewController) && [viewController.view isKindOfClass:[UITableView class]]) {
    
    UITableView* fieldTableView = (UITableView*)viewController.view;
    
    NSInteger selectedRow = [self selectedRowForFieldWithTag:fieldTableView.tag];
    if ([fieldTableView numberOfRowsInSection:0] > selectedRow) {
      [fieldTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
  }
}


#pragma mark - <UIPopoverControllerDelegate>

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  
  // Cleanup by removing KVO and reference to popover
  UIView* view = popoverController.contentViewController.view;
  if ([view isKindOfClass:[UITableView class]]) {
    [(UITableView*)view removeObserver:self forKeyPath:@"contentSize"];
  }
  
  self.popover = nil;
}


#pragma mark - <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if ([keyPath isEqualToString:@"contentSize"]) {
    
    if ([object isKindOfClass:[UITableView class]]) {
      UITableView* tableView = (UITableView*)object;
      
      if (self.popover != nil) {
        [self.popover setPopoverContentSize:tableView.contentSize animated:NO];
      }
      
      // Make sure the selected row is scrolled into view when it appears
      NSInteger fieldTag = tableView.tag;
      NSInteger selectedRow = [self selectedRowForFieldWithTag:fieldTag];
      
      if ([tableView numberOfRowsInSection:0] > selectedRow) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
      }
    }
  }
}


@end


#pragma mark - Categories

@implementation UIColor (KLCPopupExample)

+ (UIColor*)klcLightGreenColor {
  return [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
}

+ (UIColor*)klcGreenColor {
  return [UIColor colorWithRed:(0.0/255.0) green:(204.0/255.0) blue:(134.0/255.0) alpha:1.0];
}

@end



@implementation UIView (KLCPopupExample)

- (UITableViewCell*)parentCell {
  
  // Iterate over superviews until you find a UITableViewCell
  UIView* view = self;
  while (view != nil) {
    if ([view isKindOfClass:[UITableViewCell class]]) {
      return (UITableViewCell*)view;
    } else {
      view = [view superview];
    }
  }
  return nil;
}

@end


