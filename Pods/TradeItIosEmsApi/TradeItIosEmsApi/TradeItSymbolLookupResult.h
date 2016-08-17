//
//  TradeItSymbolLookupResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItResult.h"
#import "TradeItSymbolLookupCompany.h"

@interface TradeItSymbolLookupResult : TradeItResult

// The query you passed in
@property (copy) NSString<Optional> * query;

// List of matches
@property (copy) NSArray<Optional, TradeItSymbolLookupCompany> * results;

@end
