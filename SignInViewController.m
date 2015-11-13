//
//  SignInViewController.m
//  TwitterMapBeta1.2
//
//  Created by GuoRui on 10/29/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "SignInViewController.h"
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#import <UIKit/UIKit.h>
@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView_icon;


@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self generateLogInButton];
    [self.view sendSubviewToBack:_imageView_icon];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark login button by twitterkit and digitskit and segue method
-(void)generateLogInButton{
    TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
            [self navigateToMainAppScreen];
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
    
    
}

-(void)navigateToMainAppScreen {
   
    //performSegueWithIdentifier("ShowThemeChooser", sender: self)
    [self performSegueWithIdentifier:@"gotoTableView" sender:self];
}


- (IBAction)singInWithTwitter:(id)sender {


}
- (IBAction)singInWithPhone:(id)sender {
}
@end
