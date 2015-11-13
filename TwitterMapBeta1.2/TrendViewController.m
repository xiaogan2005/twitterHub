//
//  TrendViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/4.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "TrendViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocalTrendViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "ValidateHelper.h"
@interface TrendViewController() <CLLocationManagerDelegate>

- (IBAction)buttonAction_countryList:(id)sender;
- (IBAction)buttonAction_myLocation:(id)sender;
- (IBAction)buttonAction_chooseOnMap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_myLocation;

@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end

@implementation TrendViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    self.navigationItem.title = @"Get Trend";
    
    //network test
    [self networkTest];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    self.button_myLocation.enabled = NO;
    CLAuthorizationStatus cs=[CLLocationManager authorizationStatus];
    if(cs != kCLAuthorizationStatusNotDetermined && cs !=kCLAuthorizationStatusDenied){
        self.button_myLocation.enabled = YES;
        
    }else{
        [ValidateHelper alertWithTitle:self title:@"GPS location is disabled" message:@"Please go to settings->privacy->location services->Twitter Hub to setup GPS enable"];
    }
}
-(void)networkTest{
    NSString *userID=[Twitter sharedInstance].sessionStore.session.userID;
    
    [self getUserNameFromID:userID];
    
}
-(void)getUserNameFromID:(NSString*)userID {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/lookup.json";
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                [ValidateHelper alertWithTitle:self title:@"Network issue" message:@"Unable to connect twitter server, please check your network"];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action
- (IBAction)buttonAction_countryList:(id)sender {
    [self performSegueWithIdentifier:@"ShowList" sender:self];
}

- (IBAction)buttonAction_myLocation:(id)sender {
    [self performSegueWithIdentifier:@"ShowLocal" sender:self];
}

- (IBAction)buttonAction_chooseOnMap:(id)sender {
    [self performSegueWithIdentifier:@"ShowMap" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"ShowList"]) {
    } else if([[segue identifier]isEqualToString:@"ShowLocal"]) {
        LocalTrendViewController *vController = [segue destinationViewController];
        vController.lat = [NSString stringWithFormat:@"%.6f", self.userLocation.coordinate.latitude];
        vController.lng = [NSString stringWithFormat:@"%.6f", self.userLocation.coordinate.longitude];
        vController.placeName = @"Trends Around Me";
    } else if([[segue identifier]isEqualToString:@"ShowMap"]) {
    }
}

#pragma mark - location manager
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.userLocation = locations.lastObject;
    self.button_myLocation.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"The Error message is %@",error.localizedDescription);
}

@end
