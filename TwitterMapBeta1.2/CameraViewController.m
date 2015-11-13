//
//  CameraViewController.m
//  TwitterMapBeta1.2
//
//  Created by Hongjin Su on 11/5/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "CameraViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface CameraViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView_cameraPhoto;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView_cameraPhoto.image = _image_camera;
    UIImageWriteToSavedPhotosAlbum(_image_camera, nil, nil, nil);
    //add title
    self.navigationItem.title = @"Take Photo";
    
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
- (IBAction)ButtonAction_TweetCameraPhoto:(id)sender {
    
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    // Attach the photo just taken
    [composer setImage:_image_camera];
    
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
