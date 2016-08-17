//
//  BaseCalculatorViewController.m
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 8/2/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKBaseTradeViewController.h"
#import <TradeItIosEmsApi/TradeItTradeService.h>
#import <TradeItIosEmsApi/TradeItMarketDataService.h>
#import <TradeItIosEmsApi/TradeItQuotesResult.h>
#import "TTSDKAlertController.h"

@interface TTSDKBaseTradeViewController()

@property NSTimer * quoteTimer;

@end

@implementation TTSDKBaseTradeViewController


static NSString * kLoginSegueIdentifier = @"TradeToLogin";


#pragma mark Initialization

-(void) viewDidLoad {
    [super viewDidLoad];
}

-(void) waitForQuotes {
    self.quoteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkQuotes:) userInfo:nil repeats:YES];
}

-(void) checkQuotes:(id)sender {
    if (!self.ticket.loadingQuote) {
        [self populateSymbolDetails];
        [self.quoteTimer invalidate];
    }
}

-(void) checkIfReadyToTrade {
    // implement in subclass
}


#pragma mark Authentication

-(void) authenticate {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [self authenticate:^(TradeItResult * res) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        [self retrieveAccountSummaryData];
        [self checkIfReadyToTrade];
    }];
}


#pragma mark Order

-(void) retrieveQuoteData {
    [self.ticket retrieveQuote:^(void) {
        [self populateSymbolDetails];
    }];

    [self populateSymbolDetails];
}

-(void) retrieveAccountSummaryData {
    self.currentPortfolioAccount = [[TTSDKPortfolioAccount alloc] initWithAccountData: self.ticket.currentAccount];

    [self.currentPortfolioAccount retrieveAccountSummaryWithCompletionBlock:^(void){
        [self performSelectorOnMainThread:@selector(populateSymbolDetails) withObject:nil waitUntilDone:NO];

        if (self.ticket.currentSession.needsAuthentication) {
            [self authenticate];
        }
    }];
}

-(void) populateSymbolDetails {
    // Implement me in subclass
}

-(void) changeOrderAction: (NSString *) action {
    // Implement me in subclass
}

-(void) changeOrderExpiration: (NSString *) exp {
    // Implement me in subclass
}

-(void) acknowledgeAlert {
    // implement in sub class
}

-(void) sendPreviewRequestWithCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    [self.ticket.currentSession previewTrade:self.ticket.previewRequest withCompletionBlock:^(TradeItResult * res){
        if ([res isKindOfClass:TradeItPreviewTradeResult.class]) {
            self.ticket.resultContainer.status = USER_CANCELED;
            self.ticket.resultContainer.reviewResponse = (TradeItPreviewTradeResult *)res;

            [self performSegueWithIdentifier:@"TradeToReview" sender:self];
        } else if([res isKindOfClass:[TradeItErrorResult class]]){
            NSString * errorMessage = @"Could Not Complete Your Order";
            TradeItErrorResult * error = (TradeItErrorResult *)res;

            if(error.errorFields.count > 0) {
                NSString * errorField = (NSString *) error.errorFields[0];
                if([errorField isEqualToString:@"authenticationInfo"]) {
                    errorMessage = error.longMessages.count > 0 ? [[error longMessages] componentsJoinedByString:@" "] : errorMessage;
                    
                    self.ticket.resultContainer.status = AUTHENTICATION_ERROR;
                    self.ticket.resultContainer.errorResponse = error;
                } else {
                    errorMessage = error.longMessages.count > 0 ? [[error longMessages] componentsJoinedByString:@" "] : errorMessage;
                }
            } else if (error.longMessages.count > 0) {
                errorMessage = error.longMessages.count > 0 ? [[error longMessages] componentsJoinedByString:@" "] : errorMessage;
            }

            if(![UIAlertController class]) {
                [self showOldErrorAlert:@"Could Not Complete Order" withMessage:errorMessage];
            } else {
                TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:@"Could Not Complete Order"
                                                                                message:errorMessage
                                                                         preferredStyle:UIAlertControllerStyleAlert];

                alert.modalPresentationStyle = UIModalPresentationPopover;

                NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:errorMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
                NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:@"Could Not Complete Order" attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

                [alert setValue:attributedMessage forKey:@"attributedMessage"];
                [alert setValue:attributedTitle forKey:@"attributedTitle"];

                UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           [self acknowledgeAlert];
                                                                       }];
                [alert addAction:defaultAction];

                [self presentViewController:alert animated:YES completion:nil];

                alert.view.tintColor = self.styles.alertButtonColor;

                UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
                alertPresentationController.sourceView = self.view;
                alertPresentationController.permittedArrowDirections = 0;
                alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
            }
        } else {
            if(![UIAlertController class]) {
                [self showOldErrorAlert:@"Could Not Complete Order" withMessage:@"TradeIt is temporarily unavailable. Please try again in a few minutes."];
            } else {
                TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:@"Could Not Complete Order"
                                                                                message:@"TradeIt is temporarily unavailable. Please try again in a few minutes."
                                                                         preferredStyle:UIAlertControllerStyleAlert];

                alert.modalPresentationStyle = UIModalPresentationPopover;

                NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:@"TradeIt is temporarily unavailable. Please try again in a few minutes." attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
                NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:@"Could Not Complete Order" attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

                [alert setValue:attributedMessage forKey:@"attributedMessage"];
                [alert setValue:attributedTitle forKey:@"attributedTitle"];

                UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           [self acknowledgeAlert];
                                                                       }];
                [alert addAction:defaultAction];

                [self presentViewController:alert animated:YES completion:nil];

                alert.view.tintColor = self.styles.alertButtonColor;

                UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
                alertPresentationController.sourceView = self.view;
                alertPresentationController.permittedArrowDirections = 0;
                alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
            }
        }

        if (completionBlock) {
            completionBlock(res);
        }
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if([segue.identifier isEqualToString:kLoginSegueIdentifier]) {
        UINavigationController * dest = (UINavigationController *)segue.destinationViewController;
        [self.ticket removeBrokerSelectFromNav: dest cancelToParent: YES];
    }
}


@end
