//
//  TTSDKBrokerSelectFooterView.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/2/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKBrokerSelectFooterView.h"
#import "TradeItStyles.h"

@implementation TTSDKBrokerSelectFooterView

-(void) awakeFromNib {
    TradeItStyles * styles = [TradeItStyles sharedStyles];

    self.backgroundColor = styles.pageBackgroundColor;

    [self.terms setTintColor: styles.activeColor];
    [self.privacy setTintColor: styles.activeColor];
    [self.help setTintColor: styles.activeColor];
}

@end
