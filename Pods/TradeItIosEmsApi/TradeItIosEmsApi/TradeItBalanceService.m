//
//  TradeItBalanceService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/20/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItBalanceService.h"
#import "TradeItEmsUtils.h"
#import "TradeItAccountOverviewResult.h"

@implementation TradeItBalanceService

-(id) initWithSession:(TradeItSession *) session {
    self = [super init];
    if(self) {
        self.session = session;
    }
    return self;
}

- (void) getAccountOverview:(TradeItAccountOverviewRequest *) request withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    request.token = self.session.token;

    NSMutableURLRequest * balanceRequest = buildJsonRequest(request, @"balance/getAccountOverview", self.session.connector.environment);

    [self.session.connector sendEMSRequest:balanceRequest withCompletionBlock:^(TradeItResult * result, NSMutableString * jsonResponse) {
        TradeItResult * resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]){
            resultToReturn = buildResult([TradeItAccountOverviewResult alloc], jsonResponse);
        }
        
        completionBlock(resultToReturn);
    }];
}

@end
