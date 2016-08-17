//
//  TTSDKAccountSummaryResult.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountSummaryResult.h"

@implementation TTSDKAccountSummaryResult


-(id)init {
    if (self = [super init]) {
        self.positions = [NSArray array];
        self.balances = [NSArray array];
    }

    return self;
}


@end
