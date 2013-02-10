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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Scan Count: %i", [self.scanLists count]);
	return [self.scanLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BarcodeResult"];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"BarcodeResult"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	// Get the barcodeResult that has the data backing this cell
	NSMutableDictionary *scanSession = [self.scanLists objectAtIndex:indexPath.section];
	ZXResult *barcode = [self.scanLists objectAtIndex:indexPath.row];
    
    cell.textLabel.text = barcode.text;
	
    return cell;
}

@end
