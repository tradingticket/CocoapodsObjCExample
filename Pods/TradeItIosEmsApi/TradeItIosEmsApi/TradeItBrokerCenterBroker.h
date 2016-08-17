//
//  TradeItBrokerCenterBroker.h
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 5/10/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@protocol TradeItBrokerCenterBroker
@end

@interface TradeItBrokerCenterBroker : TIEMSJSONModel<NSCopying>

@property (copy) NSString<Optional>* broker;
@property (copy) NSNumber<Optional>* active;
@property (copy) NSString<Optional>* signupTitle;
@property (copy) NSString<Optional>* signupDescription;
@property (copy) NSString<Optional>* signupPostfix;
@property (copy) NSString<Optional>* accountMinimum;
@property (copy) NSString<Optional>* optionsOffer;
@property (copy) NSString<Optional>* optionsPostfix;
@property (copy) NSString<Optional>* stocksEtfsOffer;
@property (copy) NSString<Optional>* stocksEtfsPostfix;
@property (copy) NSString<Optional>* prompt;
@property (copy) NSString<Optional>* promptUrl;
@property (copy) NSArray<Optional>* backgroundColor;
@property (copy) NSArray<Optional>* textColor;
@property (copy) NSArray<Optional>* promptBackgroundColor;
@property (copy) NSArray<Optional>* promptTextColor;
@property (copy) NSDictionary<Optional>* logo;
@property (copy) NSArray<Optional>* disclaimers;
@property (copy) NSArray<Optional>* features;

@end
