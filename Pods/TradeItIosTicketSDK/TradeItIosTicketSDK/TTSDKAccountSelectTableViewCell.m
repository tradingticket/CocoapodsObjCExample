//
//  TTSDKAccountSelectTableViewCell.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/16/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountSelectTableViewCell.h"
#import "TTSDKTradeItTicket.h"
#import "TTSDKUtils.h"
#import "TradeItStyles.h"

@interface TTSDKAccountSelectTableViewCell() {
    TTSDKUtils * utils;
    TTSDKTradeItTicket * globalTicket;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel * brokerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * accountTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyingPowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyingPower;
@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *buyingPowerLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;

@end

@implementation TTSDKAccountSelectTableViewCell


-(void) awakeFromNib {
    // Initialization code
    if (self) {
        self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.detailTextLabel.textColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1];

        self.indentationLevel = 6;

        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 20)];
        }
        
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 20)];
        }

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selected = NO;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];

        TradeItStyles * styles = [TradeItStyles sharedStyles];
        self.buyingPower.textColor = styles.smallTextColor;
        self.accountTypeLabel.textColor = styles.primaryTextColor;
        self.selectionView.backgroundColor = [UIColor clearColor];

        self.backgroundColor = [UIColor clearColor];
        
        self.selectedImage.image = [self.selectedImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.selectedImage setTintColor: styles.secondaryActiveColor];

        self.buyingPowerLoadingIndicator.transform = CGAffineTransformMakeScale(0.65, 0.65);
        self.buyingPowerLoadingIndicator.hidden = YES;
        [self.buyingPowerLoadingIndicator startAnimating];

        utils = [TTSDKUtils sharedUtils];
        globalTicket = [TTSDKTradeItTicket globalTicket];
    }
}

-(void) configureSelectedState:(BOOL)selected {
    if (selected) {
        self.selectionView.hidden = NO;
    } else {
        self.selectionView.hidden = YES;
    }
}

-(void) configureCellWithAccount:(TTSDKPortfolioAccount *)account loaded:(BOOL)loaded {
    self.brokerLabel.text = account.accountNumber;
    self.brokerLabel.frame = CGRectMake(self.textLabel.frame.origin.x + 40, self.textLabel.frame.origin.y, self.brokerLabel.frame.size.width, self.textLabel.frame.size.height);

    if (loaded) {
        self.buyingPowerLoadingIndicator.hidden = YES;
        [self.buyingPowerLoadingIndicator stopAnimating];
        self.buyingPowerLabel.text = account.balance.buyingPower != nil ? [utils formatPriceString:account.balance.buyingPower withLocaleId:account.balance.accountBaseCurrency] : @"N/A";
    } else {
        self.buyingPowerLabel.text = @"";
        self.buyingPowerLoadingIndicator.hidden = NO;
        [self.buyingPowerLoadingIndicator startAnimating];
    }

    NSString * symbol = globalTicket.quote.symbol;
    NSString * shares;
    for (TTSDKPosition * position in account.positions) {
        if ([position.symbol isEqualToString: symbol]) {
            shares = [position.quantity stringValue];
            break;
        }
    }

    self.accountTypeLabel.text = [globalTicket getBrokerDisplayString: account.broker];
}


@end
