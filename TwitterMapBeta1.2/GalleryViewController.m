//
//  GalleryViewController.m
//  TwitterMapBeta1.2
//
//  Created by Hongjin Su on 11/5/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "GalleryViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface GalleryViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView_galleryPhoto;

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView_galleryPhoto.image = _image_gallery;
    // Do any additional setup after loading the view.
    //add title
    self.navigationItem.title = @"Gallery ";
    
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
- (IBAction)ButtonAction_TweetGalleryPhoto:(id)sender {
    
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    // Attach the photo just taken
    [composer setImage:_image_gallery];
    
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
