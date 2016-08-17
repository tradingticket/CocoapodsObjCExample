//
//  TTSDKPortfolioHoldingTableViewCell.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/6/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPortfolioHoldingTableViewCell.h"
#import "TTSDKPosition.h"
#import "TTSDKUtils.h"
#import "TTSDKTradeItTicket.h"
#import "TradeItStyles.h"
#import "TTSDKLabel.h"

@interface TTSDKPortfolioHoldingTableViewCell () {
    TTSDKUtils * utils;
    TTSDKPosition * currentPosition;
    TTSDKTradeItTicket * globalTicket;
    TradeItStyles * styles;
}

@property (weak, nonatomic) IBOutlet UIButton *sellButton;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIView *secondaryView;
@property (weak, nonatomic) IBOutlet UIView *primaryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *primaryLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *primaryRightConstraint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalReturnVerticalConstraint;

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *bidLabel;
@property (weak, nonatomic) IBOutlet UILabel *askLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalValueLabel;
@property (weak, nonatomic) IBOutlet TTSDKLabel *totalReturnLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalReturnValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UIButton *dropDownBuyButton;
@property (weak, nonatomic) IBOutlet UIButton *dropDownSellButton;

@end

@implementation TTSDKPortfolioHoldingTableViewCell


#pragma mark Constants

static CGFloat const kBounceValue = 20.0f;


#pragma mark Initialization

-(void) awakeFromNib {
    [super awakeFromNib];

    utils = [TTSDKUtils sharedUtils];
    globalTicket = [TTSDKTradeItTicket globalTicket];
    styles = [TradeItStyles sharedStyles];

    if (!UITableViewRowAction.class) {
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(panCell:)];
        self.panRecognizer.delegate = self;
        [self.primaryView addGestureRecognizer: self.panRecognizer];
    }

    self.primaryView.backgroundColor = styles.pageBackgroundColor;
    self.expandedView.backgroundColor = styles.pageBackgroundColor;
    self.separatorView.backgroundColor = styles.primarySeparatorColor;

    self.dropDownBuyButton.layer.cornerRadius = 5.0f;
    self.dropDownSellButton.layer.cornerRadius = 5.0f;

    UITapGestureRecognizer * buyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buySelected:)];
    [self.buyButton addGestureRecognizer: buyTap];
    [self.dropDownBuyButton addGestureRecognizer: buyTap];

    UITapGestureRecognizer * sellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sellSelected:)];
    [self.sellButton addGestureRecognizer: sellTap];
    [self.dropDownSellButton addGestureRecognizer: sellTap];
}

-(IBAction) sellSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectSell:)]) {
        [self.delegate didSelectSell: currentPosition];
    }
}

-(IBAction) buySelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectBuy:)]) {
        [self.delegate didSelectBuy: currentPosition];
    }
}


#pragma mark Configuration

-(void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void) hideSeparator {
    self.separatorView.hidden = YES;
}

-(void) showSeparator {
    self.separatorView.hidden = NO;
}

-(void) configureCellWithPosition:(TTSDKPosition *)position withLocale:(NSString *) locale {
    // Cost
    NSString * cost = position.costbasis ? [utils formatPriceString: position.costbasis withLocaleId:locale] : @"N/A";
    self.costLabel.text = [cost isEqualToString:@"0"] ? @"N/A" : cost;

    NSString * lastPrice = position.lastPrice != nil ? [utils formatPriceString: position.lastPrice withLocaleId:locale] : @"N/A";
    self.lastLabel.text = lastPrice;

    if ([position.symbolClass isEqualToString:@"EQUITY_OR_ETF"]) {
        self.dropDownBuyButton.hidden = NO;
        self.dropDownSellButton.hidden = NO;
        [self.dropDownBuyButton setTitle:[NSString stringWithFormat:@"Buy %@", position.symbol] forState:UIControlStateNormal];
        [self.dropDownSellButton setTitle:[NSString stringWithFormat:@"Sell %@", position.symbol] forState:UIControlStateNormal];
    } else {
        self.dropDownBuyButton.hidden = YES;
        self.dropDownSellButton.hidden = YES;
        [self.dropDownBuyButton setTitle:@"Buy" forState:UIControlStateNormal];
        [self.dropDownSellButton setTitle:@"Sell" forState:UIControlStateNormal];
    }

    // Symbol and Quantity
    NSString * quantityPostfix = @"";
    if (position.quantity < 0) {
        quantityPostfix = @" x%@", [position.quantity stringValue];
    }

    NSString * quantityStr = [position.quantity stringValue];
    if ([quantityStr rangeOfString:@"."].location != NSNotFound) {
        quantityStr = [NSString stringWithFormat:@"%.02f", fabs([position.quantity floatValue])];
    } else {
        quantityStr = [NSString stringWithFormat:@"%i", abs([position.quantity intValue])];
    }

    if (!position.symbol) {
        self.symbolLabel.text = @"N/A";
    } else {
        self.symbolLabel.text = [NSString stringWithFormat:@"%@ (%@%@)", position.symbol, quantityStr, quantityPostfix];
    }

    // Bid and Ask
    NSString * bid;
    if (position.quote.bidPrice) {
        bid = [NSString stringWithFormat:@"%.02f", [position.quote.bidPrice floatValue]];
    } else {
        bid = @"N/A";
    }
    NSString * ask;
    if (position.quote.askPrice) {
        ask = [NSString stringWithFormat:@"%.02f", [position.quote.askPrice floatValue]];
    } else {
        ask = @"N/A";
    }
    self.bidLabel.text = bid;
    self.askLabel.text = ask;

    // Change
    NSString * changeStr;
    UIColor * changeColor;
    NSString * changePrefix;
    if (position.quote.change != nil) {
        if ([position.quote.change floatValue] > 0) {
            changePrefix = @"+";
            changeColor = styles.gainColor;
        } else if ([position.quote.change floatValue] < 0) {
            changePrefix = @""; // number will already have the minus sign
            changeColor = styles.lossColor;
        } else {
            changePrefix = @"";
            changeColor = [UIColor lightGrayColor];
        }

        NSString * changePctStr;
        if (position.quote.pctChange) {
            changePctStr = [NSString stringWithFormat:@"%.02f%@", [position.quote.pctChange floatValue], @"%"];
        } else {
            changePctStr = @"N/A";
        }

        changeStr = [NSString stringWithFormat:@"%@%.02f(%@)", changePrefix, [position.quote.change floatValue], changePctStr];
    } else {
        changeColor = [UIColor lightGrayColor];
        changeStr = @"N/A";
    }
    self.changeLabel.text = changeStr;
    self.changeLabel.textColor = changeColor;

    // Total Value
    NSString * totalValue;
    if (position.totalValue != nil) {
        totalValue = [utils formatPriceString:position.totalValue];
    } else {
        if (position.quantity && position.quote.lastPrice) {
            totalValue = [NSString stringWithFormat:@"%@", [utils formatPriceString: [NSNumber numberWithFloat:[position.quantity floatValue] * [position.quote.lastPrice floatValue]] withLocaleId:locale]];
        } else {
            totalValue = @"N/A";
        }
    }
    self.totalValueLabel.text = totalValue;

    // Total Return
    UIColor * returnColor;
    NSString * returnPrefix;
    NSString * returnStr;
    if (position.totalGainLossDollar != nil) {
        if ([position.totalGainLossDollar floatValue] > 0) {
            returnColor = styles.gainColor;
            returnPrefix = @"+";
        } else if ([position.totalGainLossDollar floatValue] == 0) {
            returnColor = [UIColor lightGrayColor];
            returnStr = @"N/A";
        } else {
            returnColor = styles.lossColor;
            returnPrefix = @"";
        }
        
        NSString * returnPctStr;
        if (position.totalGainLossPercentage) {
            returnPctStr = [NSString stringWithFormat:@"%.02f%@", [position.totalGainLossPercentage floatValue], @"%"];
        } else {
            returnPctStr = @"N/A";
        }
        
        if (!returnStr) {
            returnStr = [NSString stringWithFormat:@"%@%.02f(%@)", returnPrefix, [position.totalGainLossDollar floatValue], returnPctStr];
        }
    } else {
        returnColor = [UIColor lightGrayColor];
        returnStr = @"N/A";
    }

    self.totalReturnValueLabel.text = returnStr;
    self.totalReturnValueLabel.textColor = returnColor;

    [self.totalReturnValueLabel sizeToFit];

    // Here we need to see whether the total return value collides with its label. If so, we want to move it down to the next line
    CGRect totalReturnLabelRect = self.totalReturnLabel.frame;
    CGFloat totalReturnLabelOffset = totalReturnLabelRect.origin.x + self.totalReturnLabel.intrinsicContentSize.width;
    CGFloat totalReturnValueLabelOffset = self.totalReturnValueLabel.frame.origin.x;

    if (totalReturnLabelOffset > totalReturnValueLabelOffset) {
        self.totalReturnVerticalConstraint.constant = 20.0f;
    } else {
        self.totalReturnVerticalConstraint.constant = 0.0f;
    }

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    currentPosition = position; // set current position
}

-(CGFloat) secondaryViewWidth {
    return self.secondaryView.frame.size.width;
}


#pragma mark Custom UI

-(void) panCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.primaryView];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView: self.primaryView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }

            if (self.startingRightLayoutConstraint == 0) {
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0);
                    if (constant == 0) {
                        [self resetConstraintsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.primaryRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self secondaryViewWidth]);
                    if (constant == [self secondaryViewWidth]) {
                        [self setConstraintsToShowOptions:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.primaryRightConstraint.constant = constant;
                    }
                }
            } else {
                CGFloat adjustment = self.startingRightLayoutConstraint - deltaX;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant == 0) {
                        [self resetConstraintsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.primaryRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self secondaryViewWidth]);
                    if (constant == [self secondaryViewWidth]) {
                        [self setConstraintsToShowOptions:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.primaryRightConstraint.constant = constant;
                    }
                }
            }

            self.primaryLeftConstraint.constant = -self.primaryRightConstraint.constant;
        }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraint == 0) {
                CGFloat quarterWay = [self secondaryViewWidth] / 4;
                if (self.primaryRightConstraint.constant >= quarterWay) {
                    [self setConstraintsToShowOptions:YES notifyDelegateDidOpen:YES];
                } else {
                    [self resetConstraintsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                CGFloat threeQuarters = [self secondaryViewWidth] - ([self secondaryViewWidth] / 4);
                if (self.primaryRightConstraint.constant >= threeQuarters) {
                    [self setConstraintsToShowOptions:YES notifyDelegateDidOpen:YES];
                } else {
                    [self resetConstraintsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraint == 0) {
                [self resetConstraintsToZero:YES notifyDelegateDidClose:YES];
            } else {
                [self setConstraintsToShowOptions:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

-(void) updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

-(void) resetConstraintsToZero:(BOOL) animated notifyDelegateDidClose:(BOOL) endEditing {
    if (self.startingRightLayoutConstraint == 0 && self.primaryRightConstraint.constant == 0) {
        return;
    }

    self.primaryRightConstraint.constant = -kBounceValue;
    self.primaryLeftConstraint.constant = kBounceValue;

    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.primaryRightConstraint.constant = 0;
        self.primaryLeftConstraint.constant = 0;

        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraint = self.primaryRightConstraint.constant;
        }];
    }];
}

-(void) setConstraintsToShowOptions:(BOOL) animated notifyDelegateDidOpen:(BOOL) notifyDelegate {
    if (self.startingRightLayoutConstraint == [self secondaryViewWidth] && self.primaryRightConstraint.constant == [self secondaryViewWidth]) {
        return;
    }

    self.primaryLeftConstraint.constant = -[self secondaryViewWidth] - kBounceValue;
    self.primaryRightConstraint.constant = [self secondaryViewWidth] + kBounceValue;

    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.primaryLeftConstraint.constant = -[self secondaryViewWidth];
        self.primaryRightConstraint.constant = [self secondaryViewWidth];

        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraint = self.primaryRightConstraint.constant;
        }];
    }];
}


@end
