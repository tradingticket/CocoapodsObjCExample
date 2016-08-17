//
//  TTSDKBaseViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/12/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKTabBarViewController.h"
#import "TradeItStyles.h"

@interface TTSDKTabBarViewController() {
    TradeItStyles * styles;
}

@end

@implementation TTSDKTabBarViewController


#pragma mark Rotation

-(BOOL) shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark Initialization

-(void) viewDidLoad {
    [super viewDidLoad];

    styles = [TradeItStyles sharedStyles];

    self.navigationController.navigationBar.backgroundColor = styles.navigationBarBackgroundColor;
    self.navigationController.navigationBar.tintColor = styles.activeColor;

    [[UITabBar appearanceWhenContainedIn:self.class, nil] setTintColor: styles.tabBarItemColor];
    [[UITabBar appearanceWhenContainedIn:self.class, nil] setBarTintColor: styles.tabBarBackgroundColor];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    styles = [TradeItStyles sharedStyles];
    
    return styles.statusBarStyle;
}


@end
