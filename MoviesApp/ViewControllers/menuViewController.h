//
//  menuViewController.h
//  MoviesApp
//
//  Created by Kerollos Magdy Takawey Atallah on 9/14/18.
//  Copyright © 2018 Kerollos Magdy & Mohamed Maged. All rights reserved.
//
#define menuWidth 150.0
#import <UIKit/UIKit.h>

@interface menuViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UITableView *menuTable;

@property (nonatomic, strong) UIDynamicAnimator *animator;


-(void)setupMenuView;
-(void)toggleMenu:(BOOL)shouldOpenMenu;
-(void)handleGesture:(UISwipeGestureRecognizer *)gesture;

@end
