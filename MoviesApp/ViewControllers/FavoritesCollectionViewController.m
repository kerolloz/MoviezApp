//
//  FavoritesCollectionViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/5/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "FavoritesCollectionViewController.h"


@interface FavoritesCollectionViewController ()

@property CGFloat width;
@property CGFloat height;
@property NSDictionary *apiPlistDictionary;
@property (strong , nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;
@property (weak, nonatomic) IBOutlet UILabel *noMoviesLabel;

@end

@implementation FavoritesCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self intializeDataBase];

    self.width = [UIScreen mainScreen].bounds.size.width/2;
    self.height = [UIScreen mainScreen].bounds.size.height/2;
}

-(void)viewWillAppear:(BOOL)animated{
    self.moviesArray = [NSMutableArray new];
    [self fetchMoviesFromDataBase];
    [self.collectionView reloadData];
    if(self.moviesArray.count) _noMoviesLabel.hidden = YES;
    else _noMoviesLabel.hidden = NO;
}

-(void)intializeDataBase{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"movies.db"]];

}


-(void)fetchMoviesFromDataBase{
    
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM MOVIES WHERE isFav=1"]; // bring all movies
        //ID 0
        //TITLE 1
        //OVERVIEW 2
        //RATING 3
        //RELEASE_YEAR 4
        //RUNTIME 5
        //POSTER_PATH 6
        //SORT 7          -1 MostPop -2 Highest
        //isFav 8   1. True 0.False
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                Movie *movie = [Movie new];
                // set data from table
               movie.movie_id = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(
                                                                             statement, 0)];
                
               movie.title = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 1)];
                
               movie.overview = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 2)];
                
               movie.rating = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 3)];
                
                movie.releaseDate = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 4)];
                
                movie.movieLength = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 5)];
                
               movie.posterPath = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 6)];
                
                [self.moviesArray addObject:movie];
                NSLog( @"Match found");

            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }
    
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
    
    if([self.moviesArray count]){
        NSString *moviePosterURLFormat = [self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"];
        NSString *posterPath = [(Movie *)[self.moviesArray objectAtIndex:indexPath.row] posterPath];
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
    MovieDetailsViewController *movie = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsViewController"];
    [movie setShouldInitializeWithDict:NO];
    [movie setMyMovie:[self.moviesArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:movie animated:YES];
}
    
    
    
@end
