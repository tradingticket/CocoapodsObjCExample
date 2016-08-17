//
//  TradeItResult.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/23/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"


/**
 *  Base Execution Management System(EMS) server result class. All Results sent by the server extend this class
 */
@interface TradeItResult : TIEMSJSONModel

/**
 *  Contains the status of the result which helps identify the type of result sent back. Possible values are
 *  SUCCESS, ERROR,IN_PROGRESS,INFORMATION_NEEDED,MULTIPLE_ACCOUNTS,REVIEW_ORDER
 */
@property (copy) NSString* status;

/**
 *  Thes Session token that is used to identify the session when sending security answer, selectin and account or placing an order
 */
@property (copy) NSString<Optional> * token;

/**
 *
 *  Should be displayed if an error is returned. Usually contains a description of the error
 *  For other type of results this field usually contains a more user friendly description of the status such.
 */
@property (copy) NSString<Optional> * shortMessage;

/**
 *  Should be displayed if an error is returned. Usually provides more information about the error
 *  For other type of results this field is nil
 */
@property (copy) NSArray<Optional> * longMessages;


@end
