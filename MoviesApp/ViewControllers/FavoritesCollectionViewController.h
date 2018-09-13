//
//  FavoritesCollectionViewController.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/5/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <sqlite3.h>
#import "Movie.h"

@interface FavoritesCollectionViewController : UICollectionViewController

@property NSMutableArray *moviesArray; // of Movie


@end
