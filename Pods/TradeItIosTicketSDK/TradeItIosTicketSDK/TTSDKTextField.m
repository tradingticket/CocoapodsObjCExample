//
//  TTSDKTextField.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/8/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKTextField.h"
#import "TradeItStyles.h"

@interface TTSDKTextField() {
    TradeItStyles * styles;
}

@end

@implementation TTSDKTextField

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

    self.textColor = styles.primaryTextColor;

    self.tintColor = styles.primaryTextColor;

    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, self.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];

    self.leftView = leftView;

    self.leftViewMode = UITextFieldViewModeAlways;
}


@end
