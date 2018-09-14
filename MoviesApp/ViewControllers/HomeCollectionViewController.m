//
//  HomeCollectionViewController.m
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import "HomeCollectionViewController.h"


@interface HomeCollectionViewController ()

@property CGFloat width;
@property CGFloat height;
@property NSMutableArray *moviesArray; // of dictionaries
@property NSDictionary *apiPlistDictionary;
@property (strong, nonatomic) IBOutlet UIView *moviesSortedByView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property BOOL isInSortView;
@property (strong , nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;
@property NSArray *menuOptions;

@end



@implementation HomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuOptions = @[@"Movies Sorted By:", @"Most Popular", @"Highest Rated", @"Night Mode 🌙"];
    //  ************************** Right Menu *******************************
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UISwipeGestureRecognizer *hideMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleGesture:)];
    hideMenuGesture.direction = UISwipeGestureRecognizerDirectionRight ;
    [self.view addGestureRecognizer:hideMenuGesture];

    UISwipeGestureRecognizer *showMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleGesture:)];
    showMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:showMenuGesture];
    
    [self setupMenuView];
    //  ******************************************************************
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"plist"];
    self.apiPlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self intializeDataBase];
    [self checkInternetConnectivity];
    
    self.isInSortView = 0;
    
    
    self.moviesSortedByView.layer.cornerRadius = 5;
    
    
    self.moviesArray = [NSMutableArray new]; // dumb object
    
    self.width = [UIScreen mainScreen].bounds.size.width/2;
    self.height = [UIScreen mainScreen].bounds.size.height/2;
}

-(void)checkInternetConnectivity{
   
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable){
        //connection unavailable
        [self fetchMoviesFromDataBaseSortedBy];
    }
    else{
        //connection available
        [self fetchMoviesFromAPISortedBy];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.width = [UIScreen mainScreen].bounds.size.width/2;
    self.height = [UIScreen mainScreen].bounds.size.height/2;
    [self.collectionView reloadData];
    
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
        "CREATE TABLE IF NOT EXISTS MOVIES (Movie_ID TEXT PRIMARY KEY, TITLE TEXT, OVERVIEW TEXT, RATING TEXT, Release_Date TEXT, RUNTIME TEXT, POSTER_PATH TEXT, SORT INTEGER, isFav INTEGER)";
        
        if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        sqlite3_close(_contactDB);
    } else {
        NSLog(@"Failed to open/create database");
    }
}

-(void)fetchMoviesFromDataBaseSortedBy{
    
    
    NSString *sortedBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortedBy"];
    if(sortedBy == nil){sortedBy = @"discoverMostPopular";}
    
    int sortMethod = ([sortedBy isEqualToString:@"discoverMostPopular"])? 1 : 2;
    
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM MOVIES WHERE Sort=\"%d\"", sortMethod]; // bring all movies
        //ID 0
        //TITLE 1
        //OVERVIEW 2
        //RATING 3
        //RELEASE_YEAR 4
        //RUNTIME 5
        //POSTER_PATH 6
        //Sort 7  = (1=Most POP, 2=HighestRated)
        //isFav 8
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


-(void)addFetchedMoviesToDataBase{

    NSString *sortedBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortedBy"];
    if(sortedBy == nil){sortedBy = @"discoverMostPopular";}
    
    int sortMethod = ([sortedBy isEqualToString:@"discoverMostPopular"])? 1 : 2;
    
    sqlite3_stmt    *statement = NULL;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        for (NSDictionary *movieDict in self.moviesArray) {
            Movie *myMovie = [Movie new];
            [myMovie intializeMovieWithDictionary:movieDict]; // not sure !!!
        
            myMovie.title = [myMovie.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            myMovie.overview = [myMovie.overview stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO MOVIES (MOVIE_ID, TITLE, OVERVIEW, RATING, Release_Date, RUNTIME, POSTER_PATH, SORT, isFav) VALUES (\'%@\', \'%@\', \'%@\', \'%@\', \'%@\', \'%@\', \'%@\', \'%d\', 0)",
                                   myMovie.movie_id,
                                   myMovie.title,
                                   myMovie.overview,
                                   myMovie.rating,
                                   myMovie.releaseDate,
                                   myMovie.movieLength,
                                   myMovie.posterPath,
                                   sortMethod
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
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
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
            [self addFetchedMoviesToDataBase];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }else{
            // show alert here with the error message
            NSLog(@"%@", error); // error is null when the data is fetched successfuly
        }
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [dataTask resume];
}

- (IBAction)sortButtonPressed:(id)sender {
    // show the view
    // animate in
    if(!self.isInSortView){
        [self toggleMenu:YES];
        self.isInSortView = 1;
    }else{
        [self toggleMenu:NO];
        self.isInSortView = 0;
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
        [movie setShouldInitializeWithDict:YES];
        [movie setMovieDictionary:[self.moviesArray objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:movie animated:YES];
    }
    
}


-(void)handleGesture:(UISwipeGestureRecognizer *)gesture{
    if (!self.isInSortView && gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self toggleMenu:YES];
        self.isInSortView = 1;
    }
    else if (self.isInSortView && gesture.direction == UISwipeGestureRecognizerDirectionRight){
        [self toggleMenu:NO];
        self.isInSortView = 0;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.isInSortView){
        [self toggleMenu:NO];
        self.isInSortView = 0;
    }
}

-(void)setupMenuView{
    // Setup the background view.
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor lightGrayColor];
    self.backgroundView.alpha = 0.0;
    [self.view addSubview:self.backgroundView];
    // Setup the menu view.
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(self.tabBarController.tabBar.frame.size.width + 10,
                                self.navigationController.navigationBar.frame.size.height+20,
                                                             menuWidth,
                                                             self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height)];
    
    self.menuView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [self.view addSubview:self.menuView];
    // Setup the table view.
    self.menuTable = [[UITableView alloc] initWithFrame:self.menuView.bounds
                                                  style:UITableViewStylePlain];
    self.menuTable.backgroundColor = [UIColor clearColor];
    self.menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.menuTable.scrollEnabled = NO;
    self.menuTable.alpha = 1.0;
    
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    
    [self.menuTable reloadData];
    
    [self.menuView addSubview:self.menuTable];
}
-(void)toggleMenu:(BOOL)shouldOpenMenu{
    [self.animator removeAllBehaviors];
    
    CGFloat gravityDirectionX = (shouldOpenMenu) ? -1.0 : 1.0;
    CGFloat pushMagnitude = (shouldOpenMenu) ? -20.0 : 20.0;
    CGFloat boundaryPointX = (shouldOpenMenu) ? self.tabBarController.tabBar.frame.size.width-menuWidth : self.tabBarController.tabBar.frame.size.width+menuWidth;
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.menuView]];
    gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX, 0.0);
    [self.animator addBehavior:gravityBehavior];
    
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    [collisionBehavior addBoundaryWithIdentifier:@"menuBoundary"
                                       fromPoint:CGPointMake(boundaryPointX, 20.0)
                                         toPoint:CGPointMake(boundaryPointX, self.tabBarController.tabBar.frame.origin.y)];
    [self.animator addBehavior:collisionBehavior];
    
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.menuView]
                                                                    mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.magnitude = pushMagnitude;
    [self.animator addBehavior:pushBehavior];
    
    
    UIDynamicItemBehavior *menuViewBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.menuView]];
    menuViewBehavior.elasticity = 0.4;
    [self.animator addBehavior:menuViewBehavior];
    
    self.backgroundView.alpha = (shouldOpenMenu) ? 0.5 : 0.0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSString *sortMethod = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortedBy"];
    
    cell.textLabel.text = [self.menuOptions objectAtIndex:indexPath.row];
    
    if(indexPath.row == 1 && [sortMethod isEqualToString:@"discoverMostPopular"]){
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:YES];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", cell.textLabel.text, @"✅"];
    }else if(indexPath.row == 2 && [sortMethod isEqualToString:@"discoverHighestRated"]){
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:YES];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", cell.textLabel.text, @"✅"];
    }else{
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    }
    
   
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:13.0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    if(indexPath.row == 0 || indexPath.row == 3){
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    if(indexPath.row == self.menuOptions.count-1){
        UISwitch *switchController = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchController setOn:YES animated:YES];
        switchController.tag = indexPath.row;
        cell.accessoryView = switchController;
    }

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    if(indexPath.row == 1){
        [[NSUserDefaults standardUserDefaults] setValue:@"discoverMostPopular" forKey:@"sortedBy"];
        [self checkInternetConnectivity];
        [self toggleMenu:NO];
        self.isInSortView = 0;
        [tableView cellForRowAtIndexPath:indexPath].textLabel.text = [NSString stringWithFormat:@"%@ %@", [self.menuOptions objectAtIndex:indexPath.row], @"✅"];
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].textLabel.text = [self.menuOptions objectAtIndex:[NSIndexPath indexPathForRow:2 inSection:0].row];
    }
    else if(indexPath.row == 2){
        [[NSUserDefaults standardUserDefaults] setValue:@"discoverHighestRated" forKey:@"sortedBy"];
        [self checkInternetConnectivity];
        [self toggleMenu:NO];
        self.isInSortView = 0;
        [tableView cellForRowAtIndexPath:indexPath].textLabel.text = [NSString stringWithFormat:@"%@ %@", [self.menuOptions objectAtIndex:indexPath.row], @"✅"];
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].textLabel.text = [self.menuOptions objectAtIndex:[NSIndexPath indexPathForRow:1 inSection:0].row];

    }
}


@end
