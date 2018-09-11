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
    self.rating = [NSString stringWithFormat:@"%.1f", [[movie objectForKey:@"vote_average"] floatValue]  ];
    self.movie_id = [NSString stringWithFormat:@"%d",  [[movie objectForKey:@"id"] intValue] ];
    self.releaseDate = [movie objectForKey:@"release_date"];
    
    [self bringRuntime];
    [self bringTrailers];
    [self bringReviews];
    
    [self bringPosterWithPosterPath:[movie objectForKey:@"poster_path"]];
    
}


//  ***** protected *****

-(NSURLRequest*)requestPrepearForKey: (NSString*)key{
    
    NSString *keyURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:key], self.movie_id];
 
    
    NSURL *URL = [NSURL URLWithString:keyURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    return request;
}

-(AFURLSessionManager*)getSessionManager{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    return manager;
    
}



-(void)bringTrailers{
    
    NSURLSessionDataTask *dataTask = [[self getSessionManager] dataTaskWithRequest:[self requestPrepearForKey:@"movieTrailerURLFormat"] uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
            
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
    
    
    NSURLSessionDataTask *dataTask = [[self getSessionManager] dataTaskWithRequest:[self requestPrepearForKey:@"movieReviewsURLFormat"] uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
            if(!error){
                self.reviews = [responseObject objectForKey:@"results"];
                [self.movieDelegate setMyReviews:self.reviews];
            }else{
                // show alert here with the error message
                NSLog(@"%@", error); // error is null when the data is fetched successfuly
            }
        }
    ];
    [dataTask resume];
    
}


-(void)bringRuntime{
    
    NSURLSessionDataTask *dataTask = [[self getSessionManager] dataTaskWithRequest:[self requestPrepearForKey:@"movieInfoURLFormat"] uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
           
            if([responseObject objectForKey:@"runtime"] && [responseObject objectForKey:@"runtime"] != [NSNull null]){
                self.movieLength = [NSString stringWithFormat:@"%d", [[responseObject objectForKey:@"runtime"] intValue]];
                    [self.movieDelegate setRunTime:self.movieLength];
            }
        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [dataTask resume];
}

-(void)bringPosterWithPosterPath: (NSString*)posterPath{
    self.posterPath = posterPath;
    NSString *moviePosterURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"], posterPath];
    UIImageView *imgView = [UIImageView new];
    [imgView sd_setImageWithURL:[NSURL URLWithString:moviePosterURL]];
    self.poster = [imgView image];
}

@end
