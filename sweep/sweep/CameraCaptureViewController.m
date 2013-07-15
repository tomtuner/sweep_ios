//
//  CameraCaptureViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/30/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "CameraCaptureViewController.h"

@interface CameraCaptureViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) ZXCapture *capture;
@property(nonatomic, strong) NSMutableArray *barcodeResultArray;
@property (nonatomic, strong) IBOutlet UIView *buttonOverlayView;
@property (nonatomic, strong) IBOutlet UIButton *finishButton;
@property (nonatomic, strong) IBOutlet UIButton *flashButton;
@property (nonatomic, strong) IBOutlet UIButton *multiScanButton;
@property (nonatomic, strong) IBOutlet UILabel *lastScannedCode;
@property (nonatomic, strong) IBOutlet UILabel *lastScannedTitleLabel;

@property (nonatomic) BOOL multiScan;

@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;

@end

@implementation CameraCaptureViewController
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];

    [self createSeperateCameraMaskViews];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.capture = [[ZXCapture alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //    });
            self.capture.delegate = self;
            self.capture.camera = self.capture.back;
            self.capture.rotation = 90.0f;
            
            self.capture.layer.frame = self.scannerView.bounds;
            [self.scannerView.layer addSublayer:self.capture.layer];
            [self.capture start];
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self animateCameraMaskViews];
//                                 [self.scannerView addSubview:self.buttonOverlayView];
                                 [self.view addSubview:self.buttonOverlayView];
                             }
                             completion:^(BOOL finished){
                                 [_topMaskView removeFromSuperview];
                                 [_bottomMaskView removeFromSuperview];
                                 
                                 //                                [self.scannerView.layer addSublayer:self.buttonOverlayView.layer];
                             }];
        });
    });
    self.multiScan = NO;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void) animateCameraMaskViews
{
    _topMaskView.frame = CGRectMake(0, 0 - _topMaskView.frame.size.height, _topMaskView.frame.size.width, _topMaskView.frame.size.height);
    _bottomMaskView.frame = CGRectMake(0, _bottomMaskView.frame.size.height + _bottomMaskView.frame.size.height, _bottomMaskView.frame.size.width, _bottomMaskView.frame.size.height);
}

- (void) createSeperateCameraMaskViews
{
    
    _topMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2)];
    _topMaskView.backgroundColor = [UIColor colorWithRed:0.3176470588 green:0.1921568627 blue:0.1529411765 alpha:1.0];
    
    // Add the top RIT Logo
    UIImage *ritTopImage = [UIImage imageNamed:@"rit_white_top"];
    CGRect topRIT = CGRectMake((_topMaskView.frame.size.width / 2) - (ritTopImage.size.width / 2), (_topMaskView.frame.size.height - ritTopImage.size.height), ritTopImage.size.width, ritTopImage.size.height);
    UIImageView *ritTop = [[UIImageView alloc] initWithFrame:topRIT];
    ritTop.image = ritTopImage;
    
    [_topMaskView addSubview:ritTop];
    
    [self.view addSubview:_topMaskView];
    
    _bottomMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2)];
    _bottomMaskView.backgroundColor = [UIColor colorWithRed:0.3176470588 green:0.1921568627 blue:0.1529411765 alpha:1.0];
    
    // Add the top RIT Logo
    UIImage *ritBottomImage = [UIImage imageNamed:@"rit_white_bottom"];
    CGRect bottomRIT = CGRectMake((_bottomMaskView.frame.size.width / 2) - (ritBottomImage.size.width / 2), 0, ritBottomImage.size.width, ritBottomImage.size.height);
    UIImageView *ritBottom = [[UIImageView alloc] initWithFrame:bottomRIT];
    ritBottom.image = ritBottomImage;
    
    [_bottomMaskView addSubview:ritBottom];
    
    [self.view addSubview:_bottomMaskView];
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void) playSoundAndVibrate
{
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
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
    if (result) {
        // We got a result. Display information about the result onscreen.
        //        [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:[self displayForResult:result] waitUntilDone:YES];
        //        [self displayForResult:result];
        
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([result.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // newString consists only of the digits 0 through 9
            NSLog(@"Valid Number: %@", result.text);
            
#if !(TARGET_IPHONE_SIMULATOR)
            // Vibrate
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self playSoundAndVibrate];
#endif
            
           /* SBarcodeResult *br = [[SBarcodeResult alloc] init];
            br.text = result.text;
            br.timestamp = result.timestamp;
            //        br.timestamp = [NSDate dateF]
            br.resultMetadata = result.resultMetadata;
            //        br.resultPoints = result.resultPoints;
            //        br.rawBytes = [NSString stringWithFormat:@"%s", result.rawBytes];
            br.barcodeFormat = result.barcodeFormat;
            br.length = result.length;
            
            //        [self dismissViewControllerAnimated:YES completion:nil];
            [self.barcodeResultArray addObject:br];
            */
            
            Scans *newScan = [NSEntityDescription insertNewObjectForEntityForName:@"Scans" inManagedObjectContext:self.managedObjectContext];
            newScan.value = result.text;
//            newScan.scanned_at = result.timestamp;
            newScan.event_id = self.event.remote_id;
            newScan.sync_status = [NSNumber numberWithInt:SWObjectCreated];

            // Set the visual feedback for user
            self.lastScannedCode.text = result.text;
            
            NSError *error = nil;
            BOOL saved = [self.managedObjectContext save:&error];
            if (!saved) {
                // do some real error handling
                NSLog(@"Could not save Event due to %@", error);
            }
            [[SWCoreDataController sharedInstance] saveMasterContext];

            if (!self.multiScan) {
                // Call the delegates method to return set of barcodes scanned
                /*[SBarcodeResult globalBarcodeScanWithSBarcodeResult:br withBlock:^(NSArray * barcodes, NSError *error) {
                    if (error) // If there is an error sending the code
                    {
                        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error sending code"
                                                                          message:error.localizedDescription
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                        [message show];
                    }
                }];
             */
                [self returnBarcodeResults];
            }else {
                [NSThread sleepForTimeInterval:3];
            }
        }
    }
}

- (void) returnBarcodeResults {
    if([self.delegate respondsToSelector:@selector(cameraCaptureController:)])
    {
        //send the delegate function with the amount entered by the user
        [self cleanUpCamera];
        
        [self.delegate cameraCaptureController:self];
    }
}

-(void) cleanUpCamera {
    [self.buttonOverlayView removeFromSuperview];
    [self.capture.layer removeFromSuperlayer];
    [self.capture stop];
}

-(IBAction)done:(id)sender
{
    [self returnBarcodeResults];
}

/*
-(IBAction)cancel:(id)sender
{
    if([self.delegate respondsToSelector:@selector(barcodeCaptureController:)])
    {
        [self cleanUpCamera];
        //send the delegate function with the amount entered by the user
        [self.delegate cameraCaptureController:self];
    }
}
*/

-(IBAction)flash:(id)sender {
    if ([self.capture hasTorch]) {
        self.capture.torch = !self.capture.torch;
    }
}

-(IBAction)multiScan:(id)sender {
    NSLog(@"MultiScan");
    NSLog(@"MultiScan was %i", self.multiScan);
    if (self.multiScan == NO) {
        self.lastScannedTitleLabel.hidden = NO;
        self.lastScannedCode.hidden = NO;
        self.finishButton.titleLabel.text = @"Done";
    }else {
        self.lastScannedTitleLabel.hidden = YES;
        self.lastScannedCode.hidden = YES;
        self.finishButton.titleLabel.text = @"Cancel";
    }
    self.multiScan = !self.multiScan;
    NSLog(@"MultiScan is %i", self.multiScan);
    self.finishButton.titleLabel.text = self.multiScan ? @"Done" : @"Cancel";
    
//    [self.finishButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
}

@end
