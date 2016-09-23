//
//  ProfileCellTableViewCell.h
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol ProfileCellDelegate <NSObject>

- (void)pageChanged:(UIPageControl *)pageControl;

@end;

@interface ProfileCell : UITableViewCell

@property (strong, nonatomic) User *user;

@property (weak, nonatomic) id <ProfileCellDelegate> delegate;

@end
