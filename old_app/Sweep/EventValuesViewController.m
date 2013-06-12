//
//  ViewController.m
//  Sweep
//
//  Created by Thomas DeMeo on 1/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "EventValuesViewController.h"


@interface EventValuesViewController ()



@end

@implementation EventValuesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil scanDataArchiveString:(NSString *) scanDataArchiveString {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        self.scanDataArchiveString = scanDataArchiveString;
		// Load in any saved scan history we may have
		@try {
    		NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                          NSUserDomainMask, YES) objectAtIndex:0];
            NSLog(@"Scan Data Archive String: %@", self.scanDataArchiveString);
			NSString *archivePath = [documentsDir stringByAppendingPathComponent:self.scanDataArchiveString];
			scanHistory = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
		}
		@catch (...)
		{
            NSLog(@"Exception unarchiving file.");
    	}
        /*
        // Set up swipe from bottom geasture
        UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleLeftSwipe:)];
        swipeUpRecognizer.numberOfTouchesRequired = 2;
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeUpRecognizer];
*/
        
//        pickerController = [[BarcodePickerController alloc] init];
//        [pickerController setDelegate:self];
        
		if (!scanHistory) {
			scanHistory = [[NSMutableArray alloc] init];
        }
        
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:)
//                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	
	return self;
}

- (void)setupMenuBarButtonItems {

    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];

    
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStyleBordered
            target:self.viewDeckController
            action:@selector(toggleLeftView)];
}


- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithTitle:@"Scan" style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(scanPressed:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self leftMenuBarButtonItem];
    [self setupMenuBarButtonItems];
}

- (IBAction)scanPressed:(id)sender {
	
    BarcodeCaptureViewController *vc = [[BarcodeCaptureViewController alloc] initWithNibName:@"BarcodeCaptureViewController" bundle:nil];
    vc.delegate = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//            [vc.capture start];
//        
//    });
    [self presentViewController:vc animated:NO completion:nil];
}

-(IBAction)emailButtonPressed {
    NSString *csvFullString = [scanHistory componentsJoinedByString:@","];
    NSLog(@"csvFullString:%@",csvFullString);
    NSMutableString *csvString = [NSMutableString string];
    
    for (int i = 0; i < [scanHistory count]; i++) {
        [csvString appendString:[[scanHistory objectAtIndex:i] text]];
        if ([scanHistory count] > i+1) {
            [csvString appendString:@", "];
        }
    }
    NSLog(@"csvString:%@",csvString);
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"CSV File"];
    [mailer addAttachmentData:[csvString dataUsingEncoding:NSUTF8StringEncoding]
                     mimeType:@"text/csv"
                     fileName:@"Event Attendies.csv"];
    [self presentViewController:mailer animated:YES completion:nil];
}

- (void)handleDoubleLeftSwipe:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Double left Swipe!");
    
// TODO: AlertView Should go here
    [self clearScannedCodes];
    
    // Save our new scans out to the archive file
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
    NSString *archivePath = [documentsDir stringByAppendingPathComponent:self.scanDataArchiveString];
    [NSKeyedArchiver archiveRootObject:scanHistory toFile:archivePath];
}

- (void) clearScannedCodes {
    [scanHistory removeAllObjects];
	[self.scanHistoryTable reloadData];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - SScanDelegate

- (void) barcodeCaptureController:(BarcodeCaptureViewController *)controller scanResults:(NSArray *)barcodeResult
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	
	// Restore main screen (and restore title bar for 3.0)
    [self dismissViewControllerAnimated:NO completion:^(void) {
        if (barcodeResult && [barcodeResult count])
        {
            NSMutableDictionary *scanSession = [[NSMutableDictionary alloc] init];
            [scanSession setObject:[NSDate date] forKey:@"Session End Time"];
            [scanSession setObject:barcodeResult forKey:@"Scanned Items"];
            NSLog(@"Keys: %@ Values: %@", [scanSession allKeys], [scanSession allValues]);
            
            for( NSObject *bar in barcodeResult ) {
                [scanHistory insertObject:bar atIndex:0];
            }
            
            //            [scanHistory insertObject:scanSession atIndex:0];
            
            // Save our new scans out to the archive file
            NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                          NSUserDomainMask, YES) objectAtIndex:0];
            NSString *archivePath = [documentsDir stringByAppendingPathComponent:self.scanDataArchiveString];
            [NSKeyedArchiver archiveRootObject:scanHistory toFile:archivePath];
            
            [self.scanHistoryTable reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Scan Count: %i", [scanHistory count]);
	return [scanHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SBarcodeResult"];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"SBarcodeResult"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	// Get the barcodeResult that has the data backing this cell
//	NSMutableDictionary *scanSession = [scanHistory objectAtIndex:indexPath.section];
	ZXResult *barcode = [scanHistory objectAtIndex:indexPath.row];
    SBarcodeResult *bc = [scanHistory objectAtIndex:indexPath.row];
    cell.textLabel.text = bc.text;
	
    return cell;
}

@end
