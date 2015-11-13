//
//  LocalTrendViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/3.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "LocalTrendViewController.h"
#import <TwitterKit/TwitterKit.h>

#import "TimeLineViewController.h"

@interface LocalTrendViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView_localTrend;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray *array_trend;

@end

@implementation LocalTrendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    if([self.placeName isEqualToString:@""]){
        self.navigationItem.title = @"Get Local Trends";
    } else {
        self.navigationItem.title = self.placeName;
    }
    
    self.array_trend = [[NSMutableArray alloc]init];
    if (self.hasWoeid) {
        [self getTrendDataWithWoeid:self.woeid];
    } else {
        [self getWoeidFromLat:self.lat AndLng:self.lng];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - twitter
-(void) getWoeidFromLat:(NSString*)lat AndLng:(NSString*)lng{
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/trends/closest.json";
    NSDictionary *params = @{@"lat":lat,@"long":lng};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                [self getTrendDataWithWoeid:[json[0] objectForKey:@"woeid"]];
            }
        }];
    }
}

-(void) getTrendDataWithWoeid:(NSString*)woeid {
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/trends/place.json";
    NSDictionary *params = @{@"id":[NSString stringWithFormat:@"%@", woeid]};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                NSDictionary *trendDict = [json[0] objectForKey:@"trends"];
                for(NSDictionary *trend in trendDict){
                    MyTrend *obj = [[MyTrend alloc]init];
                    obj.name = [trend objectForKey:@"name"];
                    obj.query = [trend objectForKey:@"query"];
                    [self.array_trend addObject:obj];
                }

                //disable the activity indicator
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView_localTrend reloadData];
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
    return self.array_trend.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    MyTrend *obj = [self.array_trend objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.name;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier]isEqualToString:@"Show"]) {
        TimeLineViewController *vController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView_localTrend indexPathForSelectedRow];
        vController.trend = [self.array_trend objectAtIndex:indexPath.row];
    }
}


@end
