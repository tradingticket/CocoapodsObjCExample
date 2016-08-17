//
//  TTSDKAccountsViewController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/16/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKViewController.h"

@interface TTSDKAccountSelectViewController : TTSDKViewController <UITableViewDataSource,UITableViewDelegate>

@property BOOL isModal;

@end
