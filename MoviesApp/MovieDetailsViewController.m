//
//  MovieDetailsViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "MovieDetailsViewController.h"

@interface MovieDetailsViewController ()

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    printf("MovieDetailsViewController viewDidLoad\n");
    [self.movieYearLabel setText:[self.movie objectForKey:@"release_date"]];
    [self.movieLengthLabel setText:[self.movie objectForKey:@"release_date"]];
    [self.movieDescriptionLabel setText:[self.movie objectForKey:@"overview"]];
   // [self.movieRatingLabel setText:[self.movie objectForKey:@"vote_average"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)markAsFavoriteButtonPressed:(id)sender {
    
}
    @end
