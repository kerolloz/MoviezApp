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
#import "YoutubeViewController.h"

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
    
    [self.movieReviewsTableView setDelegate:self];
    [self.movieReviewsTableView setDataSource:self];
    
    Movie *myMovie = [Movie new];
    [myMovie setMovieDelegate:self];
    [myMovie intializeMovieWithDictionary:self.movie];
    
    self.trailers = @[];
    self.reviews = @[];
    
    [super viewDidLoad];
    
    printf("MovieDetailsViewController viewDidLoad\n");
    
    [self.movieYearLabel setText:myMovie.releaseDate];
    [self.movieLengthLabel setText:myMovie.movieLength];
    [self.movieDescriptionLabel setText:myMovie.overview];
    [self.movieRatingLabel setText:myMovie.rating];
    [self.movieTitleLabel setText:myMovie.title];
    [self.moviePosterImageView setImage:myMovie.poster];
    
    [self.myScrollview setScrollEnabled:YES];
    [self.myScrollview setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1200)];
    
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
    [self.movieReviewsTableView reloadData];
}


- (IBAction)markAsFavoriteButtonPressed:(id)sender {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:self.movieTrailersTableView]) { return [self.trailers count]; }
    else{ return [self.reviews count]; }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if ([tableView isEqual:self.movieTrailersTableView]) {
       
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trailerCell"
                                                                forIndexPath:indexPath];
        UILabel *trailerName = [cell viewWithTag:1];
        UIImageView *imgView = [cell viewWithTag:2];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"movieYoutubeVideoThumbnailURLFormat"], [[self.trailers objectAtIndex:indexPath.row] objectForKey:@"key"]]];
        
        [trailerName setText:[[self.trailers objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [imgView sd_setImageWithURL:url];
        
        return cell;
    
    }else{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
        UILabel *reviewAuthor = [cell viewWithTag:1];
        UILabel *reviewContent = [cell viewWithTag:2];
        
        [reviewAuthor setText:[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"author"] ];
        [reviewContent setText:[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"content"]];
        
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if([tableView isEqual:self.movieTrailersTableView]){
        YoutubeViewController *YTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YoutubeViewController"];
    
        [YTVC setVideoKey:[[self.trailers objectAtIndex:indexPath.row] objectForKey:@"key"]];
        [self.navigationController pushViewController:YTVC animated:YES];
    }

}

@end
