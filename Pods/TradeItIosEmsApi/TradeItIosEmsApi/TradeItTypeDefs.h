//
//  TradeItTypeDefs.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/14/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#ifndef TradeItIosEmsApi_TradeItTypeDefs_h
#define TradeItIosEmsApi_TradeItTypeDefs_h

#import "TradeItResult.h"

/**
 Determine which server to send the request to.
 */
typedef enum {
    TradeItEmsProductionEnv,
    TradeItEmsTestEnv,
    TradeItEmsLocalEnv
} TradeitEmsEnvironments;

typedef void (^TradeItRequestCompletionBlock)(TradeItResult* result);

#endif
