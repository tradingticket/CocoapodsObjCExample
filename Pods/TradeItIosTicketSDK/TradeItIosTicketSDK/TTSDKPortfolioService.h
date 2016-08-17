//
//  TTSDKPortfolioService.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSDKAccountSummaryResult.h"
#import "TTSDKPortfolioAccount.h"

@interface TTSDKPortfolioService : NSObject


@property NSArray * accounts;
@property TTSDKPortfolioAccount * selectedAccount;

+(id) serviceForAllAccounts;
+(id) serviceForLinkedAccounts;
+(NSArray *)allAccounts;
+(NSArray *)linkedAccounts;

-(id) initWithAccounts:(NSArray *)accounts;
-(TTSDKPortfolioAccount *) accountByAccountNumber:(NSString *)accountNumber;
-(void) getSummaryForAccounts:(void (^)(void)) completionBlock;
-(void) getSummaryForSelectedAccount:(void (^)(void)) completionBlock;
-(void) getSummaryForAccount:(TTSDKPortfolioAccount *) account withCompletionBlock:(void (^)(void)) completionBlock;
-(void) getBalancesForAccounts:(void (^)(void)) completionBlock;
-(void) getQuotesForAccounts:(void (^)(void)) completionBlock;
-(void) getQuoteForPosition:(TTSDKPosition *)position withCompletionBlock:(void (^)(TradeItResult *)) completionBlock;
-(NSArray *) positionsForAccounts;
-(NSArray *) filterPositionsByAccount:(TTSDKPortfolioAccount *)portfolioAccount;
-(TTSDKPortfolioAccount *) retrieveAutoSelectedAccount;
-(void) selectAccount:(NSString *)accountNumber;
-(void) toggleAccount:(TTSDKPortfolioAccount *)account;
-(void) deleteAccounts:(NSString *)userId session:(TTSDKTicketSession *)session;
-(void) deleteAccount:(TTSDKPortfolioAccount *)account;
-(int) linkedAccountsCount;

@end
