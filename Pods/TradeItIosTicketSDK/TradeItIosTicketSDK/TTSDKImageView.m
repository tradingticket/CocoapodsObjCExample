//
//  TTSDKImageView.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKImageView.h"
#import "TradeItStyles.h"

@implementation TTSDKImageView


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
    
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.tintColor = styles.activeColor;
}


@end
