//
//  TTSDKNavigationController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/12/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKNavigationController.h"
#import "TradeItStyles.h"

@interface TTSDKNavigationController() {
    TradeItStyles * styles;
}

@end

@implementation TTSDKNavigationController


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

    [self setViewStyles];
}

-(void) setViewStyles {
    styles = [TradeItStyles sharedStyles];

    self.view.backgroundColor = styles.pageBackgroundColor;
    if (styles.navigationBarTitleColor) {
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : styles.navigationBarTitleColor}];
    }
    self.navigationController.navigationBar.barTintColor = styles.navigationBarBackgroundColor;
    self.navigationController.navigationBar.tintColor = styles.activeColor;
    [[UIBarButtonItem appearanceWhenContainedIn:TTSDKNavigationController.class, nil] setTintColor: styles.activeColor];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    styles = [TradeItStyles sharedStyles];

    return styles.statusBarStyle;
}

@end
