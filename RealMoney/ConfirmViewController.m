//
//  ConfirmViewController.m
//  RealMoney
//
//  Created by Yilong Geng on 5/28/13.
//  Copyright (c) 2013 Yilong Geng. All rights reserved.
//

#import "ConfirmViewController.h"

@interface ConfirmViewController ()

@end

@implementation ConfirmViewController

@synthesize label;
@synthesize location;
@synthesize serialNumber;
@synthesize responseData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
}

- (void)viewWillAppear:(BOOL)animated
{
    label.text = [NSString stringWithFormat:@"time:%@\nlongitude:%f\nlatitude:%f\nSN:%@", [location.timestamp description], location.coordinate.longitude, location.coordinate.latitude, serialNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)send:(id)sender {
    responseData = [NSMutableData data];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
									requestWithURL:[NSURL URLWithString:@"http://10.33.6.88/realmoney/index.php"]];
    
    NSString *params = [[NSString alloc] initWithFormat:@"ID=gyl&SN=%@&longitude=%f&latitude=%f", serialNumber, location.coordinate.longitude, location.coordinate.latitude];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Getting your response string
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    self.responseData = nil;
    label.text = responseString;
}
@end
