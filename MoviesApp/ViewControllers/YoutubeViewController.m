//
//  YoutubeViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/6/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "YoutubeViewController.h"

@interface YoutubeViewController ()

@end

@implementation YoutubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.playerView loadWithVideoId:self.videoKey];
}

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.barStyle = ([[NSUserDefaults standardUserDefaults] boolForKey:@"NightMode"])? UIBarStyleBlack : UIBarStyleDefault;
    self.navigationController.navigationBar.barStyle = ([[NSUserDefaults standardUserDefaults] boolForKey:@"NightMode"])? UIBarStyleBlack : UIBarStyleDefault;
    self.navigationController.navigationItem.rightBarButtonItem.tintColor = ([[NSUserDefaults standardUserDefaults] boolForKey:@"NightMode"])? [UIColor whiteColor] : [UIColor blackColor];
    [[UIView appearance] setTintColor:([[NSUserDefaults standardUserDefaults] boolForKey:@"NightMode"])? [UIColor whiteColor] : [UIColor blackColor]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
