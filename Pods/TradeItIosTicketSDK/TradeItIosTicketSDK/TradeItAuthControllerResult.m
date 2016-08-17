//
//  TradeItAuthControllerResult.m
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 10/23/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import "TradeItAuthControllerResult.h"

@implementation TradeItAuthControllerResult

- (id)initWithResult:(TradeItResult *)result {
    self = [super init];
    if (self) {
        if ([result isKindOfClass:TradeItAuthenticationResult.class]) {
            self.success = true;
        } else if ([result isKindOfClass:TradeItErrorResult.class]) {
            TradeItErrorResult * errorResult = (TradeItErrorResult *)result;

            self.success = false;
            self.errorTitle = errorResult.shortMessage;

            NSMutableString * mutableStr = [[NSMutableString alloc] init];
            for (NSString *msg in errorResult.longMessages) {
                [mutableStr appendString:msg];
            }

            self.errorMessage = [mutableStr copy];
        }
    }

    return self;
}

@end
