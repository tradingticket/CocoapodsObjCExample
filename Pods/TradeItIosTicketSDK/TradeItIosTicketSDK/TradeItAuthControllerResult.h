//
//  TradeItAuthControllerResult.h
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 10/23/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TradeItIosEmsApi/TradeItAuthenticationResult.h>
#import <TradeItIosEmsApi/TradeItErrorResult.h>

@interface TradeItAuthControllerResult : NSObject

@property BOOL success;
@property NSString * errorTitle;
@property NSString * errorMessage;

- (id)initWithResult:(TradeItResult *)result;

@end
