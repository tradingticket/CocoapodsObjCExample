//
//  TTSKAccountsHeaderView.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/21/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountsHeaderView.h"
#import "TTSDKUtils.h"
#import "TradeItStyles.h"

@interface TTSDKAccountsHeaderView() {
    TTSDKUtils * utils;
    TradeItStyles * styles;
}

@property (weak, nonatomic) IBOutlet UILabel *totalPortfolioValueLabel;
@property (weak, nonatomic) IBOutlet UIView *header;

@end

@implementation TTSDKAccountsHeaderView


-(void) awakeFromNib {
    utils = [TTSDKUtils sharedUtils];
    styles = [TradeItStyles sharedStyles];

    self.backgroundColor = styles.pageBackgroundColor;

    if (styles.navigationBarBackgroundColor) {
        self.header.backgroundColor = styles.navigationBarBackgroundColor;
    }

    [self.editAccountsButton setTitleColor:styles.activeColor forState:UIControlStateNormal];
}

-(void) populateTotalPortfolioValue:(NSString *)value {
    self.totalPortfolioValueLabel.text = value;
}


@end
