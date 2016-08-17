//
//  TTSDKLoginViewController.m
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 7/21/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKLoginViewController.h"
#import <TradeItIosEmsApi/TradeItErrorResult.h>
#import <TradeItIosEmsApi/TradeItAuthLinkResult.h>
#import <TradeItIosEmsApi/TradeItAuthenticationResult.h>
#import <TradeItIosEmsApi/TradeItSecurityQuestionResult.h>
#import "TTSDKCustomIOSAlertView.h"
#import "TTSDKPrimaryButton.h"
#import "TTSDKTradeViewController.h"
#import "TTSDKNavigationController.h"
#import "TTSDKPortfolioService.h"
#import "TTSDKAlertController.h"


@implementation TTSDKLoginViewController {
    __weak IBOutlet UILabel *pageTitle;
    __weak IBOutlet UITextField *emailInput;
    __weak IBOutlet UITextField *passwordInput;
    __weak IBOutlet TTSDKPrimaryButton *linkAccountButton;
    __weak IBOutlet NSLayoutConstraint *linkAccountCenterLineConstraint;
    __weak IBOutlet NSLayoutConstraint *loginButtonBottomConstraint;
    __weak IBOutlet UIImageView *lock;

    UIPickerView * currentPicker;
    NSDictionary * currentAccount;
    NSArray * multiAccounts;
    NSString * selectedBroker;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add a "textFieldDidChange" notification method to the text field control.
    [emailInput addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    [passwordInput addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];

    selectedBroker = (self.addBroker == nil) ? self.ticket.currentSession.broker : self.addBroker;

    if (self.cancelToParent || self.reAuthenticate) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationController.navigationItem.hidesBackButton = YES;

        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(home:)];
        self.navigationItem.rightBarButtonItem = closeButton;
    }

    // Listen for keyboard appearances and disappearances
    if (![self.utils isSmallScreen]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }

    [pageTitle setText:[NSString stringWithFormat:@"Log in to %@", [self.ticket getBrokerDisplayString:selectedBroker]]];

    [emailInput setDelegate:self];
    [passwordInput setDelegate:self];

    emailInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.utils getBrokerUsername: selectedBroker] attributes: @{NSForegroundColorAttributeName: self.styles.primaryPlaceholderColor}];
    passwordInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Broker password" attributes: @{NSForegroundColorAttributeName: self.styles.primaryPlaceholderColor}];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    [linkAccountButton deactivate];
}

- (void)setViewStyles {
    [super setViewStyles];

    emailInput.layer.borderColor = self.styles.inactiveColor.CGColor;
    emailInput.layer.borderWidth = 1.0f;
    emailInput.layer.shadowOpacity = 0.0f;
    emailInput.tintColor = self.styles.primaryTextColor;

    passwordInput.layer.borderColor = self.styles.inactiveColor.CGColor;
    passwordInput.layer.borderWidth = 1.0f;
    passwordInput.layer.shadowOpacity = 0.0f;
    passwordInput.tintColor = self.styles.primaryTextColor;

    UIImage * lockImage = [lock.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [lock setTintColor:self.styles.primaryTextColor];
    lock.image = lockImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self checkAuthState];

    if(self.ticket.errorTitle) {
        if(![UIAlertController class]) {
            [self showOldErrorAlert:self.ticket.errorTitle withMessage:self.ticket.errorMessage];
        } else {
             TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:self.ticket.errorTitle
                                                                            message:self.ticket.errorMessage
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            alert.modalPresentationStyle = UIModalPresentationPopover;

            NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:self.ticket.errorMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
            NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:self.ticket.errorTitle attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
            
            [alert setValue:attributedMessage forKey:@"attributedMessage"];
            [alert setValue:attributedTitle forKey:@"attributedTitle"];

            UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

            alert.view.tintColor = self.styles.alertButtonColor;

            UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
            alertPresentationController.sourceView = self.view;
            alertPresentationController.permittedArrowDirections = 0;
            alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
        }
    }

    self.ticket.errorMessage = nil;
    self.ticket.errorTitle = nil;

    [emailInput becomeFirstResponder];
}

- (void)dismissKeyboard {
    if (emailInput.isFirstResponder) {
        [emailInput resignFirstResponder];
    }
    
    if (passwordInput.isFirstResponder) {
        [passwordInput resignFirstResponder];
    }
}


#pragma mark - Authentication

- (void)checkAuthState {
    if(self.ticket.brokerSignUpComplete) {
        TradeItAuthControllerResult * res = [[TradeItAuthControllerResult alloc] init];
        res.success = true;

        if (self.ticket.brokerSignUpCallback) {
            self.ticket.brokerSignUpCallback(res);
        }

        return;
    }
}

- (IBAction)linkAccountPressed:(id)sender {
    if(emailInput.text.length < 1 || passwordInput.text.length < 1) {
        NSString * message = [NSString stringWithFormat:@"Please enter a %@ and password.",  [self.utils getBrokerUsername: self.ticket.currentSession.broker]];

        if(![UIAlertController class]) {
            [self showOldErrorAlert:@"Invalid Credentials" withMessage:message];
        } else {
            TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:@"Invalid Credentials"
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            alert.modalPresentationStyle = UIModalPresentationPopover;

            NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString: message attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
            NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString: @"Invalid Credentials" attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

            [alert setValue:attributedMessage forKey:@"attributedMessage"];
            [alert setValue:attributedTitle forKey:@"attributedTitle"];

            UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

            alert.view.tintColor = self.styles.alertButtonColor;

            UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
            alertPresentationController.sourceView = self.view;
            alertPresentationController.permittedArrowDirections = 0;
            alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
        }

    } else {
        [linkAccountButton enterLoadingState];

        [self authenticate];
    }
}

- (void)authenticate {
    selectedBroker = self.addBroker == nil ? self.ticket.currentSession.broker : self.addBroker;

    self.verifyCreds = [[TradeItAuthenticationInfo alloc] initWithId:emailInput.text andPassword:passwordInput.text andBroker:selectedBroker];

    [self.ticket.connector linkBrokerWithAuthenticationInfo:self.verifyCreds andCompletionBlock:^(TradeItResult * res){
        if ([res isKindOfClass:TradeItErrorResult.class]) {

            TradeItErrorResult * error = (TradeItErrorResult *)res;

            NSMutableString * errorMessage = [[NSMutableString alloc] initWithString:@""];

            for (NSString * message in error.longMessages) {
                [errorMessage appendString: message];
            }

            self.ticket.errorTitle = error.shortMessage;
            self.ticket.errorMessage = [errorMessage copy];

            [self showErrorAlert:error onAccept:^(void) {
                // do nothing
            }];

            self.ticket.errorMessage = nil;
            self.ticket.errorTitle = nil;

            [self dismissKeyboard];

            [linkAccountButton exitLoadingState];
            [linkAccountButton activate];
        } else {
            TradeItAuthLinkResult * result = (TradeItAuthLinkResult*)res;
            TradeItLinkedLogin * newLinkedLogin = [self.ticket.connector saveLinkToKeychain: result withBroker:self.verifyCreds.broker];
            TTSDKTicketSession * newSession = [[TTSDKTicketSession alloc] initWithConnector:self.ticket.connector andLinkedLogin:newLinkedLogin andBroker:self.verifyCreds.broker];

            [newSession authenticateFromViewController:self withCompletionBlock:^(TradeItResult * result) {
                [self dismissKeyboard];

                [linkAccountButton exitLoadingState];
                [linkAccountButton activate];

                if ([result isKindOfClass:TradeItErrorResult.class]) {
                    self.ticket.resultContainer.status = AUTHENTICATION_ERROR;

                    if(self.ticket.brokerSignUpCallback) {
                        TradeItAuthControllerResult * res = [[TradeItAuthControllerResult alloc] initWithResult: result];
                        self.ticket.brokerSignUpCallback(res);
                    }

                    TradeItErrorResult * error = (TradeItErrorResult *)result;

                    [self showErrorAlert:error onAccept:^(void) {
                        if (self.cancelToParent) {
                            [self.ticket returnToParentApp];
                        } else if (self.isModal) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } else if (self.navigationController) {
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self.ticket returnToParentApp];
                        }
                    }];

                } else if ([result isKindOfClass:TradeItAuthenticationResult.class]) {

                    TradeItAuthenticationResult * authResult = (TradeItAuthenticationResult *)result;

                    if ([self.ticket checkIsAuthenticationDuplicate: authResult.accounts]) {
                        [self.ticket replaceAccountsWithNewAccounts: authResult.accounts];
                    }

                    [self.ticket addSession: newSession];
                    [self.ticket addAccounts: authResult.accounts withSession: newSession];

                    NSArray * newLinkedAccounts = [TTSDKPortfolioService linkedAccounts];

                    if (!self.reAuthenticate && newLinkedAccounts.count > 1 && (self.ticket.presentationMode != TradeItPresentationModeAuth && self.ticket.presentationMode != TradeItPresentationModeAccounts)) {

                        multiAccounts = [self buildAccountOptions: newLinkedAccounts];
                        [self showPicker:@"Select account to trade it" withSelection:nil andOptions:multiAccounts onSelection:^(void) {
                            NSDictionary * selectedAccount;
                            for (NSDictionary *newLinkedAccount in newLinkedAccounts) {
                                if ([[newLinkedAccount valueForKey:@"accountNumber"] isEqualToString: self.currentSelection]) {
                                    selectedAccount = newLinkedAccount;
                                }
                            }

                            TTSDKTicketSession * selectedSession = [self.ticket retrieveSessionByAccount: selectedAccount];

                            [self.ticket selectCurrentSession:selectedSession andAccount:selectedAccount];

                            [self completeAuthenticationAndClose: authResult account: authResult.accounts session: newSession];
                        }];

                    } else {
                        [self completeAuthenticationAndClose: authResult account: authResult.accounts session: newSession];
                    }
                }
            }];
        }
    }];
}

- (void)completeAuthenticationAndClose:(TradeItAuthenticationResult *)result
                               account:(NSArray *)accounts
                               session:(TTSDKTicketSession *)session {
    // TODO - refactor to avoid duplication
    if (self.ticket.presentationMode == TradeItPresentationModeAuth) {
        // auto-select account. this does nothing but ensure the user always has a lastSelectedAccount
        [self autoSelectAccount: [accounts lastObject] withSession:session];
        self.ticket.resultContainer.status = AUTHENTICATION_SUCCESS;

        [self.ticket returnToParentApp];

        if(self.ticket.brokerSignUpCallback) {
            TradeItAuthControllerResult * res = [[TradeItAuthControllerResult alloc] initWithResult:result];
            self.ticket.brokerSignUpCallback(res);
        }
    } else if (self.isModal) {
        if (!multiAccounts) {
            [self autoSelectAccount: [accounts lastObject] withSession:session];
        }

        [self dismissViewControllerAnimated:YES completion:^(void){
            if(self.onCompletion) {
                self.onCompletion(result);
            }
        }];
    } else {
        [self autoSelectAccount: [accounts lastObject] withSession:session];

        if (self.ticket.presentationMode == TradeItPresentationModePortfolio && self.ticket.presentationMode == TradeItPresentationModePortfolioOnly) {
            [self performSegueWithIdentifier: @"LoginToPortfolioNav" sender: self];
        } else if (self.ticket.presentationMode == TradeItPresentationModeTrade || self.ticket.presentationMode == TradeItPresentationModeTradeOnly) {
            [self performSegueWithIdentifier: @"LoginToTradeNav" sender: self];
        } else if (self.ticket.presentationMode == TradeItPresentationModeAccounts) {
            [self performSegueWithIdentifier:@"LoginToAccountLink" sender:self];
        } else {
            [self performSegueWithIdentifier: @"LoginToTradeNav" sender: self];
        }
    }
}

- (void)autoSelectAccount:(NSDictionary *)account withSession:(TTSDKTicketSession *)session {
    NSDictionary * lastAccount = account;
    NSDictionary * selectedAccount;

    NSArray * allAccounts = [TTSDKPortfolioService allAccounts];
    for (NSDictionary *account in allAccounts) {
        if ([[lastAccount valueForKey:@"accountNumber"] isEqualToString:[account valueForKey:@"accountNumber"]]) {
            selectedAccount = account;
        }
    }

    [self.ticket selectCurrentSession:session andAccount:selectedAccount];
}

- (NSArray *)buildAccountOptions:(NSArray *)accounts {
    NSMutableArray * multiAccountsArray = [[NSMutableArray alloc] init];

    for (NSDictionary * acct in accounts) {
        NSString * accountNumber = [acct valueForKey:@"accountNumber"];
        NSString * displayTitle = [NSString stringWithFormat:@"%@*%@",
                                   [acct valueForKey:@"broker"],
                                   [accountNumber substringFromIndex:accountNumber.length - 4]
                                   ];

        NSDictionary * option = @{displayTitle: accountNumber};

        [multiAccountsArray addObject:option];
    }

    return [multiAccountsArray copy];
}

#pragma mark - Text Editing Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(emailInput.text.length >= 1 && passwordInput.text.length >= 1) {
        [linkAccountButton activate];
    } else {
        [linkAccountButton deactivate];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(emailInput.text.length < 1) {
        [emailInput becomeFirstResponder];
    } else if(passwordInput.text.length < 1) {
        [passwordInput becomeFirstResponder];
    } else {
        [self linkAccountPressed:self];
    }

    return YES;
}

- (void)keyboardDidShow: (NSNotification *) notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

    loginButtonBottomConstraint.constant = keyboardFrameBeginRect.size.height + 20.0f;
}

- (void)keyboardDidHide: (NSNotification *) notification {
    loginButtonBottomConstraint.constant = 20.0f;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if(emailInput.text.length >= 1 && passwordInput.text.length >= 1) {
        [linkAccountButton activate];
    } else {
        [linkAccountButton deactivate];
    }
}


#pragma mark - Navigation

- (void)home:(UIBarButtonItem *)sender {
    if (self.cancelToParent) {
        [self.ticket returnToParentApp];
    } else if (self.isModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.ticket returnToParentApp];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"LoginToAccountSelect"]) {
        UINavigationController * nav = (UINavigationController *)[segue destinationViewController];
        [self.ticket configureAccountLinkNavController: nav];
    }
}


#pragma mark - iOS7 fallback

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // nothing to do
}


@end
