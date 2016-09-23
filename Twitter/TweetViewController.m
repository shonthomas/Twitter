//
//  TweetViewController.m
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "TweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"

@interface TweetViewController ()

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Title
    self.navigationItem.title = @"Tweet";
    
    // Reply button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Replay" style:UIBarButtonItemStylePlain target:self action:@selector(onReply)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    if (_tweet) {
        User *user = _tweet.user;
        Tweet *tweetToDisplay;
        
        if (_tweet.retweetedTweet) {
            tweetToDisplay = _tweet.retweetedTweet;
            self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted", user.name];
            [self.retweetIcon setHidden:NO];
            [self.retweetedByLabel setHidden:NO];
        } else {
            tweetToDisplay = _tweet;
            [self.retweetIcon setHidden:YES];
            [self.retweetedByLabel setHidden:YES];
        }
        
        // rounded corners for profile images
        CALayer *layer = [self.profileImageView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:3.0];
        [self.profileImageView setImageWithURL:[NSURL URLWithString:tweetToDisplay.user.profileImageUrl]];
        
        self.nameLabel.text = tweetToDisplay.user.name;
        self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweetToDisplay.user.screenName];
        self.tweetLabel.text = tweetToDisplay.text;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/d/yy, h:mm a"];
        self.timestampLabel.text = [dateFormat stringFromDate:tweetToDisplay.createdAt];
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToDisplay.favoriteCount];
        
         // set action button highlight states
        [self highlightButton:self.retweetButton highlight:_tweet.retweeted];
        [self highlightButton:self.favoriteButton highlight:_tweet.favorited];
        
        // if this tweet has no id, then disable all actions
        if (!_tweet.idStr) {
            rightBarButton.enabled = NO;
            self.retweetButton.enabled = NO;
            self.replyButton.enabled = NO;
            self.favoriteButton.enabled = NO;
        }
        
        // if this is the user's own tweet, disable retweet
        if (!_tweet.retweetedTweet && [[[User currentUser] screenName] isEqualToString:user.screenName]) {
            self.retweetButton.enabled = NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)highlightButton:(UIButton *)button highlight:(BOOL)highlight {
    if (highlight) {
        [button setSelected:YES];
    } else {
        [button setSelected:NO];
    }
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
}

- (void)onReply {
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    composeVC.delegate = self;
    // set reply to tweet property
    composeVC.replyToTweet = _tweet;
    [self.navigationController pushViewController:composeVC animated:YES];
}

- (IBAction)onReply:(id)sender {
    [self onReply];
}

- (IBAction)onRetweet:(id)sender {
    [_tweet retweet];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
    [self highlightButton:self.retweetButton highlight:_tweet.retweeted];
    [self.delegate didRetweet:_tweet.retweeted];
}

- (IBAction)onFavorite:(id)sender {
    // favorite the original tweet if applicable
    Tweet *tweetToFavorite;
    if (_tweet.retweetedTweet) {
        tweetToFavorite = _tweet.retweetedTweet;
    } else {
        tweetToFavorite = _tweet;
    }
    
    BOOL favorited = [tweetToFavorite favorite];
    
    // favorite/unfavorite the source
    if (_tweet.retweetedTweet) {
        _tweet.favorited = favorited;
    }
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToFavorite.favoriteCount];
    [self highlightButton:self.favoriteButton highlight:favorited];
    [self.delegate didFavorite:favorited];
}

- (void) didTweet:(Tweet *)tweet {
    [self.delegate didReply:tweet];
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
