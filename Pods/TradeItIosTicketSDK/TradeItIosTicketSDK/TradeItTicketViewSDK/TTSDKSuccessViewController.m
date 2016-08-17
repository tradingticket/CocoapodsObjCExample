//
//  SuccessViewController.m
//  TradingTicket
//
//  Created by Antonio Reyes on 6/26/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKSuccessViewController.h"
#import "TTSDKPrimaryButton.h"
#import <TradeItIosEmsApi/TradeItPlaceTradeResult.h>
#import "TTSDKTradeViewController.h"
#import "TTSDKImageView.h"
#import <TradeItIosAdSdk/TradeItIosAdSdk-Swift.h>

@interface TTSDKSuccessViewController() {
    __weak IBOutlet TTSDKPrimaryButton *tradeButton;
    __weak IBOutlet UILabel *successMessage;
    __weak IBOutlet TTSDKImageView * successImage;
    __weak IBOutlet UILabel *confirmTitle;
    __weak IBOutlet TradeItAdView *adView;
    __weak IBOutlet NSLayoutConstraint *adViewHeightConstraint;
}

@end

@implementation TTSDKSuccessViewController


#pragma mark Initialization

-(IBAction) closeApp:(id)sender {
    [self.ticket returnToParentApp];
}

-(void) viewDidLoad {
    [super viewDidLoad];

    TradeItPlaceTradeResult * result = self.ticket.resultContainer.tradeResponse;

    if (result) {
        // tell the portfolio to reload data
        self.ticket.clearPortfolioCache = YES;
    }

    if (result.confirmationMessage) {
        [successMessage setText: result.confirmationMessage];
    }

    [tradeButton activate];
    [self initializeAd];

    NSMutableAttributedString * logoString = [[NSMutableAttributedString alloc] initWithAttributedString:[self.utils logoStringLight]];
    [logoString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0f] range:NSMakeRange(0, 7)];
}

-(void) setViewStyles {
    [super setViewStyles];

    self.view.backgroundColor = self.styles.darkPageBackgroundColor;
    [successImage setTintColor:self.styles.gainColor];

    confirmTitle.textColor = [UIColor whiteColor];
    successMessage.textColor = [UIColor whiteColor];
}

-(void) viewWillAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES];
}

-(void) initializeAd {
    [adView configureWithAdType:@"tradeConfirmation"
                         broker:[self.ticket.currentSession broker]
               heightConstraint:adViewHeightConstraint];
}


#pragma mark Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

-(IBAction) closeButtonPressed:(id)sender {
    [self.ticket returnToParentApp];
}

-(IBAction) tradeButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
