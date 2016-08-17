//
//  TTSDKSeparator.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 6/1/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKSeparator.h"
#import "TradeItStyles.h"

@implementation TTSDKSeparator

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void) commonInit {
    TradeItStyles * styles = [TradeItStyles sharedStyles];

    self.backgroundColor = styles.primarySeparatorColor;
}

@end
