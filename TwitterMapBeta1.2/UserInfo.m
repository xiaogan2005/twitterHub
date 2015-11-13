//
//  UserInfo.m
//  UserInfoProjectPractise
//
//  Created by GuoRui on 10/21/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
-(UserInfo *)initWithParameters:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber address:(NSString *) address{
    UserInfo *userInfo=[[UserInfo alloc]init];
    userInfo.firstName=firstName;
    userInfo.lastName=lastName;
    userInfo.email=email;
    userInfo.phoneNumber=phoneNumber;
    userInfo.email=email;
    userInfo.address=address;
    return userInfo;
}
@end
