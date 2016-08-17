//
//  TTSDKPortfolioViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/5/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPortfolioViewController.h"
#import "TTSDKPortfolioService.h"
#import <TradeItIosEmsApi/TradeItAuthenticationResult.h>
#import "TTSDKAccountsHeaderView.h"
#import "TTSDKHoldingsHeaderView.h"
#import "TTSDKLoginViewController.h"
#import <TradeItIosEmsApi/TradeItQuotesResult.h>
#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKTradeViewController.h"
#import "TTSDKAlertController.h"
#import <TradeItIosAdSdk/TradeItIosAdSdk-Swift.h>

@interface TTSDKPortfolioViewController () {
    TTSDKPortfolioService * portfolioService;
    TTSDKUtils * utils;
    NSArray * accountsHolder;
    NSArray * positionsHolder;
    BOOL initialAuthenticationComplete;
    BOOL initialSummaryComplete;
    NSString * addBroker;
}

@property (weak, nonatomic) IBOutlet UITableView *accountsTable;
@property NSInteger selectedHoldingIndex;
@property NSInteger selectedAccountIndex;
@property TTSDKAccountsHeaderView * accountsHeaderNib;
@property TTSDKHoldingsHeaderView * holdingsHeaderNib;
@property NSString * holdingsHeaderTitle;
@property UIView * accountsFooterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewHeightConstraint;
@property (weak, nonatomic) IBOutlet TradeItAdView *adView;

@end

@implementation TTSDKPortfolioViewController


#pragma mark Constants

static float kAccountsHeaderHeight = 135.0f;
static float kHoldingsHeaderHeight = 65.0f;
static float kAccountsFooterHeight = 15.0f;
static float kHoldingCellDefaultHeight = 44.0f;
static float kHoldingCellExpandedHeight = 164.0f;
static float kAccountCellHeight = 44.0f;
static NSString * kPortfolioToLoginSegueIdentifier = @"PortfolioToLogin";


#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    accountsHolder = [[NSArray alloc] init];
    positionsHolder = [[NSArray alloc] init];

    self.holdingsHeaderTitle = @"My Holdings";
    self.selectedHoldingIndex = -1;

    if (!self.ticket.currentSession.isAuthenticated) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    utils = [TTSDKUtils sharedUtils];
    [self.accountsTable reloadData];

    NSArray * linkedAccounts = [TTSDKPortfolioService linkedAccounts];

    if (self.ticket.clearPortfolioCache || !portfolioService || (linkedAccounts.count != portfolioService.accounts.count)) {
        portfolioService = nil;
        portfolioService = [[TTSDKPortfolioService alloc] initWithAccounts: linkedAccounts];
        self.ticket.clearPortfolioCache = NO;
    }

    if ((!self.ticket.currentSession.isAuthenticated || self.ticket.currentSession.needsAuthentication) && !self.ticket.currentSession.authenticating) {
        self.navigationItem.leftBarButtonItem.enabled = NO;

        [self showLoadingAndWait];

        [self authenticate:^(TradeItResult * res) {
            self.navigationItem.leftBarButtonItem.enabled = YES;
            initialAuthenticationComplete = YES;
            [self loadPortfolioData];
        }];
    } else {
        initialAuthenticationComplete = YES;
        [self showLoadingAndWait];
        [self loadPortfolioData];
    }

    if (self.ticket.presentationMode == TradeItPresentationModePortfolioOnly) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    [self initializeAd];
}

- (void)initializeAd {
    [self.adView configureWithAdType:@"portfolio"
                              broker: self.ticket.currentSession.broker
                    heightConstraint:self.adViewHeightConstraint];
}

- (void)loadPortfolioData {
    TTSDKPortfolioAccount * initialAccount = [portfolioService retrieveAutoSelectedAccount];
    [portfolioService selectAccount: initialAccount.accountNumber];

    self.selectedAccountIndex = [portfolioService.accounts indexOfObject:portfolioService.selectedAccount];

    self.holdingsHeaderTitle = [NSString stringWithFormat:@"%@ Holdings", portfolioService.selectedAccount.displayTitle ?: @""];

    [portfolioService getSummaryForAccounts:^(void) {
        if (self.ticket.currentSession.needsAuthentication) {
            initialAuthenticationComplete = NO;
            [self authenticate:^(TradeItResult * res) {
                initialAuthenticationComplete = YES;
                [self performSelector:@selector(loadPortfolioData) withObject:nil];
            }];
        } else {
            initialSummaryComplete = YES;
            
            accountsHolder = portfolioService.accounts;
            positionsHolder = [portfolioService filterPositionsByAccount: portfolioService.selectedAccount];
            
            [self.accountsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)showLoadingAndWait {
    TTSDKMBProgressHUD * hud = [TTSDKMBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (initialAuthenticationComplete) {
        hud.labelText = @"Retrieving Account Summary";
    } else {
        hud.labelText = @"Authenticating";
    }

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        int cycles = 0;

        while((!initialAuthenticationComplete || !initialSummaryComplete) && cycles < 200) {
            if (initialAuthenticationComplete) {
                hud.labelText = @"Retrieving Account Summary";
            }
            [NSThread sleepForTimeInterval:0.25f];
            cycles++;
        }

        if(!initialAuthenticationComplete || !initialSummaryComplete) {
            if(![UIAlertController class]) {
                [self showOldErrorAlert:@"An Error Has Occurred" withMessage:@"TradeIt is temporarily unavailable. Please try again in a few minutes."];
                return;
            }
            
            TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:@"An Error Has Occurred"
                                                                            message:@"TradeIt is temporarily unavailable. Please try again in a few minutes."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            alert.modalPresentationStyle = UIModalPresentationPopover;

            NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString: @"TradeIt is temporarily unavailable. Please try again in a few minutes." attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
            NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString: @"An Error Has Occurred" attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

            [alert setValue:attributedMessage forKey:@"attributedMessage"];
            [alert setValue:attributedTitle forKey:@"attributedTitle"];

            UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       [self.ticket returnToParentApp];
                                                                   }];
            [alert addAction:defaultAction];

            dispatch_async(dispatch_get_main_queue(), ^{
                [TTSDKMBProgressHUD hideHUDForView:self.view animated:YES];
                [self presentViewController:alert animated:YES completion:nil];

                alert.view.tintColor = self.styles.alertButtonColor;

                UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
                alertPresentationController.sourceView = self.view;
                alertPresentationController.permittedArrowDirections = 0;
                alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTSDKMBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    });
}

- (NSString *)retrieveTotalPortfolioValue {
    float totalPortfolioValue = 0.0f;
    TTSDKPortfolioAccount * firstAccount = (TTSDKPortfolioAccount *)[accountsHolder firstObject];
    NSString * baseCurrency = firstAccount.balance.accountBaseCurrency;
    
    for (TTSDKPortfolioAccount * portfolioAccount in accountsHolder) {
        totalPortfolioValue += [portfolioAccount.balance.totalValue floatValue];
        
        if(![portfolioAccount.balance.accountBaseCurrency isEqualToString:baseCurrency]) {
            NSLog(@"Base Currency Mismatch, Potentially Invalid Data");
            //TODO - better handling should this ever happen
        }
    }

    return [utils formatPriceString:[[NSNumber alloc] initWithFloat: totalPortfolioValue] withLocaleId:baseCurrency];
}


#pragma mark Table Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return accountsHolder.count;
    } else {
        return positionsHolder.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];
    NSArray *headerArray;

    if (section == 0) {
        if (!self.accountsHeaderNib) {
            headerArray = [resourceBundle loadNibNamed:@"TTSDKAccountsHeader" owner:self options:nil];
            self.accountsHeaderNib = (TTSDKAccountsHeaderView *)[headerArray firstObject];

            UITapGestureRecognizer * editTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(editAccountsPressed:)];
            [self.accountsHeaderNib.editAccountsButton addGestureRecognizer: editTap];
        }

        [self.accountsHeaderNib populateTotalPortfolioValue: [self retrieveTotalPortfolioValue]];
        
        return self.accountsHeaderNib;

    } else {
        if (!self.holdingsHeaderNib) {
            headerArray = [resourceBundle loadNibNamed:@"TTSDKHoldingsHeader" owner:self options:nil];
            self.holdingsHeaderNib = (TTSDKHoldingsHeaderView *)[headerArray firstObject];
        }

        self.holdingsHeaderNib.holdingsHeaderTitle.text = self.holdingsHeaderTitle;

        return self.holdingsHeaderNib;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kAccountsHeaderHeight;
    } else {
        return kHoldingsHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return kAccountsFooterHeight;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    NSString *nibIdentifier;
    NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];

    if (indexPath.section == 0) {
        cellIdentifier = @"PortfolioAccountIdentifier";
        nibIdentifier = @"TTSDKPortfolioAccountCell";
        TTSDKPortfolioAccountsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName: nibIdentifier bundle:resourceBundle] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        }

        cell.delegate = self;

        if (indexPath.row == 0) {
            [cell hideSeparator];
        } else {
            [cell showSeparator];
        }

        TTSDKPortfolioAccount * acct = [accountsHolder objectAtIndex: indexPath.row];
        [cell configureCellWithAccount: acct];

        BOOL selected = [portfolioService.selectedAccount.accountNumber isEqualToString: acct.accountNumber];
        [cell configureSelectedState: selected];

        return cell;
    } else {
        cellIdentifier = @"PortfolioHoldingIdentifier";
        nibIdentifier = @"TTSDKPortfolioHoldingCell";
        TTSDKPortfolioHoldingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName: nibIdentifier bundle:resourceBundle] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        }

        cell.clipsToBounds = YES;
        cell.delegate = self;

        if (indexPath.row == 0) {
            [cell hideSeparator];
        } else {
            [cell showSeparator];
        }
        
        [cell configureCellWithPosition: [positionsHolder objectAtIndex: indexPath.row] withLocale: portfolioService.selectedAccount.balance.accountBaseCurrency];

        if (self.selectedHoldingIndex == indexPath.row) {
            cell.expandedView.hidden = NO;
        } else {
            cell.expandedView.hidden = YES;
        }

        return cell;
    }
}

- (void)handleAccountSelection:(TTSDKPortfolioAccount *)selectedAccount {
    [portfolioService selectAccount: selectedAccount.accountNumber];
    positionsHolder = [portfolioService filterPositionsByAccount: selectedAccount];
    
    if (selectedAccount.displayTitle) {
        self.holdingsHeaderTitle = [NSString stringWithFormat:@"%@ Holdings", selectedAccount.displayTitle];
    } else {
        self.holdingsHeaderTitle = [NSString stringWithFormat:@"Holdings"];
    }
    
    [self updateTableContentSize];
    [self.accountsTable reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row != self.selectedAccountIndex) {
            self.selectedAccountIndex = indexPath.row;
            TTSDKPortfolioAccount * selectedAccount = [accountsHolder objectAtIndex:indexPath.row];
            [self handleAccountSelection: selectedAccount];
        }
    } else {
        if (indexPath.row == self.selectedHoldingIndex) {
            // User taps expanded row
            self.selectedHoldingIndex = -1;

            [UIView setAnimationsEnabled: NO];
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
            [UIView setAnimationsEnabled: YES];

            [self.accountsTable endUpdates];
        } else if (self.selectedHoldingIndex != -1) {
            // User taps different row
            NSIndexPath * prevPath = [NSIndexPath indexPathForRow: self.selectedHoldingIndex inSection: 1];
            self.selectedHoldingIndex = indexPath.row;

            [CATransaction begin];
            [UIView setAnimationsEnabled: NO];
            [tableView beginUpdates];

            [CATransaction setCompletionBlock: ^{
                [tableView reloadData];
            }];

            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
            [UIView setAnimationsEnabled: YES];
            [CATransaction commit];

            [self retrieveQuoteDataForPosition:[positionsHolder objectAtIndex:indexPath.row]];
        } else {
            // User taps new row with none expanded
            self.selectedHoldingIndex = indexPath.row;

            [UIView setAnimationsEnabled: NO];
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
            [UIView setAnimationsEnabled: YES];

            [self retrieveQuoteDataForPosition:[positionsHolder objectAtIndex:indexPath.row]];
        }

        [self updateTableContentSize];
        [self.accountsTable layoutIfNeeded];
    }
}

- (void)retrieveQuoteDataForPosition:(TTSDKPosition *)position {
    [portfolioService getQuoteForPosition:position withCompletionBlock:^(TradeItResult * res) {
        if ([res isKindOfClass:TradeItQuotesResult.class]) {
            TradeItQuotesResult * result = (TradeItQuotesResult *)res;
            position.quote = [[TradeItQuote alloc] initWithQuoteData:[result.quotes objectAtIndex:0]];
            [self.accountsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewRowAction.class) {
        if (indexPath.section == 0) {
            return NO;
        } else {
            TTSDKPosition * position = [positionsHolder objectAtIndex: indexPath.row];

            if (indexPath.row == self.selectedHoldingIndex) {
                return NO;
            } else if (![position.symbolClass isEqualToString:@"EQUITY_OR_ETF"]) {
                return NO;
            }
        }

        return YES;
    } else {
        return NO;
    }
}

- (NSArray<UITableViewRowAction *> *) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewRowAction.class && indexPath.section == 1) {
        TTSDKPosition * position = [positionsHolder objectAtIndex: indexPath.row];

        // Don't allow Buy or Sell on anything other than equity or etf
        if (![position.symbolClass isEqualToString:@"EQUITY_OR_ETF"]) {
            [tableView setEditing:NO];
            return nil;
        }

        UITableViewRowAction *buyAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"BUY" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [tableView setEditing:NO];
            [self performSelector:@selector(didSelectBuy:) withObject:[positionsHolder objectAtIndex:indexPath.row] afterDelay:0];
        }];
        buyAction.backgroundColor = [UIColor colorWithRed:43.0f/255.0f green:100.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        

        UITableViewRowAction *sellAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"SELL" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [tableView setEditing:NO];
            [self performSelector:@selector(didSelectSell:) withObject:[positionsHolder objectAtIndex:indexPath.row] afterDelay:0];
        }];
        sellAction.backgroundColor = [UIColor colorWithRed:88.0f/255.0f green:163.0f/255.0f blue:255.0f/255.0f alpha:1.0f];


        return @[sellAction, buyAction];
    } else {
        [tableView setEditing:NO];
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // nothing to do, but must be implemented
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return kAccountCellHeight;
    } else {
        if (self.selectedHoldingIndex == indexPath.row) {
            return kHoldingCellExpandedHeight;
        } else {
            return kHoldingCellDefaultHeight;
        }
    }
}


#pragma mark Custom Delegate Methods

- (void)didSelectBuy:(TTSDKPosition *)position {
    self.ticket.previewRequest.orderAction = @"buy";
    [self updateQuoteByPosition: position];

    NSDictionary * selectedAccountData = [portfolioService.selectedAccount accountData];
    if (![portfolioService.selectedAccount.userId isEqualToString:self.ticket.currentSession.login.userId]) {
        [self.ticket selectCurrentSession:[self.ticket retrieveSessionByAccount: selectedAccountData] andAccount:selectedAccountData];
    } else {
        [self.ticket selectCurrentAccount: selectedAccountData];
    }

    UIViewController * rootVC = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:0];

    if ([rootVC isKindOfClass:TTSDKTradeViewController.class]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        UIStoryboard *ticket = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
        TTSDKTradeViewController * tradeView = (TTSDKTradeViewController *)[ticket instantiateViewControllerWithIdentifier: @"tradeViewController"];
        [tradeView setModalPresentationStyle:UIModalPresentationFullScreen];
        tradeView.navigationItem.leftBarButtonItem = nil;

        [self.navigationController pushViewController:tradeView animated:YES];
    }
}

- (void)didSelectSell:(TTSDKPosition *)position {
    self.ticket.previewRequest.orderAction = @"sell";
    [self updateQuoteByPosition: position];

    NSDictionary * selectedAccountData = [portfolioService.selectedAccount accountData];
    if (![portfolioService.selectedAccount.userId isEqualToString:self.ticket.currentSession.login.userId]) {
        [self.ticket selectCurrentSession:[self.ticket retrieveSessionByAccount: selectedAccountData] andAccount:selectedAccountData];
    } else {
        [self.ticket selectCurrentAccount: selectedAccountData];
    }

    UIViewController * rootVC = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    
    if ([rootVC isKindOfClass:TTSDKTradeViewController.class]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        // Get storyboard
        UIStoryboard *ticket = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
        
        TTSDKTradeViewController * tradeView = (TTSDKTradeViewController *)[ticket instantiateViewControllerWithIdentifier: @"tradeViewController"];
        [tradeView setModalPresentationStyle:UIModalPresentationFullScreen];
        tradeView.navigationItem.leftBarButtonItem = nil;
        
        [self.navigationController pushViewController:tradeView animated:YES];
    }
}

- (void)updateQuoteByPosition:(TTSDKPosition *)position {
    TradeItQuote * quote = [[TradeItQuote alloc] init];
    quote.symbol = position.symbol;
    quote.companyName = position.companyName;
    self.ticket.quote = quote;
    self.ticket.previewRequest.orderSymbol = position.symbol;
}

- (void)didSelectAuth:(TTSDKPortfolioAccount *)account {
    [self handleAccountSelection:account];

    NSDictionary * accountData = [account accountData];
    TTSDKTicketSession * accountSession = [self.ticket retrieveSessionByAccount:accountData];

    self.ticket.clearPortfolioCache = YES; // since it's a new authentication, we'll want to go ahead and clear the portfolio cache

    if (accountSession.needsManualAuthentication) {
        addBroker = [accountSession broker];
        [self performSegueWithIdentifier:kPortfolioToLoginSegueIdentifier
                                  sender:self];
    } else {
        [self authenticateSession:accountSession
                   cancelToParent:NO
                           broker:[accountSession broker]
              withCompletionBlock:^(TradeItResult * res) {
                  [portfolioService getSummaryForAccount:account
                                     withCompletionBlock:^(void) {
                      [self performSelectorOnMainThread:@selector(handleAccountSelection:)
                                             withObject:account
                                          waitUntilDone:NO];
                  }];
              }];
    }
}


#pragma mark Custom UI

-(void) updateTableContentSize {
    CGRect contentRect = CGRectZero;

    for (UIView * view in [[self.accountsTable.subviews firstObject] subviews]) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }

    [self.accountsTable setContentSize:contentRect.size];
}


#pragma mark Navigation

- (IBAction)navigateToTrade:(id)sender {
    [self performSegueWithIdentifier:@"PortfolioToTrade" sender:self];
}

- (IBAction)closePressed:(id)sender {
    [self.ticket returnToParentApp];
}

- (IBAction)editAccountsPressed:(id)sender {
    [self performSegueWithIdentifier:@"PortfolioToAccountLink" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString: kPortfolioToLoginSegueIdentifier]) {
        UINavigationController *loginNav = (UINavigationController *)[segue destinationViewController];

        UIStoryboard *ticketStoryboard = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];

        TTSDKLoginViewController *loginViewController = [ticketStoryboard instantiateViewControllerWithIdentifier:@"LOGIN"];
        [loginViewController setAddBroker:addBroker];
        loginViewController.reAuthenticate = YES;
        loginViewController.isModal = YES;
        [loginNav pushViewController:loginViewController animated:YES];

        addBroker = nil; // immediately reset

        // If the current account needs authentication to continue, we should cancel to parent app
        BOOL cancelToParent;
        if (self.ticket.currentSession.needsManualAuthentication) {
            cancelToParent = YES;
        } else {
            cancelToParent = NO;
        }

        [self.ticket removeBrokerSelectFromNav:loginNav cancelToParent:cancelToParent];
    } else if ([segue.identifier isEqualToString:@"PortfolioToTrade"]) {

        segue.destinationViewController.navigationItem.leftBarButtonItem = nil;

    }
}


@end
