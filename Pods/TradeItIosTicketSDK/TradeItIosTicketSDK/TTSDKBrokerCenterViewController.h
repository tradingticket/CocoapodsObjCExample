//
//  TTSDKBrokerCenterViewController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/9/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKTableViewController.h"
#import "TTSDKBrokerCenterTableViewCell.h"

@interface TTSDKBrokerCenterViewController : TTSDKTableViewController <TTSDKBrokerCenterDelegate, UIWebViewDelegate>

@property BOOL isModal;

@end
