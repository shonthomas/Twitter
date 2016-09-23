//
//  ComposeViewController.m
//  Twitter
//
//  Created by Shon Thomas on 9/20/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "ComposeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "TwitterClient.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add Cancel button icon
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // Add Tweet button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    User *currentUser = [User currentUser];
    
    // Rounded corners for profile images
    CALayer *layer = [self.profileImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[currentUser profileImageUrl]]];
    self.nameLabel.text = currentUser.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
    
    // Set self as delegate for text view events
    self.tweetTextView.delegate = self;
    
    // Ret initial reply to string if a reply
    if (_replyToTweet) {
        // if replying to a retweet, mention original tweet author and retweeter
        if (_replyToTweet.retweetedTweet) {
            if ([_replyToTweet.user.screenName isEqualToString:[[User currentUser] screenName]]) {
                self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _replyToTweet.retweetedTweet.user.screenName];
            } else {
                self.tweetTextView.text = [NSString stringWithFormat:@"@%@ @%@ ", _replyToTweet.retweetedTweet.user.screenName, _replyToTweet.user.screenName];
            }
        } else {
            self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _replyToTweet.user.screenName];
        }
    }
    
    // Set initial mention if writing to user
    if (_messageToUser) {
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _messageToUser.screenName];
    }
    
    // Initialize character count
    [self textViewDidChange:self.tweetTextView];
    
    // Start with focus on the text view
    [self.tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancel {
    // Update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController popViewControllerAnimated:YES];
    [self.view endEditing:YES];
}

- (void)onTweet {
    Tweet *tweet = [[Tweet alloc] initWithText:self.tweetTextView.text replyToTweet:self.replyToTweet];
    
    [[TwitterClient sharedInstance] sendTweetWithParams:nil tweet:tweet completion:^(NSString *tweetIdStr, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error sending tweet: %@", tweet]);
        } else {
            // set tweet id so it can be favorited
            NSLog([NSString stringWithFormat:@"Tweet successful, tweet id_str: %@", tweetIdStr]);
            tweet.idStr = tweetIdStr;
            if ([self.delegate respondsToSelector:@selector(didTweetSuccessfully)]) {
                [self.delegate didTweetSuccessfully];
            }
        }
    }];
    
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController popViewControllerAnimated:YES];
    [self.view endEditing:YES];
    
    [self.delegate didTweet:tweet];
}

- (void) textViewDidChange:(UITextView *)textView {
    long charsLeft = 140 - textView.text.length;
    
    // if negative count, set to red
    UIColor *titleColor = nil;
    if (charsLeft < 0) {
        titleColor = [UIColor redColor];
    } else {
        titleColor = [UIColor blackColor];
    }
    if (charsLeft < 0 || charsLeft == 140) {
        // disable tweet button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        // enable tweet button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    UILabel *charsLeftTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    charsLeftTitle.textAlignment = NSTextAlignmentRight;
    charsLeftTitle.text = [NSString stringWithFormat:@"%ld", charsLeft];
    charsLeftTitle.textColor = titleColor;
    [charsLeftTitle setFont: [UIFont fontWithName:@"Helvetica Neue" size:12.0]];
    self.navigationItem.titleView = charsLeftTitle;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
