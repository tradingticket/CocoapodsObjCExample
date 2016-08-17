//
//  ReviewScreenViewController.h
//  TradingTicket
//
//  Created by Antonio Reyes on 6/24/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeResult.h>
#import "TTSDKViewController.h"

@interface TTSDKReviewScreenViewController : TTSDKViewController

@property TradeItPreviewTradeResult * reviewTradeResult;

@end
