//
//  TTSDKAccountLinkViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/13/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountLinkViewController.h"
#import "TTSDKPortfolioService.h"
#import "TTSDKPortfolioAccount.h"
#import "TTSDKPrimaryButton.h"
#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKAlertController.h"
#import <TradeItIosAdSdk/TradeItIosAdSdk-Swift.h>

@interface TTSDKAccountLinkViewController () {
    TTSDKPortfolioService * portfolioService;
    BOOL noAccounts;
}
@property (weak, nonatomic) IBOutlet TTSDKPrimaryButton *addBrokerButton;
@property (weak, nonatomic) IBOutlet UITableView *linkTableView;
@property BOOL authenticated;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewHeightConstraint;
@property (weak, nonatomic) IBOutlet TradeItAdView *adView;

@end

@implementation TTSDKAccountLinkViewController

static NSString * kBrokerSelectViewIdentifier = @"BROKER_SELECT";
static NSString * kLoginSegueIdentifier = @"AccountLinkToLogin";

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
    [super viewDidLoad];

    [self.addBrokerButton activate];

    UITapGestureRecognizer * addBrokerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBrokerButtonPressed:)];
    [self.addBrokerButton addGestureRecognizer: addBrokerTap];

    [self initializeAd];
}

- (void)initializeAd {
    [self.adView configureWithAdType:@"account"
                    broker: self.ticket.currentSession.broker ?: nil
                    heightConstraint:self.adViewHeightConstraint];
}

-(void) setViewStyles {
    [super setViewStyles];

    if (self.pushed) {
        [self.doneBarButton setTintColor:[UIColor clearColor]];
    }

    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = self.styles.secondaryDarkActiveColor;
    self.doneButton.layer.cornerRadius = 5.0f;
}

-(void) viewWillAppear:(BOOL)animated {
    portfolioService = [TTSDKPortfolioService serviceForAllAccounts];

    [self.linkTableView reloadData];

    if (self.relinking) {
        [self loadBalances];
    } else {
        if (self.ticket.currentSession && !self.ticket.currentSession.isAuthenticated) {
            
            [self authenticate:^(TradeItResult * res) {
                [self loadBalances];
            }];
            
        } else {
            [self loadBalances];
        }
    }
}

-(void) loadBalances {
    [portfolioService getBalancesForAccounts:^(void) {
        [self.linkTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}


#pragma mark Table Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return portfolioService.accounts.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"AccountLink";
    TTSDKAccountLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];

        [tableView registerNib:[UINib nibWithNibName:@"TTSDKAccountLinkCell" bundle:resourceBundle] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }

    [cell setDelegate: self];

    TTSDKPortfolioAccount * account = [portfolioService.accounts objectAtIndex: indexPath.row];
    [cell configureCellWithAccount: account];

    if (self.relinking) {
        if ([self.ticket isAccountCurrentAccount:[account accountData]] && !self.ticket.currentSession.isAuthenticated) {
            [cell setBalanceNil];
        }
    }

    return cell;
}


#pragma mark Custom Delegate Methods

-(void) linkToggleDidSelect:(UISwitch *)toggle forAccount:(TTSDKPortfolioAccount *)account {
    // Unlinking account, so check whether it's the last account for a login
    BOOL isUnlinkingBroker = NO;

    if (!toggle.on) {
        int accountsToUnlink = 0;

        for (TTSDKPortfolioAccount * portfolioAccount in portfolioService.accounts) {
            if ([portfolioAccount.userId isEqualToString: account.userId] && portfolioAccount.active) {
                accountsToUnlink++;
            }
        }

        isUnlinkingBroker = accountsToUnlink < 2;
    }

    if (isUnlinkingBroker) {
        // This is a bit weird, but prevents unnecessary complexity for showing alerts
        TradeItErrorResult * error = [[TradeItErrorResult alloc] init];
        error.shortMessage = [NSString stringWithFormat:@"Unlink %@", account.broker];
        error.longMessages = @[ [NSString stringWithFormat:@"Deselecting all the accounts for %@ will automatically delete this broker and its associated data. ", account.broker], @"Tap \"Add Broker\" to bring it back"];

        // Prompt the user to either login or cancel the unlink action
        [self showErrorAlert:error onAccept:^(void) {
            [self toggleAccount: account];

            TTSDKTicketSession * sessionToDelete = [self.ticket retrieveSessionByAccount:[account accountData]];

            [portfolioService deleteAccounts: account.userId session: sessionToDelete];

            [self.linkTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

            if ([portfolioService linkedAccountsCount] < 1) {
                noAccounts = YES;
                self.ticket.sessions = [[NSArray alloc] init]; // reset the sessions
                [self performSegueWithIdentifier:kLoginSegueIdentifier sender:self];
            }

            // Check to see if we're unlinking the current account. If so, auto-select another account
            if ([self.ticket isAccountCurrentAccount:[account accountData]]) {
                [self autoSelectNewAccount];
            }

        } onCancel:^(void) {
            toggle.on = YES;
        }];
    } else {
        [self toggleAccount: account];

        // Check to see if we're unlinking the current account. If so, auto-select another account
        if ([self.ticket isAccountCurrentAccount:[account accountData]]) {
            [self autoSelectNewAccount];
        }
    }
}

-(void) autoSelectNewAccount {
    self.relinking = NO;

    TTSDKPortfolioAccount * newSelectedAccount = [portfolioService retrieveAutoSelectedAccount];

    NSDictionary * newAcctData = [newSelectedAccount accountData];
    if (![newSelectedAccount.userId isEqualToString:self.ticket.currentSession.login.userId]) {
        [self.ticket selectCurrentSession:[self.ticket retrieveSessionByAccount: newAcctData] andAccount:newAcctData];
    } else {
        [self.ticket selectCurrentAccount: newAcctData];
    }
}

-(void) toggleAccount:(TTSDKPortfolioAccount *)account {
    [portfolioService toggleAccount: account];
}

-(void) linkToggleDidNotSelect:(NSString *)errorMessage {
    NSString * errorTitle = @"Unable to unlink account";
    if(![UIAlertController class]) {
        [self showOldErrorAlert: errorTitle withMessage:errorMessage];
    } else {
         TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle: errorTitle
                                                                        message: errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];

        alert.modalPresentationStyle = UIModalPresentationPopover;

        NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:errorMessage attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
        NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:errorTitle attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

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


#pragma mark Navigation

-(IBAction) addBrokerButtonPressed:(id)sender {
    [self performSegueWithIdentifier:kLoginSegueIdentifier sender:self];
}

-(IBAction) donePressed:(id)sender {
    if (self.relinking || self.ticket.presentationMode == TradeItPresentationModeAccounts) {
        
        if (self.relinking) {
            if (self.ticket.currentSession.isAuthenticated) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }

            self.ticket.sessions = nil;
        }

        [self.ticket returnToParentApp];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction) doneBarButtonPressed:(id)sender {
    if (self.relinking || self.ticket.presentationMode == TradeItPresentationModeAccounts) {

        if (self.relinking) {
            if (self.ticket.currentSession.isAuthenticated) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }

            self.ticket.sessions = nil;
        }

        [self.ticket returnToParentApp];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:kLoginSegueIdentifier]) {
        UINavigationController * nav = (UINavigationController *)segue.destinationViewController;
        TTSDKBrokerSelectViewController * brokerSelect = (TTSDKBrokerSelectViewController *) [nav.viewControllers objectAtIndex:0];
        brokerSelect.isModal = YES;
        if (noAccounts) {
            brokerSelect.cancelToParent = YES;
        }
    }
}


@end
