//
//  SideMenuViewController.h
//  Sweep
//
//  Created by Thomas DeMeo on 2/8/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "MFSideMenu.h"
#import "SScanEvent.h"
#import "Theme.h"
#import "IIViewDeckController.h"
#import "SideMenuTableViewCell.h"

#define KEYBOARDHEIGHT 216
#define kScanListArchiveName @"SScanListArchiveName"

@interface SideMenuViewController : UIViewController <UITextFieldDelegate>

//@property (nonatomic, assign) MFSideMenu *sideMenu;

@property(nonatomic, strong) IBOutlet UITableView *scanEventListTable;
@property(nonatomic, strong) IBOutlet UINavigationBar *navBar;

- (SScanEvent *) getInitialScanEvent;

@end
