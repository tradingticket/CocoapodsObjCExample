//
//  TTSDKAccount.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/21/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TradeItIosEmsApi/TradeItAccountOverviewResult.h>
#import "TTSDKTradeItTicket.h"

@interface TTSDKPortfolioAccount : NSObject


@property NSString * userId;
@property NSString * accountNumber;
@property NSString * displayTitle;
@property NSString * name;
@property NSString * broker;
@property BOOL active;
@property BOOL tradable;
@property NSArray * positions;
@property TradeItAccountOverviewResult * balance;
@property NSString * locale;

@property TTSDKTicketSession * session;

// bools, for data retrieval
@property BOOL balanceComplete;
@property BOOL positionsComplete;
@property BOOL needsAuthentication;

-(id) initWithAccountData:(NSDictionary *)data;
-(void) retrieveAccountSummary;
-(void) retrieveAccountSummaryWithCompletionBlock:(void (^)(void)) completionBlock;
-(void) retrieveBalance;
-(NSDictionary *) accountData;
-(BOOL) dataComplete;


@end
