//
//  BarcodeCaptureViewController.m
//  Sweep
//
//  Created by Thomas DeMeo on 2/4/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "BarcodeCaptureViewController.h"

@interface BarcodeCaptureViewController ()

@property (nonatomic, assign) BOOL multiScan;
@property (nonatomic, strong) IBOutlet UIButton *finishButton;
@property (nonatomic, strong) IBOutlet UIButton *flashButton;
@property (nonatomic, strong) IBOutlet UIButton *multiScanButton;
@property (nonatomic, strong) IBOutlet UIView *buttonOverlayView;

@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;

@end

@implementation BarcodeCaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.barcodeResultArray = [NSMutableArray array];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
                                 [self.scannerView.layer addSublayer:self.buttonOverlayView.layer];

                             }
                             completion:^(BOOL finished){
                                 [_topMaskView removeFromSuperview];
                                 [_bottomMaskView removeFromSuperview];

//                                [self.scannerView.layer addSublayer:self.buttonOverlayView.layer];
                             }];
        });
    });
    self.multiScan = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (void)deviceDidRotate:(NSNotification *)notification
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    double rotation = 0;
    UIInterfaceOrientation statusBarOrientation;
    switch (currentOrientation) {
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationUnknown:
            return;
        case UIDeviceOrientationPortrait:
            rotation = 0;
            statusBarOrientation = UIInterfaceOrientationPortrait;
            self.capture.rotation = 90.0f;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            rotation = -M_PI;
            statusBarOrientation = UIInterfaceOrientationPortraitUpsideDown;
            self.capture.rotation = 270.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotation = M_PI_2;
            statusBarOrientation = UIInterfaceOrientationLandscapeRight;
            self.capture.rotation = 180.0f;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotation = -M_PI_2;
            statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
            self.capture.rotation = 0.0f;
            break;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.finishButton setTransform:transform];
        [self.multiScanButton setTransform:transform];
        [self.flashButton setTransform:transform];
    } completion:nil];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"UI Orientation: %i", toInterfaceOrientation);
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        self.capture.rotation = 180.0f;
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.capture.rotation = 0.0f;
    }else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.capture.rotation = 90.0f;
    }else {
        NSLog(@"UI Orientation: %i", toInterfaceOrientation);
    }
}

#pragma mark - Private Methods

- (NSString*)displayForResult:(ZXResult*)result {
    NSString *formatString;
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    
    NSLog(@"%@", [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text]);
    return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
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
            NSLog(@"Valid Number");
            
            #if !(TARGET_IPHONE_SIMULATOR)
                // Vibrate
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            #endif
            
            SBarcodeResult *br = [[SBarcodeResult alloc] init];
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
            
            if (!self.multiScan) {
                // Call the delegates method to return set of barcodes scanned
                [SBarcodeResult globalBarcodeScanWithSBarcodeResult:br withBlock:^(NSArray * barcodes, NSError *error) {
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
                [self returnBarcodeResults];
            }else {
                [NSThread sleepForTimeInterval:3];
            }
        }
    }
}

- (void) waitMethod {
    NSLog(@"In Wait Method");
}

- (void) returnBarcodeResults {
    if([self.delegate respondsToSelector:@selector(barcodeCaptureController:scanResults:)])
    {
        //send the delegate function with the amount entered by the user
        [self cleanUpCamera];
        
        [self.delegate barcodeCaptureController:self scanResults:self.barcodeResultArray];
    }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
}

-(void) cleanUpCamera {
    [self.buttonOverlayView.layer removeFromSuperlayer];
    [self.capture.layer removeFromSuperlayer];
    [self.capture stop];
}

-(IBAction)done:(id)sender
{
    [self returnBarcodeResults];
}


-(IBAction)cancel:(id)sender
{
    if([self.delegate respondsToSelector:@selector(barcodeCaptureController:scanResults:)])
    {
        [self cleanUpCamera];
        //send the delegate function with the amount entered by the user
        [self.delegate barcodeCaptureController:self scanResults:nil];
    }
}

-(IBAction)flash:(id)sender {
    if ([self.capture hasTorch]) {
        self.capture.torch = !self.capture.torch;
    }
}

-(IBAction)multiScan:(id)sender {
    NSLog(@"MultiScan");
    NSLog(@"MultiScan was %i", self.multiScan);
    self.multiScan = !self.multiScan;
    if ([self.finishButton.titleLabel.text isEqual:@"Cancel"]) {
        self.finishButton.titleLabel.text = @"Done";
    }else {
        self.finishButton.titleLabel.text = @"Cancel";
    }
    
    NSLog(@"MultiScan is %i", self.multiScan);
//    self.finishButton.titleLabel.text = self.multiScan ? @"Done" : @"Cancel";
    
    [self.finishButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
