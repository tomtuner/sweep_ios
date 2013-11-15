//
//  MasterViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "ScansViewController.h"

static NSUInteger kNumberOfPages = 2;


@interface ScansViewController () {
    // UniMag Properties
    uniMag *uniReader;
}

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UILabel *totalScansLabel;
@property (nonatomic, strong) IBOutlet UILabel *uniqueScansLabel;

@property (nonatomic, strong) IBOutlet UIView *headerView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *totalScansIndicator;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uniqueScansIndicator;

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *readerBarButtonItem;

@property (nonatomic, strong) UIButton *readerButton;

@property (nonatomic, strong) UIActivityIndicatorView *scrollView1ActivityIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *scrollView2ActivityIndicator;

@property (nonatomic, strong) UIImageView *arrow1;
@property (nonatomic, strong) UIImageView *arrow2;
@property (nonatomic, strong) UIImageView *arrow3;
@property (nonatomic, strong) UIImageView *arrow4;

@property (nonatomic) BOOL shouldAnimateActivity;

// Table View properties for pull to refresh
@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isLoading;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureView;

@end

@implementation ScansViewController
/*
- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.scansTable.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}
*/



- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.scansTable.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor grayColor];
//    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0,-480,self.view.frame.size.width,480)];
//    topview.backgroundColor = [UIColor blackColor];
    
//    [self.scansTable addSubview:topview];
    
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];

    [self setupMenuBarButtonItems];
    [self configureView];
    [self addPullToRefreshHeader];
    [self setupStrings];
    
    // Activate UniMag SDK
    [self umsdk_activate];

    [self displayLoginControllerIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
        [self stopLoading];
    }];
    
    [self showActivtyIndicatorView];
    
    self.headerView.layer.masksToBounds = NO;
    self.headerView.layer.cornerRadius = 3.0f;
    self.headerView.layer.shadowOpacity = 0.8f;
    self.headerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.headerView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.headerView.layer.shadowRadius = 4.0f;
    
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:6.0
                                              target:self
                                            selector:@selector(animateOddArrows)
                                            userInfo:nil
                                             repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
    [timer1 fire];
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:6.0
                                              target:self
                                            selector:@selector(animateEvenArrows)
                                            userInfo:nil
                                             repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
    [timer2 fire];
    _shouldAnimateActivity = YES;
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_shouldAnimateActivity)
    {
        [self sizeImagesAndContentSize];

        self.scrollView1ActivityIndicator.hidden = NO;
        self.scrollView2ActivityIndicator.hidden = NO;

        [self.scrollView1ActivityIndicator startAnimating];
        [self.scrollView2ActivityIndicator startAnimating];
        _shouldAnimateActivity = NO;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
    {
        [self sizeImagesAndContentSize];
//        self.scrollView1ActivityIndicator.hidden = YES;
//        self.scrollView2ActivityIndicator.hidden = YES;
        self.totalScansLabel.text = [NSString stringWithFormat:@"%i", self.scans.count];
        NSSet *uniqueStates = [NSSet setWithArray:[self.scans valueForKey:@"value"]];
        //        NSLog(@"Unique Entries: %i", uniqueStates.count);
        self.uniqueScansLabel.text = [NSString stringWithFormat:@"%i", uniqueStates.count];

    }
}

- (void) sizeImagesAndContentSize
{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
    {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSString *aggregateText = @"99999";
        UIFont *font = [UIFont boldSystemFontOfSize:20.0f];
        CGSize aggregatelabelSize = [aggregateText sizeWithFont:font];

        for (int i = 0; i < kNumberOfPages; i++) {
            //We'll create an imageView object in every 'page' of our scrollView.
            CGRect frame;
            frame.origin.x = self.scrollView.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = self.scrollView.frame.size;
            
            UIView *view = [[UIView alloc] initWithFrame:frame];
            
            NSString *text;
            
            if (i == 0)
            {
                text = [NSString stringWithFormat:@"Total Attendees:"];
                self.scrollView1ActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - self.scrollView1ActivityIndicator.frame.size.width + 75, self.scrollView.frame.size.height / 2, self.scrollView1ActivityIndicator.frame.size.width, self.scrollView1ActivityIndicator.frame.size.height)];
                self.scrollView1ActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [self.scrollView1ActivityIndicator setHidesWhenStopped:YES];
                [view addSubview:self.scrollView1ActivityIndicator];
                _arrow1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
                _arrow1.frame = CGRectMake(self.scrollView.frame.size.width - (_arrow1.frame.size.width * 2) - 10, (self.scrollView.frame.size.height / 2) - (_arrow1.frame.size.height / 2), _arrow1.frame.size.width, _arrow1.frame.size.height);
                _arrow2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
                _arrow2.frame = CGRectMake(_arrow1.frame.origin.x + 10, (self.scrollView.frame.size.height / 2) - (_arrow2.frame.size.height / 2), _arrow2.frame.size.width, _arrow2.frame.size.height);
                
                _totalScansLabel = [[UILabel alloc] initWithFrame:CGRectMake(_scrollView1ActivityIndicator.frame.origin.x - 10, _scrollView1ActivityIndicator.frame.origin.y - aggregatelabelSize.height / 2, aggregatelabelSize.width, aggregatelabelSize.height)];
                _totalScansLabel.backgroundColor = [UIColor clearColor];

//                _totalScansLabel.hidden = YES;
                [view addSubview:_totalScansLabel];
                [view addSubview:_arrow1];
                [view addSubview:_arrow2];
                
            } else if (i == 1) {
                text = [NSString stringWithFormat:@"Unique Attendees:"];
                self.scrollView2ActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - self.scrollView2ActivityIndicator.frame.size.width + 75, self.scrollView.frame.size.height / 2, self.scrollView2ActivityIndicator.frame.size.width, self.scrollView2ActivityIndicator.frame.size.height)];
                self.scrollView2ActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [self.scrollView2ActivityIndicator setHidesWhenStopped:YES];
                [view addSubview:self.scrollView2ActivityIndicator];
                _arrow3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_left"]];
                _arrow3.frame = CGRectMake(self.scrollView.frame.origin.x + 10, (self.scrollView.frame.size.height / 2) - (_arrow3.frame.size.height / 2), _arrow1.frame.size.width, _arrow3.frame.size.height);
                _arrow4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_left"]];
                _arrow4.frame = CGRectMake(_arrow3.frame.origin.x + 10, (self.scrollView.frame.size.height / 2) - (_arrow4.frame.size.height / 2), _arrow4.frame.size.width, _arrow4.frame.size.height);
                _uniqueScansLabel = [[UILabel alloc] initWithFrame:CGRectMake(_scrollView2ActivityIndicator.frame.origin.x - 10, _scrollView2ActivityIndicator.frame.origin.y - aggregatelabelSize.height / 2, aggregatelabelSize.width, aggregatelabelSize.height)];
                _uniqueScansLabel.backgroundColor = [UIColor clearColor];
                
//                _uniqueScansLabel.hidden = YES;
                [view addSubview:_uniqueScansLabel];
                [view addSubview:_arrow3];
                [view addSubview:_arrow4];
            }
            
            CGSize labelSize = [text sizeWithFont:font];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - labelSize.width + 60, 10, labelSize.width, labelSize.height)];
            label.font = font;
            label.text = text;
            
            [view addSubview:label];
            [self.scrollView addSubview:view];
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
        
        [self layoutPullToRefreshView];
    }else {
        self.scrollView.hidden = YES;
    }
}

-(void) animateOddArrows{
    [UIView animateWithDuration:2.0 animations:^{
        _arrow1.alpha = 0.0;
//        _arrow2.alpha = 0.0;
        _arrow3.alpha = 0.0;
//        _arrow4.alpha = 0.0;
    }];
    [UIView animateWithDuration:2.0 animations:^{
        _arrow1.alpha = 1.0;
//        _arrow2.alpha = 1.0;
        _arrow3.alpha = 1.0;
//        _arrow4.alpha = 1.0;
    }];
}

- (void) animateEvenArrows
{
    [UIView animateWithDuration:3.0 animations:^{
//        _arrow1.alpha = 0.0;
        _arrow2.alpha = 0.0;
//        _arrow3.alpha = 0.0;
        _arrow4.alpha = 0.0;
    }];
    [UIView animateWithDuration:3.0 animations:^{
//        _arrow1.alpha = 1.0;
        _arrow2.alpha = 1.0;
//        _arrow3.alpha = 1.0;
        _arrow4.alpha = 1.0;
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.view setNeedsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWSyncEngineSyncCompleted" object:nil];
}

- (void) dealloc
{
    //    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWSyncEngineSyncCompleted" object:nil];
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Scans"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id = %@", self.detailItem.remote_id];
        NSLog(@"Event_ID: %@", self.detailItem.remote_id);
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES]]];
        self.scans = [self.managedObjectContext executeFetchRequest:request error:&error];
        self.totalScansLabel.text = [NSString stringWithFormat:@"%i", self.scans.count];
        NSSet *uniqueStates = [NSSet setWithArray:[self.scans valueForKey:@"value"]];
//        NSLog(@"Unique Entries: %i", uniqueStates.count);
        self.uniqueScansLabel.text = [NSString stringWithFormat:@"%i", uniqueStates.count];

        [self.scansTable reloadData];
        [self stopActivityIndicatorView];
    }];
}

- (void) stopActivityIndicatorView
{
    [_totalScansIndicator stopAnimating];
    [_uniqueScansIndicator stopAnimating];
    [_scrollView1ActivityIndicator stopAnimating];
    [_scrollView2ActivityIndicator stopAnimating];
}

- (void) showActivtyIndicatorView
{
    [_totalScansIndicator setHidesWhenStopped:YES];
    [_uniqueScansIndicator setHidesWhenStopped:YES];
    
    [_uniqueScansIndicator startAnimating];
    [_totalScansIndicator startAnimating];
}

- (void)setupMenuBarButtonItems {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [self rightMenuBarButtonItem],[self keypadBarButtonItem], nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [self rightMenuBarButtonItem], nil];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStyleBordered
            target:self.viewDeckController
            action:@selector(toggleLeftView)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
            target:self
            action:@selector(scanPressed:)];
}
                                               
- (UIBarButtonItem *)keypadBarButtonItem {
    UIBarButtonItem *keypadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keypad_bar_button"] style:UIBarButtonItemStylePlain target:self  action:@selector(keypadButtonPressed:)];
    return keypadButton;
}

-(IBAction)keypadButtonPressed:(id)sender
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    KeypadViewController *kpvc = [st instantiateViewControllerWithIdentifier:@"keypadViewController"];
    kpvc.event = self.detailItem;
    kpvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    kpvc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:kpvc animated:YES completion:nil];
}

- (IBAction)scanPressed:(id)sender {
	UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    CameraCaptureViewController *cameraCapture = [st instantiateViewControllerWithIdentifier:@"cameraCaptureViewController"];
    cameraCapture.delegate = self;
    cameraCapture.event = self.detailItem;
//    cameraCapture.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:cameraCapture animated:NO completion:nil];
    /*BarcodeCaptureViewController *vc = [[BarcodeCaptureViewController alloc] initWithNibName:@"BarcodeCaptureViewController" bundle:nil];
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];*/
}


- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = self.detailItem.name;
        [self loadRecordsFromCoreData];
    }
}

#pragma mark - Pull to Refresh Header

- (void)addPullToRefreshHeader {
    _refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, self.scansTable.frame.size.width, REFRESH_HEADER_HEIGHT)];
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    _refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scansTable.frame.size.width, REFRESH_HEADER_HEIGHT)];
    _refreshLabel.backgroundColor = [UIColor clearColor];
    _refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    //    _refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_icon"]];
    _refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sweep_broom"]];
    
    _refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT) / 2),
                                     (floorf(REFRESH_HEADER_HEIGHT - 35) / 2),
                                     _refreshArrow.frame.size.width, _refreshArrow.frame.size.height);
    
    _refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    _refreshSpinner.hidesWhenStopped = YES;
    
    [_refreshHeaderView addSubview:_refreshLabel];
    [_refreshHeaderView addSubview:_refreshArrow];
    [_refreshHeaderView addSubview:_refreshSpinner];
    [self.scansTable addSubview:_refreshHeaderView];
}

- (void) layoutPullToRefreshView
{
    _refreshHeaderView.frame = CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, self.scansTable.frame.size.width, REFRESH_HEADER_HEIGHT);
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    _refreshLabel.frame = CGRectMake(0, 0, self.scansTable.frame.size.width, REFRESH_HEADER_HEIGHT);
    _refreshLabel.backgroundColor = [UIColor clearColor];
    _refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    _refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT) / 2),
                                     (floorf(REFRESH_HEADER_HEIGHT - 35) / 2),
                                     _refreshArrow.frame.size.width, _refreshArrow.frame.size.height);
    
//    _refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    _refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
//    _refreshSpinner.hidesWhenStopped = YES;
}

- (void)setupStrings{
    _textPull = @"Pull down to refresh...";
    _textRelease = @"Release to refresh...";
    _textLoading = @"Loading...";
}

- (void)stopLoading {
    _isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.scansTable.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.scansTable.contentInset;
    tableContentInset.top = 0.0;
    self.scansTable.contentInset = tableContentInset;
    [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    _refreshLabel.text = self.textPull;
    _refreshArrow.hidden = NO;
    [_refreshSpinner stopAnimating];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.tag != 101) {
        if (_isLoading) return;
            _isDragging = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag != 101) {

        if (_isLoading) {
            // Update the content inset, good for section headers
            if (scrollView.contentOffset.y > 0)
                self.scansTable.contentInset = UIEdgeInsetsZero;
            else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
                self.scansTable.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (_isDragging && scrollView.contentOffset.y < 0) {
            // Update the arrow direction and label
            [UIView beginAnimations:nil context:NULL];
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                _refreshLabel.text = self.textRelease;
                [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else { // User is scrolling somewhere within the header
                _refreshLabel.text = self.textPull;
                [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
    }
    else
    {
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.tag != 101) {

        if (_isLoading) return;
        _isDragging = NO;
        if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
            // Released above the header
            [self startLoading];
        }
    }
}

- (void)startLoading {
    _isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.scansTable.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    _refreshLabel.text = self.textLoading;
    _refreshArrow.hidden = YES;
    [_refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh View of Parking Lots
    //    [self refreshLots];
//    [[LocationManager sharedLocationManager] startUpdates];
    [[SWSyncEngine sharedEngine] startSync];
}

#pragma mark - Login Check

-(void) displayLoginControllerIfNeeded
{
    NSString *departmentKey = (NSString *)[self.departmentKeyItem objectForKey:(__bridge id)(kSecValueData)];
    if (departmentKey.length)
    {
        // Department Key was once valid but validate again on startup
        [self validateDepartmentKey:departmentKey];
    }else {
        // No department key found
        // Perform Selector seems to be more stable when loading the view
        [self performSelector:@selector(showLoginController) withObject:nil afterDelay:0.0];
        //        [self showLoginController];
    }
}

- (void) showLoginController
{
    [self stopActivityIndicatorView];
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    LogInViewController *logInController = [st instantiateViewControllerWithIdentifier:@"logInViewController"];
    logInController.departmentKeyItem = self.departmentKeyItem;
    logInController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void) validateDepartmentKey:(NSString *) departmentKey
{
    [Departments globalDepartmentVerificationWithValidationKey:departmentKey
                                                     withBlock:^(NSDictionary *departmentAndCustomer, NSError *error) {
         if (!error)
         {
             [[SWSyncEngine sharedEngine] removeDepartmentObjects];
             [[SWSyncEngine sharedEngine] removeCustomerObjects];
            
             NSLog(@"Department Returned: %@", [departmentAndCustomer valueForKey:@"department"]);
             NSLog(@"Customer Returned: %@", [departmentAndCustomer valueForKey:@"customer"]);
             
             [self.departmentKeyItem setObject:[[departmentAndCustomer valueForKey:@"department"] objectForKey:@"valid_key"] forKey:(__bridge id)(kSecValueData)];
             
             [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Departments" forRecord: [departmentAndCustomer valueForKey: @"department"]];
             [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Customers" forRecord:[departmentAndCustomer valueForKey:@"customer"]];
             
             [self.managedObjectContext performBlockAndWait:^{
                 [self.managedObjectContext reset];
                 
                 NSError *error = nil;
                 BOOL saved = [self.managedObjectContext save:&error];
                 if (!saved) {
                     // do some real error handling
                     NSLog(@"Could not save Department due to %@", error);
                 }
                 [[SWCoreDataController sharedInstance] saveMasterContext];
                 [ThemeManager customizeAppAppearance];
                 [self.view setNeedsDisplay];
             }];
             
             [[SWSyncEngine sharedEngine] startSync];
             
         }else {
             NSLog(@"Error Code: %i", [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode] );
             
             NSLog(@"Error: %@", [error localizedDescription]);
             // Look for an unauthorized response code
             if ([[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 401)
             {
                 [self resetDepartment];
             }else {
                 [[SWSyncEngine sharedEngine] startSync];
             }
         }
     }];
}

- (void) resetDepartment
{
    // Key is no longer valid reset the keychain and reenter
    [self.departmentKeyItem resetKeychainItem];
    
    // Remove ALL core data objects when department key is deemed invalid
    [[SWSyncEngine sharedEngine] removeCoreDataObjects];
    [ThemeManager customizeAppAppearance];
    
    [self showLoginController];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.image = [UIImage imageNamed:@"menu_icon"];
//    [self.navigationItem setLeftBarButtonItem:[self leftMenuBarButtonItem] animated:YES];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - SScanDelegate

- (void) cameraCaptureController:(CameraCaptureViewController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [self dismissViewControllerAnimated:NO completion:^(void) {
        /*if (barcodeResult && [barcodeResult count])
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
         
        }*/
        [[SWSyncEngine sharedEngine] startSync];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [self.scans count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScanValuesTableViewCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.scansTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.scansTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.scansTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.scansTable endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: Do this whole block more efficiently
    Scans *scan = [self.scans objectAtIndex:indexPath.row];
    NSString *valueString;
    NSInteger num = (scan.value.length * [[[ThemeManager sharedTheme] percentageIDAvailable] integerValue]) / 100;
    
    valueString = [scan.value substringFromIndex:(scan.value.length - num) ];
    NSMutableString *padString = [NSMutableString string];
    for (int i = 0; i < (scan.value.length - num); i++)
    {
        [padString appendString:@"*"];
    }
    valueString = [NSString stringWithFormat:@"%@%@", padString, valueString];
    cell.textLabel.text = valueString;
}

- (void) playSoundAndVibrate
{
#if !(TARGET_IPHONE_SIMULATOR)
    
//    // Get the main bundle for the app
//    CFBundleRef mainBundle = CFBundleGetMainBundle ();
//    
//    // Get the URL to the sound file to play. The file in this case
//    // is "tap.aif"
//    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (
//                                                         mainBundle,
//                                                         CFSTR ("DING"),
//                                                         CFSTR ("caf"),
//                                                         NULL
//                                                         );
//    
//    // Create a system sound object representing the sound file
//    SystemSoundID soundFileObject;
//    AudioServicesCreateSystemSoundID (
//                                      soundFileURLRef,
//                                      &soundFileObject
//                                      );
//    // Play the sound
//    AudioServicesPlaySystemSound (soundFileObject);
    
    // And Vibrate if possible
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playSoundAndVibrate) userInfo:nil repeats:NO];

    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
#endif
}

# pragma mark - AlertView

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index: %i", buttonIndex);
    // If user
    if (buttonIndex == 1)
    {
        
        UmRet ret = [uniReader startUniMag:TRUE];
        if (ret == UMRET_SUCCESS)
        {
            NSLog(@"Starting to connect to reader");
            //        [uniReader setAutoAdjustVolume:TRUE];
            
            double delayInSeconds = 4.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                NSLog(@"Starting to request swipe");
                UmRet ret = [uniReader requestSwipe];
            });
        }
    }
}

# pragma mark - UniMag SDK


- (void)umDevice_attachment:(NSNotification *)notification {

//    [self umsdk_unRegisterObservers];
//    [self umsdk_registerObservers];
    NSLog(@"Notification: %@", notification);
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connect?"
                                                      message:@"YES if the device is a card reader.\nNO if the device is an audio headset.\n WARNING: A loud tone will be generated if an audio headset is connected."
                                                     delegate:self
                                            cancelButtonTitle:@"NO"
                                            otherButtonTitles:@"YES", nil];
    [message show];

}

//called when SDK received a swipe successfully
- (void)umSwipe_receivedSwipe:(NSNotification *)notification {

	NSData *data = [notification object];
	NSString *idScanned = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"Mag Read: %@", idScanned);
    
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if (idScanned.length >= [[[ThemeManager sharedTheme] lengthOfValidID] integerValue])
    {
//        idScanned = [idScanned substringToIndex: [[[ThemeManager sharedTheme] lengthOfValidID] integerValue]];
        
        idScanned = [idScanned substringWithRange:NSMakeRange(1, [[[ThemeManager sharedTheme] lengthOfValidID] integerValue])];
        NSLog(@"Formatted Read: %@", idScanned);
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
        newScan.event_id = self.detailItem.remote_id;
        newScan.sync_status = [NSNumber numberWithInt:SWObjectCreated];
        
        NSError *error = nil;
        BOOL saved = [self.managedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save Event due to %@", error);
        }else {
#ifndef DEBUG
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:@"Type", @"Swipe",
                                           @"Theme", NSStringFromClass([ThemeManager sharedTheme]),
                                           nil];
            [Flurry logEvent:@"Scan"];
#endif
        }
        
        [[SWCoreDataController sharedInstance] saveBackgroundContext];
        
        // Add check to see if anything should be entered
        [[SWSyncEngine sharedEngine] startSync];
    }
    
    UmRet ret = [uniReader requestSwipe];

}

// called when the SDK has read something from the uniMag device
// (eg a swipe, a response to a command) and is in the process of decoding it
// Use this to provide an early feedback on the UI
- (void)umDataProcessing:(NSNotification *)notification {
	[_readerButton setTintColor:[UIColor redColor]];
    
}

//called when the swipe task is successfully starting, meaning the SDK starts to
// wait for a swipe to be made
- (void)umSwipe_starting:(NSNotification *)notification {
    
    NSMutableArray *toolbarButtons = [NSMutableArray arrayWithArray:[_bottomToolbar items]];

    [_readerButton setTintColor:[UIColor colorWithRed:0.7411764706 green:0.8509803922 blue:0.2549019608 alpha:1.0]];

    if (![toolbarButtons containsObject:_readerBarButtonItem]) {
        UIImage *buttonImage = [UIImage imageNamed:@"reader_icon"];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            buttonImage = [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
    //
        //create the button and assign the image
        _readerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_readerButton setImage:buttonImage forState:UIControlStateNormal];
        [_readerButton setTintColor:[UIColor colorWithRed:0.7411764706 green:0.8509803922 blue:0.2549019608 alpha:1.0]];
    //
    //    //sets]; the frame of the button to the size of the image
        _readerButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    //
    //    //creates a UIBarButtonItem with the button as a custom view
        _readerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_readerButton];
//        [_readerBarButtonItem setTintColor:[UIColor redColor]];
        // Get the reference to the current toolbar buttons
        
        // This is how you add the button to the toolbar and animate it

        // The following line adds the object to the end of the array.
        // If you want to add the button somewhere else, use the `insertObject:atIndex:`
        // method instead of the `addObject` method.
        [toolbarButtons insertObject:_readerBarButtonItem atIndex:0];
        [_bottomToolbar setItems:toolbarButtons animated:YES];
    }
}

-(void) umsdk_activate {
    
    //register observers for all uniMag notifications
	[self umsdk_registerObservers];
    
    
	//enable info level NSLogs inside SDK
    // Here we turn on before initializing SDK object so the act of initializing is logged
    [uniMag enableLogging:TRUE];
    
    //initialize the SDK by creating a uniMag class object
    uniReader = [[uniMag alloc] init];
    
    /*
     //set SDK to perform the connect task automatically when headset is attached
     [uniReader setAutoConnect:TRUE];
     */
    
    //set swipe timeout to infinite. By default, swipe task will timeout after 20 seconds
	[uniReader setSwipeTimeoutDuration:0];
    
    //make SDK maximize the volume automatically during connection
//    [uniReader setAutoAdjustVolume:TRUE];
    
    //By default, the diagnostic wave file logged by the SDK is stored under the temp directory
    // Here it is set to be under the Documents folder in the app sandbox so the log can be accessed
    // through iTunes file sharing. See UIFileSharingEnabled in iOS doc.
    [uniReader setWavePath: [NSHomeDirectory() stringByAppendingPathComponent: @"/Documents/audio.caf"]];
}

//called when uniMag is physically detached
- (void)umDevice_detachment:(NSNotification *)notification {
//    uniReader = nil;
    
    [self umsdk_unRegisterObservers];
    
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [NSMutableArray arrayWithArray:[_bottomToolbar items]];
    
    // This is how you remove the button from the toolbar and animate it
    [toolbarButtons removeObject:_readerBarButtonItem];
    [_bottomToolbar setItems:toolbarButtons animated:YES];
}

//called when SDK failed to handshake with reader in time. ie, the connection task has timed out
- (void)umCommand_receivedResponse:(NSNotification *)notification {
   // Do Nothing
    
    NSLog(@"Recieved CMD Resposne: %@", notification);
}

-(void) umsdk_registerObservers {
//	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//
//    //list of notifications and their corresponding selector
//    const struct {NSString *n; SEL s;} noteAndSel[] = {
//        //
//        {uniMagAttachmentNotification       , @selector(umDevice_attachment:)},
//        {uniMagDetachmentNotification       , @selector(umDevice_detachment:)},
//        //
//        {uniMagInsufficientPowerNotification, @selector(umConnection_lowVolume:)},
//        {uniMagPoweringNotification         , @selector(umConnection_starting:)},
//        {uniMagTimeoutNotification          , @selector(umConnection_timeout:)},
//        {uniMagDidConnectNotification       , @selector(umConnection_connected:)},
//        {uniMagDidDisconnectNotification    , @selector(umConnection_disconnected:)},
//        //
//        {uniMagSwipeNotification            , @selector(umSwipe_starting:)},
//        {uniMagTimeoutSwipeNotification     , @selector(umSwipe_timeout:)},
//        {uniMagDataProcessingNotification   , @selector(umDataProcessing:)},
//        {uniMagInvalidSwipeNotification     , @selector(umSwipe_invalid:)},
//        {uniMagDidReceiveDataNotification   , @selector(umSwipe_receivedSwipe:)},
//        //
//        {uniMagCmdSendingNotification       , @selector(umCommand_starting:)},
//        {uniMagCommandTimeoutNotification   , @selector(umCommand_timeout:)},
//        {uniMagDidReceiveCmdNotification    , @selector(umCommand_receivedResponse:)},
//        //
//        {uniMagSystemMessageNotification    , @selector(umSystemMessage:)},
//        
//        {nil, nil},
//    };
//    
//    //register or unregister
//    for (int i=0; noteAndSel[i].s != nil ;i++) {
//        if (reg)
//            [nc addObserver:self selector:noteAndSel[i].s name:noteAndSel[i].n object:nil];
//        else
//            [nc removeObserver:self name:noteAndSel[i].n object:nil];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umDevice_attachment:) name:uniMagAttachmentNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umDevice_detachment:) name:uniMagDetachmentNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umDataProcessing:) name:uniMagDataProcessingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umSwipe_receivedSwipe:) name:uniMagDidReceiveDataNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umSwipe_starting:) name:uniMagSwipeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umCommand_receivedResponse:) name:uniMagDidReceiveCmdNotification object:nil];

}

-(void) umsdk_unRegisterObservers {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:uniMagAttachmentNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uniMagDetachmentNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uniMagDataProcessingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uniMagDidReceiveDataNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uniMagSwipeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uniMagTimeoutNotification object:nil];


}

@end
