//
//  TradeItPosition.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/3/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@protocol TradeItPosition
@end

@interface TradeItPosition : TIEMSJSONModel<NSCopying>

// Symbol - normally the street symbol, w/ bonds it's a cusip
@property (copy) NSString<Optional> * symbol;

// String, the type of security: EQUITY_OR_ETF, MUTUAL_FUND, OPTION, FIXED_INCOME, CASH, UNKOWN
@property (copy) NSString<Optional> * symbolClass;

// String, "LONG" or "SHORT"
@property (copy) NSString<Optional> * holdingType;

// Double, the total base cost of the security
@property (copy) NSNumber<Optional> * costbasis;

// Double, the last traded price of the security
@property (copy) NSNumber<Optional> * lastPrice;

// Double, the total quantity held. It's a double to support cash and Mutual Funds
@property (copy) NSNumber<Optional> * quantity;

// Double, the total gain/loss in dollars for the day for the position
@property (copy) NSNumber<Optional> * todayGainLossDollar;

// Double, the percentage gain/loss for the day for the position
@property (copy) NSNumber<Optional> * todayGainLossPercentage;

// Double, the total gain/loss in dollars for the position
@property (copy) NSNumber<Optional> * totalGainLossDollar;

// Double, the total percentage of gain/loss for the position
@property (copy) NSNumber<Optional> * totalGainLossPercentage;


@end
