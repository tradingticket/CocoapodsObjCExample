//
//  TradeItTicketControllerResult.h
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 8/4/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TradeItIosEmsApi/TradeItErrorResult.h>
#import <TradeItIosEmsApi/TradeItPreviewTradeResult.h>
#import <TradeItIosEmsApi/TradeItPlaceTradeResult.h>

@interface TradeItTicketControllerResult : NSObject


/**
 *  NO_BROKER is triggered if the user doesn't setup an initial broker
 *  AUTHENTICATION_ERROR triggered if, post initial setup, user fails security questions, errorResponse will be set
 *  AUTHENTICATION_SUCCESS triggered when user completes authentication in TradeItPresentationModeAuth
 *  USER_CANCELED user leaves the ticket before sending an order, if they canceled from the review screen reviewResponse will be set
 *  USER_CANCELED_SECURITY triggered if user cancels rather than answer security question
 *  EXECUTION_ERROR user attempted to send order, it failed, errorResponse will be set
 *  SUCCESS user successfully placed order, reviewResponse and successReponse will be set
 */
enum controllerStatus {
    NO_BROKER,
    AUTHENTICATION_ERROR,
    AUTHENTICATION_SUCCESS,
    USER_CANCELED,
    USER_CANCELED_SECURITY,
    EXECUTION_ERROR,
    SUCCESS
};

/**
 *  Status of the ticket when the user exits, see enum for more information
 */
@property enum controllerStatus status;

/**
 *  Will be set with error information, if AUTHENTICATION_ERROR or EXECUTION_ERROR
 */
@property TradeItErrorResult * errorResponse;

/**
 *  Will be set when review screen loads, will be set for some USER_CANCELED and all SUCCESS
 */
@property TradeItPreviewTradeResult * reviewResponse;

/**
 *  Will be set when the success screen loads
 */
@property TradeItPlaceTradeResult * tradeResponse;


- (id)initNoBrokerStatus;


@end
