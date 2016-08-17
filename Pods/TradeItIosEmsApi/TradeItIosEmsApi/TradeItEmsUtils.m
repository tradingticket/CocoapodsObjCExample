//
//  TradeItEmsUtils.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/14/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItEmsUtils.h"
#import "TradeItErrorResult.h"

NSURL* getEmsBaseUrl(TradeitEmsEnvironments env){
    switch (env) {
        case TradeItEmsProductionEnv:
            return [NSURL URLWithString:@"https://ems.tradingticket.com/api/v1/"];
        case TradeItEmsTestEnv:
            return [NSURL URLWithString:@"https://ems.qa.tradingticket.com/api/v1/"];
        case TradeItEmsLocalEnv:
            return [NSURL URLWithString:@"http://localhost:8080/api/v1/"];
        default:
            NSLog(@"Invalid environment %d - directing to production by default", env);
            return [NSURL URLWithString:@"https://ems.tradingticket.com/api/v1/"];
    }
}


NSMutableURLRequest * buildJsonRequest(TIEMSJSONModel* requestObject, NSString*emsMethod, TradeitEmsEnvironments env){
    NSData *requestData = [[requestObject toJSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"requestdata is %@", requestData);
    NSURL * url = [NSURL URLWithString:emsMethod relativeToURL:getEmsBaseUrl(env)];
    
    //NSLog(@"ems url is %@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    return request;
    
}

TradeItResult* buildResult (TradeItResult* tradeItResult, NSString* jsonString){
    
    TIEMSJSONModelError* jsonModelError = nil;
    TradeItResult * resultFromJson = [tradeItResult initWithString:jsonString error:&jsonModelError];
    
    if(jsonModelError!=nil)
    {
        NSLog(@"Received invalid json from ems server error=%@ response=%@", jsonModelError, jsonString);
        return [TradeItErrorResult tradeErrorWithSystemMessage:@"error parsing json response"];
    }
    
    return resultFromJson;
}



