//
//  TTSDKSmallLabel.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/12/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKSmallLabel.h"
#import "TradeItStyles.h"

@implementation TTSDKSmallLabel

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

    self.textColor = styles.smallTextColor;
    self.backgroundColor = [UIColor clearColor];
}

@end
