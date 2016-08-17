//
//  TTSDKPrimaryButton.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/8/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPrimaryButton.h"
#import "TradeItStyles.h"

@interface TTSDKPrimaryButton() {
    TradeItStyles * styles;
    UIActivityIndicatorView * currentIndicator;
}

@end

@implementation TTSDKPrimaryButton

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
    styles = [TradeItStyles sharedStyles];
    [self deactivate];
}

-(void) activate {
    self.backgroundColor = styles.primaryActiveButton.backgroundColor;

    self.layer.borderColor = styles.primaryActiveButton.layer.borderColor;
    self.layer.borderWidth = styles.primaryActiveButton.layer.borderWidth;
    self.layer.cornerRadius = styles.primaryActiveButton.layer.cornerRadius;
    
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = styles.primaryActiveButton.layer.shadowColor;
    self.layer.shadowOpacity = styles.primaryActiveButton.layer.shadowOpacity;
    self.layer.shadowRadius = styles.primaryActiveButton.layer.shadowRadius;
    self.layer.shadowOffset = styles.primaryActiveButton.layer.shadowOffset;

    [self setTitleColor:[styles.primaryActiveButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
}

-(void) deactivate {
    self.backgroundColor = styles.primaryInactiveButton.backgroundColor;
    self.layer.borderColor = styles.primaryInactiveButton.layer.borderColor;
    self.layer.borderWidth = styles.primaryInactiveButton.layer.borderWidth;
    self.layer.cornerRadius = styles.primaryInactiveButton.layer.cornerRadius;
    self.layer.shadowColor = styles.primaryInactiveButton.layer.shadowColor;
    self.layer.shadowOpacity = styles.primaryInactiveButton.layer.shadowOpacity;
    [self setTitleColor:[styles.primaryInactiveButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
}

-(void) enterLoadingState {
    if (currentIndicator) {
        [currentIndicator removeFromSuperview];
    } else {
        currentIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }

    currentIndicator.hidden = NO;

    [self addSubview:currentIndicator];

    currentIndicator.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 10.0, self.titleLabel.frame.origin.y, 20.0, 20.0);
    [currentIndicator bringSubviewToFront: self];

    self.userInteractionEnabled = NO;

    [currentIndicator startAnimating];
}

-(void) exitLoadingState {
    if (currentIndicator) {
        [currentIndicator removeFromSuperview];
    }

    self.userInteractionEnabled = YES;
}

@end
