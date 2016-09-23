//
//  ProfileViewController.h
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeViewController.h"
#import "TweetCell.h"
#import "TweetViewController.h"
#import "ProfileCell.h"

@protocol ProfileViewControllerDelegate <NSObject>

@end

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetCellDelegate, TweetViewControllerDelegate, ProfileCellDelegate>

@property (strong, nonatomic) User *user;

@property (weak, nonatomic) id <ProfileViewControllerDelegate> delegate;

@end
