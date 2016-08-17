//
//  TTSDKAdService.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/9/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPublisherService.h"
#import <TradeItIosEmsApi/TradeItPublisherDataRequest.h>
#import <TradeItIosEmsApi/TradeItPublisherService.h>
#import "TTSDKTradeItTicket.h"
#import <TradeItIosEmsApi/TradeItEmsUtils.h>

@interface TTSDKPublisherService() {
    TTSDKTradeItTicket * globalTicket;
    NSMutableArray * imagesToLoad;
}

@property NSArray * data;
@property NSArray * brokerCenterLogoImages;

@end

@implementation TTSDKPublisherService


- (id)init {
    if (self = [super init]) {
        self.brokerCenterLogoImages = [[NSArray alloc] init];
        self.brokerCenterButtonViews = [[NSMutableArray alloc] init];

        globalTicket = [TTSDKTradeItTicket globalTicket];
        imagesToLoad = [[NSMutableArray alloc] init];
    }

    return self;
}

-(void) getPublisherData {
    self.isRetrievingPublisherData = YES;
    self.publisherDataLoaded = NO;

    TradeItPublisherService * publisherService = [[TradeItPublisherService alloc] initWithConnector:globalTicket.connector];
    TradeItPublisherDataRequest * publisherRequest = [[TradeItPublisherDataRequest alloc] init];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);

    dispatch_async(queue, ^{
        [publisherService getPublisherData:publisherRequest withCompletionBlock:^(TradeItResult *res) {
            self.publisherDataLoaded = YES;
            self.isRetrievingPublisherData = NO;

            if ([res isKindOfClass:TradeItErrorResult.class]) {
                self.brokerCenterActive = NO; // disable the broker center if we can't get the data
                globalTicket.brokerList = [globalTicket getDefaultBrokerList];
            } else {
                TradeItPublisherDataResult * result = (TradeItPublisherDataResult *)res;

                [self parsePublisherDataResultForBrokerList: result];
                [self parsePublisherDataResultForBrokerCenter: result];
            }
        }];
    });
}

-(void) parsePublisherDataResultForBrokerList:(TradeItPublisherDataResult *)result {
    NSMutableArray * brokers = [[NSMutableArray alloc] init];
    NSArray * brokerList = result.brokerList;

    for (NSDictionary * broker in brokerList) {
        NSArray * entry = @[broker[@"longName"], broker[@"shortName"]];
        [brokers addObject:entry];
    }

    globalTicket.brokerList = brokers;
}

-(void) parsePublisherDataResultForBrokerCenter:(TradeItPublisherDataResult *)result {
    self.brokerCenterActive = result.brokerCenterActive;
    self.brokerCenterBrokers = result.brokers;

    for (TradeItBrokerCenterBroker * broker in result.brokers) {
        NSMutableDictionary * logoItem = [broker.logo mutableCopy];
        logoItem[@"broker"] = [broker valueForKey:@"broker"];
        
        [imagesToLoad addObject:[logoItem copy]];
    }

    [self loadWebViews];
    [self dequeueImageDataAndLoad];
}

-(UIImage *) logoImageByBoker:(NSString *)broker {
    if (!self.brokerCenterLogoImages || !self.brokerCenterLogoImages.count) {
        return nil;
    }

    NSDictionary * selectedLogoItem;

    for (NSDictionary * logoItem in self.brokerCenterLogoImages) {
        if (logoItem && [[logoItem valueForKey:@"broker"] isEqualToString:broker]) {
            selectedLogoItem = logoItem;
        }
    }

    if (selectedLogoItem) {
        return [selectedLogoItem valueForKey:@"image"];
    } else {
        return nil;
    }
}

-(void) dequeueImageDataAndLoad {
    NSDictionary * logoItem = [imagesToLoad firstObject];
    [imagesToLoad removeObjectAtIndex:0];

    NSString * logoSrc = [logoItem valueForKey: @"src"];

    if ([logoSrc isEqualToString:@""]) {
        NSString *imageName = [NSString stringWithFormat:@"%@_logo.png", [logoItem valueForKey:@"broker"]];
        UIImage *img = [UIImage imageNamed:imageName
                                  inBundle:[[TTSDKTradeItTicket globalTicket] getBundle]
             compatibleWithTraitCollection:nil];

        NSMutableArray * mutableImages = [self.brokerCenterLogoImages mutableCopy];
        [mutableImages addObject:@{@"image": img, @"broker": [logoItem valueForKey:@"broker"]}];

        self.brokerCenterLogoImages = [mutableImages copy];

    } else {
        [self performSelectorInBackground:@selector(loadImageData:) withObject:logoItem];
    }

    if (imagesToLoad.count) {
        [self dequeueImageDataAndLoad];
    }
}

-(void) loadImageData:(NSDictionary *)logoItem {
    NSString * logoSrc = [logoItem valueForKey: @"src"];
    NSData * imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString:logoSrc]];

    NSDictionary * logoLoadItem = @{@"broker": [logoItem valueForKey:@"broker"], @"data": imageData};

    [self performSelectorOnMainThread:@selector(appendLoadedImageData:) withObject:logoLoadItem waitUntilDone:NO];
}

-(void) appendLoadedImageData:(NSDictionary *)logoLoadItem {
    NSData * imageData = [logoLoadItem valueForKey: @"data"];
    UIImage * img = [UIImage imageWithData: imageData];

    NSMutableArray * mutableImages = [self.brokerCenterLogoImages mutableCopy];
    [mutableImages addObject:@{@"image": img, @"broker": [logoLoadItem valueForKey:@"broker"]}];
    self.brokerCenterLogoImages = [mutableImages copy];
}

-(void) loadWebViews {
    for (TradeItBrokerCenterBroker *broker in self.brokerCenterBrokers) {
        UIWebView * buttonWebView = [[UIWebView alloc] initWithFrame:CGRectZero];

        NSString * urlStr = [NSString stringWithFormat:@"%@publisherad/brokerCenterPromptAdView?apiKey=%@-key&broker=%@", getEmsBaseUrl(globalTicket.connector.environment), globalTicket.connector.apiKey, broker.broker];
        [buttonWebView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:urlStr]]];
        [self.brokerCenterButtonViews addObject: @{@"broker": broker.broker, @"webView": buttonWebView}];
    }
}


@end
