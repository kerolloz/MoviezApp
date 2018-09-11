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


@end
