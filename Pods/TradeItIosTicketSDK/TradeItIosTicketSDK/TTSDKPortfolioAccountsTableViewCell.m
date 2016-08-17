//
//  TTSDKPortfolioAccountsTableViewCell.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/7/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPortfolioAccountsTableViewCell.h"
#import <TradeItIosEmsApi/TradeItAccountOverviewResult.h>
#import "TTSDKUtils.h"
#import "TradeItStyles.h"

@interface TTSDKPortfolioAccountsTableViewCell() {
    TTSDKUtils * utils;
    TradeItStyles * styles;
    UITapGestureRecognizer * authTap;
}

@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyingPowerLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLeadingConstraint;
@property TTSDKPortfolioAccount * portfolioAccount;

@property UIFont * defaultAccountFont;
@property CGFloat defaultAccountFontSize;

@end

@implementation TTSDKPortfolioAccountsTableViewCell


#pragma mark Initialization

-(void) awakeFromNib {
    [super awakeFromNib];
    utils = [TTSDKUtils sharedUtils];
    styles = [TradeItStyles sharedStyles];

    [self setViewStyles];
}

-(void) setViewStyles {
    self.defaultAccountFont = self.accountLabel.font;
    self.defaultAccountFontSize = self.accountLabel.font.pointSize;

    self.selectedView.backgroundColor = [UIColor clearColor];

    self.selectedImage.image = [self.selectedImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.selectedImage setTintColor: styles.secondaryActiveColor];

    self.separatorView.backgroundColor = styles.primarySeparatorColor;
    self.authenticateView.backgroundColor = styles.pageBackgroundColor;

    if ([utils isLargeScreen]) {
        self.separatorLeadingConstraint.constant = -8;
    }
}


#pragma mark Configuration

-(void) configureCellWithAccount:(TTSDKPortfolioAccount *)account {
    NSString * displayTitle = account.displayTitle;
    NSString * totalValue;

    self.backgroundColor = styles.pageBackgroundColor;

    self.portfolioAccount = account;

    self.accountLabel.text = displayTitle;

    if (account.needsAuthentication) {
        self.authenticateView.hidden = NO;

        if (!authTap) {
            authTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authSelected:)];
            [self.authenticateView addGestureRecognizer: authTap];
        }
    } else {
        if (authTap) {
            [self.authenticateView removeGestureRecognizer: authTap];
        }

        self.authenticateView.hidden = YES;
        if (account.balance.totalValue) {
            totalValue = [utils formatPriceString:account.balance.totalValue withLocaleId:account.balance.accountBaseCurrency];
        } else {
            totalValue = @"N/A";
        }

        NSString * buyingPower = account.balance.buyingPower ? [utils formatPriceString:account.balance.buyingPower withLocaleId:account.balance.accountBaseCurrency] : @"N/A";

        self.valueLabel.text = totalValue;
        self.buyingPowerLabel.text = buyingPower;
    }
}

-(void) configureSelectedState:(BOOL)selected {
    if (selected) {
        self.selectedView.hidden = NO;
        [self.accountLabel setFont: [UIFont fontWithName: [NSString stringWithFormat:@"%@-Semibold",self.defaultAccountFont] size: self.defaultAccountFontSize] ];
    } else {
        self.selectedView.hidden = YES;
        [self.accountLabel setFont:self.defaultAccountFont];
    }
}

-(IBAction) authSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectAuth:)]) {
        [self configureSelectedState:YES];
        [self.delegate didSelectAuth: self.portfolioAccount];
    }
}

-(void) hideSeparator {
    self.separatorView.hidden = YES;
}

-(void) showSeparator {
    self.separatorView.hidden = NO;
}


@end
