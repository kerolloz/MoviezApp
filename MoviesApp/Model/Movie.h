//
//  Movie.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/5/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MovieDetailsDelegate.h"

@interface Movie : NSObject

@property id<MovieDetailsDelegate> movieDelegate;
@property NSString *movie_id;
@property NSString *title;
@property NSString *releaseDate;
@property NSString *overview;
@property NSString *rating;
@property NSString *movieLength;
@property NSArray *trailers;
@property NSArray *reviews;
@property UIImage *poster;
@property NSDictionary *apiPlistDictionary;

-(void)intializeMovieWithDictionary: (NSDictionary *)movie;

@end
