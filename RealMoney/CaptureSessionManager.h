#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "RealMoneyViewController.h"

#ifndef CAPTURE_SESSION_MANAGER
#define CAPTURE_SESSION_MANAGER

@interface CaptureSessionManager : NSObject {

}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (void)addVideoInput;
- (void)addVideoDataOutput;
@end

#endif