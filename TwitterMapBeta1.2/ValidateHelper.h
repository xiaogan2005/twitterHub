//
//  ValidateHelper.h
//  UserInfoProjectPractise
//
//  Created by GuoRui on 10/21/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ValidateHelper : NSObject
+(BOOL) validateEmail: (NSString *) candidate;
+(void) emailAlert:(UIViewController *)view;
+(void) phoneNumberAlert:(UIViewController *)view;
+(BOOL) checkPhoneNumer:(NSString *)str;
+(void) alertWithTitle:(UIViewController *)view title:(NSString *)title message:(NSString *)message;
@end
