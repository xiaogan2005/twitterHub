//
//  MyRandomPoemViewController.m
//  TwitterMapBeta1.2
//
//  Created by Hongjin Su on 11/5/15.
//  Copyright © 2015 GuoRui. All rights reserved.
//

#import "MyRandomPoemViewController.h"
#import "PoemViewController.h"
#import "MyBankCollectionViewCell.h"
#import "MyJSONObject.h"
#import "ValidateHelper.h"
#import <TwitterKit/TwitterKit.h>
@interface MyRandomPoemViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_poem;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_bank;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poemHeightConstraint;
@property (strong, nonatomic) NSMutableArray *array_bankWords;
//@property (strong, nonatomic) NSMutableArray *array_poemWords;
@property (strong, nonatomic) NSMutableArray *array_myPoem;
@property (weak, nonatomic) IBOutlet UITextView *textView_poem;

@property (strong, nonatomic) NSMutableArray *array_JSONobjects;


@end

@implementation MyRandomPoemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //network test
    [self networkTest];
    
    // To initialize all the arrays
    _array_bankWords = [[NSMutableArray alloc]init];
//    _array_poemWords = [[NSMutableArray alloc]init];
    _array_myPoem = [[NSMutableArray alloc]init];
    _array_JSONobjects = [[NSMutableArray alloc]init];
    
    // Trigger a first word bank refresh to retrieve a selection of words.
    _collectionView_bank.clipsToBounds = NO;
    [self GetJSONData];
    [self GetBankWords];
    
    // Customize the navigation bar.
    self.navigationItem.title = @"#MyRandomPoem";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.translucent = YES;
    [self changeNavigationBarButtonTitle];
    
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    // Make sure the navigation bar is translucent.
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
}

// To check if wifi/data is connected
- (void)networkTest {
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    
    [self getUserNameFromID: userID];
    
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

// To get the JSON data from the file
- (void)GetJSONData {

    // To get the path for the JSON file
    NSString *JSONpath = [[NSBundle mainBundle] pathForResource:@"Themes" ofType:@"json"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:JSONpath encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        
        NSLog(@"Error reading file: %@", error.localizedDescription);
    }
    // To get the JSON array from file
    NSArray *dataList = [[NSArray alloc] init];
    dataList = (NSArray *)[NSJSONSerialization
                                JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]
                                options:0 error:NULL];
    
    // To clarify the JSON data
    for (int i = 0; i < [dataList count]; i++) {
        
        MyJSONObject *objJSON = [MyJSONObject new];
        NSDictionary *dict = dataList[i];
        
        objJSON.name = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
        
        // To get all the words of each Theme
        objJSON.array_words = [NSMutableArray new];
        NSArray *array_wordsArray =[dict objectForKey:@"words"];
        for (int j = 0; j < [array_wordsArray count]; j++) {
            
            NSString *words = array_wordsArray[j];
            [objJSON.array_words addObject:words];
        }
        
        // To get all the pics of each Theme--though they are of no use in this app
        objJSON.array_pictures = [NSMutableArray new];
        NSArray *array_picturesArray =[dict objectForKey:@"pictures"];
        for (int j = 0; j < [array_picturesArray count]; j++) {
            
            NSString *pictures = array_picturesArray[j];
            [objJSON.array_pictures addObject:pictures];
        }
        
        [_array_JSONobjects addObject:objJSON];
    }
}

// To shuffle the word bank
- (IBAction)ButtonAction_Shuffle:(id)sender {
    [self GetBankWords];
    [_collectionView_bank reloadData];
}

- (void)GetBankWords {
    // To randomly choose a Theme from JSON data and copy all the words from that theme
    NSMutableArray *array_allWords = [[NSMutableArray alloc] init];
    NSArray *arr = [[NSArray alloc] initWithObjects:@"Adventure", @"Romance", @"Nature", @"Mystery", nil];
    int j = arc4random_uniform(3);
    for (int i = 0; i < [_array_JSONobjects count]; i++) {
        MyJSONObject *myObject = _array_JSONobjects[i];
        if ([myObject.name isEqualToString:arr[j]]) {
            array_allWords = myObject.array_words;
            break;
        }
    }
    
    // To randomly choose 20 words from all the words as the word bank for user
    NSMutableArray *array_randomAllWords = [[NSMutableArray alloc] init];
    array_randomAllWords = array_allWords;
    _array_bankWords = [NSMutableArray new];
    for (int i = 0; i < 20; i++) {
        int randNum = arc4random() % [array_randomAllWords count];
        [_array_bankWords addObject:array_randomAllWords[randNum]];
        [array_randomAllWords removeObjectAtIndex:randNum];
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

#pragma mark--UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _collectionView_bank) {
        return _array_bankWords.count;
    }
    else if (collectionView == _collectionView_poem) {
//        return _array_poemWords.count;
        return _array_myPoem.count;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MyBankCollectionViewCell *myPoemCell = (MyBankCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    
    myPoemCell.contentView.frame = myPoemCell.bounds;
    myPoemCell.contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    NSString *word = @"";
    if (collectionView == _collectionView_bank) {
        word = _array_bankWords[indexPath.row];
    }
    else if (collectionView == _collectionView_poem) {
//        word = _array_poemWords[indexPath.row];
        word = _array_myPoem[indexPath.row];
    }
    
    // Inject the word in the cell.
    myPoemCell.label_word.text = word;
    myPoemCell.label_word.frame = myPoemCell.bounds;
    
    // Draw the border using the same color as the word.
    myPoemCell.layer.masksToBounds = NO;
    myPoemCell.layer.borderColor = myPoemCell.label_word.textColor.CGColor;
    myPoemCell.layer.borderWidth = 2;
    myPoemCell.layer.cornerRadius = 3;
    
     // Add a subtle opacity to poem words for better readability on top of pictures.
    if (collectionView == _collectionView_poem) {
        //myPoemCell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    }
    
    // Make sure the cell is not hidden.
    myPoemCell.hidden = NO;
    
    return myPoemCell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark--UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _collectionView_bank) {
        // A word in the bank has been tapped.
        
        // Fade out and hide the word in the bank.
        MyBankCollectionViewCell *myPoemCell = (MyBankCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (myPoemCell) {
            [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
                myPoemCell.alpha = 0;
            } completion:^(BOOL finished) {
                myPoemCell.hidden = YES;
            }];
        }
        
        // Add the word to the poem.
        NSString *word = _array_bankWords[indexPath.row];
        [_array_myPoem addObject:word];
//        NSLog(@"%@", [_array_myPoem componentsJoinedByString:@" "]);
//        _textView_poem.text = [_array_myPoem componentsJoinedByString:@" "];
//        [self DisplayWord:word inCollectionView:_collectionView_poem];
        [_collectionView_poem reloadData];
    }
    else if (collectionView == _collectionView_poem) {
        
//        MyBankCollectionViewCell *myPoemCell = (MyBankCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//        if (myPoemCell) {
//            [UIView animateWithDuration:0.15 animations:^(void) {
//                myPoemCell.alpha = 0;
//            } completion:^(BOOL finished) {
//                [collectionView performBatchUpdates:^(void) {
//                    NSArray *paths = [[NSArray alloc] initWithObjects:indexPath, nil];
//                    [collectionView deleteItemsAtIndexPaths:paths[0]];
//                } completion:^(BOOL finished) {
//                    [self resizePoemToFitContentSize];
//                    myPoemCell.alpha = 1;
//                }];
//            }];
//        }
        
        // Display the word back in the bank.
//        NSString *word = _array_poemWords[indexPath.row];
        
        NSString *word = _array_myPoem[indexPath.row];
        
//        [self DisplayWord:word inCollectionView:_collectionView_bank];
        
        // Remove the word from the poem.
        [_array_myPoem removeObjectAtIndex:indexPath.row];
        [_collectionView_poem reloadData];
        //add to bank again
         //Look for the word in the word bank.
        int index = 0;
        for (NSString *bankWord in _array_bankWords) {
            if ([word isEqualToString:bankWord]) {
                // Find the corresponding cell in the collection view and unhide it.
                MyBankCollectionViewCell *bankCell = (MyBankCollectionViewCell *)[_collectionView_bank cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                if (bankCell) {
                    if (bankCell.hidden) {
                        // Unhide and animate the cell again.
                        bankCell.hidden = NO;
                        [UIView animateWithDuration:0.15 animations:^(void) {
                            bankCell.alpha = 1;
                        }];
                        // Return since we found it.
                        return;
                    }
                }
            }
            index++;
        }

        
      
    }
    // Update the tick icon state.
    if ([_array_myPoem count] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *word = @"";
    if (collectionView == _collectionView_bank) {
        word = _array_bankWords[indexPath.row];
    }
    else if (collectionView == _collectionView_poem) {
//        word = _array_poemWords[indexPath.row];
        word = _array_myPoem[indexPath.row];
    }
    return [self sizeForWord:word];
}

#pragma mark--UICollectionView Utilities
- (CGSize)sizeForWord:(NSString *)word {
    return CGSizeMake(18 + [word length] * 10, 50);
}

//- (void)DisplayWord: (NSString *)word inCollectionView: (UICollectionView *) collectionView {
//    
//    if (collectionView == _collectionView_bank) {
//        
//        int index = 0;
//        // Look for the word in the word bank.
//        for (NSString *bankWord in _array_bankWords) {
//            if ([word isEqualToString:bankWord]) {
//                // Find the corresponding cell in the collection view and unhide it.
//                MyBankCollectionViewCell *bankCell = (MyBankCollectionViewCell *)[_collectionView_bank cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//                if (bankCell) {
//                    if (bankCell.hidden) {
//                        // Unhide and animate the cell again.
//                        bankCell.hidden = NO;
//                        [UIView animateWithDuration:0.15 animations:^(void) {
//                            bankCell.alpha = 1;
//                        }];
//                        // Return since we found it.
//                        return;
//                    }
//                }
//            }
//            index++;
//        }
//        
//        // The word has not been found because a shuffle likely happened, so append it again.
//        [_array_bankWords addObject:word];
//        
//        
//        // Display the new word accordingly at the last position.
//        NSIndexPath *bankIndexPath = [NSIndexPath indexPathForItem:[_array_bankWords count] - 1 inSection:0];
//        [collectionView insertItemsAtIndexPaths:[NSArray arrayWithObjects:bankIndexPath, nil]];
//    }
//    else if (collectionView == _collectionView_poem) {
//        
//        // Retrieve the index path of the last word of the poem.
//        
////        NSIndexPath *poemIndexPath = [NSIndexPath indexPathForItem:[_array_poemWords count] - 1 inSection:0];
//        NSIndexPath *poemIndexPath = [NSIndexPath indexPathForItem:[_array_myPoem count] - 1 inSection:0];
//        
//        // Insert the cell for this word.
//        [collectionView performBatchUpdates:^(void) {
//        
//            [collectionView insertItemsAtIndexPaths:[NSArray arrayWithObjects:poemIndexPath, nil]];
//        } completion:^(BOOL finished) {
//        
//            [self resizePoemToFitContentSize];
//        }];
//        
//        // Fade in so it appears more smoothly.
//        MyBankCollectionViewCell *myCell = (MyBankCollectionViewCell *)[collectionView cellForItemAtIndexPath:poemIndexPath];
//        if (myCell) {
//            myCell.alpha = 0;
//            [UIView animateWithDuration:0.15 animations:^(void) {
//                myCell.alpha = 1;
//            }];
//        }
//    }
//}

//func resizePoemToFitContentSize() {
//    UIView.animateWithDuration(0.15) {
//        self.poemHeightContraint.constant = self.poemCollectionView.contentSize.height
//        self.view.layoutIfNeeded()
//    }
//}

- (void)resizePoemToFitContentSize {

    [UIView animateWithDuration:0.15 animations:^(void) {
    
       // _poemHeightConstraint.constant = _collectionView_poem.contentSize.height;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PoemViewController *obj_PVC = [segue destinationViewController];
    obj_PVC.array_poem = _array_myPoem;
}


@end
