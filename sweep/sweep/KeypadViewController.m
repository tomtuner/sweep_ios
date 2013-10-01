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
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation KeypadViewController


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(NSUInteger) supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
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
//    [self setupMenuBarButtonItems];

    [self changeButtonType];
    UIImage *navCenter = [UIImage imageNamed:@"nav_bar_logo"];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:navCenter];
    [self.navBar.topItem setTitleView:titleView];
    [self setDoneButtonStatus];
    
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];

    
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
    _doneButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(donePressed)];
    return _doneButton;
}

- (void) setDoneButtonStatus
{
    if (self.idLabel.text.length != 0) {
        _doneButton.enabled = YES;
    }else {
        _doneButton.enabled = NO;
    }
}

- (IBAction)keySelected:(id)sender
{
    UIButton *keypadButton = (UIButton *) sender;
    if (self.idLabel.text.length < 15)
    {
        self.idLabel.text = [NSString stringWithFormat:@"%@%@", self.idLabel.text, keypadButton.titleLabel.text];
    }
    [self setDoneButtonStatus];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    if (self.idLabel.text.length > 0)
    {
        self.idLabel.text = [self.idLabel.text substringToIndex:self.idLabel.text.length - 1];
        [self setDoneButtonStatus];
    }
}

-(IBAction) donePressed
{
    NSString *idScanned = self.idLabel.text;
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if (idScanned.length >= [[[ThemeManager sharedTheme] lengthOfValidID] integerValue])
    {
        idScanned = [idScanned substringToIndex: [[[ThemeManager sharedTheme] lengthOfValidID] integerValue]];
    }
    
    if ([idScanned rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
#if !(TARGET_IPHONE_SIMULATOR)
        // Vibrate
        [self playSoundAndVibrate];
#endif
        
        Scans *newScan = [NSEntityDescription insertNewObjectForEntityForName:@"Scans" inManagedObjectContext:self.managedObjectContext];
        newScan.value = idScanned;
        //            newScan.scanned_at = result.timestamp;
        newScan.event_id = self.event.remote_id;
        newScan.sync_status = [NSNumber numberWithInt:SWObjectCreated];

        NSError *error = nil;
        BOOL saved = [self.managedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save Event due to %@", error);
        }
        
        [[SWCoreDataController sharedInstance] saveMasterContext];
    }
    // Add check to see if anything should be entered
    [self dismissViewControllerAnimated:YES completion:^{
        [[SWSyncEngine sharedEngine] startSync];
    }];
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

- (void) playSoundAndVibrate
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    // Get the main bundle for the app
    CFBundleRef mainBundle = CFBundleGetMainBundle ();
    
    // Get the URL to the sound file to play. The file in this case
    // is "tap.aif"
    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (
                                                         mainBundle,
                                                         CFSTR ("DING"),
                                                         CFSTR ("caf"),
                                                         NULL
                                                         );
    
    // Create a system sound object representing the sound file
    SystemSoundID soundFileObject;
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    // Play the sound
    AudioServicesPlaySystemSound (soundFileObject);
    
    // And Vibrate if possible
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
}

@end