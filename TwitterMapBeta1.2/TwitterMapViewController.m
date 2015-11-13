//
//  TwitterMapViewController.m
//  TwitterMapBeta1.2
//
//  Created by GuoRui on 11/2/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "TwitterMapViewController.h"
#import "TweetObj.h"
#import <MapKit/MapKit.h>
#import "ValidateHelper.h"
#import "SimulateActionSheet.h"
#import "placeJSONobject.h"
#import "TweetContentViewController.h"
#import <UIKit/UIKit.h>
@interface TwitterMapViewController ()<SimulateActionSheetDelegate,MKMapViewDelegate, CLLocationManagerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField_keyword;

@property (weak, nonatomic) IBOutlet UILabel *label_miles;
@property (weak, nonatomic) IBOutlet UITextField *textField_place_or_address;
- (IBAction)button_click_showTweets:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider_miles;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sement_city_or_address;

@property (strong,nonatomic) NSMutableArray *array_tweets;


//for popup actionsheet to choose place
@property SimulateActionSheet* sas_picker;
@property NSMutableArray *array_places;
@property placeJSONobject *choosenPlace;

@property NSMutableArray *array_places_name;

//map properties
@property (weak, nonatomic) IBOutlet MKMapView *mapView_1;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property  (nonatomic, strong)CLLocationManager *CLLManager_1;
@property  (nonatomic, strong)MKPointAnnotation *point;


//send the tweet string
@property NSString *string_tweet;

@end

//twitter query values
NSString *str_keyword;
NSString *str_address;
NSString *str_place;
float versionNumber;
@implementation TwitterMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _array_tweets=[[NSMutableArray alloc]init];
    _array_places=[[NSMutableArray alloc]init];
    _array_places_name=[[NSMutableArray alloc]init];
    
    //add title
    self.navigationItem.title = @"Twitter Map";
    
    [self networkTest];
    NSString *version=[[UIDevice currentDevice]systemVersion];
    versionNumber=[version floatValue];
    NSLog(@"%@",version);
    [self mapInit];
    
    
    
    
   
    [_CLLManager_1 startUpdatingLocation];
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

- (IBAction)sliderValueChanged:(id)sender {
    _label_miles.text=[NSString stringWithFormat:@"%.2f miles",_slider_miles.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark geocode
-(void) geocodeAddress:(NSString*)address {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    __block NSArray *placeMarksToReturn=nil;
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placeMarks, NSError *error) {
        if(!error){
            placeMarksToReturn = placeMarks;
            
            [self saveAddress:placeMarksToReturn];
        }
    }];
    
    
}
#pragma mark twitter query
-(void)twitterGeoSearch:(NSString *)str_place{
    //https://api.twitter.com/1.1/geo/search.json?query= query for city name or address
     TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/geo/search.json";
    
    //replace  space with %20 795%20Folsom%20St
    NSString *place=[NSString stringWithFormat:@"%@",_textField_place_or_address.text];
    //url encoded
   NSString *urlEncoded = [place stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //NSLog(urlEncoded);
    NSDictionary *params = @{@"query":urlEncoded};
    
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                //NSLog([json description]);
                [self savePlaceToObj:json];
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }

    
    
    
}

-(void)twitterQueryWithPlace:(placeJSONobject *)place{
    
    NSString *str_lat=place.centroid_lat;
    NSString *str_lng=place.centroid_long;
    //get miles
    float miles=_slider_miles.value;
    NSString *str_geocode=[NSString stringWithFormat:@"%@,%@,%.4fmi",str_lat,str_lng,miles];
    
    //handle string with only empty space
    NSString *str_keyword_withoutSpace=[str_keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // handle url encoded
    str_keyword=[str_keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str_geocode=[str_geocode  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if(str_keyword_withoutSpace.length==0){
        [ValidateHelper alertWithTitle:self title:@"keyword is empty" message:@"please enter the keyword"];
    }else{
        [self twitterQuery:str_keyword withGeoCode:str_geocode];
    }
    
}


-(void)twitterQuery:(NSString *)keyword withGeoCode:(NSString *)geocode{
    //TWTRAPIClient *client = [[TWTRAPIClient alloc] init]; THIS ONE is not working here
    //TWTRAPIClient *client = [Twitter sharedInstance].APIClient; //working
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID]; //working too
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    //NSDictionary *params = @{@"q":@"new york",@"count":@"2"};//few count to see the format
    //40.7127° N, 74.0059° W nyc
    NSDictionary *params = @{@"q":keyword,@"count":@"50",@"geocode":geocode};//37.781157,-122.398720,1mi, geocode 不能有空格, 注意south 和west 是负数 @"40.7127,-74.0059,10mi"
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                //save to file
                /*
                NSString *str=[json description];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"file.txt"];
                //NSLog([json description]);
                NSLog(@"%@",filePath);
                
                [str writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
                 */
                [self saveTweetsToObj:json];
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }

}

#pragma mark get obj
//get twitter objs
//add code to handle nil, use count not nil
-(void)saveTweetsToObj:(id) object{
    
    
    if([object isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict_main=object;
        //NSLog(@"the main dict is%@",dict_main);
        
        
            NSArray *arr_result=[dict_main objectForKey:@"statuses"];
        if([arr_result isKindOfClass:[NSNull class]]||arr_result.count==0){
            [ValidateHelper alertWithTitle:self title:@"error" message:@"no tweet match searching"];
            return;
            
        }
        //NSLog(@"the result is:%@",arr_result);
        
        
        for(int i=0;i<arr_result.count;i++){
            NSDictionary *dict_temp=arr_result[i];
            
            NSString *createdAt=[dict_temp objectForKey:@"created_at"];
            
            NSString *tweetText=[dict_temp objectForKey:@"text"];
            
            NSDictionary *user=[dict_temp objectForKey:@"user"];
            NSString *userScreenName=[user objectForKey:@"screen_name"];
            
            
            NSDictionary *geo=[dict_temp objectForKey:@"geo"];
            NSArray *coordinates=nil;
            if(![geo isKindOfClass:[NSNull class]]&&geo.count>0){
                coordinates=[geo objectForKey:@"coordinates"];
            }
            
            
            TweetObj  *obj=[[TweetObj alloc]init];
            obj.user_screen_name=userScreenName;
            obj.tweet_text =tweetText;
            if(coordinates.count==2){
                
                NSString *lat=[NSString stringWithFormat:@"%@",coordinates[0]];
                //NSLog(@"the lat is:%@",lat);
                NSString *lng=[NSString stringWithFormat:@"%@",coordinates[1]];
                obj.coordinate_lat=lat;
                //NSLog(@"the lat is:%@",lat);
                obj.coordinate_long=lng;
            }


            
           
            obj.created_at=createdAt;
            
            
            //handle if something is nil
            if(obj.coordinate_lat.length==0||obj.coordinate_long==0||obj.user_screen_name.length==0||obj.tweet_text.length==0){
                //something is missing in this obj, not add to object
                
            }else{
            [_array_tweets addObject:obj];
            }
            
            
            
        }
        
        //cause the load is ansync method
        [ValidateHelper alertWithTitle:self  title:@"finish loading tweets"  message:@"finish loading tweets" ];
                [self mapUpdate];
    }
}

-(void)savePlaceToObj:(id) object{
    
    
    if([object isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict_main=object;
       
        NSDictionary *dict_result=[dict_main objectForKey:@"result"];
        NSArray *arr_placesFormJson=[dict_result objectForKey:@"places"];
        //if places==null then address not found
        NSLog(@"the result is:%@",arr_placesFormJson);
        
        for(int i=0;i<arr_placesFormJson.count;i++){
            NSDictionary *dict_temp=arr_placesFormJson[i];
            
            NSString *placeId=[dict_temp objectForKey:@"id"];
            
            NSString *full_name=[dict_temp objectForKey:@"full_name"];
            
            NSString *country_code=[dict_temp objectForKey:@"country_code"];
            NSString *country=[dict_temp objectForKey:@"country_code"];
            
            
            
            NSArray *centroid=[dict_temp objectForKey:@"centroid"];
            
            
            placeJSONobject  *obj=[[placeJSONobject alloc]init];
            obj.full_name=full_name;
            obj.placeId =[NSString stringWithFormat:@"%@",placeId];
            obj.country=country;
            obj.country_code =country_code;
            if(![centroid isKindOfClass:[NSNull class]]&&centroid.count==2){
            obj.centroid_lat=[NSString stringWithFormat:@"%@",centroid[1]];
                obj.centroid_long=[NSString stringWithFormat:@"%@",centroid[0]];
            }
            //if one item is missing then dont add to array
            if(obj.full_name.length>0&&obj.placeId.length>0&&obj.country.length>0&&obj.country_code.length>0&&obj.centroid_long>0&&obj.centroid_lat.length>0){
            [_array_places addObject:obj];
                [_array_places_name addObject:obj.full_name];
            }
            
            
        }
        
        
        //cause the load is ansync method
        if(_array_places.count==0){
            [ValidateHelper alertWithTitle:self title:@"no place found!" message:@"no place found with city name or address,please check again" ];
        }else{
            [ValidateHelper alertWithTitle:self  title:@"finished finding places"  message:@"finish finding places" ];
            // save obj array and give to pickerview
            [self showPickerView];
        }
        
    }
}


- (IBAction)button_click_showTweets:(id)sender {
    //get geosearch if place is not empty
    //remember to handle the null
    NSString *str_place=self.textField_place_or_address.text;
    str_keyword=_textField_keyword.text;
    if(str_place.length>0){
        if(self.sement_city_or_address.selectedSegmentIndex==0){
            //city names
            [self twitterGeoSearch:str_place];
        }else{
            //place address or place name use  geocoding
            [self geocodeAddress:str_place];
            
            
        }
        
        
        
    }else{
        [ValidateHelper alertWithTitle:self title:@"please enter the city name or address" message:@"please enter the city name or address" ];
    }
    
   
    
    
    
}
//@property (nonatomic)NSString *full_name;
//@property (nonatomic)NSString *country_code;
//@property (nonatomic)NSString *country;
//@property (nonatomic)NSString *centroid_lat;
//@property (nonatomic)NSString *centroid_long;
#pragma mark save address
-(void)saveAddress:(NSArray *)array{
    for(CLPlacemark *mark in array){
        placeJSONobject *obj=[[placeJSONobject alloc]init];
        CLLocationCoordinate2D coord=mark.location.coordinate;
        obj.centroid_lat=[NSString stringWithFormat:@"%f",coord.latitude];
        obj.centroid_long=[NSString stringWithFormat:@"%f",coord.longitude];
        NSString *name=[NSString stringWithFormat:@"%@,%@",mark.name,mark.country];//
        obj.full_name=name;
        [_array_places addObject:obj];
        
        [_array_places_name addObject:name];
    }
   
    
    



    //alert when finished
    if(_array_places.count==0){
        [ValidateHelper alertWithTitle:self title:@"no place found!" message:@"no place found with city name or address,please check again" ];
    }else{
        [ValidateHelper alertWithTitle:self  title:@"finished finding address"  message:@"finish finding address" ];
        // save obj array and give to pickerview
        [self showPickerView];
    }

}

#pragma mark location and map methods
-(void)mapInit{
    //map init
    _mapView_1.delegate=self;
    _CLLManager_1=[[CLLocationManager alloc]init];
    _CLLManager_1.delegate=self;
    if([_CLLManager_1 respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [_CLLManager_1 requestWhenInUseAuthorization];
        
    }
    [_CLLManager_1 setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //show user point on map
    
    CLAuthorizationStatus cs=[CLLocationManager authorizationStatus];
    if(cs!=kCLAuthorizationStatusNotDetermined&&cs!=kCLAuthorizationStatusDenied){
    _point=[[MKPointAnnotation alloc]init];
    
    _point.coordinate=_CLLManager_1.location.coordinate;
    
    NSLog(@"%@",[_point description]);
    _point.title=@"You are here";
    
    [self.mapView_1 addAnnotation:_point];
        _mapView_1.showsUserLocation=YES;
    }
   
   
}
-(void) mapUpdate{
    //clean map first
  [_mapView_1 removeAnnotations:_mapView_1.annotations];
    [_mapView_1 removeOverlays:_mapView_1.overlays];
    
    //show user point on map
     _mapView_1.showsUserLocation = YES;
    
    
    //zoom and center
    
    //update use slider_miles to control region and radius 1:1609.34 meters
    CLLocationDistance regionLength=_slider_miles.value*1609*1.5;
    CLLocationCoordinate2D locationCenter=CLLocationCoordinate2DMake([_choosenPlace.centroid_lat doubleValue], [_choosenPlace.centroid_long doubleValue]);
    //add a search center
    MKPointAnnotation *searchCenter=[[MKPointAnnotation alloc]init];
    searchCenter.coordinate=locationCenter;
    searchCenter.title=_choosenPlace.full_name;
    [_mapView_1 addAnnotation:searchCenter];
    
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(locationCenter, regionLength, regionLength);
    [self.mapView_1 setRegion:[_mapView_1 regionThatFits:region]animated:YES];
    
    //for adding the circle(overlay)
    CLLocationDistance radius=_slider_miles.value*1609;
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:locationCenter radius:radius];
    [_mapView_1 addOverlay:circle];
    
    [self showPointsInMap:_array_tweets];
    
    
    
    
    
    
}
-(void)showPointsInMap:(NSArray *)array_objs{
    //show point in map
    for(TweetObj *obj in array_objs){
    _point=[[MKPointAnnotation alloc]init];
        if(obj.coordinate_lat.length>0){
            _point.coordinate=CLLocationCoordinate2DMake([obj.coordinate_lat floatValue], [obj.coordinate_long floatValue]);
            // NSLog(@"lag %@, lng %@", _obj.lat,_obj.str_lng);
        }
    
    NSLog(@"%@",[_point description]);
    _point.title=obj.user_screen_name;
    _point.subtitle=obj.tweet_text;
    [self.mapView_1 addAnnotation:_point];
    }
}

//-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
//    MKCircleView *circleView =[[MKCircleView alloc]initWithOverlay:overlay];
//    circleView.strokeColor = [UIColor greenColor];
//    circleView.fillColor = [[UIColor redColor]colorWithAlphaComponent:0.4];
//    return circleView;
//    
//}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay

{
    
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
     circleR.strokeColor = [UIColor blueColor];
    circleR.fillColor = [[UIColor cyanColor]colorWithAlphaComponent:0.4];
    
    
    
    return circleR;
    
}
#pragma mark zoom a map using button

- (IBAction)click_bt_zoomIn:(id)sender {
    [self  zoomMap:_mapView_1 byDelta:0.5];
}
- (IBAction)click_bt_zoomOut:(id)sender {
    [self  zoomMap:_mapView_1 byDelta:2.0];
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

//static version dont need this
//# pragma  mark will update all the time.
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    CLLocation *location=locations.lastObject;
//    //@.6f float with 6 digit after zero
//    NSLog(@"lat value is %.6f, lng value is %.6f",location.coordinate.latitude,location.coordinate.longitude);
//
//
//
//    //region should not be pointer, dont know why
//
//    //control  center and zoom for phone location
//
//
//
//
//
//}



//handle the case when GPS cant be used
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"the error message is:%@",error.localizedDescription);
}

#pragma mark for each Annotation is map, this method control the view and animation of annotation
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationview = nil;
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    
    static NSString *str =@"Identifier";
    // add pin
    
        MKPinAnnotationView *areaPin =[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:str];
        
        areaPin.animatesDrop = YES;
        areaPin.canShowCallout = YES;
       
        if([annotation.title isEqualToString:_choosenPlace.full_name]){
            
            areaPin.pinColor= MKPinAnnotationColorPurple;
            UIImage *image = [[UIImage imageNamed: @"love"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
            //areaPin.image=image; not working
            UIImageView *screwYouApple = [[UIImageView alloc] initWithImage: image];
            if(versionNumber>=9.0){
                areaPin.pinTintColor= [[UIColor redColor]colorWithAlphaComponent:0.5 ];}
            [areaPin addSubview: screwYouApple];
        }else{
            // image test
            UIImage *image = [[UIImage imageNamed: @"Twitter"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
            //areaPin.image=image; not working
            UIImageView *screwYouApple = [[UIImageView alloc] initWithImage: image];
            //screwYouApple.tintColor = [[UIColor redColor]colorWithAlphaComponent:0.4];
            [areaPin addSubview: screwYouApple];
            if(versionNumber>=9.0){
                areaPin.pinTintColor= [[UIColor blueColor]colorWithAlphaComponent:0.5 ];}else{
                 areaPin.pinColor= MKPinAnnotationColorGreen;
                }
        }
       //
        annotationview = areaPin;
        
        
        
    
    //annotation popout
    annotationview.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationview.canShowCallout = YES;
    return annotationview;
}




//Then callout method, using twitter stuff?

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    _string_tweet=view.annotation.subtitle;
    [self performSegueWithIdentifier:@"gotoTweetDetail" sender:self];
    
   
//    WebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyIdentifier"];
//    viewController.url=_obj.wikipedia;
//    
//    [self.navigationController pushViewController:viewController animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier]isEqualToString:@"gotoTweetDetail"]) {
        TweetContentViewController *vController = [segue destinationViewController];
        
        vController.string_tweet=_string_tweet;
    }
}
-(UIColor *)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    return  color;
}

#pragma mark    textfield

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return   YES;}      // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}           // became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}         // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextField *)textField{
    return  NO;
}

#pragma mark use SimulateActionSheet methods

//my defined show pickerview function
-(void)showPickerView{
    //show in picker view
    _sas_picker = [SimulateActionSheet styleDefault];
    _sas_picker.delegate = self;
    //必须在设置delegate之后调用，否则无法选中指定的行
    NSLog(@"%lu",_array_places.count/2 );
    [_sas_picker selectRow:_array_places_name.count/2 inComponent:0 animated:YES];
    [_sas_picker show:self];
}

-(void)actionCancle{
    [_sas_picker dismiss:self];
    
     //clean up remove all objects
    [_array_places removeAllObjects];
    [_array_places_name removeAllObjects];
    [_array_tweets removeAllObjects];
}

-(void)actionDone{
    [_sas_picker dismiss:self];
    
    NSUInteger index = [_sas_picker selectedRowInComponent:0];
    _choosenPlace=[_array_places objectAtIndex:index];
    
    //do the twitter search query now
    [self twitterQueryWithPlace:_choosenPlace];
    //NSLog(@"done with index of %lu",(unsigned long)index);
    
    
    //clean up remove all objects
    [_array_places removeAllObjects];
    [_array_places_name removeAllObjects];
    [_array_tweets removeAllObjects];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _array_places_name.count;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component

{
    return [_array_places_name objectAtIndex:row];
}




@end
