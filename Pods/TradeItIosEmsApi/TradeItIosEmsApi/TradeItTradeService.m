//
//  TradeItTradeService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/15/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItTradeService.h"
#import "TradeItEmsUtils.h"
#import "TradeItPreviewTradeResult.h"
#import "TradeItPlaceTradeResult.h"

@implementation TradeItTradeService

-(id) initWithSession:(TradeItSession *) session {
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

- (void) previewTrade:(TradeItPreviewTradeRequest *) order withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    order.token = self.session.token;
    
    NSMutableURLRequest * request = buildJsonRequest(order, @"order/previewStockOrEtfOrder", self.session.connector.environment);

    [self.session.connector sendEMSRequest:request withCompletionBlock:^(TradeItResult * result, NSMutableString * jsonResponse) {
        TradeItResult * resultToReturn = result;
        
        if ([result.status isEqual:@"REVIEW_ORDER"]){
            resultToReturn = buildResult([TradeItPreviewTradeResult alloc], jsonResponse);
        }

        completionBlock(resultToReturn);
    }];
}

- (void) placeTrade:(TradeItPlaceTradeRequest *) order withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    order.token = self.session.token;
    
    NSMutableURLRequest * request = buildJsonRequest(order, @"order/placeStockOrEtfOrder", self.session.connector.environment);
    
    [self.session.connector sendEMSRequest:request withCompletionBlock:^(TradeItResult * result, NSMutableString * jsonResponse) {
        TradeItResult * resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]){
            resultToReturn = buildResult([TradeItPlaceTradeResult alloc], jsonResponse);
        }
        
        completionBlock(resultToReturn);
    }];
}

@end
