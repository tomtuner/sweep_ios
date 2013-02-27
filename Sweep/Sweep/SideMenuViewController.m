//
//  SideMenuViewController.m
//  Sweep
//
//  Created by Thomas DeMeo on 2/8/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@property(nonatomic, strong) NSMutableArray *scanLists;


@end

@implementation SideMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        @try {
    		NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                          NSUserDomainMask, YES) objectAtIndex:0];
			NSString *archivePath = [documentsDir stringByAppendingPathComponent:kScanListArchiveName];
			self.scanLists = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
		}
		@catch (...)
		{
            NSLog(@"Exception unarchiving file.");
    	}
        
		if (!self.scanLists) {
			self.scanLists = [[NSMutableArray alloc] init];
        }
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.navBar setTintColor:[UIColor lightGrayColor]];
    [self tableView:self.view didSelectRowAtIndexPath:0];
}

#pragma mark - UITableViewDataSource

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.scanLists.count)
        return UITableViewCellEditingStyleInsert;
    return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Scan Count: %i", [self.scanLists count]);
    return self.scanEventListTable.editing ? self.scanLists.count : self.scanLists.count + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.scanLists.count) {
        SScanEvent *newEvent = [[SScanEvent alloc] init];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMMM d ss"];
        NSString *dateString = [dateFormat stringFromDate:newEvent.date];
        newEvent.name = dateString;
        [self.scanLists addObject:newEvent];
        // Save our new scans out to the archive file
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask, YES) objectAtIndex:0];
        NSString *archivePath = [documentsDir stringByAppendingPathComponent:kScanListArchiveName];
        [NSKeyedArchiver archiveRootObject:self.scanLists toFile:archivePath];
        [self.scanEventListTable reloadData];
    }else {
        SScanEvent *eve = (SScanEvent *)[self.scanLists objectAtIndex:indexPath.row];
        NSLog(@"Event Name: %@", eve.name);
        NSLog(@"Event UUID: %@", eve.uuid);
        ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil scanDataArchiveString:eve.uuid];
        viewController.title = eve.name;
        
        NSArray *controllers = [NSArray arrayWithObject:viewController];
        self.sideMenu.navigationController.viewControllers = controllers;
        [self.sideMenu setMenuState:MFSideMenuStateClosed];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"SSideMenuCell";
    BOOL addCell = (indexPath.row == self.scanLists.count);
    if (addCell) {
//        CellIdentifier = @"AddCell";
    }
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
	
	// Get the barcodeResult that has the data backing this cell
//	NSMutableDictionary *scanSession = [self.scanLists objectAtIndex:indexPath.section];
    
    if (addCell) {
        cell.textLabel.text = @"Add an event";
    }else {
        SScanEvent *scanEvent = [self.scanLists objectAtIndex:indexPath.row];
        cell.textLabel.text = scanEvent.name;
    }
	
    return cell;
}



@end
