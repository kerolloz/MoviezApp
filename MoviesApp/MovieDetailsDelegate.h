//
//  MovieDetailsDelegate.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/6/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MovieDetailsDelegate <NSObject>

-(void)setRunTime:(NSString*) movieLength;
-(void)setTrailers;
-(void)setReviews;

@end
