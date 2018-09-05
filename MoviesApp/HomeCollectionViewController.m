//
//  HomeCollectionViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "MovieDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking.h>


@interface HomeCollectionViewController ()

@property CGFloat width;
@property CGFloat height;
@property NSArray *moviesArray; // of dictionaries
@property NSDictionary *apiPlistDictionary;

@end



@implementation HomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self fetchMoviesFromAPISortedBy:@"discoverMostPopular"]; // this sort should be determined by the user
    // the user choice should remain consistent during the app
    // NSUserDefaults is the solution
    [super viewDidLoad];
    
    // initialize the API Dictionary from the plist
    
    
    self.moviesArray = [[NSArray alloc] initWithObjects:@"1", @"2", nil]; // 2 dumb objects
    
    self.width = [UIScreen mainScreen].bounds.size.width/2;
    self.height = [UIScreen mainScreen].bounds.size.height/2;
}

-(void)fetchMoviesFromAPISortedBy: (NSString *)sortedBy{
    // change this implementation to koko's
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSLog(@"%@", [self.apiPlistDictionary objectForKey:sortedBy]);
    NSURL *URL = [NSURL URLWithString:[self.apiPlistDictionary objectForKey:sortedBy]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
            NSLog(@"\nRESPONSE:   %@ \n", [responseObject valueForKey:@"results"]);
            self.moviesArray = [responseObject valueForKey:@"results"];
            [self.collectionView reloadData];
        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [dataTask resume];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.moviesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImageView *image = [cell viewWithTag:1];
    image.frame = CGRectMake(0, 0, self.width, self.height);
    if([self.moviesArray count] > 2){
        NSString *moviePosterURLFormat = [self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"];
        NSString *posterPath = [(NSDictionary *)[self.moviesArray objectAtIndex:indexPath.row] objectForKey:@"poster_path"];
        NSString *posterURL = [NSString stringWithFormat:moviePosterURLFormat, posterPath];
        [image sd_setImageWithURL:[NSURL URLWithString:posterURL]
                 placeholderImage:[UIImage imageNamed:@"movie.png"]];
    }
  
    // Configure the cell
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    return CGSizeMake(self.width, self.height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MovieDetailsViewController *movie = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsViewController"];
    [movie setMovie:[self.moviesArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:movie animated:YES];
}


@end
