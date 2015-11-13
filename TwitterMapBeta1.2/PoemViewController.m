//
//  PoemViewController.m
//  TwitterMapBeta1.2
//
//  Created by Hongjin Su on 11/6/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "PoemViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface PoemViewController ()

@property (weak, nonatomic) IBOutlet UITextView *label_poem;
@property (weak, nonatomic) IBOutlet UIButton *button_tweet;
@property (strong, nonatomic) NSMutableArray *array_ShuffledPoem;

@end

@implementation PoemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add title
    self.navigationItem.title = @"Tweet Your Poem";
    // To give the button a rounded rectangle shape
    _button_tweet.layer.cornerRadius = 6;
    
    // To shuffle the words
    _array_ShuffledPoem = [self ShuffleWords: _array_poem];
    
    // To get the sentence
    NSString *text = [_array_ShuffledPoem componentsJoinedByString:@" "];
    NSString *hashTag = @" #MyRandomPoem ";
    _label_poem.text = [text stringByAppendingString:hashTag];
    
    // Do any additional setup after loading the view.
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

// To shuffle the words
- (NSMutableArray *)ShuffleWords: (NSMutableArray *) Poem {

//    srandom(time(NULL));
    for (NSInteger x = 0; x < [Poem count]; x++) {
        NSInteger randInt = (random() % ([Poem count] - x)) + x;
        [Poem exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    // To clean the words
    for (int i = 0; i < [Poem count]; i++) {
        [Poem[i] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return Poem;
}

// To tweet the random poem
- (IBAction)ButtonAction_TweetPoem:(id)sender {
    
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:_label_poem.text];
    [composer setImage:[UIImage imageNamed:@"fabric"]];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            //NSLog(@"Tweet composition cancelled");
        }
        else {
            //NSLog(@"Sending Tweet!");
        }
    }];
}

@end
