//
//  TimeLineViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/3.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "TimeLineViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface TimeLineViewController ()

@end

@implementation TimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    self.navigationItem.title = [[[self.trend.query stringByReplacingOccurrencesOfString:@"%23" withString:@"#"] stringByReplacingOccurrencesOfString:@"%22" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    //TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    TWTRAPIClient *client=[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
//    self.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"screenName" APIClient:client];
    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:[NSString stringWithFormat:@"#%@", self.trend.query] APIClient:client];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
