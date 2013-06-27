//
//  RealMoneyViewController.m
//  RealMoney
//
//  Created by Yilong Geng on 5/16/13.
//  Copyright (c) 2013 Yilong Geng. All rights reserved.
//

#import "RealMoneyViewController.h"
#import "baseapi.h"
#import "ConfirmViewController.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}


@interface RealMoneyViewController ()

@end

@implementation RealMoneyViewController

@synthesize confirmViewController;
@synthesize scanningLabel;
@synthesize resultLabel;
//@synthesize overlayImageView;
@synthesize captureSession;
@synthesize previewLayer;
@synthesize videoDataOutput;
@synthesize tess;
@synthesize locationManager;
@synthesize currentLocation;


- (void)viewDidLoad {
    [self initLocationManager];
    [self initTesseract];
    [self initVideo];
    [self initView];
	[captureSession startRunning];
    [locationManager startUpdatingLocation];
}

- (void) initView {
    CGRect layerRect = [[[self view] layer] bounds];
	[previewLayer setBounds:layerRect];
	[previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                          CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:previewLayer];
    
    _roiX = 30;
    _roiY = 200;
    _roiWidth = 260;
    _roiHeight = 80;
    UIImageView *ROIImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ROI.png"]];
    [ROIImageView setFrame:CGRectMake(_roiX, _roiY, _roiWidth, _roiHeight)];
    [[self view] addSubview:ROIImageView];
    
    /*
     overlayImageView = [[UIImageView alloc] init];//WithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
     [overlayImageView setFrame:CGRectMake(_roiX, _roiY+200, _roiWidth, _roiHeight)];
     [[self view] addSubview:overlayImageView];
     */
    /*
     UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
     [overlayButton setFrame:CGRectMake(130, 320, 60, 30)];
     [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
     [[self view] addSubview:overlayButton];
     */
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 100)];
    tempLabel.numberOfLines = 0;
    [self setScanningLabel:tempLabel];
	[scanningLabel setBackgroundColor:[UIColor clearColor]];
	[scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 20.0]];
	[scanningLabel setTextColor:[UIColor redColor]];
	[scanningLabel setText:@"Scanning..."];
    //[scanningLabel setHidden:YES];
	[[self view] addSubview:scanningLabel];
    
    tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 350, 320, 100)];
    tempLabel.numberOfLines = 0;
    [self setResultLabel:tempLabel];
    [resultLabel setBackgroundColor:[UIColor clearColor]];
    [resultLabel setFont:[UIFont fontWithName:@"Courier" size:40.0]];
    [resultLabel setTextColor:[UIColor redColor]];
    [[self view] addSubview:resultLabel];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    confirmViewController = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmViewController"];
}

/*
- (void) scanButtonPressed {
	[[self scanningLabel] setHidden:NO];
	[self performSelector:@selector(hideLabel:) withObject:[self scanningLabel] afterDelay:2];
}

- (void)hideLabel:(UILabel *)label {
	[label setHidden:YES];
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initLocationManager {
    [self setLocationManager:[[CLLocationManager alloc] init]];
    [locationManager setDelegate:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self setCurrentLocation:newLocation];
    //[scanningLabel setText:[currentLocation description]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

- (void)initVideo{
    [self setCaptureSession:[[AVCaptureSession alloc] init]];
    //TODO: change this to proper value
    captureSession.sessionPreset = AVCaptureSessionPreset352x288;
    [self addVideoPreviewLayer];
    [self addVideoInput];
    [self addVideoDataOutput];
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)addVideoDataOutput {
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [captureSession addOutput:output];
    [output setAlwaysDiscardsLateVideoFrames:YES];
    
    // Configure output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:(id)self queue:queue];
    //dispatch_release(queue);
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    //setting this will make the previewLayer very slow
    // set frame duration
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if(connection.supportsVideoMinFrameDuration)
    {
        //connection.videoMinFrameDuration = CMTimeMake(1, 15);
    }
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:videoIn])
				[[self captureSession] addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    static NSString *cachedString;
    static int cachedNumber = 0;
    CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(cvimgRef,0);
    // access the data
    int width=CVPixelBufferGetWidth(cvimgRef);
    int height=CVPixelBufferGetHeight(cvimgRef);
    // get the raw image bytes
    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
    size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context=CGBitmapContextCreate(buf, width, height, 8, bprow, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorSpace);
    CGImageRef image=CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    //select ROI
    float roiX, roiY, roiWidth, roiHeight;
    roiWidth = _roiWidth * 352 / 548;
    roiHeight = _roiHeight * 352 / 548;
    roiX = (288 - roiWidth)/2;
    roiY = _roiY * 352 / 548;
    CGImageRef roiImage = CGImageCreateWithImageInRect(image, CGRectMake(roiX, roiY, roiWidth, roiHeight));
    UIImage *resultUIImage = [UIImage imageWithCGImage:roiImage];
    CGImageRelease(image);
    CGImageRelease(roiImage);
    
    //recognize the image and get legal serial number
    NSString *string = [self ocrImage:resultUIImage];
    NSString *resultString = [self getSerialNumber:string];
    
    if (resultString != nil) {
        //NSLog(@"%@", string);
        if (cachedNumber == 0) {
            cachedString = resultString;
            cachedNumber = 1;
        }
        else
        {
            if ([resultString isEqualToString:cachedString]) {
                cachedNumber++;
            }
            else{
                cachedString = resultString;
                cachedNumber = 1;
            }
        }
        
        if (cachedNumber == 3) {
            cachedNumber = 0;
            if (!(confirmViewController.isViewLoaded && confirmViewController.view.window)) {
                
                confirmViewController.serialNumber = resultString;
                confirmViewController.location = currentLocation;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    //[resultLabel setText:resultString];
                    [self presentViewController:confirmViewController animated:YES completion:nil];
                });
            }

        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [scanningLabel setText:string];
        //overlayImageView.image = resultUIImage;
    });
    
}

//That's for the US dollar bills
/*
- (NSString *) getSerialNumber:(NSString *) string
{
    int i, j;
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (i=0; i<string.length; i++) {
        
        if (string.length - i < 10) {
            return nil;
        }
                
        if ([string characterAtIndex:i] >= 'A' && [string characterAtIndex:i] <= 'L') {
            
            for (j=i+1; j<i+9; j++) {
                if ([string characterAtIndex:j] < '0' || [string characterAtIndex:j] > '9') {
                    break;
                }
            }
            
            if(j != i+9){
                i = j - 1;
                continue;
            }
            
            if ([string characterAtIndex:i+9] >= 'A' && [string characterAtIndex:i+9] <= 'Z') {
                if (i!=0 && [string characterAtIndex:i-1] >= 'A' && [string characterAtIndex:i-1] <= 'Z') {
                    return [string substringWithRange:NSMakeRange(i-1, 11)];
                }
                else{
                    return [string substringWithRange:NSMakeRange(i, 10)];
                }
            }
            else {
                i = i + 9;
            }
        }
        
    }
    return nil;
}*/

//For Singapore dollar bills
- (NSString *) getSerialNumber:(NSString *) string
{
    int i, j;
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (i=0; i<(int)string.length; i++) {
        if (i>(int)string.length-9) {
            break;
        }
        for (j=0; j<9; j++) {
            if (j==1 || j==2) {
                if ([string characterAtIndex:i+j]<'A' || [string characterAtIndex:i+j]>'Z') {
                    break;
                }
            } else {
                if ([string characterAtIndex:i+j]<'0' || [string characterAtIndex:i+j]>'9') {
                    break;
                }
            }
            if (j==8) {
                return [string substringWithRange:NSMakeRange(i, 9)];
            }
        }
    }
    return nil;
}

- (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return documentsDirectoryPath;
}

- (void) initTesseract
{
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
    
	NSString *dataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tessdata"];
	/*
	 Set up the data in the docs dir
	 want to copy the data to the documents folder if it doesn't already exist
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:dataPath]) {
		// get the path to the app bundle (with the tessdata dir)
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
		if (tessdataPath) {
			[fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
		}
	}

	NSString *dataPathWithSlash = [[self applicationDocumentsDirectory] stringByAppendingString:@"/"];
	setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
	
	// init the tesseract engine.
	tess = new tesseract::TessBaseAPI();
	
	tess->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "eng");
    tess->SetVariable("tessedit_char_whitelist", "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    //disable dictionary
    tess->SetVariable("load_system_dawg", "F");
    tess->SetVariable("load_freq_dawg", "F");
    tess->SetVariable("load_punc_dawg", "F");
    tess->SetVariable("load_number_dawg", "F");
    tess->SetVariable("load_unambig_dawg", "F");
    tess->SetVariable("load_bigram_dawg", "F");
    tess->SetVariable("load_fixed_length_dawgs", "F");
    //choice iteration
    //tess->SetVariable("save_best_choices", "T");
    tess->SetVariable("save_blob_choices", "T");
}

- (NSString *) ocrImage: (UIImage *) uiImage
{
	
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
	
    int n = 0;
    bool hit = false;
	CGSize imageSize = [uiImage size];
	double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
	double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
	const UInt8 *imageData = CFDataGetBytePtr(data);
	
	// this could take a while. maybe needs to happen asynchronously.
	//char* text = tess->TesseractRect(imageData,(int)bytes_per_pixel,(int)bytes_per_line, 0, 0,(int) imageSize.width,(int) imageSize.height);
    tess->SetImage( imageData, (int) imageSize.width, (int) imageSize.height, (int)bytes_per_pixel, (int)bytes_per_line);
    tess->Recognize(NULL);
    //***********
    
    char *text = tess->GetUTF8Text();
    NSLog(@"Converted text: %@",[NSString stringWithCString:text encoding:NSUTF8StringEncoding]);

    NSString *result = [[NSString alloc] init];
    result = @"";
    tesseract::ResultIterator* ri = tess->GetIterator();
    tesseract::ChoiceIterator* ci;
    if(ri != NULL)
    {
        do
        {
            const char* symbol = ri->GetUTF8Text(tesseract::RIL_SYMBOL);            
            if(symbol!=NULL && ((*symbol>='0' && *symbol <='9') || (*symbol>='A' && *symbol<='Z')))
            {
                float conf = ri->Confidence(tesseract::RIL_SYMBOL);
                NSLog(@"next symbol: %s conf: %f", symbol, conf);
                
                //const tesseract::ResultIterator itr = *ri;
                ci = new tesseract::ChoiceIterator(*ri);
                
                if (n==1 || n==2)
                {
                    
                    do
                    {
                        const char* choice = ci->GetUTF8Text();
                        NSLog(@"choice: %s conf: %f", choice, ci->Confidence());
                        if(*choice>='A' && *choice <='Z' && ci->Confidence()>=50)
                        {
                            result = [result stringByAppendingString:[NSString stringWithCString:choice encoding:NSUTF8StringEncoding]];
                            n++;
                            hit = true;
                            break;
                        }
                        
                    }
                    while(ci->Next());
                    
                    if (hit == false) {
                        result = @"";
                        n = 0;
                    }
                    hit = false;
                }
                else
                {
                    do
                    {
                        const char* choice = ci->GetUTF8Text();
                        NSLog(@"choice: %s conf: %f", choice, ci->Confidence());
                        if(*choice>='0' && *choice <='9' && ci->Confidence()>=50)
                        {
                            result = [result stringByAppendingString:[NSString stringWithCString:choice encoding:NSUTF8StringEncoding]];
                            n++;
                            hit = true;
                            break;
                        }
                    }
                    while(ci->Next());
                    
                    if (hit == false) {
                        result = @"";
                        n = 0;
                    }
                    hit = false;
                }
                delete ci;
                if (n == 9) {
                    break;
                }
            }
            
            delete[] symbol;
        }
        while((ri->Next(tesseract::RIL_SYMBOL)));
    }
    
    //***********
    CFRelease(data);
    NSLog(@"%@", result);
    return result;
	//return [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
}

@end
