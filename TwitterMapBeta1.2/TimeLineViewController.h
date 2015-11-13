//
//  TimeLineViewController.h
//  TwitterMapBeta1.2
//
//  Created by Yu-Jung Lee on 2015/11/3.
//  Copyright © 2015年 GuoRui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import "MyTrend.h"

@interface TimeLineViewController : TWTRTimelineViewController
@property (strong, nonatomic) MyTrend *trend;

@end
