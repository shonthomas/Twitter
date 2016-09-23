//
//  TweetCell.m
//  Twitter
//
//  Created by Shon Thomas on 9/20/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:231.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
    self.selectedBackgroundView = bgColorView;
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    User *user = tweet.user;
    
    // rounded corners for profile images
    CALayer *layer = [self.profilePic layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0];
    
    //Asynchronous
    NSString *imagePath = tweet.user.profileImageUrl;
    if ([imagePath isKindOfClass:[NSString class]]) {
        [self.profilePic setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"no-image"]];
    }
    
    self.tweetLabel.text = tweet.text;
    self.nameLabel.text = tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    
    // show relative time since now if 24 hours or more has elapsed
    NSTimeInterval secondsSinceTweet = -[tweet.createdAt timeIntervalSinceNow];
    
    if (secondsSinceTweet >= 86400) {
        // show month, day, and year
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/d/yy"];
        self.timestampLabel.text = [dateFormat stringFromDate:_tweet.createdAt];
    } else if (secondsSinceTweet >= 3600) {
        // show hours
        self.timestampLabel.text = [NSString stringWithFormat:@"%.0fh", secondsSinceTweet/3600];
    } else if (secondsSinceTweet >= 60){
        // show minutes
        self.timestampLabel.text = [NSString stringWithFormat:@"%.0fm", secondsSinceTweet/60];
    } else {
        // show seconds
        self.timestampLabel.text = [NSString stringWithFormat:@"%.0fs", secondsSinceTweet];
    }
    
    // disable if no id
    if (!tweet.idStr) {
        self.replyButton.enabled = self.retweetButton.enabled = self.favoriteButton.enabled = NO;
    } else {
        // disable retweet for self and not retweet
        if (!tweet.retweetedTweet && [user.screenName isEqualToString:[User currentUser].screenName]) {
            self.replyButton.enabled = self.favoriteButton.enabled = YES;
            self.retweetButton.enabled = NO;
        } else {
            self.replyButton.enabled = self.retweetButton.enabled = self.favoriteButton.enabled = YES;
        }
    }
    
    if (tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }
    
    if (tweet.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweet.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
    
    if (tweet.retweeted) {
        self.retweetCountLabel.textColor = [UIColor greenColor];
    }  else {
        self.retweetCountLabel.textColor = [UIColor grayColor];
    }
    
    if (tweet.favorited) {
        self.favoriteCountLabel.textColor = [UIColor orangeColor];
    } else {
        self.favoriteCountLabel.textColor = [UIColor grayColor];
    }
    
    [self.retweetButton setSelected:tweet.retweeted];
    [self.favoriteButton setSelected:tweet.favorited];
}

- (IBAction)onReply:(id)sender {
    [self.delegate onReply:self];
}

- (IBAction)onFavorite:(id)sender {
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
    
    if (favorited) {
        self.favoriteCountLabel.textColor = [UIColor orangeColor];
    } else {
        self.favoriteCountLabel.textColor = [UIColor grayColor];
    }
    if (tweetToFavorite.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToFavorite.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
    [self highlightButton:self.favoriteButton highlight:favorited];
}

- (IBAction)onRetweet:(id)sender {
    BOOL retweeted = [_tweet retweet];
    if (retweeted) {
        self.retweetCountLabel.textColor = [UIColor greenColor];
    } else {
        self.retweetCountLabel.textColor = [UIColor grayColor];
    }
    if (_tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }
    [self highlightButton:self.retweetButton highlight:retweeted];
}

- (IBAction)onProfile:(id)sender {
    NSLog(@"Profile tapped");
    if (_tweet.retweetedTweet) {
        [self.delegate onProfile:_tweet.retweetedTweet.user];
    } else {
        [self.delegate onProfile:_tweet.user];
    }
}

- (void)highlightButton:(UIButton *)button highlight:(BOOL)highlight {
    if (highlight) {
        [button setSelected:YES];
    } else {
        [button setSelected:NO];
    }
}

@end
