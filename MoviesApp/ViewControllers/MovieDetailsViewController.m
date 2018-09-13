//
//  MovieDetailsViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "MovieDetailsViewController.h"


@interface MovieDetailsViewController ()

@property NSDictionary *apiPlistDictionary;
@property NSMutableArray *trailers;
@property NSMutableArray *reviews;
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

    self.trailers = [NSMutableArray new];
    self.reviews = [NSMutableArray new];
    
    [self.movieTrailersTableView setDelegate:self];
    [self.movieTrailersTableView setDataSource:self];
    
    [self.movieReviewsTableView setDelegate:self];
    [self.movieReviewsTableView setDataSource:self];
    
    [self intializeDataBase];
    [self checkInternetConnectivity];
    

//
//    self.trailers = @[];
//    self.reviews = @[];
//
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
    [self fetchMovieFromDB];
    if(self.myMovie.isFav){
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
    } else{
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"nonStarred.png"] forState:UIControlStateNormal];
    }
}

-(void)checkInternetConnectivity{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable){
        //connection unavailable
        [self fetchTrailersFromDB];
        [self fetchReviewsFromDB];
    }
    else{
        //connection available
        if(self.shouldInitializeWithDict){
            self.myMovie = [Movie new];
            [self.myMovie setMovieDelegate:self];
            [self.myMovie intializeMovieWithDictionary:self.movieDictionary];
        }else{
            
            NSString *moviePosterURL = [NSString stringWithFormat:[self.apiPlistDictionary objectForKey:@"moviePosterURLFormat"], self.myMovie.posterPath];
            [self.moviePosterImageView sd_setImageWithURL:[NSURL URLWithString:moviePosterURL]];
            self.myMovie.poster = self.moviePosterImageView.image;
            
            [self fetchTrailersFromDB];
            [self fetchReviewsFromDB];
        }
    }
    
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
        "CREATE TABLE IF NOT EXISTS Trailers ("
        "Movie_ID TEXT,"
        "Name TEXT,"
        "Image TEXT,"
        "PRIMARY KEY(MOVIE_ID, Name)"
        "); "
        "CREATE TABLE IF NOT EXISTS Reviews ("
        "Movie_ID TEXT,"
        "Author TEXT,"
        "Content TEXT,"
        "PRIMARY KEY(MOVIE_ID, AUTHOR)"
        ")";
        
        if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        sqlite3_close(_contactDB);
    } else {
        NSLog(@"Failed to open/create database");
    }

}

-(void)setRunTime:(NSString*) movieLength{
    [self.movieLengthLabel setText:movieLength];
    self.myMovie.movieLength = movieLength;
    [self updateRuntimeInDB];
    
}
-(void)updateRuntimeInDB{
    sqlite3_stmt    *statement = NULL;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
            
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"UPDATE MOVIES SET Runtime = \'%@\' WHERE Movie_ID=\'%@\'",
                                   self.myMovie.movieLength,
                                   self.myMovie.movie_id
                                   ];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_contactDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Runtime Updated");
                
            } else {
                NSLog(@"failed to Update Runtime");
            }
        
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(void)setMyTrailers:(NSArray*) trailers{
    self.trailers = [trailers mutableCopy];
    if([self.trailers count]){
        [self.movieTrailersTableView reloadData];
        [self addFetchedTrailersToDB];
    }else{
        // no trailers available
        [self.movieTrailersTableView removeFromSuperview];
    }
        
}

-(void)setMyReviews:(NSArray*) reviews{
    self.reviews = [reviews mutableCopy];
    if([self.reviews count]){
        [self.movieReviewsTableView reloadData];
        [self addFetchedReviewsToDB];
    }else{
        [self.movieReviewsTableView removeFromSuperview];
        
    }
}

-(void)addFetchedTrailersToDB{
    sqlite3_stmt    *statement = NULL;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        for (NSDictionary *trailer in self.trailers) {
            NSString *name = [[trailer objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *image = [[trailer objectForKey:@"key"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO Trailers (MOVIE_ID, Name, Image) VALUES (\'%@\', \'%@\', \'%@\')",
                                   self.myMovie.movie_id,
                                   name,
                                   image
                                   ];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_contactDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"trailer added");
                
            } else {
                NSLog(@"failed to add Trailer");
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(void)addFetchedReviewsToDB{
    sqlite3_stmt    *statement = NULL;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        for (NSDictionary *review in self.reviews) {
            
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO Reviews (MOVIE_ID, Author, Content) VALUES (\'%@\', \'%@\', \'%@\')",
                                   self.myMovie.movie_id,
                                   [[review objectForKey:@"author"]stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
                                   [[review objectForKey:@"content"]stringByReplacingOccurrencesOfString:@"'" withString:@"''"]
                                   ];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_contactDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Review added");
                
            } else {
                NSLog(@"failed to add Review");
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(void)fetchMovieFromDB{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT isFav FROM Movies WHERE Movie_ID=\"%@\"", self.myMovie.movie_id]; // bring all movies
        //MOVIE_ID 0
        //TITLE 1
        //OVERVIEW 2
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                // set data from table
                int  isFav = sqlite3_column_int(statement, 0);
                if(isFav)
                    self.myMovie.isFav = 1;
                else
                    self.myMovie.isFav = 0;
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }
}

-(void)fetchReviewsFromDB{
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM Reviews WHERE Movie_ID=\"%@\"", self.myMovie.movie_id]; // bring all movies
        //MOVIE_ID 0
        //TITLE 1
        //OVERVIEW 2
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *review = [NSMutableDictionary new];
                // set data from table
                NSString * author = [[NSString alloc]
                                  initWithUTF8String:
                                  (const char *) sqlite3_column_text(
                                                                     statement, 1)];
                NSString * content = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, 2)];
                [review setValue:author forKey:@"author"];
                [review setValue:content forKey:@"content"];
               
                [self.reviews addObject:review];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }
    if(self.reviews.count)
        [self.movieReviewsTableView reloadData];
    else
        [self.movieReviewsTableView removeFromSuperview];
}

-(void)fetchTrailersFromDB{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM Trailers WHERE Movie_ID=\"%@\"", self.myMovie.movie_id]; // bring all movies
        //MOVIE_ID 0
        //Name 1
        //Image 2
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *trailer = [NSMutableDictionary new];
                // set data from table
                NSString * name = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, 1)];
                NSString * key = [[NSString alloc]
                                      initWithUTF8String:
                                      (const char *) sqlite3_column_text(
                                                                         statement, 2)];
                [trailer setValue:name forKey:@"name"];
                [trailer setValue:key forKey:@"key"];
                
                [self.trailers addObject:trailer];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }
    if(self.trailers.count)
        [self.movieTrailersTableView reloadData];
    else
        [self.movieTrailersTableView removeFromSuperview];
}

- (IBAction)markAsFavoriteButtonPressed:(id)sender {
    
    if(self.myMovie.isFav){
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"nonStarred.png"] forState:UIControlStateNormal];
        [self removeMovieFromFavorites];
        self.myMovie.isFav = NO;
    }else{
        [self addMovieToFavorite];
        [self.markAsFavoriteButtonOutlet setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        self.myMovie.isFav = YES;
    }
}

-(void)addMovieToFavorite{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"UPDATE Movies SET isFav=1 WHERE MOVIE_ID=\'%@\'",
                               self.myMovie.movie_id
                               ];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"movie added to FAVORITES");
            
        } else {
            NSLog(@"failed to add Movie to FAV");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(void)removeMovieFromFavorites{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"UPDATE MOVIES SET isFav=0 WHERE Movie_ID = \'%@\'",
                               self.myMovie.movie_id
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([tableView isEqual:self.movieTrailersTableView]) return @"Trailers";
    else return @"Reviews";
}

@end
