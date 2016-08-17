//
//  TTSDKSearchViewController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKTableViewController.h"

@interface TTSDKSearchViewController : TTSDKTableViewController <UISearchDisplayDelegate>

@property BOOL noSymbol;

@end
