//
//  MapTrendViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/4.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "MapTrendViewController.h"
#import "LocalTrendViewController.h"
#import "MyWoeid.h"
#import "ValidateHelper.h"
@interface MapTrendViewController() <MKMapViewDelegate ,CLLocationManagerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *textField_searchPlace;
@property (weak, nonatomic) IBOutlet UIButton *button_trendOnMyLocation;
@property (weak, nonatomic) IBOutlet UIButton *button_trendOnSelectedPlace;
@property (weak, nonatomic) IBOutlet UIButton *button_currentLocation;

- (IBAction)buttonAction_currentLocation:(id)sender;
- (IBAction)buttonAction_searchPlace:(id)sender;
- (IBAction)buttonAction_trendOnMyLocation:(id)sender;
- (IBAction)buttonAction_trendOnSelectedPlace:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *userPin;
@property (strong, nonatomic) MKPointAnnotation *trendPin;
@property (strong, nonatomic) MKPointAnnotation *selectedPin;
@property MKCoordinateRegion coordRegion;
@property BOOL isNotFirstTime;
@property float versionNumber;

@end

@implementation MapTrendViewController

- (void)viewDidLoad
{
    //add title
    self.navigationItem.title = @"Get Trends by Pin on Map";
    
    [super viewDidLoad];
    self.textField_searchPlace.delegate = self;
    
    //location manager
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    CLAuthorizationStatus cs=[CLLocationManager authorizationStatus];
    if(cs == kCLAuthorizationStatusNotDetermined || cs ==kCLAuthorizationStatusDenied){
        self.button_currentLocation.enabled = NO;
        self.button_trendOnMyLocation.enabled = NO;
        [ValidateHelper alertWithTitle:self title:@"GPS location is disabled" message:@"Please go to settings->privacy->location services->Twitter Hub to setup GPS enable"];
    }
    self.button_trendOnSelectedPlace.enabled = NO;
    
    //map view
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.userPin = [[MKPointAnnotation alloc]init];
    self.trendPin = [[MKPointAnnotation alloc]init];
    self.selectedPin = [[MKPointAnnotation alloc]init];
    
    //version check
    NSString *version=[[UIDevice currentDevice]systemVersion];
    self.versionNumber = [version floatValue];
    
    //single tap
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self.mapView addGestureRecognizer:singleTapGesture];
    
//    UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapped:)];
//    LongTapGesture.numberOfTapsRequired = 1;
//    [self.mapView addGestureRecognizer:longTapGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action
- (IBAction)buttonAction_currentLocation:(id)sender {
    [self zoomTo:self.userPin.coordinate];
}

- (IBAction)buttonAction_searchPlace:(id)sender {
    [self searchAddress];
}

- (IBAction)buttonAction_trendOnMyLocation:(id)sender {
    self.selectedPin = self.userPin;
    [self performSegueWithIdentifier:@"Show" sender:self];
}

- (IBAction)buttonAction_trendOnSelectedPlace:(id)sender {
    self.selectedPin = self.trendPin;
    [self performSegueWithIdentifier:@"Show" sender:self];
}

#pragma mark - location manager
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (!self.isNotFirstTime) {
        self.isNotFirstTime = YES;
        CLLocation *location = locations.lastObject;
        [self zoomTo:location.coordinate];
        //add a pin
        [self addTitleAndSubtitleOn:self.userPin At:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"The Error message is %@",error.localizedDescription);
}

#pragma mark - map
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    self.selectedPin = annotationView.annotation;
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *str = @"Identifier";

    // add pin
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:str];
    UIColor *pinColor = [self getRandomColor];
    
    if (!pin){
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:str];
        if(self.versionNumber >= 9.0){
            pin.tintColor = pinColor;
            pin.pinTintColor = pinColor;
        }
    }
    
    pin.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    pin.animatesDrop = YES;
    pin.canShowCallout = YES;
    annotationView = pin;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapview annotationView:(MKAnnotationView *)annotationView calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"Show" sender:self];
}


#pragma mark - pin
-(void) addTitleAndSubtitleOn:(MKPointAnnotation *)pin At:(CLLocation *)location {
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *err){
        if(!err){
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            pin.coordinate = location.coordinate;
            [pin setTitle:[placeMark.addressDictionary objectForKey:@"City"]];
            [pin setSubtitle:[placeMark.addressDictionary objectForKey:@"State"]];
            [self.mapView addAnnotation:pin];
        }
    }];
}

- (void) zoomTo:(CLLocationCoordinate2D)locCoord{
    self.coordRegion = MKCoordinateRegionMakeWithDistance(locCoord, 20000, 20000);
    [self.mapView setRegion:self.coordRegion animated:YES];
}

-(void) putPinBy:(NSString*)address {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placeMarks, NSError *error) {
        if(!error){
            CLPlacemark *placemark = [placeMarks objectAtIndex:0];
            [self putTrendPin:placemark.location];
            [self zoomTo:placemark.location.coordinate];
        }
    }];
}

-(void) putTrendPin:(CLLocation *)location{
    [self.mapView removeAnnotation:self.trendPin];
    [self addTitleAndSubtitleOn:self.trendPin At:location];
}

#pragma mark - gesture methods
-(void)singleTapped:(UIGestureRecognizer*)singleTap{
    if([singleTap state] == UIGestureRecognizerStateEnded){
        self.button_trendOnSelectedPlace.enabled = YES;
        CGPoint point = [singleTap locationInView:self.mapView];
        UIView *view = [self.mapView hitTest:point withEvent:nil];
        //not tap on pin
        if(![view isKindOfClass:[MKPinAnnotationView class]]){
            self.trendPin.coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
            [self putTrendPin:[[CLLocation alloc]initWithLatitude:self.trendPin.coordinate.latitude longitude: self.trendPin.coordinate.longitude]];
        }
    }
}
//
//-(void)longTapped:(UIGestureRecognizer*)longTap{
//    if([longTap state] == UIGestureRecognizerStateBegan){
//        self.button_trendOnSelectedPlace.enabled = YES;
//        CGPoint point = [longTap locationInView:self.mapView];
//        UIView *view = [self.mapView hitTest:point withEvent:nil];
//        //not tap on pin
//        if(![view isKindOfClass:[MKPinAnnotationView class]]){
//            self.trendPin.coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
//            [self putTrendPin:[[CLLocation alloc]initWithLatitude:self.trendPin.coordinate.latitude longitude: self.trendPin.coordinate.longitude]];
//        }
//    }
//}

#pragma mark - textfield
- (void)searchAddress {
    NSString *str_searchPlace = [self.textField_searchPlace.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![str_searchPlace isEqualToString:@""]) {
        [self putPinBy:str_searchPlace];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchAddress];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textField_searchPlace resignFirstResponder];
}

#pragma mark - other
 -(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
     if([[segue identifier]isEqualToString:@"Show"]) {
         LocalTrendViewController *vController = [segue destinationViewController];
         vController.lat = [NSString stringWithFormat:@"%.6f", self.selectedPin.coordinate.latitude];
         vController.lng = [NSString stringWithFormat:@"%.6f", self.selectedPin.coordinate.longitude];
         vController.placeName = [NSString stringWithFormat:@"Trends @ %@ ", self.selectedPin.title];
     }
 }

//random color
- (UIColor*) getRandomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark zoom button

- (IBAction)click_bt_zoomIn:(id)sender {
    [self  zoomMap:_mapView byDelta:0.5];
}
- (IBAction)click_bt_zoomOut:(id)sender {
    [self  zoomMap:_mapView byDelta:2.0];
}

// delta is the zoom factor
// 2 will zoom out x2
// .5 will zoom in by x2
- (void)zoomMap:(MKMapView*)mapView byDelta:(float) delta {
    
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = mapView.region.span;
    //latitude: [-90, 90]
    //longitude: [-180, 180] dont over extends
    CLLocationDegrees latd=span.latitudeDelta*delta;
    CLLocationDegrees longd=span.longitudeDelta*delta;
    if(latd>=90){
        span.latitudeDelta=90;
    }else if(latd<=-90){
        span.latitudeDelta=-90;
    }else{
        span.latitudeDelta=latd;
    }
    
    if(longd>=180){
        span.longitudeDelta=180;
    }else if(latd<=-180){
        span.longitudeDelta=-180;
    }else{
        span.longitudeDelta=latd;
    }
    
    region.span=span;
    [mapView setRegion:region animated:YES];
    
}

@end
