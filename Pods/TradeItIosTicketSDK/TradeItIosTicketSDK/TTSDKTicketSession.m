//
//  TTSDKTicketSession.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/11/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKTicketSession.h"
#import <TradeItIosEmsApi/TradeItAuthenticationResult.h>
#import "TTSDKCustomIOSAlertView.h"
#import "TTSDKLoginViewController.h"
#import "TTSDKTradeViewController.h"
#import "TTSDKPortfolioViewController.h"
#import "TTSDKAlertController.h"
#import "TTSDKAccountLinkViewController.h"
#import "TTSDKLoginViewController.h"
#import "TradeItStyles.h"

@interface TTSDKTicketSession() {
    NSArray * questionOptions;
    UIPickerView * currentPicker;
    UIViewController * delegateViewController;
    NSString * currentSelection;
    TradeItTradeService * tradeService;
    TTSDKUtils * utils;
    TradeItStyles * styles;
}

@end

@implementation TTSDKTicketSession

static NSString * kAccountLinkNavIdentifier = @"ACCOUNT_LINK_NAV";

- (id)initWithConnector: (TradeItConnector *) connector andLinkedLogin:(TradeItLinkedLogin *)linkedLogin andBroker:(NSString *)broker {
    self = [super initWithConnector:connector];

    if (self) {
        self.login = linkedLogin;
        self.broker = broker;
        utils = [TTSDKUtils sharedUtils];
        styles = [TradeItStyles sharedStyles];
    }

    return self;
}

- (void)previewTrade:(TradeItPreviewTradeRequest *)previewRequest withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    if (!previewRequest) {
        return;
    }

    previewRequest.token = self.token;

    tradeService = [[TradeItTradeService alloc] initWithSession: self];
    [tradeService previewTrade:previewRequest withCompletionBlock:^(TradeItResult * res) {
        if ([res isKindOfClass:TradeItErrorResult.class]) {
            TradeItErrorResult * error = (TradeItErrorResult *)res;

            if ([error.code isEqualToNumber:@600]) {
                self.needsAuthentication = YES;
            } else if ([error.code isEqualToNumber:@700]) {
                self.needsManualAuthentication = YES;
            }

            completionBlock(res);
        } else {
            self.needsManualAuthentication = NO;
            self.needsAuthentication = NO;

            completionBlock(res);
        }
    }];
}

- (void)placeTrade:(void (^)(TradeItResult *)) completionBlock {
    if (!self.tradeRequest) {
        return;
    }

    [tradeService placeTrade: self.tradeRequest withCompletionBlock: completionBlock];
}

- (void) authenticateFromViewController:(UIViewController *)viewController
                    withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    if (!self.login || self.authenticating) {
        return;
    }

    self.authenticating = YES;

    delegateViewController = viewController;

    [self authenticate:self.login withCompletionBlock:^(TradeItResult * res) {
        self.authenticating = NO;

        [self authenticationRequestReceivedWithViewController:viewController
                                          withCompletionBlock:completionBlock
                                                    andResult:res];
    }];
}

- (void)getPositionsFromAccount:(NSDictionary *)account
            withCompletionBlock:(void (^)(NSArray *))completionBlock {
    TradeItGetPositionsRequest * positionsRequest = [[TradeItGetPositionsRequest alloc] initWithAccountNumber:[account valueForKey:@"accountNumber"]];

    positionsRequest.token = self.token;

    TradeItPositionService * positionService = [[TradeItPositionService alloc] initWithSession: self];

    [positionService getAccountPositions: positionsRequest  withCompletionBlock:^(TradeItResult * result) {
        if ([result isKindOfClass: TradeItGetPositionsResult.class]) {
            TradeItGetPositionsResult * positionsResult = (TradeItGetPositionsResult *)result;

            NSMutableArray * ttsdkPositions = [[NSMutableArray alloc] init];

            for (TradeItPosition * position in positionsResult.positions) {
                TTSDKPosition * subclassPosition = [[TTSDKPosition alloc] initWithPosition: position];
                [ttsdkPositions addObject: subclassPosition];
            }

            completionBlock([ttsdkPositions copy]);
        } else if ([result isKindOfClass:TradeItErrorResult.class]) {
            TradeItErrorResult * error = (TradeItErrorResult *)result;

            if ([error.code isEqualToNumber:@600]) {
                self.needsAuthentication = YES;
            } else if ([error.code isEqualToNumber:@700]) {
                self.needsManualAuthentication = YES;
            }

            completionBlock(nil);
        }
    }];
}

- (void)getOverviewFromAccount:(NSDictionary *)account
           withCompletionBlock:(void (^)(TradeItAccountOverviewResult *))completionBlock {
    TradeItBalanceService * balanceService = [[TradeItBalanceService alloc] initWithSession: self];
    TradeItAccountOverviewRequest * request = [[TradeItAccountOverviewRequest alloc] initWithAccountNumber:[account valueForKey:@"accountNumber"]];

    request.token = self.token;

    [balanceService getAccountOverview:request withCompletionBlock:^(TradeItResult * result) {
        if ([result isKindOfClass:TradeItAccountOverviewResult.class]) {
            TradeItAccountOverviewResult * overviewResult = (TradeItAccountOverviewResult *)result;
            completionBlock(overviewResult);
        } else if ([result isKindOfClass:TradeItErrorResult.class]) {
            TradeItErrorResult * error = (TradeItErrorResult *)result;

            if ([error.code isEqualToNumber:@600]) {
                self.needsAuthentication = YES;
            } else if ([error.code isEqualToNumber:@700]) {
                self.needsManualAuthentication = YES;
            }

            completionBlock(nil);
        }
    }];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return questionOptions.count;
}

#pragma mark - private

- (void)authenticationRequestReceivedWithViewController:(UIViewController *)viewController
                                    withCompletionBlock:(void (^)(TradeItResult *))completionBlock
                                              andResult:(TradeItResult *)res {
    if ([res isKindOfClass:TradeItAuthenticationResult.class]) {
        self.isAuthenticated = YES;
        self.broker = self.login.broker;
        self.needsAuthentication = NO;
        self.needsManualAuthentication = NO;

        if (completionBlock) {
            completionBlock(res);
        }
    } else {
        self.needsAuthentication = YES;

        if ([res isKindOfClass:TradeItErrorResult.class]) {
            TradeItErrorResult *error = (TradeItErrorResult *) res;

            if ([error.code isEqualToNumber:@700]) {
                self.needsManualAuthentication = YES;
            }

            if (completionBlock) {
                completionBlock(res);
            }
        } else if (viewController &&
                   [res isKindOfClass:TradeItSecurityQuestionResult.class]) {
            TradeItSecurityQuestionResult * result = (TradeItSecurityQuestionResult *)res;

            if (result.securityQuestionOptions != nil &&
                result.securityQuestionOptions.count > 0) {

                if (![UIAlertController class]) {
                    [self showOldMultiSelectWithViewController:viewController
                                           withCompletionBlock:completionBlock
                                     andSecurityQuestionResult:result];
                } else {
                    TTSDKAlertController *alert = [TTSDKAlertController alertControllerWithTitle:@"Verify Identity"
                                                                                         message:result.securityQuestion
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                    alert.modalPresentationStyle = UIModalPresentationPopover;

                    NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString: result.securityQuestion attributes: @{NSForegroundColorAttributeName: styles.alertTextColor}];
                    NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString: @"Verify Identity" attributes: @{NSForegroundColorAttributeName: styles.alertTextColor}];

                    [alert setValue:attributedMessage forKey:@"attributedMessage"];
                    [alert setValue:attributedTitle forKey:@"attributedTitle"];

                    for (NSString *title in result.securityQuestionOptions) {
                        UIAlertAction *option = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            [self answerSecurityQuestion:title withCompletionBlock:^(TradeItResult * result) {
                                [self authenticationRequestReceivedWithViewController:viewController withCompletionBlock:completionBlock andResult:result];
                            }];
                        }];

                        [alert addAction:option];
                    }

                    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                                            style:UIAlertActionStyleCancel
                                                                          handler:^(UIAlertAction * action) {
                                                                              if ([viewController isKindOfClass:TTSDKLoginViewController.class]) {
                                                                                  if (completionBlock) {
                                                                                      completionBlock(res);
                                                                                  }

                                                                                  return;
                                                                              }

                                                                              [self launchAccountLink:viewController];
                                                                          }];
                    [alert addAction:cancelAction];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegateViewController presentViewController:alert
                                                             animated:YES
                                                           completion:nil];

                        alert.view.tintColor = styles.alertButtonColor;

                        UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;

                        alertPresentationController.sourceView = viewController.view;
                        alertPresentationController.permittedArrowDirections = 0;
                        alertPresentationController.sourceRect = CGRectMake(viewController.view.bounds.size.width / 2.0,
                                                                            viewController.view.bounds.size.height / 2.0,
                                                                            1.0,
                                                                            1.0);
                    });
                }
            } else if (result.securityQuestion != nil) {
                if (![UIAlertController class]) {
                    [self showOldSecQuestion:result.securityQuestion];
                } else {
                    NSString *title = [NSString stringWithFormat:@"%@ Security Question", self.broker];
                    TTSDKAlertController *alert = [TTSDKAlertController alertControllerWithTitle:title
                                                                                         message:result.securityQuestion
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                    alert.modalPresentationStyle = UIModalPresentationPopover;

                    NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString: result.securityQuestion attributes: @{NSForegroundColorAttributeName: styles.alertTextColor}];
                    NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString: title attributes: @{NSForegroundColorAttributeName: styles.alertTextColor}];

                    [alert setValue:attributedMessage forKey:@"attributedMessage"];
                    [alert setValue:attributedTitle forKey:@"attributedTitle"];

                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                                           style:UIAlertActionStyleCancel
                                                                         handler:^(UIAlertAction *action) {
                                                                             if ([viewController isKindOfClass:TTSDKLoginViewController.class]) {
                                                                                 if(completionBlock) {
                                                                                     completionBlock(res);
                                                                                 }

                                                                                 return;
                                                                             }

                                                                             [self launchAccountLink:viewController];
                                                                         }];

                    UIAlertAction * submitAction = [UIAlertAction actionWithTitle:@"SUBMIT"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              NSString *securityQuestionAnswer = [[alert textFields][0] text];
                                                                              [self answerSecurityQuestion:securityQuestionAnswer
                                                                                       withCompletionBlock:^(TradeItResult *result) {
                                                                                           [self authenticationRequestReceivedWithViewController:viewController
                                                                                                                             withCompletionBlock:completionBlock
                                                                                                                                       andResult:result];
                                                                                       }];
                                                                          }];

                    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {}];
                    [alert addAction:cancelAction];
                    [alert addAction:submitAction];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegateViewController presentViewController:alert
                                                             animated:YES
                                                           completion:nil];

                        alert.view.tintColor = styles.alertButtonColor;

                        UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
                        alertPresentationController.sourceView = viewController.view;
                        alertPresentationController.permittedArrowDirections = 0;
                        alertPresentationController.sourceRect = CGRectMake(viewController.view.bounds.size.width / 2.0,
                                                                            viewController.view.bounds.size.height / 2.0,
                                                                            1.0,
                                                                            1.0);
                    });
                }
            }
        }
    }
}

- (void)launchAccountLink:(UIViewController *)viewController {
    UIStoryboard *ticket = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
    UINavigationController * accountLinkNav = [ticket instantiateViewControllerWithIdentifier: kAccountLinkNavIdentifier];

    TTSDKAccountLinkViewController * accountLinkVC = (TTSDKAccountLinkViewController *)[accountLinkNav.viewControllers objectAtIndex:0];
    accountLinkVC.relinking = YES;

    [viewController presentViewController:accountLinkNav animated:YES completion:nil];
}

- (UIView *)createPickerView:(NSString *)title {
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];

    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 270, 20)];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont: [UIFont boldSystemFontOfSize:16.0f]];
    [titleLabel setNumberOfLines:0];
    [titleLabel setText: title];
    [contentView addSubview:titleLabel];

    UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 20, 270, 130)];
    currentPicker = picker;

    [picker setDataSource:self];
    [picker setDelegate:self];
    [picker setShowsSelectionIndicator:YES];

    [contentView addSubview: picker];
    [contentView setNeedsDisplay];

    return contentView;
}

- (void)showOldSecQuestion:(NSString *)question {
    UIAlertView * alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Security Question" message:question delegate: delegateViewController cancelButtonTitle:@"CANCEL" otherButtonTitles: @"SUBMIT", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)showOldMultiSelectWithViewController:(UIViewController *)viewController withCompletionBlock:(void (^)(TradeItResult *))completionBlock andSecurityQuestionResult:(TradeItSecurityQuestionResult *)securityQuestionResult {
    questionOptions = securityQuestionResult.securityQuestionOptions;
    currentSelection = questionOptions[0];
    
    TTSDKCustomIOSAlertView * alert = [[TTSDKCustomIOSAlertView alloc]init];
    [alert setContainerView:[self createPickerView: @"Security Question"]];
    [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"CANCEL",@"SUBMIT",nil]];
    
    [alert setOnButtonTouchUpInside:^(TTSDKCustomIOSAlertView *alertView, int buttonIndex) {
        if(buttonIndex == 0) {
            [delegateViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self answerSecurityQuestion: currentSelection withCompletionBlock:^(TradeItResult * result) {
                [self authenticationRequestReceivedWithViewController:viewController
                                                  withCompletionBlock:completionBlock
                                                            andResult:result];
            }];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

@end
