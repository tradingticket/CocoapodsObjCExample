//
//  TTSDKAccountSummaryResult.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSDKPosition.h"
#import <TradeItIosEmsApi/TradeItAccountOverviewResult.h>

@interface TTSDKAccountSummaryResult : NSObject

@property NSArray * positions;
@property NSArray * balances;
@property TTSDKPosition * position;
@property TradeItAccountOverviewResult * balance;

@end
