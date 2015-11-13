//
//  PhotoBoothViewController.m
//  TwitterMapBeta1.2
//
//  Created by Hongjin Su on 11/5/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "PhotoBoothViewController.h"
#import "CameraViewController.h"
#import "GalleryViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "ValidateHelper.h"
@interface PhotoBoothViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImage *image;

@end

@implementation PhotoBoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeNavigationBarButtonTitle];
    //add title
    self.navigationItem.title = @"Photo Booth";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// When pressing camera button, it goes to a next view controller and present camera
- (IBAction)ButtonAction_Camera:(id)sender {
    
    UIImagePickerController *picker =[[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

// When pressing gallery button, it goes to a next view controller and present photo gallery
- (IBAction)ButtonAction_Gallery:(id)sender {
    
    UIImagePickerController *picker =[[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        _image = info[UIImagePickerControllerEditedImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"GalleryPush" sender:self];
    }
    else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        _image = info[UIImagePickerControllerEditedImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"CameraPush" sender:self];
    }
}

- (void)changeNavigationBarButtonTitle {
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]isEqualToString:@"CameraPush"]) {
//        [segue destinationViewController];
        CameraViewController *objCVC = [segue destinationViewController];
        objCVC.image_camera = _image;
    }
    else if ([[segue identifier]isEqualToString:@"GalleryPush"]) {
        GalleryViewController *objGVC = [segue destinationViewController];
        objGVC.image_gallery = _image;
    }
}

@end
