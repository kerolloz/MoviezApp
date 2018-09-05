//
//  MovieDetailsViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "Movie.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MovieDetailsViewController ()

@property NSDictionary *apiPlistDictionary;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    Movie *myMovie = [Movie new];
    [myMovie setMovieDelegate:self];
    [myMovie intializeMovieWithDictionary:self.movie];
    
    [super viewDidLoad];
    
    printf("MovieDetailsViewController viewDidLoad\n");
//    NSLog(@"%@", self.movie);
//    [self.movieYearLabel setText:[self.movie objectForKey:@"release_date"]];
//    [self.movieLengthLabel setText:[self.movie objectForKey:@"release_date"]];
//    [self.movieDescriptionLabel setText:[self.movie objectForKey:@"overview"]];
//    //[self.movieRatingLabel setText:[self.movie objectForKey:@"vote_average"]];
//    NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"], [self.movie objectForKey:@"poster_path"]]];
//    [self.moviePosterImageView sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"movie.png"]];
    
    [self.movieYearLabel setText:myMovie.releaseDate];
    [self.movieLengthLabel setText:myMovie.movieLength];
    [self.movieDescriptionLabel setText:myMovie.overview];
    [self.movieRatingLabel setText:myMovie.rating];
    [self.moviePosterImageView setImage:myMovie.poster];
    
    
    
}

-(void)setRunTime:(NSString*) movieLength{
    [self.movieLengthLabel setText:movieLength];
}
-(void)setTrailers{
    
}
-(void)setReviews{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)markAsFavoriteButtonPressed:(id)sender {
    
}
    @end
