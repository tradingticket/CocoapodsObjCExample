//
//  TradeItQuotesRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItQuotesRequest : TradeItRequest

@property (copy) NSString * symbol;
@property (copy) NSString * symbols;
@property (copy) NSString * apiKey;
@property (copy) NSString * suffixMarket;

-(id) initWithSymbol:(NSString *) symbol;
-(id) initWithSymbols:(NSArray *) symbols;

-(id) initWithSymbol:(NSString *) symbol andMarketSuffix: (NSString *) suffix;

@end
