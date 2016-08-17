//
//  TTSDKModalAlertView.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/17/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKModalAlertView.h"

@implementation TTSDKModalAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) awakeFromNib {
    NSLog(@"awaking from nib");

    self.backgroundColor = [UIColor redColor];
}

@end
