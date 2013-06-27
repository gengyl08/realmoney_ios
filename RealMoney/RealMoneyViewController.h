//
//  RealMoneyViewController.h
//  RealMoney
//
//  Created by Yilong Geng on 5/16/13.
//  Copyright (c) 2013 Yilong Geng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <Corevideo/CVPixelBuffer.h>
#import <coremedia/CMTime.h>
#import "baseapi.h"
#import "CoreLocationController.h"
#import "ConfirmViewController.h"

@interface RealMoneyViewController : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate, CLLocationManagerDelegate>

@property (retain) ConfirmViewController *confirmViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (retain) CLLocation *currentLocation;
@property (nonatomic, retain) UILabel *scanningLabel;
@property (nonatomic, retain) UILabel *resultLabel;
//@property (nonatomic, retain) UIImageView *overlayImageView;
@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureVideoDataOutput *videoDataOutput;
@property tesseract::TessBaseAPI *tess;
@property float roiX;
@property float roiY;
@property float roiWidth;
@property float roiHeight;

@end