//
//  TTSDKWebViewController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/2/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSDKWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property NSString * pageTitle;

@end
