//
//  TradeItIosTicketSDK.h
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 7/9/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TradeItTicketController.h"
#import "TradeItTicketControllerResult.h"
#import "TradeItAuthControllerResult.h"
#import <TradeItIosEmsApi/TradeItAuthenticationInfo.h>
#import <TradeItIosEmsApi/TradeItErrorResult.h>
#import <TradeItIosEmsApi/TradeItRequest.h>
#import <TradeItIosEmsApi/TradeItSecurityQuestionRequest.h>
#import <TradeItIosEmsApi/TradeItSecurityQuestionResult.h>
#import <TradeItIosEmsApi/TIEMSJSONModel.h>
#import <TradeItIosEmsApi/TIEMSJSONAPI.h>
#import <TradeItIosEmsApi/TIEMSJSONHTTPClient.h>
#import <TradeItIosEmsApi/TIEMSJSONKeyMapper.h>
#import <TradeItIosEmsApi/TIEMSJSONModel+networking.h>
#import <TradeItIosEmsApi/TIEMSJSONModelArray.h>
#import <TradeItIosEmsApi/TIEMSJSONModelClassProperty.h>
#import <TradeItIosEmsApi/TIEMSJSONModelError.h>
#import <TradeItIosEmsApi/TIEMSJSONModelLib.h>
#import <TradeItIosEmsApi/TIEMSJSONValueTransformer.h>
#import <TradeItIosEmsApi/NSArray+TIEMSJSONModel.h>


// Imports to use the underlying TradeItIosEmsLib


// Generic classes for the request/results sent the to EMS server
#import <TradeItIosEmsApi/TradeItRequest.h>
#import <TradeItIosEmsApi/TradeItResult.h>
#import <TradeItIosEmsApi/TradeItErrorResult.h>

// Start with the connector, you'll set your API key and the environment
// Then link a user to their brokerage(s) account(s)
#import <TradeItIosEmsApi/TradeItConnector.h>
#import <TradeItIosEmsApi/TradeItLinkedLogin.h>
#import <TradeItIosEmsApi/TradeItAuthenticationInfo.h>
#import <TradeItIosEmsApi/TradeItAuthenticationRequest.h>
#import <TradeItIosEmsApi/TradeItAuthenticationResult.h>
#import <TradeItIosEmsApi/TradeItAuthLinkRequest.h>
#import <TradeItIosEmsApi/TradeItAuthLinkResult.h>

// Once you have a link you'll establish a session using the linkedLogin
#import <TradeItIosEmsApi/TradeItSession.h>
#import <TradeItIosEmsApi/TradeItSecurityQuestionRequest.h>
#import <TradeItIosEmsApi/TradeItSecurityQuestionResult.h>

// Use the PublisherService to retrieve ad sources
#import <TradeItIosEmsApi/TradeItAdsRequest.h>
#import <TradeItIosEmsApi/TradeitAdsResult.h>

// Use the TradeService to preview and place trades
#import <TradeItIosEmsApi/TradeItTradeService.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeRequest.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeOrderDetails.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeResult.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeRequest.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeResult.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeOrderInfo.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeOrderInfoPrice.h>

// Use the BalanceService to get account balance information
#import <TradeItIosEmsApi/TradeItBalanceService.h>
#import <TradeItIosEmsApi/TradeItAccountOverviewRequest.h>
#import <TradeItIosEmsApi/TradeItAccountOverviewResult.h>

// Use the PositionSerview to get account position information
#import <TradeItIosEmsApi/TradeItPositionService.h>
#import <TradeItIosEmsApi/TradeItGetPositionsRequest.h>
#import <TradeItIosEmsApi/TradeItGetPositionsResult.h>
#import <TradeItIosEmsApi/TradeItPosition.h>

// Use the PublisherService to get publisher specific configurations/data
#import <TradeItIosEmsApi/TradeItPublisherService.h>
#import <TradeItIosEmsApi/TradeItAdsRequest.h>
#import <TradeItIosEmsApi/TradeItAdsResult.h>

// EMS API Util classes
#import <TradeItIosEmsApi/TradeItTypeDefs.h>

@interface TradeItIosTicketSDK : NSObject

@end
