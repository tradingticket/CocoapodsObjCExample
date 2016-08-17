//
//  TradeItSuccessAuthenticationResult.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/14/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItResult.h"

@interface TradeItAuthenticationResult : TradeItResult

/**
 *  An array of NSDictionary objects, where each object has a "name" and "accountNumber" property corresponding to the account.
 *  The name should be displayed to the user. The whole object for the account should be sent back to the server when calling
 *  the selectAccount method of the TradeItStockOrEtfTradeSession
 */
@property (copy) NSArray<Optional> * accounts;

@end
