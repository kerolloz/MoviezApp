//
//  MovieDetailsViewController.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"
#import "MovieDetailsDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YoutubeViewController.h"
#import <sqlite3.h>
#import "Reachability.h"

@interface MovieDetailsViewController : UIViewController <MovieDetailsDelegate, UITableViewDelegate, UITableViewDataSource>

@property NSDictionary *movieDictionary;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *traikersHight;
@property Movie *myMovie;
@property (weak, nonatomic) IBOutlet UIImageView *moviePosterImageView;
@property (weak, nonatomic) IBOutlet UILabel *movieYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *movieTrailersTableView;
@property (weak, nonatomic) IBOutlet UITableView *movieReviewsTableView;
@property BOOL shouldInitializeWithDict;
- (IBAction)markAsFavoriteButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reviewsHight;


@end
