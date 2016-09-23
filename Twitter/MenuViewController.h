//
//  MenuViewController.h
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "TweetsViewController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ProfileViewControllerDelegate, TweetsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeftMargin;

@end
