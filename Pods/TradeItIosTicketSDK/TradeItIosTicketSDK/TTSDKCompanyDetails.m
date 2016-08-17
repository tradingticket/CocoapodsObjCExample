//
//  CompanyDetails.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/23/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKCompanyDetails.h"
#import "TTSDKUtils.h"
#import "TradeItStyles.h"
#import "TTSDKTradeItTicket.h"

@interface TTSDKCompanyDetails() {
    TTSDKTradeItTicket * globalTicket;
    TTSDKUtils * utils;
    TradeItStyles * styles;
    UIView * accountLoadingView;
    UIColor * lastPriceLabelColor;
}

@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;

@end

@implementation TTSDKCompanyDetails


#pragma mark Initialization

-(id) init {
    if (self = [super init]) {
        globalTicket = [TTSDKTradeItTicket globalTicket];
        utils = [TTSDKUtils sharedUtils];
        [self setViewStyles];
    }

    return self;
}

-(void) awakeFromNib {
    self.lastPriceLoadingIndicator.layer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self.lastPriceLoadingIndicator.transform = CGAffineTransformMakeScale(0.65, 0.65);
    self.lastPriceLoadingIndicator.hidden = YES;
    [self.lastPriceLoadingIndicator startAnimating];

    self.buyingPowerLoadingIndicator.layer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self.buyingPowerLoadingIndicator.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.buyingPowerLoadingIndicator.hidden = YES;
    [self.buyingPowerLoadingIndicator startAnimating];
}

-(void) setViewStyles {
    styles = [TradeItStyles sharedStyles];

    [self.symbolLabel setTitleColor:styles.activeColor forState:UIControlStateNormal];
    [self.brokerButton setTitleColor:styles.primaryTextColor forState:UIControlStateNormal];

    self.rightArrow.image = [self.rightArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightArrow.tintColor = styles.activeColor;

    self.symbolDetailLabel.textColor = styles.smallTextColor;

    lastPriceLabelColor = self.lastPriceLabel.textColor;
}


#pragma mark Configuration

-(void) populateDetailsWithQuote:(TradeItQuote *)quote {
    [self populateSymbol: quote.symbol];
    [self populateLastPrice: quote.lastPrice];
    [self populateChangeLabelWithChange:quote.change andChangePct:quote.pctChange];
}

-(void) populateSymbol: (NSString *)symbol {
    if (globalTicket.quote.symbol) {
        [self.symbolLabel setTitle:globalTicket.quote.symbol forState:UIControlStateNormal];
    } else {
        [self.symbolLabel setTitle:@"N/A" forState:UIControlStateNormal];

        if (self.lastPriceLoadingIndicator) {
            self.lastPriceLoadingIndicator.hidden = YES;
        }
    }
}

-(void) populateLastPrice: (NSNumber *)lastPrice {
    NSNumber * theLastPrice = globalTicket.quote.lastPrice;
    if (theLastPrice && (theLastPrice > 0)) {
        self.lastPriceLabel.text = [utils formatPriceString:theLastPrice withLocaleId:globalTicket.currentAccount[@"accountBaseCurrency"]];
        self.lastPriceLabel.textColor = lastPriceLabelColor;
        self.lastPriceLoadingIndicator.hidden = YES;
    } else {
        if (globalTicket.loadingQuote) {
            self.lastPriceLabel.text = @"";
            self.lastPriceLoadingIndicator.hidden = NO;
        } else {
            self.lastPriceLabel.text = @"N/A";
            self.lastPriceLabel.textColor = styles.inactiveColor;
            self.lastPriceLoadingIndicator.hidden = YES;
        }
    }
}

-(void) populateChangeLabelWithChange: (NSNumber *)change andChangePct: (NSNumber *)changePct {
    if (change != nil && changePct != nil) {
        NSString * changePrefix;
        UIColor * changeColor;

        if ([change floatValue] > 0) {
            changePrefix = @"+";
            changeColor = styles.gainColor;
        } else if ([change floatValue] < 0) {
            changePrefix = @"";
            changeColor = styles.lossColor;
        } else {
            changePrefix = @"";
            changeColor = styles.inactiveColor;
        }

        self.changeLabel.text = [NSString stringWithFormat:@"%@%.02f (%.02f%@)", changePrefix, [change floatValue], [changePct floatValue], @"%"];
        self.changeLabel.textColor = changeColor;
        self.changeLabel.hidden = NO;
    } else {
        self.changeLabel.textColor = styles.inactiveColor;
        self.changeLabel.text = @"";
    }
}

-(void) populateBrokerButtonTitle:(NSString *)broker {
    if (broker) {
        [self.brokerButton setTitle:broker forState:UIControlStateNormal];
    } else {
        [self.brokerButton setTitle:@"N/A" forState:UIControlStateNormal];
    }
}

-(void) populateAccountDetail:(TTSDKPortfolioAccount *)account sharesOwned:(NSNumber *)sharesOwned {
    if (sharesOwned == nil) {

        if (account.balanceComplete) {
            self.buyingPowerLoadingIndicator.hidden = YES;
            self.symbolDetailValue.hidden = NO;
            self.symbolDetailLabel.text = @"BUYING POWER";

            if (account.balance.buyingPower != nil) {
                self.symbolDetailValue.text = [utils formatPriceString: account.balance.buyingPower withLocaleId:account.balance.accountBaseCurrency];
            } else {
                self.symbolDetailValue.text = @"N/A";
            }

        } else {
            self.symbolDetailValue.hidden = YES;
            self.buyingPowerLoadingIndicator.hidden = NO;
        }

    } else {

        if (account.positionsComplete) {
            self.buyingPowerLoadingIndicator.hidden = YES;
            self.symbolDetailValue.hidden = NO;
            self.symbolDetailLabel.text = @"SHARES OWNED";

            self.symbolDetailValue.text = [NSString stringWithFormat:@"%@", sharesOwned];
        } else {
            self.symbolDetailValue.hidden = YES;
            self.buyingPowerLoadingIndicator.hidden = NO;
        }
    }
}


@end
