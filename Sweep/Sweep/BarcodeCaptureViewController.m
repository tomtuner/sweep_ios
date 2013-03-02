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
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *flashButton;

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
    dispatch_async(dispatch_get_main_queue(), ^{

        self.capture = [[ZXCapture alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{

//    });
            self.capture.delegate = self;
            self.capture.camera = self.capture.back;
            self.capture.rotation = 90.0f;

            self.capture.layer.frame = self.scannerView.bounds;
            [self.scannerView.layer addSublayer:self.capture.layer];
    //    [self.scannerView.layer addSublayer:self.cancel.layer];
        
            [self.capture start];
        });
    });
    // Do any additional setup after loading the view from its nib.
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
        [self displayForResult:result];
        
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
            [self returnBarcodeResults];
        }else {
            [NSThread sleepForTimeInterval:5];
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
    self.capture.torch = !self.capture.torch;
}

-(IBAction)multiScan:(id)sender {
    self.multiScan = !self.multiScan;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
