//
//  TTSDKViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/6/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKViewController.h"
#import "TTSDKLoginViewController.h"
#import "TTSDKAlertController.h"
#import "TTSDKAccountLinkViewController.h"

@interface TTSDKViewController()
    @property (copy) void (^acceptanceBlock)();
    @property (copy) void (^cancellationBlock)();
@end

@implementation TTSDKViewController

static NSString * kLoginNavIdentifier = @"AUTH_NAV";
static NSString * kAccountLinkNavIdentifier = @"ACCOUNT_LINK_NAV";

#pragma mark Rotation

-(BOOL) shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark Initialization

-(void) viewDidLoad {
    self.ticket = [TTSDKTradeItTicket globalTicket];
    self.utils = [TTSDKUtils sharedUtils];
    self.styles = [TradeItStyles sharedStyles];

    [super viewDidLoad];

    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];

    [self setViewStyles];
}

-(void) setViewStyles {
    self.view.backgroundColor = self.styles.pageBackgroundColor;

    if (self.styles.navigationBarTitleColor) {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.styles.navigationBarTitleColor}];
    }

    self.navigationController.navigationBar.barTintColor = self.styles.navigationBarBackgroundColor;
    self.navigationController.navigationBar.tintColor = self.styles.activeColor;
    self.navigationController.navigationItem.leftBarButtonItem.tintColor = self.styles.activeColor;
    self.navigationController.navigationItem.rightBarButtonItem.tintColor = self.styles.activeColor;
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    self.styles = [TradeItStyles sharedStyles];
    
    return self.styles.statusBarStyle;
}

-(void) authenticate:(void (^)(TradeItResult * resultToReturn)) completionBlock {
    [self authenticateSession:self.ticket.currentSession cancelToParent:NO broker:NULL withCompletionBlock:completionBlock];
}

-(void) authenticateSession:(TTSDKTicketSession *) session cancelToParent:(BOOL) cancelToParent broker:(NSString *) broker withCompletionBlock:(void (^)(TradeItResult *))completionBlock {

    [session authenticateFromViewController:self withCompletionBlock:^(TradeItResult * res) {
        self.navigationItem.leftBarButtonItem.enabled = YES; // sometimes we need to disable the portfolio link during authentication, so unset it
        

        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        if ([res isKindOfClass:TradeItAuthenticationResult.class]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(res);
                }
            });
        } else if ([res isKindOfClass:TradeItErrorResult.class]) {
            TradeItErrorResult * error = (TradeItErrorResult *)res;
            NSMutableString * errorMessage = [[NSMutableString alloc] init];
            
            for (NSString * str in error.longMessages) {
                [errorMessage appendString:str];
            }
            
            if(![UIAlertController class]) {
                [self showOldErrorAlert:error.shortMessage withMessage:errorMessage];
            } else {
                TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:error.shortMessage
                                                                                message:errorMessage
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                alert.modalPresentationStyle = UIModalPresentationPopover;

                NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:errorMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
                NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:error.shortMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
                
                [alert setValue:attributedMessage forKey:@"attributedMessage"];
                [alert setValue:attributedTitle forKey:@"attributedTitle"];

                UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           UIStoryboard *ticket =[[TTSDKTradeItTicket globalTicket] getTicketStoryboard];

                                                                           UINavigationController * loginNav = [ticket instantiateViewControllerWithIdentifier: kLoginNavIdentifier];
                                                                           [self.ticket removeBrokerSelectFromNav: loginNav cancelToParent:cancelToParent];

                                                                           TTSDKLoginViewController * login = (TTSDKLoginViewController *)[loginNav.viewControllers lastObject];
                                                                           login.addBroker = broker;
                                                                           login.reAuthenticate = YES;
                                                                           login.isModal = YES;
                                                                           login.onCompletion = completionBlock;

                                                                           [self presentViewController:loginNav animated:YES completion:nil];
                                                                       }];

                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                    if (cancelToParent) {
                        [self.ticket returnToParentApp];
                    } else {
                        [self launchAccountLink];
                    }
                }];

                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                
                [self presentViewController:alert animated:YES completion:nil];

                [self.utils styleAlertController:alert.view];

                UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
                alertPresentationController.sourceView = self.view;
                alertPresentationController.permittedArrowDirections = 0;
                alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
            }
        }
    }];
}

-(void) launchAccountLink {
    UIStoryboard *ticket = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
    UINavigationController * accountLinkNav = [ticket instantiateViewControllerWithIdentifier: kAccountLinkNavIdentifier];

    TTSDKAccountLinkViewController * accountLinkVC = (TTSDKAccountLinkViewController *)[accountLinkNav.viewControllers objectAtIndex:0];
    accountLinkVC.relinking = YES;

    [self presentViewController:accountLinkNav animated:YES completion:nil];
}

#pragma mark Picker

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerTitles.count;
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerTitles[row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentSelection = self.pickerValues[row];
}

-(void) showPicker:(NSString *)pickerTitle withSelection:(NSString *)selection andOptions:(NSArray *)options onSelection:(void (^)(void))selectionBlock {
    self.currentSelection = selection;

    if(![UIAlertController class]) {
        NSMutableArray * titles = [[NSMutableArray alloc] init];
        NSMutableArray * values = [[NSMutableArray alloc] init];

        for (NSDictionary *optionContainer in options) {
            NSString * k = [optionContainer.allKeys firstObject];
            NSString * v = optionContainer[k];
            [titles addObject: k];
            [values addObject: v];
        }

        self.pickerTitles = [titles copy];
        self.pickerValues = [values copy];

        TTSDKCustomIOSAlertView * alert = [[TTSDKCustomIOSAlertView alloc]init];
        [alert setContainerView:[self createPickerView: pickerTitle]];
        [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"CANCEL",@"SELECT",nil]];
        
        [alert setOnButtonTouchUpInside:^(TTSDKCustomIOSAlertView *alertView, int buttonIndex) {
            if(buttonIndex == 1) {
                selectionBlock();
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    } else {
        TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:pickerTitle
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
        alert.modalPresentationStyle = UIModalPresentationPopover;

        NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:pickerTitle attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
        [alert setValue:attributedTitle forKey:@"attributedTitle"];

        for (NSDictionary *optionContainer in options) {
            NSString * k = [optionContainer.allKeys firstObject];
            NSString * v = optionContainer[k];

            UIAlertAction * action = [UIAlertAction actionWithTitle:k style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                self.currentSelection = v;
                selectionBlock();
            }];

            [alert addAction: action];
        }

        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            // do nothing
        }];
        [alert addAction: cancelAction];

        [self presentViewController:alert animated:YES completion:nil];

        [self.utils styleAlertController:alert.view];

        UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
        alertPresentationController.sourceView = self.view;
        alertPresentationController.permittedArrowDirections = 0;
        alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
}

-(UIView *) createPickerView: (NSString *) title {
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 270, 20)];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont: [UIFont boldSystemFontOfSize:16.0f]];
    [titleLabel setNumberOfLines:0];
    [titleLabel setText: title];
    [contentView addSubview:titleLabel];
    
    UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 20, 270, 130)];
    self.currentPicker = picker;
    
    [picker setDataSource: self];
    [picker setDelegate: self];
    picker.showsSelectionIndicator = YES;
    [contentView addSubview:picker];
    
    [contentView setNeedsDisplay];
    return contentView;
}


#pragma mark Alert Delegate Methods

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (self.acceptanceBlock) {
            self.acceptanceBlock();
        }
    } else {
        if (self.cancellationBlock) {
            self.cancellationBlock();
        }
    }
}


#pragma mark iOS7 fallbacks

-(void) showErrorAlert:(TradeItErrorResult *)error onAccept:(void (^)(void))acceptanceBlock {
    [self showErrorAlert:error onAccept:acceptanceBlock onCancel:nil];
}

-(void) showErrorAlert:(TradeItErrorResult *)error onAccept:(void (^)(void))acceptanceBlock onCancel:(void (^)(void))cancellationBlock {
    NSMutableString * errorMessage = [[NSMutableString alloc] init];
    
    for (NSString * str in error.longMessages) {
        [errorMessage appendString:str];
    }

    self.acceptanceBlock = acceptanceBlock;

    self.cancellationBlock = nil; // we should reset the cancel block each time a new alert is created
    if (cancellationBlock) {
        self.cancellationBlock = cancellationBlock;
    }

    if(![UIAlertController class]) {
        [self showOldErrorAlert:error.shortMessage withMessage:errorMessage];
    } else {

        TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:error.shortMessage
                                                                        message:errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];

        alert.modalPresentationStyle = UIModalPresentationPopover;

        NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:errorMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
        NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:error.shortMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

        [alert setValue:attributedMessage forKey:@"attributedMessage"];
        [alert setValue:attributedTitle forKey:@"attributedTitle"];

        UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   self.acceptanceBlock();
                                                               }];

        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            if (self.cancellationBlock) {
                self.cancellationBlock();
            }
        }];

        [alert addAction:defaultAction];
        [alert addAction:cancelAction];

        [self presentViewController:alert animated:YES completion:nil];

        [self.utils styleAlertController:alert.view];

        UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
        alertPresentationController.sourceView = self.view;
        alertPresentationController.permittedArrowDirections = 0;
        alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
}

-(void) showOldErrorAlert: (NSString *) title withMessage:(NSString *) message {
    UIAlertView * alert;

    alert = [[UIAlertView alloc] initWithTitle:title
                            message:message
                            delegate:self
                             cancelButtonTitle:@"OK" otherButtonTitles: nil];

    if (self.cancellationBlock) {
        [alert addButtonWithTitle: @"Cancel"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.ticket.lastUsed = [NSDate date];
}


@end
