//
//  ViewController.h
//  Sweep
//
//  Created by Thomas DeMeo on 1/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import <ZXingObjC/ZXingObjC.h>

#import "BarcodeCaptureViewController.h"
#import "MFSideMenu.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, SScanDelegate> {
    NSMutableArray *scanHistory;
}

@property(nonatomic, strong) IBOutlet UITableView *scanHistoryTable;

@property (nonatomic, retain) IBOutlet UITextView *resultsView;
@property (nonatomic, strong) NSString *scanDataArchiveString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil scanDataArchiveString:(NSString *) scanDataArchiveString;
- (IBAction)scanPressed:(id)sender;


@end
