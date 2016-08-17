//
//  TTSDKTicketController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/3/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TradeItTicketControllerResult.h"
#import <TradeItIosEmsApi/TradeItResult.h>
#import <TradeItIosEmsApi/TradeItConnector.h>
#import <TradeItIosEmsApi/TradeItAuthenticationInfo.h>
#import "TradeItAuthControllerResult.h"
#import <TradeItIosEmsApi/TradeItLinkedLogin.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeOrderDetails.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeRequest.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeResult.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeRequest.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeResult.h>
#import <TradeItIosEmsApi/TradeItPosition.h>
#import <TradeItIosEmsApi/TradeItAccountOverviewResult.h>
#import <TradeItIosEmsApi/TradeItGetPositionsResult.h>
#import "TTSDKTicketSession.h"
#import "TTSDKPosition.h"
#import "TTSDKPublisherService.h"


@interface TTSDKTradeItTicket : NSObject

@property BOOL brokerSignUpComplete;
@property BOOL debugMode;
@property BOOL clearPortfolioCache;
@property BOOL loadingQuote;
@property NSDate * lastUsed;
@property UIViewController * parentView;
@property NSString * errorTitle;
@property NSString * errorMessage;
@property NSString * initialHighlightedAccountNumber; // override for initial account to highlight in portfolio view
@property (nonatomic) NSArray * brokerList;
@property NSArray * sessions;
@property (nonatomic) NSDictionary * currentAccount;
@property (nonatomic) TTSDKTicketSession * currentSession;
@property TradeItConnector * connector;
@property TradeItPresentationMode presentationMode;
@property TradeItQuote * quote;
@property TradeItPreviewTradeRequest * previewRequest;
@property TradeItAuthControllerResult * authResultContainer;
@property TradeItTicketControllerResult * resultContainer;
@property TTSDKPublisherService * publisherService;
@property (copy) void (^callback)(TradeItTicketControllerResult * result);
@property (copy) void (^brokerSignUpCallback)(TradeItAuthControllerResult * result);


#pragma mark Initialization
+(id) globalTicket;
-(void) launchAccountsFlow;
-(void) launchAuthFlow;
-(void) launchTradeFlow;
-(void) launchPortfolioFlow;
-(void) launchTradeOrPortfolioFlow;
-(void) launchBrokerCenterFlow:(void (^)(BOOL))completionBlock;
-(void) retrievePublisherData:(void (^)(BOOL))completionBlock;

#pragma mark Quote
-(void) retrieveQuote:(void (^)(void))completionBlock;

#pragma mark Authentication
-(void) removeBrokerSelectFromNav:(UINavigationController *)nav cancelToParent:(BOOL)cancelToParent;
-(BOOL) checkIsAuthenticationDuplicate:(NSArray *)accounts;

#pragma mark Sessions
-(void) createSessions: (void (^)(NSString * userId, TTSDKTicketSession * session)) onInitialAccount;
-(void) addSession:(TTSDKTicketSession *)session;
-(void) removeSession:(TTSDKTicketSession *)session;
-(void) selectCurrentSession:(TTSDKTicketSession *)session andAccount:(NSDictionary *)account;
-(void) selectCurrentSession:(TTSDKTicketSession *)session;
-(TTSDKTicketSession *)retrieveSessionByAccount:(NSDictionary *)account;

#pragma mark Accounts
-(BOOL) isAccountCurrentAccount:(NSDictionary *)account;
-(void) configureAccountLinkNavController:(UINavigationController *)nav;
-(void) selectCurrentAccount:(NSDictionary *)account;
-(void) selectCurrentAccountByAccountNumber:(NSString *)accountNumber;
-(void) addAccounts:(NSArray *)accounts withSession:(TTSDKTicketSession *)session;
-(void) replaceAccountsWithNewAccounts:(NSArray *)accounts;
-(void) saveAccountsToUserDefaults:(NSArray *)accounts;
-(void) unlinkAccounts;

#pragma mark Broker
-(NSArray *) getDefaultBrokerList;
-(NSString *) getBrokerDisplayString:(NSString *) value;
-(NSString *) getBrokerValueString:(NSString *) displayString;
-(NSArray *) getBrokerByValueString:(NSString *) valueString;

#pragma mark Navigation
-(void)returnToParentApp;

#pragma mark Resources
- (UIStoryboard *)getTicketStoryboard;
- (NSBundle *)getBundle;

@end
