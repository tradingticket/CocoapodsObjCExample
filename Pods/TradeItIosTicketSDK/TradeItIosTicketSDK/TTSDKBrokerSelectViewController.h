//
//  BrokerSelectViewController.h
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 7/20/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKTableViewController.h"
#import "TTSDKLoginViewController.h"

@interface TTSDKBrokerSelectViewController : TTSDKTableViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property BOOL isModal;
@property BOOL cancelToParent;

@end
