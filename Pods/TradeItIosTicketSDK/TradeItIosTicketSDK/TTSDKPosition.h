//
//  TTSDKPosition.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/14/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <TradeItIosEmsApi/TradeItPosition.h>
#import <TradeItIosEmsApi/TradeItResult.h>
#import <TradeItIosEmsApi/TradeItQuote.h>

@interface TTSDKPosition : TradeItPosition


@property NSNumber * change;
@property NSNumber * changePct;
@property NSString * companyName;
@property NSNumber * totalValue;
@property TradeItQuote * quote;

-(id) initWithPosition:(TradeItPosition *)position;


@end
