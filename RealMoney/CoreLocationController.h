//
//  CoreLocationController.h
//  RealMoney
//
//  Created by Yilong Geng on 5/27/13.
//  Copyright (c) 2013 Yilong Geng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoreLocationController : NSObject <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;
@end

@protocol CoreLocationControllerDelegate
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end