//
//  KeypadViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 9/25/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "KeypadViewController.h"

@interface KeypadViewController ()

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *keypadButtons;

@end

@implementation KeypadViewController


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupMenuBarButtonItems];

    [self changeButtonType];
    UIImage *navCenter = [UIImage imageNamed:@"nav_bar_logo"];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:navCenter];
    [self.navBar.topItem setTitleView:titleView];
    
}

- (void)setupMenuBarButtonItems {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(cancelPressed)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithTitle:@"Done" style:UIBarButtonItemStyleDone
            target:self
            action:@selector(donePressed)];
}

-(IBAction) donePressed
{
    // Add check to see if anything should be entered
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction) cancelPressed
{
    // Add check to see if anything should be entered
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) changeButtonType
{
    UIImage *keyImage = [UIImage imageNamed:@"keypad_button"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        keyImage = [keyImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }

    for (UIButton* but in _keypadButtons) {
//        but.tintColor = [UIColor redColor];
        [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [but setImage:keyImage forState:UIControlStateNormal];
        [but setBackgroundImage:keyImage forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
