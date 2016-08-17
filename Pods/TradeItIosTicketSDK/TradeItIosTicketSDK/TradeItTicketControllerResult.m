//
//  TradeItTicketControllerResult.m
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 8/4/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TradeItTicketControllerResult.h"

@implementation TradeItTicketControllerResult


- (id)initNoBrokerStatus {
    self = [super init];
    if (self) {
        self.status = NO_BROKER;
    }

    return self;
}


@end
