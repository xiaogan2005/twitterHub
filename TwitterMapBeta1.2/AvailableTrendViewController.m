//
//  AvailableTrendViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/3.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "AvailableTrendViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "MyWoeid.h"
#import "LocalTrendViewController.h"

@interface AvailableTrendViewController() <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableDictionary *dictionary_location;
@property (strong, nonatomic) NSMutableArray *array_country;
@property (strong, nonatomic) NSString *str_currentSelected;

@end


@implementation AvailableTrendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    self.navigationItem.title = @"Trends Around World ";
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    
    self.str_currentSelected = @"Worldwide";
    self.dictionary_location = [[NSMutableDictionary alloc]init];
    self.array_country = [[NSMutableArray alloc]init];
    [self getAvailableLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) getAvailableLocation {
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/trends/available.json";
    NSDictionary *params = @{};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                [self.array_country addObject:@"Worldwide"];
                NSMutableArray *worldwideArray = [[NSMutableArray alloc]init];
                [self.dictionary_location setObject:worldwideArray forKey:@"Worldwide"];
                
                for(NSDictionary *location in json) {
                    NSString *name = [location objectForKey:@"name"];
                    NSString *woeid = [location objectForKey:@"woeid"];
                    
                    NSString *country = [location objectForKey:@"country"];
                    if([country isEqualToString:@""]) {
                        country = @"Worldwide";
                    }
                    
                    NSString *placeType = [[location objectForKey:@"placeType"] objectForKey:@"name"];
                    MyWoeid *obj = [[MyWoeid alloc]init];
                    obj.name = name;
                    obj.woeid = woeid;
                    
                    if([placeType isEqualToString:@"Country"]) {
                        [self.array_country addObject:obj.name];
                        [worldwideArray addObject:obj];
                    }
                    
                    NSMutableArray *array = [self.dictionary_location objectForKey:country];
                    if (!array) {
                        array = [[NSMutableArray alloc]init];
                        [self.dictionary_location setObject:array forKey:country];
                    }
                    [array addObject:obj];
                }
                
                [self.pickerView reloadAllComponents];
                
                //disable the activity indicator
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    self.activityIndicator.hidden = YES;
                });
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

#pragma mark - table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dictionary_location objectForKey:self.str_currentSelected] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    MyWoeid *obj = [[self.dictionary_location objectForKey:self.str_currentSelected] objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.name;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier]isEqualToString:@"Show"]) {
        LocalTrendViewController *vController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MyWoeid *obj = [[self.dictionary_location objectForKey:self.str_currentSelected] objectAtIndex:indexPath.row];
        vController.woeid = obj.woeid;
        vController.placeName = [NSString stringWithFormat:@"Trends @ %@ ", obj.name];
        vController.hasWoeid = YES;
    }
}

#pragma mark - picker view methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.array_country.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.array_country objectAtIndex:row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.str_currentSelected = [self.array_country objectAtIndex:row];
    [self.tableView reloadData];
}

@end
