//
//  TweetObj.h
//  TwitterMapBeta1.2
//
//  Created by GuoRui on 11/3/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetObj : NSObject
@property (nonatomic) NSString *user_screen_name;
@property (nonatomic) NSString *tweet_text;
 @property (nonatomic) NSString *created_at;
@property (nonatomic) NSString *coordinate_lat;
@property (nonatomic) NSString *coordinate_long;
@end
