//
//  DBHelper.m
//  UserInfoProjectPractise
//
//  Created by GuoRui on 10/21/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "DBHelper.h"
@interface DBHelper()


@end
@implementation DBHelper

static  NSString *databasePath;
static  sqlite3 *contactDB;
static  NSMutableArray *array_ObjArray;

+(void)initDB{
    NSArray *dirPaths;
    NSString *docsDir;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"UserInfo.db"]];
    
    //using userDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults  objectForKey:@"DataBasePath"];
    [userDefaults synchronize];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) // this is first time, u r installing the app.
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS UserInfo (ID INTEGER PRIMARY KEY AUTOINCREMENT, firstname TEXT, lastname TEXT, email TEXT,phonenumber TEXT, address TEXT )";
                //UNIQUE EMAIL
            if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            NSLog(@"sucessfully to create table");
            sqlite3_close(contactDB);
        }
        else
        {
            NSLog(@"Failed to open/create database") ;
        }
    }
    else
        NSLog(@"Data base already created") ;
    
    
}

+(void) saveToDB:(UserInfo *)userInfoObj{
   
    sqlite3_stmt   *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        
       
        
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO UserInfo (firstname, lastname, email,phonenumber, address) VALUES (\"%@\", \"%@\", \"%@\",\"%@\", \"%@\")",
                               userInfoObj.firstName, userInfoObj.lastName, userInfoObj.email,userInfoObj.phoneNumber, userInfoObj.address];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {   /*
             self.lb_LabelStatus.text = @"usrInfo added";
             self.lb_fullName.text = @"";
             self.txtF_Name.text = @"";
             self.txtF_Address.text = @"";
             */
            NSLog(@"usrInfo added into dataBase");
        } else {
            NSLog(@"failed added added into dataBase");
            NSLog(@"%d",sqlite3_step(statement));
        
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}


+(NSString *)selectEmailFromDB:(NSString *)str{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    NSString *email=@"";
    
    NSLog(@"the email to be found is %@",str);
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        
        NSString *querySQL =[NSString stringWithFormat:@"SELECT email FROM UserInfo WHERE  email LIKE '%@' ",str];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
           // NSLog(@"just get inside the select");
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
//                firstname = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]; //0 -ID 1- firstname;
//                email = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];//3- email
                email=[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
            }
            
            sqlite3_finalize(statement);
        }
        //NSLog(@"just get out the select query");
        sqlite3_close(contactDB);
        
    }
    return email;

}
+(UserInfo *)selectAllFromDBwithEmail:(NSString *)str{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    UserInfo *obj;
    
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        
        NSString *querySQL =[NSString stringWithFormat:@"SELECT * FROM UserInfo WHERE  email LIKE '%@'",str];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"just get inside the select");
            array_ObjArray =[NSMutableArray new];
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
               NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]; //0 -ID 1- firstname;
                NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];//3- email
                 NSString *email = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];//3- email
                 NSString *phoneNumber = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];//3- email
                 NSString *address = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];//3- email
                obj=[[UserInfo alloc]initWithParameters:firstName lastName:lastName email:email phoneNumber:phoneNumber address:address];
                //no problem here
                 NSLog(@"%@",[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]);
                NSLog(@"%@",obj.email);
            }
            
            sqlite3_finalize(statement);
        }
        NSLog(@"just get out the select query");
        sqlite3_close(contactDB);
        
    }
    return obj;
    
}




+(void)getInfoFromDB
{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT * FROM userInfo";
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            array_ObjArray =[NSMutableArray new];
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                UserInfo *obj_User =[UserInfo new];
//                NSString *fullname = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]; //0 - name;
//                NSString *location = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];//1- location
                
                
//                obj_User.str_fullname = fullname;
//                obj_User.str_location = location;
                
                
                [array_ObjArray addObject:obj_User];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
        
    }
}


+(BOOL)checkUserExist{

    
    return NO;
}
@end
