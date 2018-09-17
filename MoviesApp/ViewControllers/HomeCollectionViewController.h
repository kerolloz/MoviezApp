//
//  HomeCollectionViewController.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/4/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking.h>
#import <sqlite3.h>
#import "Reachability.h"
#import <LGSideMenuController/LGSideMenuController.h>
#import <LGSideMenuController/UIViewController+LGSideMenuController.h>

#define menuWidth 200 // <- side menu "Settings Menu"

@interface HomeCollectionViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UITableView *menuTable;

@property (nonatomic, strong) UIDynamicAnimator *animator;


-(void)setupMenuView;
-(void)toggleMenu:(BOOL)shouldOpenMenu;
-(void)handleGesture:(UISwipeGestureRecognizer *)gesture;

@end
