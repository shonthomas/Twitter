//
//  AppDelegate.m
//  Twitter
//
//  Created by Shon Thomas on 9/19/16.
//  Copyright © 2016 shon. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:UserDidLogoutNotification object:nil];
    
    User *user = [User currentUser];
    if (user != nil) {
        NSLog(@"Welcome %@", user.name);
        MenuViewController *menuVC = [[MenuViewController alloc] init];
        self.window.rootViewController = menuVC;
    } else {
        NSLog(@"Not logged in");
        self.window.rootViewController = [[LoginViewController alloc] init];
    }
    
    // Styling the Navigation Bar across the application 
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    
    [self.window makeKeyAndVisible];
    
    // Added for debugging
    // [self performSelector:@selector(checkUser) withObject:nil afterDelay:3];
    
    return YES;
}

- (void)checkUser {
    User *user = [User currentUser];
    if (user != nil) {
        NSLog(@"Welcome %@", user.name);
    } else {
        NSLog(@"Not logged in");
    }
}

- (void)userDidLogout {
    self.window.rootViewController = [[LoginViewController alloc] init];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[TwitterClient sharedInstance] openUrl:url];
    
    return YES;
}

@end
