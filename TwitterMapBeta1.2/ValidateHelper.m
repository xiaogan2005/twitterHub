//
//  ValidateHelper.m
//  UserInfoProjectPractise
//
//  Created by GuoRui on 10/21/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "ValidateHelper.h"
#import <UIKit/UIKit.h>
@implementation ValidateHelper
+(BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


+(BOOL) checkPhoneNumer:(NSString *)str{
    //using Apple NSDataDetector
    //using Apple NSTextCheckingTypePhoneNumber
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    
    NSRange inputRange = NSMakeRange(0, [str length]);
    NSArray *matches = [detector matchesInString:str options:0 range:inputRange];
    
    // no match at all
    if ([matches count] == 0) {
        return NO;
    }
    
    // found match but we need to check if it matched the whole string
    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
    
    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length) {
        // it matched the whole string
        return YES;
    }
    else {
        // it only matched partial string
        return NO;
    }
}

+(void) emailAlert:(UIViewController *)view{
    
    UIAlertController *alerCont=[UIAlertController alertControllerWithTitle:@"attention" message:@"please enter the right email" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alerCont addAction:okButton];
    [view presentViewController:alerCont animated:YES completion:nil];
}

+(void) phoneNumberAlert:(UIViewController *)view{
    
    UIAlertController *alerCont=[UIAlertController alertControllerWithTitle:@"attention" message:@"please enter the right phone number" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alerCont addAction:okButton];
    [view presentViewController:alerCont animated:YES completion:nil];
}

+(void) alertWithTitle:(UIViewController *)view title:(NSString *)title message:(NSString *)message{
    
    UIAlertController *alerCont=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alerCont addAction:okButton];
    [view presentViewController:alerCont animated:YES completion:nil];
}

@end
