//
//  TTSDKTicketSession.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/11/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <TradeItIosTicketSDK/TradeItIosTicketSDK.h>
#import <TradeItIosEmsApi/TradeItSession.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeRequest.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeRequest.h>
#import <TradeItIosEmsApi/TradeItGetPositionsRequest.h>
#import <TradeItIosEmsApi/TradeItTradeService.h>
#import <TradeItIosEmsApi/TradeItPositionService.h>
#import <TradeItIosEmsApi/TradeItBalanceService.h>
#import <TradeItIosEmsApi/TradeItAccountOverviewResult.h>

@interface TTSDKTicketSession : TradeItSession <UIPickerViewDataSource, UIPickerViewDelegate>

@property NSArray * positions;
@property TradeItLinkedLogin * login;
@property NSString * broker;
@property BOOL isAuthenticated;
@property BOOL needsAuthentication; // needs to be authenticated
@property BOOL needsManualAuthentication; // needs the user to re-link
@property BOOL authenticating;

@property TradeItPlaceTradeRequest * tradeRequest;
@property TradeItGetPositionsRequest * positionsRequest;

- (id)initWithConnector:(TradeItConnector *)connector
         andLinkedLogin:(TradeItLinkedLogin *)linkedLogin
              andBroker:(NSString *)broker;

- (void)authenticateFromViewController:(UIViewController *)viewController
                   withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

- (void)previewTrade:(TradeItPreviewTradeRequest *)previewRequest
  withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

- (void)placeTrade:(void (^)(TradeItResult *))completionBlock;

- (void)getPositionsFromAccount:(NSDictionary *)account
            withCompletionBlock:(void (^)(NSArray *))completionBlock;

- (void)getOverviewFromAccount:(NSDictionary *)account
           withCompletionBlock:(void (^)(TradeItAccountOverviewResult *)) completionBlock;

@end
