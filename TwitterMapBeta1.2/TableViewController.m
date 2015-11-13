//
//  TableViewController.m
//  TwitterMapBeta1.2
//
//  Created by GuoRui on 10/29/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "TableViewController.h"
#import "MyCell.h"
#import <Twitter/Twitter.h>
#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>
#import "ValidateHelper.h"
@interface TableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button_MorseCode;
@property (weak, nonatomic) IBOutlet UIButton *button_twitterMap;

@property (weak, nonatomic) IBOutlet UIButton *button_MorseCodeEncrpty;



@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
    
    //add title
    self.navigationItem.title = @"Main Menu";
    //change title color
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [self networkTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
