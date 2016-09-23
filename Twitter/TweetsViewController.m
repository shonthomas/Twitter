//
//  TweetsViewController.m
//  Twitter
//
//  Created by Shon Thomas on 9/20/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "TweetsViewController.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "MBProgressHUD.h"
#import "ComposeViewController.h"
#import "TweetViewController.h"
#import "ProfileViewController.h"
#import "MenuViewController.h"

@interface TweetsViewController ()

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Menu toggle button
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // Title
    self.navigationItem.title = @"Home";
    
    // New/Compose button
    // UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // Tweets table
    [self.tweetTableView setBackgroundColor:[UIColor clearColor]];
    if([self.tweetTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tweetTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    // Loading state, show the loading icon and hide the table row separator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    NSAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControl setAttributedTitle:title];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tweetTableView addSubview:self.refreshControl];
    
    // Register tweet cell nib
    [self.tweetTableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    // Set self as table view data source and delegate
    self.tweetTableView.dataSource = self;
    self.tweetTableView.delegate = self;
    self.tweetTableView.estimatedRowHeight = 100;
    self.tweetTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Getting Tweets
    [self loadTweets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleMenu {
    [self.delegate toggleMenu];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    tweetCell.tweet = self.tweets[indexPath.row];
    tweetCell.delegate = self;
    
    // End of list load more
    if (indexPath.row == self.tweets.count - 1) {
        NSLog(@"End of list reached, loading more");
        [self loadMoreTweets];
    }
    
    return tweetCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TweetViewController *tweetVC = [[TweetViewController alloc] init];
    tweetVC.delegate = self;
    tweetVC.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:tweetVC animated:YES];
}

- (void) loadMoreTweets {
    // Return if no previous max id str
    NSString *maxIdStr = [self.tweets[self.tweets.count - 1] idStr];
    if (!maxIdStr) {
        return;
    }
    [[TwitterClient sharedInstance] homeTimelineWithParams:@{ @"max_id": maxIdStr} completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting more tweets: %@", error]);
        } else if (tweets.count > 0) {
            // Ignore duplicate requests
            if ([[tweets[tweets.count - 1] idStr] isEqualToString:[self.tweets[self.tweets.count - 1] idStr]]) {
                NSLog(@"Ignoring duplicate data");
            } else {
                NSLog([NSString stringWithFormat:@"Got %lu more tweets", tweets.count]);
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
                [temp addObjectsFromArray:tweets];
                self.tweets = [temp copy];
                [self.tweetTableView reloadData];
            }
        } else {
            NSLog(@"No more tweets retrieved");
        }
    }];
}

- (void)loadTweets {
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting timeline: %@", error]);
        } else {
            self.tweets = tweets;
            [self.tweetTableView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshControl endRefreshing];
        [self.tweetTableView setHidden:NO];
        self.tweetTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;    }];
}

- (void)refreshView {
    [self loadTweets];
}

- (void)didTweet:(Tweet *)tweet {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
    [temp insertObject:tweet atIndex:0];
    self.tweets = [temp copy];
    [self.tweetTableView reloadData];
}

- (void)didTweetSuccessfully {
    [self.tweetTableView reloadData];
}

- (void)didReply:(Tweet *)tweet {
    [self didTweet:tweet];
}

- (void)didRetweet:(BOOL)didRetweet {
    [self.tweetTableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
    [self.tweetTableView reloadData];
}

- (void)onCompose {
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    composeVC.delegate = self;
    [self.navigationController pushViewController:composeVC animated:YES];
}

- (void)onReply:(TweetCell *)tweetCell {
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    composeVC.delegate = self;
    // Set reply to tweet property
    composeVC.replyToTweet = tweetCell.tweet;
    [self.navigationController pushViewController:composeVC animated:YES];
}

- (void)onProfile:(User *)user {
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    [profileVC setUser:user];
    [self.navigationController pushViewController:profileVC animated:YES];
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
