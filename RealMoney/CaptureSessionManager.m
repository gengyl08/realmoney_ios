#import "CaptureSessionManager.h"


@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
//@synthesize realMoneyViewController;


#pragma mark Capture Session Configuration

- (id)init/*:(RealMoneyViewController *) realMoneyViewController*/{
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
        //TODO: change this to proper value
        captureSession.sessionPreset = AVCaptureSessionPresetMedium;
                
      //  [self setRealMoneyViewController:realMoneyViewController];
        [self addVideoPreviewLayer];
        [self addVideoInput];
        [self addVideoDataOutput];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (void)addVideoDataOutput {
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [captureSession addOutput:output];
    
    // Configure your output.
    //dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    //[output setSampleBufferDelegate:realMoneyViewController queue:queue];
    //dispatch_release(queue);
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    if(connection.supportsVideoMinFrameDuration)
    {
        connection.videoMinFrameDuration = CMTimeMake(1, 1);
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

@end
