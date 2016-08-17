//
//  TradeItPlaceTradeOrderInfoPrice.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/2/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@interface TradeItPlaceTradeOrderInfoPrice : TIEMSJSONModel<NSCopying>

// The type of the order, possible values are market, limit, stopMarket or stopLimit
@property (copy) NSString * type;

// Set limit price for limit, and stopLimit orders
@property (copy) NSNumber<Optional> * limitPrice;

// Set stop price for stopLimit and and stopMarket
@property (copy) NSNumber<Optional> * stopPrice;

// Quote from the broker, bid price
@property (copy) NSNumber<Optional> * bidPrice;

// Quote from the broker, ask price
@property (copy) NSNumber<Optional> * askPrice;

// Quote from the broker, last trade price
@property (copy) NSNumber<Optional> * lastPrice;

// Quote from the broker, timestamp is ET
@property (copy) NSString<Optional> * timestamp;

@end
