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
//    [self.scanEventListTable setSeparatorColor:[UIColor darkGrayColor]];

    [self.scanEventListTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
//    [self tableView:self.scanEventListTable didSelectRowAtIndexPath:0];
}


- (SScanEvent *) getInitialScanEvent
{
    SScanEvent *eve = nil;
    if (self.scanLists.count != 0) {
        eve = (SScanEvent *)[self.scanLists objectAtIndex:0];
    }
    return eve;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (![textField.text isEqualToString:@""]) {
        SScanEvent *newEvent = [[SScanEvent alloc] init];
    //    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setDateFormat:@"MMMM d ss"];
    //    NSString *dateString = [dateFormat stringFromDate:newEvent.date];
        newEvent.name = textField.text;
        [self.scanLists addObject:newEvent];
        // Save our new scans out to the archive file
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask, YES) objectAtIndex:0];
        NSString *archivePath = [documentsDir stringByAppendingPathComponent:kScanListArchiveName];
        [NSKeyedArchiver archiveRootObject:self.scanLists toFile:archivePath];
        [self.scanEventListTable reloadData];
        
    }
    // Release the keyboard
    self.scanEventListTable.frame = CGRectMake(self.scanEventListTable.frame.origin.x, self.scanEventListTable.frame.origin.y, self.scanEventListTable.frame.size.width, self.scanEventListTable.frame.size.height + KEYBOARDHEIGHT);
    [self.scanEventListTable reloadData];
    [textField resignFirstResponder];
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    SideMenuTableViewCell *cell = (SideMenuTableViewCell*) [[textField superview] superview];
    [self.scanEventListTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scanLists.count inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark - UITableViewDataSource

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.scanLists.count)
        return UITableViewCellEditingStyleInsert;
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return [UIView new];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"Scan Count: %i", [self.scanLists count]);
    return self.scanEventListTable.editing ? self.scanLists.count : self.scanLists.count + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // FIXME: This should only happen in else statement, should stay selected during new event
    if (indexPath.row == self.scanLists.count) {
        
        SideMenuTableViewCell *cell = (SideMenuTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.nameLabel setHidden:YES];
        [cell.nameTextField setHidden:NO];
        [cell.nameTextField setSelected:YES];
        
        cell.nameTextField.delegate = self;
        [cell.nameTextField becomeFirstResponder];
        
        // Animate tableview frame change
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            self.scanEventListTable.frame = CGRectMake(self.scanEventListTable.frame.origin.x, self.scanEventListTable.frame.origin.y, self.scanEventListTable.frame.size.width, self.scanEventListTable.frame.size.height - KEYBOARDHEIGHT);
        }
        completion:^(BOOL finished){
            [self.scanEventListTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }];
        
        
        

        /*
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
         */
    }else {

        SScanEvent *eve = (SScanEvent *)[self.scanLists objectAtIndex:indexPath.row];
        NSLog(@"Event Name: %@", eve.name);
        NSLog(@"Event UUID: %@", eve.uuid);
        EventValuesViewController *viewController = [[EventValuesViewController alloc] initWithNibName:@"EventValuesViewController" bundle:nil scanDataArchiveString:eve.uuid];
        viewController.title = eve.name;
        
        NSArray *controllers = [NSArray arrayWithObject:viewController];
        [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
            ((UINavigationController *)controller.centerController).viewControllers = controllers;
            // ...
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"SideMenuTableViewCell";
    BOOL addCell = (indexPath.row == self.scanLists.count);
    
	SideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[SideMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSArray *topLevel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        //topLevel = [[NSBundle mainBundle] loadNibNamed:iPadCellClassName owner:self options:nil];
        
    }else {
        topLevel = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
    }
    for (id currentObject in topLevel) {
        if ([currentObject isKindOfClass:[UITableViewCell class]]) {
            cell = (SideMenuTableViewCell *) currentObject;
            break;
        }
    }
	
	// Get the barcodeResult that has the data backing this cell
//	NSMutableDictionary *scanSession = [self.scanLists objectAtIndex:indexPath.section];
//    [ThemeManager customizeLabelWithCustomFont:cell.nameLabel];
    if (addCell) {
        cell.nameLabel.text = @"Add an event...";
    }else {
        SScanEvent *scanEvent = [self.scanLists objectAtIndex:indexPath.row];
        cell.nameLabel.text = scanEvent.name;
    }
	
    return cell;
}



@end
