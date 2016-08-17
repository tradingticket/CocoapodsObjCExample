//
//  TradeItEmsUtils.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/14/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#ifndef TradeItIosEmsApi_TradeItEmsUtils_h
#define TradeItIosEmsApi_TradeItEmsUtils_h

#import "TradeItTypeDefs.h"
#import "TradeItResult.h"

NSURL* getEmsBaseUrl(TradeitEmsEnvironments env);
NSMutableURLRequest * buildJsonRequest(TIEMSJSONModel* requestObject, NSString*emsMethod, TradeitEmsEnvironments env);
TradeItResult* buildResult (TradeItResult* tradeItResult, NSString* jsonString) ;
    
#endif
