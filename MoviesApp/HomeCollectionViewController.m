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

@interface HomeCollectionViewController ()


@property CGFloat width;
@property CGFloat height;

@end

@implementation HomeCollectionViewController

static NSString * const apiKey = @"a305175029b4b63a7b388477740d49c7";
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.width = [UIScreen mainScreen].bounds.size.width/2;
    self.height = [UIScreen mainScreen].bounds.size.height/3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImageView *image = [cell viewWithTag:1];
    image.frame = CGRectMake(0, 0, self.width, self.height);
    NSString *moviePosterUrl = @"http://image.tmdb.org/t/p/w185/nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg";
    [image sd_setImageWithURL:[NSURL URLWithString:moviePosterUrl]
                 placeholderImage:[UIImage imageNamed:@"movie.png"]];
  
    // Configure the cell
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    return CGSizeMake(self.width, self.height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MovieDetailsViewController *movie = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsViewController"];
    [self.navigationController pushViewController:movie animated:YES];
}


@end
