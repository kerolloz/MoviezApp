//
//  MovieDetailsViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YoutubeViewController.h"
#import <sqlite3.h>

@interface MovieDetailsViewController ()

@property BOOL isFavorite;
@property NSDictionary *apiPlistDictionary;
@property NSArray *trailers;
@property NSArray *reviews;
@property (strong , nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;
@property (weak, nonatomic) IBOutlet UIButton *markAsFavoriteButtonOutlet;
@property NSMutableArray *moviesArray;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviesArray = [NSMutableArray new];
    //self.shouldInitializeWithDict = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self intializeDataBase];
    
    [self.movieTrailersTableView setDelegate:self];
    [self.movieTrailersTableView setDataSource:self];
    
    [self.movieReviewsTableView setDelegate:self];
    [self.movieReviewsTableView setDataSource:self];
    
    [self fetchMoviesFromDataBase];
    
    if(self.shouldInitializeWithDict){
        self.myMovie = [Movie new];
        [self.myMovie setMovieDelegate:self];
        [self.myMovie intializeMovieWithDictionary:self.movieDictionary];
    }else{
        
        NSString *moviePosterURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"], self.myMovie.posterPath];
        [self.moviePosterImageView sd_setImageWithURL:[NSURL URLWithString:moviePosterURL]];
        self.myMovie.poster = self.moviePosterImageView.image;
    }
    
    self.trailers = @[];
    self.reviews = @[];
    
    printf("MovieDetailsViewController viewDidLoad\n");
    
    [self.movieYearLabel setText:self.myMovie.releaseDate];
    [self.movieLengthLabel setText:self.myMovie.movieLength];
    [self.movieDescriptionLabel setText:self.myMovie.overview];
    [self.movieRatingLabel setText:self.myMovie.rating];
    [self.movieTitleLabel setText:self.myMovie.title];
    [self.moviePosterImageView setImage:self.myMovie.poster];
    
    [self.myScrollview setScrollEnabled:YES];
    [self.myScrollview setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1200)];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.isFavorite = NO;
    for(Movie *movie in self.moviesArray){
        if([movie.title isEqualToString:_myMovie.title]){
            self.isFavorite = YES;
            break;
        }
    }
    if(self.isFavorite)
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
    else
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"nonStarred.png"] forState:UIControlStateNormal];

}

-(void)intializeDataBase{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"movies.db"]];

    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt =
        "CREATE TABLE IF NOT EXISTS MOVIES (ID TEXT PRIMARY KEY, TITLE TEXT, OVERVIEW TEXT, RATING TEXT, RELEASE_YEAR TEXT, RUNTIME TEXT, POSTER_PATH TEXT)";
        
        if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        sqlite3_close(_contactDB);
    } else {
        NSLog(@"Failed to open/create database");
    }
}

-(void)addMovieToDataBase{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        self.myMovie.title = [self.myMovie.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        self.myMovie.overview = [self.myMovie.overview stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO MOVIES (ID, TITLE, OVERVIEW, RATING, RELEASE_YEAR, RUNTIME, POSTER_PATH) VALUES (\'%@\', \'%@\', \'%@\', \'%@\', \'%@\', \'%@\', \'%@\')",
                               self.myMovie.movie_id,
                               self.myMovie.title,
                               self.myMovie.overview,
                               self.myMovie.rating,
                               self.myMovie.releaseDate,
                               self.myMovie.movieLength,
                               self.myMovie.posterPath
                               ];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"movie added");
            
        } else {
            NSLog(@"failed to add Movie");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(void)removeMovieFromDataBase{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];

    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"DELETE FROM MOVIES WHERE TITLE = \"%@\"",
                               
                               self.myMovie.title
                               ];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"movie DELETED");
            
        } else {
            NSLog(@"failed to add Movie");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(void)fetchMoviesFromDataBase{
    
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM MOVIES"]; // bring all movies
        //ID 0
        //TITLE 1
        //OVERVIEW 2
        //RATING 3
        //RELEASE_YEAR 4
        //RUNTIME 5
        //POSTER_PATH 6
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


-(void)setRunTime:(NSString*) movieLength{
    [self.movieLengthLabel setText:movieLength];
}

-(void)setMyTrailers:(NSArray*) trailers{
    self.trailers = trailers;
    NSLog(@"trailers: %@", trailers);
    [self.movieTrailersTableView reloadData];
}

-(void)setMyReviews:(NSArray*) reviews{
    self.reviews = reviews;
    [self.movieReviewsTableView reloadData];
}


- (IBAction)markAsFavoriteButtonPressed:(id)sender {
    
    if(self.isFavorite){
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"nonStarred.png"] forState:UIControlStateNormal];
        [self removeMovieFromDataBase];
        self.isFavorite = NO;
    }else{
        [self addMovieToDataBase];
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        self.isFavorite = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:self.movieTrailersTableView]) { return [self.trailers count]; }
    else{ return [self.reviews count]; }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if ([tableView isEqual:self.movieTrailersTableView]) {
       
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trailerCell"
                                                                forIndexPath:indexPath];
        UILabel *trailerName = [cell viewWithTag:1];
        UIImageView *imgView = [cell viewWithTag:2];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"movieYoutubeVideoThumbnailURLFormat"], [[self.trailers objectAtIndex:indexPath.row] objectForKey:@"key"]]];
        
        [trailerName setText:[[self.trailers objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [imgView sd_setImageWithURL:url];
        
        return cell;
    
    }else{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
        UILabel *reviewAuthor = [cell viewWithTag:1];
        UILabel *reviewContent = [cell viewWithTag:2];
        
        [reviewAuthor setText:[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"author"] ];
        [reviewContent setText:[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"content"]];
        
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if([tableView isEqual:self.movieTrailersTableView]){
        YoutubeViewController *YTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YoutubeViewController"];
    
        [YTVC setVideoKey:[[self.trailers objectAtIndex:indexPath.row] objectForKey:@"key"]];
        [self.navigationController pushViewController:YTVC animated:YES];
    }

}

@end
