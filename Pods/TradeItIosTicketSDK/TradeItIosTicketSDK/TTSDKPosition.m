//
//  TTSDKPosition.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/14/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPosition.h"
#import <TradeItIosEmsApi/TradeItMarketDataService.h>
#import "TTSDKTradeItTicket.h"
#import <TradeItIosEmsApi/TradeItQuotesResult.h>
#import <TradeItIosEmsApi/TradeItQuote.h>

@implementation TTSDKPosition


-(id) initWithPosition:(TradeItPosition *)position {
    if (self = [super init]) {
        self.symbol = position.symbol;
        self.symbolClass = position.symbolClass;
        self.holdingType = position.holdingType;
        self.costbasis = position.costbasis;
        self.lastPrice = position.lastPrice;
        self.quantity = position.quantity;
        self.todayGainLossDollar = position.todayGainLossDollar;
        self.todayGainLossPercentage = position.todayGainLossPercentage;
        self.totalGainLossDollar = position.totalGainLossDollar;
        self.totalGainLossPercentage = position.totalGainLossPercentage;
    }
    return self;
}


@end
