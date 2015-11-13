//
//  FavoriteViewController.m
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/7.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import "FavoriteViewController.h"
#import "ValidateHelper.h"
#import <TwitterKit/TwitterKit.h>

@interface FavoriteViewController() <TWTRTweetViewDelegate>
@property (strong, nonatomic) __block NSMutableArray *array_tweets;
@property (strong, nonatomic) TWTRAPIClient *client;


@end

static NSString *cellIdentifier = @"Cell";

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    self.navigationItem.title = @"My Favorite";
    
    //network test
    [self networkTest];
    self.array_tweets = [[NSMutableArray alloc] init];
    NSString *userID = [Twitter sharedInstance].session.userID;
    self.client = [[TWTRAPIClient alloc]initWithUserID:userID];
    [self getUserNameFromID:userID];
    
    // Setup tableview
//    self.tableView.estimatedRowHeight = 150;
//    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:cellIdentifier];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getUserNameFromID:(NSString*)userID {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/lookup.json";
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    if (request) {
        [self.client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                [self getFavoriteTweets:[[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject] objectForKey:@"screen_name"]];
            }
        }];
    }
}

-(void)getFavoriteTweets:(NSString*)screen_name  {
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/favorites/list.json";
    NSDictionary *params = @{@"screen_name":screen_name};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *dict in json){
                    [self.array_tweets addObject:[dict objectForKey:@"id_str"]];
                }
            }
//            NSLog(@"Favorate tweets:\n%@", self.array_tweets);
            [self loadTweets];
        }];
    }
}

-(void) loadTweets{
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].session.userID];
    [client loadTweetsWithIDs:self.array_tweets completion:^(NSArray *tweets, NSError *error) {
        if (tweets) { //mutableCopy = transfer array to mutable array
            self.array_tweets = [tweets mutableCopy];
            [self.tableView reloadData];
        } else {
            NSLog(@"Failed to load tweet: %@", [error localizedDescription]);
        }
    }];
}

# pragma mark - UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.array_tweets count];
}

- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.array_tweets[indexPath.row];
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.tweetView configureWithTweet:tweet];
    cell.tweetView.delegate = self;
//    cell.tweetView.theme = TWTRTweetViewThemeDark;
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.array_tweets[indexPath.row];
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.selectedTweet = [self.array_tweets objectAtIndex:indexPath.row];
//    [self performSegueWithIdentifier:@"ShowTweet" sender:self];
//    NSLog(@"%lu", indexPath.row);
}

//- (void)tweetView:(TWTRTweetView *)tweetView didSelectTweet:(TWTRTweet *)tweet {
//    self.selectedTweet = tweet;
//    [self performSegueWithIdentifier:@"ShowTweet" sender:self];
//}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if([[segue identifier]isEqualToString:@"ShowTweet"]) {
//        MyTweetViewController *vController = [segue destinationViewController];
////        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
////        NSLog(@"%lu", indexPath.row);
//        vController.tweet = self.selectedTweet;
//    }
//}

@end
