//
//  LocalTrendViewController.h
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/3.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalTrendViewController : UIViewController
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lng;
@property (strong, nonatomic) NSString *woeid;
@property (strong, nonatomic) NSString *placeName;
@property BOOL hasWoeid;

@end
