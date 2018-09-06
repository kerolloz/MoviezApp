//
//  MovieDetailsViewController.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieDetailsDelegate.h"

@interface MovieDetailsViewController : UIViewController <MovieDetailsDelegate, UITableViewDelegate, UITableViewDataSource>
    // naming convention
    // 'movie' + [name] + [type]
@property NSDictionary *movie;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollview;
@property (weak, nonatomic) IBOutlet UIImageView *moviePosterImageView;
@property (weak, nonatomic) IBOutlet UILabel *movieYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *movieTrailersTableView;
@property (weak, nonatomic) IBOutlet UITableView *movieReviewsTableView;
- (IBAction)markAsFavoriteButtonPressed:(id)sender;


@end
