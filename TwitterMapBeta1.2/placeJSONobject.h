//
//  placeJSONobject.h
//  TwitterMapBeta1.2
//
//  Created by GuoRui on 11/4/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface placeJSONobject : NSObject
@property (nonatomic)NSString *placeId;
@property (nonatomic)NSString *full_name;
@property (nonatomic)NSString *country_code;
@property (nonatomic)NSString *country;
@property (nonatomic)NSString *centroid_lat;
@property (nonatomic)NSString *centroid_long;
@end
