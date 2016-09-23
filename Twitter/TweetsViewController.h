//
//  TweetsViewController.h
//  Twitter
//
//  Created by Shon Thomas on 9/20/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeViewController.h"
#import "TweetViewController.h"
#import "TweetCell.h"

@protocol TweetsViewControllerDelegate <NSObject>

- (void)toggleMenu;

@end

@interface TweetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetViewControllerDelegate, TweetCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;

@property (weak, nonatomic) id <TweetsViewControllerDelegate> delegate;

@end
