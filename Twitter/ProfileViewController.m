//
//  ProfileViewController.m
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "ProfileViewController.h"
#import "ComposeViewController.h"
#import "ProfileCell.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "TweetViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopConstraint;

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshTweetsControl;
@property (strong, nonatomic) MBProgressHUD *loadingIndicator;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    User *user = self.user ? self.user : [User currentUser];
    
    // Sign Out button
    if (!self.user) {
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
        self.navigationItem.leftBarButtonItem = leftBarButton;
    }
    // Compose button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // Title
    self.navigationItem.title = user.name;
    
    // use banner url if provided, or profile bg url
    NSString *bannerUrl = user.bannerUrl ? [NSString stringWithFormat:@"%@/mobile_retina", user.bannerUrl] : user.backgroundImageUrl;
//    NSString *bannerUrl = @"https://s3-media3.fl.yelpcdn.com/bphoto/YsiHTOAtIkyRp_IxSeObeA/o.jpg";
    NSLog(@"Banner bannerUrl: %@", bannerUrl);
    if ([bannerUrl isKindOfClass:[NSString class]]) {
        NSLog(@"Banner bannerUrl ok: %@", bannerUrl);
        [self.bgView setImageWithURL:[NSURL URLWithString:bannerUrl]];
    }
    
    // register profile cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    // register tweet cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // add pull to refresh tweets control
    self.refreshTweetsControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshTweetsControl];
    [self.refreshTweetsControl addTarget:self action:@selector(refreshProfile) forControlEvents:UIControlEventValueChanged];
    
    // show loading indicator
    self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (user) {
        [self refreshProfile];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // do nothing if profile cell
    if (indexPath.row == 0) {
        return;
    }
    
    TweetViewController *tweetVC = [[TweetViewController alloc] init];
    tweetVC.delegate = self;
    tweetVC.tweet = self.tweets[indexPath.row - 1];
    [self.navigationController pushViewController:tweetVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 ) {
        ProfileCell *profileCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        User *user;
        
        if (self.user) {
            user = self.user;
        } else {
            user = [User currentUser];
        }
        
        [profileCell setUser:user];
        
        profileCell.delegate = self;
        profileCell.backgroundColor = [UIColor clearColor];
        
        return profileCell;
    } else {
        TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
        tweetCell.tweet = self.tweets[indexPath.row - 1];
        tweetCell.delegate = self;
        
        return tweetCell;
    }
}

- (void)onCompose {
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    if (self.user && ![self.user.screenName isEqualToString:[[User currentUser] screenName]]) {
        composeVC.messageToUser = self.user;
    }
    composeVC.delegate = self;
    [self.navigationController pushViewController:composeVC animated:YES];
}

- (void)onReply:(TweetCell *)tweetCell {
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    composeVC.delegate = self;
    // set reply to tweet property
    composeVC.replyToTweet = tweetCell.tweet;
    [self.navigationController pushViewController:composeVC animated:YES];
}

- (void)didReply:(Tweet *)tweet {
    [self didTweet:tweet];
}

- (void)didRetweet:(BOOL)didRetweet {
    [self.tableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
    [self.tableView reloadData];
}

- (void)didTweet:(Tweet *)tweet {
    // only add if own tweet
    if (!self.user) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
        [temp insertObject:tweet atIndex:0];
        self.tweets = [temp copy];
        [self.tableView reloadData];
    }
}

- (void)didTweetSuccessfully {
    [self.tableView reloadData];
}

- (void)refreshProfile {
    [[TwitterClient sharedInstance] userTimelineWithParams:nil user:self.user completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting user timeline, too many requests?: %@", error]);
        } else {
            self.tweets = tweets;
            [self.tableView reloadData];
        }
        [self.loadingIndicator hide:YES];
        [self.refreshTweetsControl endRefreshing];
        [self.bgView setHidden:NO];
        [self.tableView setHidden:NO];
    }];
}

- (void)onLogout {
    [User logout];
}

- (void)pageChanged:(UIPageControl *)pageControl {
    if (pageControl.currentPage == 0) {
        [UIView animateWithDuration:.24 animations:^{
            self.bgView.alpha = 1;
            self.bgImageHeightConstraint.constant = 80;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:.24 animations:^{
            self.bgView.alpha = .5;
            self.bgImageHeightConstraint.constant = 100;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)onProfile:(User *)user {
    // just shake the screen if for the same profile
    NSString *profileScreenName = self.user ? self.user.screenName : [[User currentUser] screenName];
    if ([user.screenName isEqualToString:profileScreenName]) {
        NSLog(@"Profile for user already displayed");
        // source: http://stackoverflow.com/questions/1632364/shake-visual-effect-on-iphone-not-shaking-the-device
        CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
        anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
        anim.autoreverses = YES ;
        anim.repeatCount = 2.0f ;
        anim.duration = 0.07f ;
        
        [self.view.layer addAnimation:anim forKey:nil];
        return;
    }
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    [pvc setUser:user];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset < 0) {
        // pulling down
        self.bgImageHeightConstraint.constant = 80 - scrollOffset;
        self.bgImageTopConstraint.constant = 0;
    } else {
        // scrolling up
        self.bgImageHeightConstraint.constant = 80;
        
        // parallax
        self.bgImageTopConstraint.constant = - scrollOffset / 3;
    }
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
