//
//  UserInfo.h
//  UserInfoProjectPractise
//
//  Created by GuoRui on 10/21/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property NSString* firstName;
@property NSString* lastName;
@property NSString* email;
@property NSString* phoneNumber;
@property NSString* address;
-(UserInfo *)initWithParameters:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber address:(NSString *) address;
@end
