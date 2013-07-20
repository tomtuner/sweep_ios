//
//  SideMenuViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "Events.h"
#import "ScansViewController.h"
#import "IIViewDeckController.h"
#import "SideMenuTableViewCell.h"

@interface SideMenuViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) ScansViewController *scansViewController;

@property(nonatomic, strong) IBOutlet UITableView *eventsTable;
@property(nonatomic, strong) IBOutlet UIView *overlayView;

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) UIActivityIndicatorView *eventRefreshNetworkIndicator;

@end
