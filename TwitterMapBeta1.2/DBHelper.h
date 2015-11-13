//
//  DBHelper.h
//  UserInfoProjectPractise
//
//  Created by GuoRui on 10/21/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "UserInfo.h"
@interface DBHelper : NSObject
+(void)initDB;
+(void) saveToDB:(UserInfo *)userInfoObj;
+(void)getInfoFromDB;
+(BOOL)checkUserExist;
+(NSString *)selectEmailFromDB:(NSString *)str;
+(UserInfo *)selectAllFromDBwithEmail:(NSString *)str;
@end
