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
@property NSArray *trailers;
@property NSArray *reviews;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self.movieTrailersTableView setDelegate:self];
    [self.movieTrailersTableView setDataSource:self];
    
    Movie *myMovie = [Movie new];
    [myMovie setMovieDelegate:self];
    [myMovie intializeMovieWithDictionary:self.movie];
    
    [super viewDidLoad];
    
    printf("MovieDetailsViewController viewDidLoad\n");
    
    [self.movieYearLabel setText:myMovie.releaseDate];
    [self.movieLengthLabel setText:myMovie.movieLength];
    [self.movieDescriptionLabel setText:myMovie.overview];
    [self.movieRatingLabel setText:myMovie.rating];
    [self.moviePosterImageView setImage:myMovie.poster];
    
    
    
}

-(void)setRunTime:(NSString*) movieLength{
    [self.movieLengthLabel setText:movieLength];
}

-(void)setMyTrailers:(NSArray*) trailers{
    self.trailers = trailers;
    NSLog(@"trailers: %@", trailers);
    [self.movieTrailersTableView reloadData];
}
-(void)setMyReviews:(NSArray*) reviews{
    self.reviews = reviews;
}


- (IBAction)markAsFavoriteButtonPressed:(id)sender {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.trailers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trailerCell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *trailerName = [cell viewWithTag:1];
    [trailerName setText:[[self.trailers objectAtIndex:indexPath.row] objectForKey:@"name"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"movieYoutubeVideoThumbnailURLFormat"], [[self.trailers objectAtIndex:indexPath.row] objectForKey:@"key"]]];
    UIImageView *imgView = [cell viewWithTag:2];
    [imgView sd_setImageWithURL:url];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
