//
//  ComposeViewController.h
//  Twitter
//
//  Created by Shon Thomas on 9/20/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeViewControllerDelegate <NSObject>

- (void)didTweet:(Tweet *)tweet;

@optional
- (void)didTweetSuccessfully;

@end

@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@property (strong, nonatomic) Tweet *replyToTweet;
@property (strong, nonatomic) User *messageToUser;

@property (weak, nonatomic) id <ComposeViewControllerDelegate> delegate;

@end
