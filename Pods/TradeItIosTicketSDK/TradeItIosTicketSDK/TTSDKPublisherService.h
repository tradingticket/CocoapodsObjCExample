//
//  TTSDKAdService.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/9/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTSDKPublisherService : NSObject

@property BOOL isRetrievingPublisherData;
@property BOOL publisherDataLoaded;
@property BOOL brokerCenterActive;
@property NSArray * brokerCenterBrokers;
@property NSMutableArray * brokerCenterButtonViews;

-(void) getPublisherData;
-(UIImage *) logoImageByBoker:(NSString *)broker;

@end
