//
//  TweetViewController.h
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "ComposeViewController.h"

@protocol TweetViewControllerDelegate <NSObject>

- (void)didReply:(Tweet *)tweet;
- (void)didRetweet:(BOOL)didRetweet;
- (void)didFavorite:(BOOL)didFavorite;

@end

@interface TweetViewController : UIViewController <ComposeViewControllerDelegate>

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, weak) id <TweetViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *retweetIcon;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end
