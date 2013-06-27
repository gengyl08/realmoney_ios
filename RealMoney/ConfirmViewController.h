//
//  ConfirmViewController.h
//  RealMoney
//
//  Created by Yilong Geng on 5/28/13.
//  Copyright (c) 2013 Yilong Geng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ConfirmViewController : UIViewController <NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (retain) CLLocation *location;
@property (retain) NSString *serialNumber;
@property (retain) NSMutableData *responseData;

- (IBAction)send:(id)sender;

@end
