//
//  MorseViewController.m
//  TwitterMapBeta1.2
//
//  Created by GuoRui on 10/29/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "MorseViewController.h"
#import "NSString+MorseCode.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "DBHelper.h"
#import "ValidateHelper.h"
@interface MorseViewController ()<UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tf_input;
@property (weak, nonatomic) IBOutlet UITextView *tv_output;
- (IBAction)click_bt_translate:(id)sender;
@property   NSMutableArray *arr_letters;
@property   NSMutableArray *arr_morseCode;


@property NSMutableDictionary *dict_Morsetweets;
@end

@implementation MorseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //add title
    self.navigationItem.title = @"Morse Tweet";
  
    _tv_output.text=@"";
    
    [self networkTest];
}
-(void)networkTest{
    NSString *userID=[Twitter sharedInstance].sessionStore.session.userID;
    
    [self getUserNameFromID:userID];
    
}
-(void)getUserNameFromID:(NSString*)userID {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/lookup.json";
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    TWTRAPIClient *client =[[TWTRAPIClient alloc]initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
               [ValidateHelper alertWithTitle:self title:@"Network issue" message:@"Unable to connect twitter server, please check your network"];
            }
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click_bt_translate:(id)sender {
    self.tv_output.text = [self translate:self.tf_input.text];
}

#pragma mark translate

-(NSString *)translate :(NSString *)str{
    NSArray *arr=[NSString returnAnArrayOfMorseCodeSymbolsFromAWord:str];
    
    NSString* allMorseCodesTogether = @"";
    for(NSString* aString in arr){
        allMorseCodesTogether = [allMorseCodesTogether stringByAppendingString:[NSString stringWithFormat:@"%@    ",aString]];
    }
    return allMorseCodesTogether;
    
}

-(NSArray*)returnArrayOfMorseCodeLettersFromAnArrayOfLetters:(NSArray*)arrayOfLetters{
    NSMutableArray* arrayOfMorseCodes =  [[NSMutableArray alloc]init];
    
    for(NSString* oneLetter in arrayOfLetters){
        [arrayOfMorseCodes addObject:[NSString returnAStringRepresentingTheMorseCodeNumberOfThisLetter:oneLetter]];
    }
    return arrayOfMorseCodes;
}
#pragma mark    textfield

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return   YES;}      // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}           // became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}         // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextField *)textField{
    return  NO;
}


- (IBAction)click_bt_tweet:(id)sender {
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    NSString *tweetContent=[NSString stringWithFormat:@"#MorseCode %@",_tv_output.text];
    [composer setText:tweetContent];
    
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}
@end