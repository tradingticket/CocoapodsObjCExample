//
//  TTSDKWebViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/2/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKWebViewController.h"
#import "TradeItStyles.h"


@implementation TTSDKWebViewController


- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewDidLoad {
    self.navBar.topItem.title = @"Loading...";
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    self.navBar.topItem.title = self.pageTitle;
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    TradeItStyles * styles = [TradeItStyles sharedStyles];

    return styles.statusBarStyle;
}


@end
