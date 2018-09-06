//
//  YoutubeViewController.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/6/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YTPlayerView.h>

@interface YoutubeViewController : UIViewController

@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@property NSString *videoKey;

@end
