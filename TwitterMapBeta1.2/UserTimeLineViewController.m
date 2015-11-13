//
//  UserTimeLineViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/6.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "UserTimeLineViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "ValidateHelper.h"
@interface UserTimeLineViewController()
@property (strong, nonatomic)TWTRAPIClient *client;

@end

@implementation UserTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    self.navigationItem.title = @"My Timeline";
    
    //test network
    [self networkTest];
    NSString *userID = [Twitter sharedInstance].session.userID;
    self.client = [[TWTRAPIClient alloc]initWithUserID:userID];
    [self getUserNameFromID:userID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)networkTest{
    NSString *userID=[Twitter sharedInstance].sessionStore.session.userID;
    
    [self getUserNameFromID2:userID];
    
}
-(void)getUserNameFromID2:(NSString*)userID {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/lookup.json";
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                [ValidateHelper alertWithTitle:self title:@"Network issue" message:@"unable to connet twitter server, please check your network"];
            }
        }];
    }
}

-(void)getUserNameFromID:(NSString*)userID {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/lookup.json";
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    if (request) {
        [self.client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                [self setDataSourceWithScreenName:[[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject] objectForKey:@"screen_name"]];
            }
        }];
    }
}

-(void) setDataSourceWithScreenName:(NSString*)str_name{
    self.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:str_name APIClient:self.client];
}
@end
