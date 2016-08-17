//
//  TTSDKAccountLinkTableViewCell.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/13/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountLinkTableViewCell.h"
#import "TTSDKUtils.h"
#import "TTSDKTradeItTicket.h"
#import "TradeItStyles.h"


@interface TTSDKAccountLinkTableViewCell() {
    TTSDKUtils * utils;
    TTSDKPortfolioAccount * account;
    TTSDKTradeItTicket * globalTicket;
}

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * buyingPowerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * accountTypeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView * circleGraphic;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *buyingPowerLoadingIndicator;

@end

@implementation TTSDKAccountLinkTableViewCell


#pragma mark Initialization

-(void) awakeFromNib {
    utils = [TTSDKUtils sharedUtils];
    globalTicket = [TTSDKTradeItTicket globalTicket];

    self.buyingPowerLoadingIndicator.transform = CGAffineTransformMakeScale(0.65, 0.65);
    self.buyingPowerLoadingIndicator.hidden = YES;
    [self.buyingPowerLoadingIndicator startAnimating];

    [self setViewStyles];
}

-(void) setViewStyles {
    TradeItStyles * styles = [TradeItStyles sharedStyles];

    self.backgroundColor = [UIColor clearColor];
    [self.toggle setOnTintColor: styles.switchColor];
    self.separator.backgroundColor = styles.primarySeparatorColor;
}


#pragma mark Configuration

-(void) configureCellWithAccount:(TTSDKPortfolioAccount *)portfolioAccount {
    account = portfolioAccount;

    self.accountName = account.accountNumber;
    self.accountNameLabel.text = self.accountName;

    if (account.balanceComplete) {
        self.buyingPowerLabel.text = account.balance.buyingPower != nil ? [utils formatPriceString:account.balance.buyingPower withLocaleId:account.balance.accountBaseCurrency] : @"N/A";
        self.buyingPowerLoadingIndicator.hidden = YES;
        [self.buyingPowerLoadingIndicator stopAnimating];
    } else {
        self.buyingPowerLabel.text = @"";
        self.buyingPowerLoadingIndicator.hidden = NO;
        [self.buyingPowerLoadingIndicator startAnimating];
    }

    self.toggle.on = account.active;

    NSString * broker = account.broker ?: @"N/A";

    self.accountTypeLabel.text = broker;
    UIColor * brokerColor = [utils retrieveBrokerColorByBrokerName:broker];
    CAShapeLayer * circleLayer = [utils retrieveCircleGraphicWithSize:(self.circleGraphic.frame.size.width - 1) andColor:brokerColor];
    self.circleGraphic.backgroundColor = [UIColor clearColor];
    [self.circleGraphic.layer addSublayer:circleLayer];
}

-(void) setBalanceNil {
    self.buyingPowerLabel.text = @"";
    self.buyingPowerLoadingIndicator.hidden = YES;
    [self.buyingPowerLoadingIndicator stopAnimating];
}


#pragma mark Custom Recognizers

-(IBAction) togglePressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(linkToggleDidSelect:forAccount:)]) {
        [self.delegate linkToggleDidSelect:self.toggle forAccount:account];
    }
}

-(void) callLinkToggleDidNotSelect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(linkToggleDidNotSelect:)]) {
        [self.delegate linkToggleDidNotSelect: @""];
    }
}


@end
