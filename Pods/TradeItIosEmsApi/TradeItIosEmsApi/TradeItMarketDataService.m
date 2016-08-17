//
//  TradeItMarketDataService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItMarketDataService.h"
#import "TradeItEmsUtils.h"
#import "TradeItQuotesResult.h"
#import "TradeItSymbolLookupResult.h"

@implementation TradeItMarketDataService

-(id) initWithSession:(TradeItSession *) session {
    self = [super init];
    if(self) {
        self.session = session;
    }
    return self;
}

- (void) getQuoteData:(TradeItQuotesRequest *) request withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    request.apiKey = self.session.connector.apiKey;
    
    NSString * endpoint;
    if (request.suffixMarket) {
        endpoint = @"marketdata/getYahooQuotes";
    } else if (request.symbol) {
        endpoint = @"marketdata/getQuote";
    } else if (request.symbols) {
        endpoint = @"marketdata/getQuotes";
    } else {
        completionBlock(nil);
        return;
    }

    NSMutableURLRequest * quoteRequest = buildJsonRequest(request, endpoint, self.session.connector.environment);
    
    [self.session.connector sendEMSRequest:quoteRequest withCompletionBlock:^(TradeItResult * result, NSMutableString * jsonResponse) {
        TradeItResult * resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]){
            resultToReturn = buildResult([TradeItQuotesResult alloc], jsonResponse);
        }
        
        completionBlock(resultToReturn);
    }];
}

-(void) symbolLookup:(TradeItSymbolLookupRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    NSMutableURLRequest * symbolLookupRequest = buildJsonRequest(request, @"marketdata/symbolLookup", self.session.connector.environment);
    
    [self.session.connector sendEMSRequest:symbolLookupRequest withCompletionBlock:^(TradeItResult * result, NSMutableString * jsonResponse) {
        TradeItResult * resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]){
            resultToReturn = buildResult([TradeItSymbolLookupResult alloc], jsonResponse);
        }
        
        completionBlock(resultToReturn);
    }];
}

@end
