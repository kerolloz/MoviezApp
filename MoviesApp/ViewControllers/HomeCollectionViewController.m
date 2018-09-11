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
@property (strong, nonatomic) IBOutlet UIView *moviesSortedByView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property BOOL isInSortView;


@end



@implementation HomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    self.isInSortView = 0;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self fetchMoviesFromAPISortedBy]; // this sort should be determined by the user
    // the user choice should remain consistent during the app
    // NSUserDefaults is the solution
    [super viewDidLoad];
    
    // initialize the API Dictionary from the plist
    self.moviesSortedByView.layer.cornerRadius = 5;
    
    
    self.moviesArray = [[NSArray alloc] initWithObjects:@"1", @"2", nil]; // 2 dumb objects
    
    self.width = [UIScreen mainScreen].bounds.size.width/2;
    self.height = [UIScreen mainScreen].bounds.size.height/2;
}


-(void)fetchMoviesFromAPISortedBy{
    
    NSString *sortedBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortedBy"];
    if(sortedBy == nil){sortedBy = @"discoverMostPopular";}
  
    NSString *title = ([sortedBy isEqualToString:@"discoverMostPopular"])? @"Most Popular" : @"Highest Rated";
    [self.navigationItem setTitle:title];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:[self.apiPlistDictionary objectForKey:sortedBy]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError* error){
        // responseObject holds the data we want
        // responseObject is a dictionary so we need to extract the results arrray from it
        if(!error){
            self.moviesArray = [responseObject valueForKey:@"results"];
           [self.collectionView reloadData];
        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [dataTask resume];
}

- (IBAction)sortButtonPressed:(id)sender {
    // show the view
    // animate in
    self.isInSortView = 1;
    [self.collectionView setScrollEnabled:NO];
    
    [self.view addSubview:self.moviesSortedByView];
    
    self.moviesSortedByView.center = self.view.center;
    self.moviesSortedByView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.moviesSortedByView.alpha = 0;
    
    [UIView animateWithDuration:0.4 animations:^(){
        self.moviesSortedByView.alpha = 1;
        self.moviesSortedByView.transform = CGAffineTransformIdentity;
        
    }];
    
    
}


- (IBAction)sortMethodChosen:(id)sender { // hide the view
   
    // ***** Tags *****
    // 1 most popular
    // 2 highest rated
    // ****************
   
    [self.moviesSortedByView removeFromSuperview];
    
    if([sender tag] == 1){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"discoverMostPopular" forKey:@"sortedBy"];
        
    }else if ([sender tag] == 2){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"discoverHighestRated" forKey:@"sortedBy"];
        
    }
    
    // once out of sort view, you can select a movie
    self.isInSortView = 0;
    [self.collectionView setScrollEnabled:YES];
    
    [self fetchMoviesFromAPISortedBy];
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
  
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    return CGSizeMake(self.width, self.height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(!self.isInSortView){ // if not in sort view , you can select a movie
        MovieDetailsViewController *movie = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsViewController"];
   
        [movie setMovie:[self.moviesArray objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:movie animated:YES];
    }
    
}


@end
