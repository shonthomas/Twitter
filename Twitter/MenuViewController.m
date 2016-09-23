//
//  MenuViewController.m
//  Twitter
//
//  Created by Shon Thomas on 9/21/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "User.h"

@interface MenuViewController ()

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *currentVC;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (assign, nonatomic) BOOL menuOpen;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setMenuOpen:NO];
    
    // set bg color
    self.view.backgroundColor = [UIColor colorWithRed:14/255.0f green:144/255.0f blue:233/255.0f alpha:1.0f];
    
    // reset constraint
    self.contentViewLeftMargin.constant = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    
    [self initViewControllers];
    [self.tableView reloadData];
}

- (void)initViewControllers {
    
    // Timeline
    TweetsViewController *tweetsVC = [[TweetsViewController alloc] init];
    UINavigationController *tweetsNC = [[UINavigationController alloc] initWithRootViewController:tweetsVC];
    tweetsNC.navigationBar.translucent = NO;
    tweetsVC.delegate = self;
    
    // Profile View
    ProfileViewController *profileViewVC = [[ProfileViewController alloc] init];
    UINavigationController *profileViewNC = [[UINavigationController alloc] initWithRootViewController:profileViewVC];
    profileViewNC.navigationBar.translucent = NO;
    
    self.viewControllers = [NSArray arrayWithObjects:tweetsNC, profileViewNC, nil];
    
    // set Timeline as initial view
    self.currentVC = tweetsNC;
    self.currentVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.currentVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2) {
        [User logout];
    } else {
        [self removeCurrentViewController];
        self.currentVC = self.viewControllers[indexPath.row];
        [self setContentController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.tableView.bounds.size.height / 3;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Home";
            break;
        case 1:
            cell.textLabel.text = @"Profile";
            break;
        case 2:
            cell.textLabel.text = @"Sign Out";
            break;
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:231.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
    cell.selectedBackgroundView = bgColorView;
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)removeCurrentViewController {
    [self.currentVC willMoveToParentViewController:nil];
    [self.currentVC.view removeFromSuperview];
    [self.currentVC didMoveToParentViewController:nil];
}

- (void)setContentController {
    self.currentVC.view.frame = self.contentView.bounds;
    [self.currentVC willMoveToParentViewController:self];
    [self.contentView addSubview:self.currentVC.view];
    [self.currentVC didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.24 animations:^{
        [self showContentViewController];
        [self.view layoutIfNeeded];
    }];
}

- (void)viewDidLayoutSubviews {
    [self removeCurrentViewController];
    [self setContentController];
}

- (void)showProfileViewController {
    [self removeCurrentViewController];
    self.currentVC = self.viewControllers[1];
    [self setContentController];
}

- (void)showContentViewController {
    self.contentView.center = CGPointMake(self.contentView.bounds.size.width/2, self.contentView.center.y);
    // self.contentView.userInteractionEnabled = YES;
    [self.contentView removeGestureRecognizer:self.tap];
    [self setMenuOpen:NO];
}

- (void)toggleMenu {
    if (self.menuOpen) {
        [self dismissMenu];
    } else {
        [self showMenu];
    }
}

- (void)showMenu {
    [UIView animateWithDuration:.24 animations:^{
        self.contentView.center = CGPointMake(self.contentView.bounds.size.width/2 + 240, self.contentView.center.y);
        // self.contentView.userInteractionEnabled = NO;
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)];
        [self.contentView addGestureRecognizer:self.tap];
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [self setMenuOpen:YES];
    }];
}

- (void)dismissMenu {
    [UIView animateWithDuration:.24 animations:^{
        [self showContentViewController];
        [self setMenuOpen:NO];
    }];
}

- (IBAction)didSwipeLeft:(UISwipeGestureRecognizer *)sender {
    [UIView animateWithDuration:.24 animations:^{
        [self showContentViewController];
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)didSwipeRight:(UISwipeGestureRecognizer *)sender {
    [self showMenu];
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
