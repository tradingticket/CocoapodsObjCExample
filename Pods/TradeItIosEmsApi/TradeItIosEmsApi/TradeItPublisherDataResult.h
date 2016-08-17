//
//  TradeItPublisherDataResult.h
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 5/17/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItBrokerCenterBroker.h"
#import "TradeItBrokerListResult.h"

@interface TradeItPublisherDataResult : TradeItResult

@property BOOL brokerCenterActive;
@property NSArray<TradeItBrokerCenterBroker, Optional> * brokers;
@property (copy) NSArray* brokerList;
@property NSString <Optional>* preferredBroker;

@end
