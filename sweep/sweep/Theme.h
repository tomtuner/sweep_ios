//
//  Theme.h
//  rit_bus
//
//  Created by Thomas DeMeo on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@protocol Theme <NSObject>

- (UIColor *)mainColor;
- (UIColor *)highlightColor;
- (UIColor *)shadowColor;
- (UIColor *)backgroundColor;

- (UIColor *)baseTintColor;
- (UIColor *)accentTintColor;

- (UIColor *)customerPrimaryColor;
- (UIColor *)customerSecondaryColor;

- (UIColor *)cameraOverlayBackgroundColor;

- (UIColor *)navigationTintColor;

- (UIColor *)switchThumbColor;
- (UIColor *)switchOnColor;
- (UIColor *)switchTintColor;

- (CGSize)shadowOffset;

- (UIImage *)topShadow;
- (UIImage *)bottomShadow;

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;
- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

- (UIImage *)toolbarBackgroundForBarMetrics:(UIBarMetrics)metrics;

- (UIImage *)searchBackground;
- (UIImage *)searchFieldImage;
- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state;
- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state;
- (UIImage *)searchScopeButtonDivider;

- (UIImage *)segmentedBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)segmentedDividerForBarMetrics:(UIBarMetrics)barMetrics;

- (UIImage *)tableBackground;

- (UIImage *)onSwitchImage;
- (UIImage *)offSwitchImage;

- (UIImage *)sliderThumbForState:(UIControlState)state;
- (UIImage *)sliderMinTrack;
- (UIImage *)sliderMaxTrack;
- (UIImage *)speedSliderMinImage;
- (UIImage *)speedSliderMaxImage;

- (UIImage *)progressTrackImage;
- (UIImage *)progressProgressImage;

- (UIImage *)stepperBackgroundForState:(UIControlState)state;
- (UIImage *)stepperDividerForState:(UIControlState)state;
- (UIImage *)stepperIncrementImage;
- (UIImage *)stepperDecrementImage;

- (UIImage *)buttonBackgroundForState:(UIControlState)state;

- (UIImage *)tabBarBackground;
- (UIImage *)tabBarSelectionIndicator;
- (UIFont *)customFontWithSize:(CGFloat)fontSize;
- (UIImageView *) customNavigationBarTitleView:(UIBarMetrics)metrics;

- (UIImage *) customerTopCameraMaskImage;
- (UIImage *) customerBottomCameraMaskImage;

- (NSNumber *) percentageIDAvailable;

- (NSNumber *) lengthOfValidID;
- (NSString *) themeName;

// One of these must return a non-nil image for each tab:
//- (UIImage *)imageForTab:(SSThemeTab)tab;
//- (UIImage *)finishedImageForTab:(SSThemeTab)tab selected:(BOOL)selected;

- (UIImage *)doorImageForState:(UIControlState)state;

@end

@interface ThemeManager : NSObject

+ (id <Theme>)sharedTheme;

+ (id <Theme>)updateTheme;

+ (void)customizeAppAppearance;
+ (void)customizeView:(UIView *)view;
+ (void)customizeTableView:(UITableView *)tableView;
+ (void) customizeLabelWithCustomFont:(UILabel *)label;
+ (void) customizeButtonWithCustomFont:(UIButton *)button;
+ (void) customizeNavigationControllerTitleView:(UINavigationController *) navController barMetrics:(UIBarMetrics) metrics;

//+ (void)customizeTabBarItem:(UITabBarItem *)item forTab:(SSThemeTab)tab;

@end
