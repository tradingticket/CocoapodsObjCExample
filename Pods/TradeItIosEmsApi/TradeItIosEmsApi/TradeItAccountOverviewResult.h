//
//  TradeItAccountOverviewResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/3/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItResult.h"

@interface TradeItAccountOverviewResult : TradeItResult

// The total account value
@property (copy) NSNumber<Optional> * totalValue;

// Cash available to withdraw
@property (copy) NSNumber<Optional> * availableCash;

// The buying power of the account
@property (copy) NSNumber<Optional> * buyingPower;

// The daily return of the account
@property (copy) NSNumber<Optional> * dayAbsoluteReturn;

// The daily return percentage
@property (copy) NSNumber<Optional> * dayPercentReturn;

// The total absolute return on the account
@property (copy) NSNumber<Optional> * totalAbsoluteReturn;

// The total percentage return on the account
@property (copy) NSNumber<Optional> * totalPercentReturn;

// The base currency used in the account
@property (copy) NSString<Optional> * accountBaseCurrency;

@end
