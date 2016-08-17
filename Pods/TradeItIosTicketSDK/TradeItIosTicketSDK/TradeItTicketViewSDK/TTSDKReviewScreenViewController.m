//
//  ReviewScreenViewController.m
//  TradingTicket
//
//  Created by Antonio Reyes on 6/24/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKReviewScreenViewController.h"
#import "TTSDKPrimaryButton.h"
#import "TTSDKSuccessViewController.h"
#import <TradeItIosEmsApi/TradeItPlaceTradeResult.h>
#import "TTSDKSmallLabel.h"
#import "TTSDKAlertController.h"

@interface TTSDKReviewScreenViewController () {
    
    __weak IBOutlet UILabel *reviewLabel;
    __weak IBOutlet TTSDKPrimaryButton *submitOrderButton;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIScrollView *scrollView;

    __weak IBOutlet UIView *accountLabelContainer;
    __weak IBOutlet TTSDKSmallLabel *accountNameLabel;

    //Field Views - needed to set the borders, sometimes collapse
    __weak IBOutlet UIView *quantityVV;
    __weak IBOutlet UIView *quantityVL;
    __weak IBOutlet UIView *priceVV;
    __weak IBOutlet UIView *priceVL;
    __weak IBOutlet UIView *expirationVV;
    __weak IBOutlet UIView *expirationVL;
    __weak IBOutlet UIView *sharesLongVV;
    __weak IBOutlet UIView *sharesLongVL;
    __weak IBOutlet UIView *sharesShortVV;
    __weak IBOutlet UIView *sharesShortVL;
    __weak IBOutlet UIView *buyingPowerVV;
    __weak IBOutlet UIView *buyingPowerVL;
    __weak IBOutlet UIView *estimatedFeesVV;
    __weak IBOutlet UIView *estimatedFeesVL;
    __weak IBOutlet UIView *estimatedCostVV;
    __weak IBOutlet UIView *estimatedCostVL;
    __weak IBOutlet UIView *warningView;
    __weak IBOutlet NSLayoutConstraint *buyingPowerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *sharesShortHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *sharesLongHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *warningHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *brokerFeesHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *estimatedCostHeightConstraint;

    //Labels that change
    __weak IBOutlet UILabel *buyingPowerLabel;
    __weak IBOutlet UILabel *estimateCostLabel;
    __weak IBOutlet UILabel *accountLabel;
    __weak IBOutlet UILabel *accountValue;

    //Value Fields
    __weak IBOutlet UILabel *quantityValue;
    __weak IBOutlet UILabel *actionValue;
    __weak IBOutlet UILabel *priceValue;
    __weak IBOutlet UILabel *expirationValue;
    __weak IBOutlet UILabel *sharesLongValue;
    __weak IBOutlet UILabel *sharesShortValue;
    __weak IBOutlet UILabel *buyingPowerValue;
    __weak IBOutlet UILabel *estimatedFeesValue;
    __weak IBOutlet UILabel *estimatedCostValue;
    
    UIView * lastAttachedMessage;
    NSMutableArray * ackLabels; // used for sizing
    NSMutableArray * warningLabels; // used for sizing

    int ackLabelsToggled;
    float totalRemovedCellHeight;

    TradeItPlaceTradeResult * placeTradeResult;
    
    TTSDKUtils * utils;
}

@end


static float kMessageSeparatorHeight = -15.0f;


@implementation TTSDKReviewScreenViewController


-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    utils = [TTSDKUtils sharedUtils];

    ackLabels = [[NSMutableArray alloc] init];
    warningLabels = [[NSMutableArray alloc] init];

    totalRemovedCellHeight = 0.0f;

    // used for attaching constraints
    lastAttachedMessage = accountLabelContainer;

    self.reviewTradeResult = self.ticket.resultContainer.reviewResponse;

    [self updateUIWithReviewResult];

    if ([ackLabels count]) {
        [submitOrderButton deactivate];
        submitOrderButton.enabled = NO;
    } else {
        [submitOrderButton activate];
    }

    scrollView.alwaysBounceHorizontal = NO;
    scrollView.alwaysBounceVertical = YES;

    [self initContentViewHeight];
}

-(void) setViewStyles {
    [super setViewStyles];

    contentView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = self.styles.darkPageBackgroundColor;
}

-(void) updateUIWithReviewResult {
    accountNameLabel.text = [self.ticket.currentAccount valueForKey: @"displayTitle"];

    accountLabel.text = [[self.ticket.currentAccount valueForKey: @"broker"] uppercaseString];
    accountValue.text = [self.ticket.currentAccount valueForKey: @"accountNumber"];

    [quantityValue setText:[NSString stringWithFormat:@"%@", [[[self reviewTradeResult] orderDetails] valueForKey:@"orderQuantity"]]];

    NSDictionary * actionOptions = @{
                                     @"buy": @"Buy",
                                     @"sell": @"Sell",
                                     @"buyToCover": @"Buy to Cover",
                                     @"sellShort": @"Sell Short"
                                     };

    if ([actionOptions valueForKey:self.ticket.previewRequest.orderAction] != nil) {
        [actionValue setText: [actionOptions valueForKey:self.ticket.previewRequest.orderAction]];
    } else {
        [actionValue setText: @""];
    }

    [priceValue setText:[[[self reviewTradeResult] orderDetails] valueForKey:@"orderPrice"]];
    [expirationValue setText:[[[self reviewTradeResult] orderDetails] valueForKey:@"orderExpiration"]];

    if(![[[self reviewTradeResult] orderDetails] valueForKey:@"longHoldings"] || [[[[self reviewTradeResult] orderDetails] valueForKey:@"longHoldings"] isEqualToValue: [NSNumber numberWithDouble:-1]]) {
        totalRemovedCellHeight += sharesLongHeightConstraint.constant;
        sharesLongHeightConstraint.constant = 0.0f;
        sharesLongVL.hidden = YES;
        sharesLongVV.hidden = YES;
    } else {
        [sharesLongValue setText:[NSString stringWithFormat:@"%@", [[[self reviewTradeResult] orderDetails] valueForKey:@"longHoldings"]]];
    }

    if(![[[self reviewTradeResult] orderDetails] valueForKey:@"shortHoldings"] || [(NSNumber *)[[[self reviewTradeResult] orderDetails] valueForKey:@"shortHoldings"] isEqualToValue: [NSNumber numberWithDouble:-1]]) {
        totalRemovedCellHeight += sharesShortHeightConstraint.constant;
        sharesShortHeightConstraint.constant = 0.0f;
        sharesShortVL.hidden = YES;
        sharesShortVV.hidden = YES;
    } else {
        [sharesShortValue setText:[NSString stringWithFormat:@"%@", [[[self reviewTradeResult] orderDetails] valueForKey:@"shortHoldings"]]];
    }

    if(![[[self reviewTradeResult] orderDetails] valueForKey:@"buyingPower"] && ![[[self reviewTradeResult] orderDetails] valueForKey:@"availableCash"]) {
        totalRemovedCellHeight += buyingPowerHeightConstraint.constant;
        buyingPowerHeightConstraint.constant = 0.0f;
        buyingPowerVL.hidden = YES;
        buyingPowerVV.hidden = YES;
    } else if ([[[self reviewTradeResult] orderDetails] valueForKey:@"buyingPower"]) {
        [buyingPowerLabel setText:@"BUYING POWER"];
        [buyingPowerValue setText:[utils formatPriceString:[[[self reviewTradeResult] orderDetails] valueForKey:@"buyingPower"] withLocaleId:self.ticket.currentAccount[@"accountBaseCurrency"]]];
    } else {
        [buyingPowerLabel setText:@"AVAIL. CASH"];
        [buyingPowerValue setText:[utils formatPriceString:[[[self reviewTradeResult] orderDetails] valueForKey:@"availableCash"] withLocaleId:self.ticket.currentAccount[@"accountBaseCurrency"]]];
    }

    if([[[self reviewTradeResult] orderDetails] valueForKey:@"estimatedOrderCommission"]) {
        [estimatedFeesValue setText:[utils formatPriceString:[[[self reviewTradeResult] orderDetails] valueForKey:@"estimatedOrderCommission"] withLocaleId:self.ticket.currentAccount[@"accountBaseCurrency"]]];
    } else {
        totalRemovedCellHeight += brokerFeesHeightConstraint.constant;
        brokerFeesHeightConstraint.constant = 0.0f;
        estimatedFeesVL.hidden = YES;
        estimatedFeesVV.hidden = YES;
    }

    if([[[[self reviewTradeResult] orderDetails] valueForKey:@"orderAction"] isEqualToString:@"Sell"] || [[[[self reviewTradeResult] orderDetails] valueForKey:@"orderAction"] isEqualToString:@"Buy to Cover"]) {
        [estimateCostLabel setText:@"ESTIMATED PROCEEDS"];
    } else {
        [estimateCostLabel setText:@"ESTIMATED COST"];
    }

    if([[[self reviewTradeResult] orderDetails] valueForKey:@"estimatedOrderValue"]) {
        [estimatedCostValue setText:[utils formatPriceString:[[[self reviewTradeResult] orderDetails] valueForKey:@"estimatedOrderValue"] withLocaleId:self.ticket.currentAccount[@"accountBaseCurrency"]]];
    } else if ([[[self reviewTradeResult] orderDetails] valueForKey:@"estimatedTotalValue"]) {
        [estimatedCostValue setText:[utils formatPriceString:[[[self reviewTradeResult] orderDetails] valueForKey:@"estimatedTotalValue"] withLocaleId:self.ticket.currentAccount[@"accountBaseCurrency"]]];
    } else {
        totalRemovedCellHeight += estimatedCostHeightConstraint.constant;
        estimatedCostHeightConstraint.constant = 0.0f;
        estimatedCostVL.hidden = YES;
        estimatedCostVV.hidden = YES;
    }

    for(NSString * warning in [[self reviewTradeResult] ackWarningsList]) {
        [self addAcknowledgeMessage: warning];
    }

    for(NSString * warning in [[self reviewTradeResult] warningsList]) {
        [self addReviewMessage: warning];
    }
}

-(void) addReviewMessage:(NSString *) message {
    UILabel * messageLabel = [self createAndSizeMessageUILabel:message toggle: NO];

    [warningView insertSubview:messageLabel atIndex:0];

    [messageLabel sizeToFit];

    [self addConstraintsToMessage:messageLabel];

    [messageLabel setNeedsUpdateConstraints];
    [messageLabel layoutSubviews];

    [warningLabels addObject:messageLabel];
}

-(void) addAcknowledgeMessage:(NSString *) message {
    UIView * container = [[UIView alloc] init];
    [container setTranslatesAutoresizingMaskIntoConstraints:NO];

    UISwitch * toggle = [[UISwitch alloc] init];
    UILabel * messageLabel = [self createAndSizeMessageUILabel:message toggle: YES];
    toggle.autoresizesSubviews = YES;
    messageLabel.autoresizesSubviews = YES;
    toggle.userInteractionEnabled = YES;
    [toggle addTarget:self action:@selector(ackLabelToggled:) forControlEvents:UIControlEventValueChanged];

    [ackLabels addObject:messageLabel];

    [messageLabel sizeToFit];

    [container addSubview:toggle];
    [container addSubview:messageLabel];
    [warningView insertSubview:container atIndex:0];

    [self constrainToggle:toggle andLabel:messageLabel toView:container];

    [self addConstraintsToMessage:container];
}

-(UILabel *) createAndSizeMessageUILabel: (NSString *) message toggle:(BOOL)toggle {
    CGRect labelFrame = CGRectMake(0, 0, warningView.frame.size.width, 14.0f);
    UILabel * label = [[UILabel alloc] init];

    [label setText: message];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.autoresizesSubviews = YES;
    label.adjustsFontSizeToFitWidth = NO;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setNumberOfLines: 0]; // 0 allows unlimited lines
    label.textColor = self.styles.warningColor;
    label.font = [UIFont systemFontOfSize:11];
    label.frame = labelFrame;

    [label sizeToFit];

    return label;
}

-(void) addConstraintsToMessage:(UIView *) label {
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint
                                         constraintWithItem:label
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:lastAttachedMessage
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1
                                         constant:kMessageSeparatorHeight];
    topConstraint.priority = 900;

    NSLayoutConstraint * leftConstraint = [NSLayoutConstraint
                                           constraintWithItem:label
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:warningView
                                           attribute:NSLayoutAttributeLeadingMargin
                                           multiplier:1
                                           constant:3];
    leftConstraint.priority = 900;

    NSLayoutConstraint * rightConstraint = [NSLayoutConstraint
                                           constraintWithItem:label
                                           attribute:NSLayoutAttributeTrailing
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:warningView
                                           attribute:NSLayoutAttributeTrailingMargin
                                           multiplier:1
                                           constant:-3];
    rightConstraint.priority = 900;

    lastAttachedMessage = label;

    [contentView addConstraint: topConstraint];
    [contentView addConstraint: leftConstraint];
    [contentView addConstraint: rightConstraint];
}

-(void) constrainToggle:(UISwitch *) toggle andLabel:(UILabel *) label toView:(UIView *) view {
    NSLayoutConstraint * toggleLeftConstraint = [NSLayoutConstraint
                                                 constraintWithItem:toggle
                                                 attribute:NSLayoutAttributeLeading
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:view
                                                 attribute:NSLayoutAttributeLeading
                                                 multiplier:1
                                                 constant:3];
    toggleLeftConstraint.priority = 900;
    
    NSLayoutConstraint * toggleTopConstraint = [NSLayoutConstraint
                                                constraintWithItem:toggle
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:view
                                                attribute:NSLayoutAttributeTop
                                                multiplier:1
                                                constant:0];
    toggleTopConstraint.priority = 900;
    
    NSLayoutConstraint * toggleLabelConstraint = [NSLayoutConstraint
                                                  constraintWithItem:toggle
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:label
                                                  attribute:NSLayoutAttributeLeading
                                                  multiplier:1
                                                  constant:-10];
    toggleLabelConstraint.priority = 900;
    
    NSLayoutConstraint * labelTopConstraint = [NSLayoutConstraint
                                               constraintWithItem:label
                                               attribute:NSLayoutAttributeTop
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:view
                                               attribute:NSLayoutAttributeTop
                                               multiplier:1
                                               constant:0];
    labelTopConstraint.priority = 900;
    
    NSLayoutConstraint * labelRightConstraint = [NSLayoutConstraint
                                                 constraintWithItem:label
                                                 attribute:NSLayoutAttributeTrailing
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:view
                                                 attribute:NSLayoutAttributeTrailing
                                                 multiplier:1
                                                 constant:0];
    labelRightConstraint.priority = 900;
    
    NSLayoutConstraint * labelBottomConstraint = [NSLayoutConstraint
                                                  constraintWithItem:label
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:view
                                                  attribute:NSLayoutAttributeBottom
                                                  multiplier:1
                                                  constant:0];
    labelBottomConstraint.priority = 900;
    
    
    [self.view addConstraint:toggleLeftConstraint];
    [self.view addConstraint:toggleTopConstraint];
    [self.view addConstraint:toggleLabelConstraint];
    [self.view addConstraint:labelTopConstraint];
    [self.view addConstraint:labelRightConstraint];
    [self.view addConstraint:labelBottomConstraint];
}

-(void) initContentViewHeight {
    CGRect contentRect = CGRectZero;
    for (UIView * view in [contentView subviews]) {
        CGRect frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height + fabs(kMessageSeparatorHeight));
        contentRect = CGRectUnion(contentRect, frame);
    }

    CGRect warningRect = CGRectZero;

    for(UIView * aLabel in ackLabels) {
        contentRect.size.height += aLabel.frame.size.height + fabs(kMessageSeparatorHeight);
        warningRect.size.height += aLabel.frame.size.height + fabs(kMessageSeparatorHeight);
    }

    for(UILabel * wLabel in warningLabels) {
        contentRect.size.height += wLabel.frame.size.height + fabs(kMessageSeparatorHeight);
        warningRect.size.height += wLabel.frame.size.height + fabs(kMessageSeparatorHeight);
    }

    if (ackLabels.count || warningLabels.count) { // extra padding
        warningHeightConstraint.constant = warningRect.size.height;

        if ([self.utils isMediumScreen]) {
            warningHeightConstraint.constant += 20;
            contentRect.size.height += 20;
        }
    }

    contentRect.size.height -= totalRemovedCellHeight;

    NSLayoutConstraint * heightConstraint = [NSLayoutConstraint
                                             constraintWithItem:contentView
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:NSLayoutAttributeNotAnAttribute
                                             attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1
                                             constant:contentRect.size.height];
    heightConstraint.priority = 900;
    [self.view addConstraint:heightConstraint];

    [scrollView setContentSize:contentRect.size];
    [scrollView layoutIfNeeded];
    [scrollView setNeedsUpdateConstraints];
}


#pragma mark Trade Request

-(IBAction) placeOrderPressed:(id)sender {
    [submitOrderButton enterLoadingState];
    [self sendTradeRequest];
}

-(void) sendTradeRequest {
    self.ticket.currentSession.tradeRequest = [[TradeItPlaceTradeRequest alloc] initWithOrderId: self.reviewTradeResult.orderId];

    [self.ticket.currentSession placeTrade:^(TradeItResult *result) {
        [self tradeRequestRecieved: result];
    }];
}

-(void) tradeRequestRecieved: (TradeItResult *) result {
    [submitOrderButton exitLoadingState];
    [submitOrderButton activate];

    //success
    if ([result isKindOfClass: TradeItPlaceTradeResult.class]) {
        self.ticket.resultContainer.status = SUCCESS;
        self.ticket.resultContainer.tradeResponse = (TradeItPlaceTradeResult *) result;
        [self performSegueWithIdentifier:@"ReviewToSuccess" sender: self];
    } else if([result isKindOfClass:[TradeItErrorResult class]]) { //error
        TradeItErrorResult * error = (TradeItErrorResult *) result;

        NSString * errorMessage = @"TradeIt is temporarily unavailable. Please try again in a few minutes.";
        errorMessage = [error.longMessages count] > 0 ? [error.longMessages componentsJoinedByString:@" "] : errorMessage;

        self.ticket.resultContainer.status = EXECUTION_ERROR;
        self.ticket.resultContainer.errorResponse = error;

        TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:@"Could Not Complete Order"
                                                                        message:errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        alert.modalPresentationStyle = UIModalPresentationPopover;

        NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString: errorMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
        NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString: @"Could Not Complete Order" attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
        
        [alert setValue:attributedMessage forKey:@"attributedMessage"];
        [alert setValue:attributedTitle forKey:@"attributedTitle"];

        UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [self performSelectorOnMainThread:@selector(navigateBackToTrade) withObject:nil waitUntilDone:NO];
                                                               }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;

        alert.view.tintColor = self.styles.alertButtonColor;

        alertPresentationController.sourceView = self.view;
        alertPresentationController.permittedArrowDirections = 0;
        alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
}


#pragma mark Navigation

-(void) navigateBackToTrade {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

-(IBAction) ackLabelToggled:(id)sender {
    UISwitch * switchSender = sender;

    if (switchSender.on) {
        ackLabelsToggled++;
    } else {
        ackLabelsToggled--;
    }

    if (ackLabelsToggled >= [ackLabels count]) {
        [submitOrderButton activate];
        submitOrderButton.enabled = YES;
    } else {
        [submitOrderButton deactivate];
        submitOrderButton.enabled = NO;
    }
}


@end
