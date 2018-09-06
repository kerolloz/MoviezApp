//
//  Movie.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/5/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "Movie.h"
#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation Movie


// ***** public *****

-(void)intializeMovieWithDictionary: (NSDictionary *)movie{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path]; // links to all the APIs we use
    self.title = [movie objectForKey:@"title"];
    self.overview = [movie objectForKey:@"overview"];
    self.rating = [NSString stringWithFormat:@"%.1f", [[movie objectForKey:@"vote_average"] floatValue]  ]; // may get error
    self.movie_id = [NSString stringWithFormat:@"%d",  [[movie objectForKey:@"id"] intValue] ];  // 
    self.releaseDate = [movie objectForKey:@"release_date"];
    [self bringRuntime];
    [self bringTrailers];
    [self bringReviews];
    [self bringPosterWithPosterPath:[movie objectForKey:@"poster_path"]];
    
}


//  ***** protected *****



-(void)bringTrailers{
    NSString *movieTrailerURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"movieTrailerURLFormat"], self.movie_id];
    NSLog(@"MOVIE URL : %@", movieTrailerURL);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:movieTrailerURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
            NSLog(@"\nbringTrailers RESPONSE:   %@ \n", responseObject);
            self.trailers = [responseObject objectForKey:@"results"];
            [self.movieDelegate setMyTrailers:self.trailers];

        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [dataTask resume];
}


-(void)bringReviews{
    NSString *movieReviewsURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"movieReviewsURLFormat"], self.movie_id];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:movieReviewsURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
            NSLog(@"\nbringReviews RESPONSE:   %@ \n", responseObject);
            self.reviews = [responseObject objectForKey:@"result"];
            [self.movieDelegate setMyReviews:self.reviews];
        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [dataTask resume];
    
}


-(void)bringRuntime{
    NSString *movieInfoURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"movieInfoURLFormat"], self.movie_id];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
    NSURL *URL = [NSURL URLWithString:movieInfoURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
            NSLog(@"\nRESPONSE:   %@ \n", [responseObject valueForKey:@"runtime"]);
            self.movieLength = [NSString stringWithFormat:@"%d", [[responseObject objectForKey:@"runtime"] intValue]];
            [self.movieDelegate setRunTime:self.movieLength];
        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [dataTask resume];
}

-(void)bringPosterWithPosterPath: (NSString*)posterPath{
    NSString *moviePosterURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"], posterPath];
    UIImageView *imgView = [UIImageView new];
    [imgView sd_setImageWithURL:[NSURL URLWithString:moviePosterURL]];
    self.poster = [imgView image];
}

@end
