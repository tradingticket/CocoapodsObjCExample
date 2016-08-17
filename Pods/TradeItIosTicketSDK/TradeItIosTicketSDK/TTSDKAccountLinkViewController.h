//
//  TTSDKAccountLinkViewController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/13/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKAccountLinkTableViewCell.h"
#import "TTSDKViewController.h"

@interface TTSDKAccountLinkViewController : TTSDKViewController <UITableViewDataSource, UITableViewDelegate, TTSDKAccountLinkDelegate>

@property BOOL pushed;
@property BOOL relinking;

@end
