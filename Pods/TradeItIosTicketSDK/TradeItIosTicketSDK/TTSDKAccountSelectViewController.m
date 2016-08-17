//
//  TTSDKPortfolioViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/16/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountSelectViewController.h"
#import "TTSDKAccountSelectTableViewCell.h"
#import "TTSDKTradeViewController.h"
#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKPortfolioService.h"
#import "TTSDKPortfolioAccount.h"
#import "TTSDKAccountLinkViewController.h"

@interface TTSDKAccountSelectViewController () {
    TTSDKPortfolioService * portfolioService;
    NSArray * accountResults;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TTSDKAccountSelectViewController


-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}

-(void) viewDidLoad {
    [super viewDidLoad];

    accountResults = [[NSArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tableView.backgroundColor = self.styles.pageBackgroundColor;
    portfolioService = [TTSDKPortfolioService serviceForLinkedAccounts];

    if (self.ticket.currentSession.isAuthenticated) {
        [self loadAccounts];
    } else {
        [self.ticket.currentSession authenticateFromViewController:self withCompletionBlock:^(TradeItResult * res) {
            [self performSelectorOnMainThread:@selector(loadAccounts) withObject:nil waitUntilDone:NO];
        }];
    }

    [self.tableView reloadData];
}

-(void) loadAccounts {
    [portfolioService getBalancesForAccounts:^(void) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

-(void) checkAuth {
    if (self.ticket.currentSession.isAuthenticated) {
        [self loadAccounts];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return portfolioService.accounts.count;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isModal) {
        TTSDKPortfolioAccount * account = [portfolioService.accounts objectAtIndex: indexPath.row];
        NSDictionary * selectedAccount = [account accountData];

        if (![account.userId isEqualToString:self.ticket.currentSession.login.userId]) {
            [self.ticket selectCurrentSession:[self.ticket retrieveSessionByAccount: selectedAccount] andAccount:selectedAccount];
        } else {
            [self.ticket selectCurrentAccount: selectedAccount];
        }

        [self.navigationController popViewControllerAnimated: YES];
    } else {
        [self.tableView reloadData];
    }
}

- (IBAction)closePressed:(id)sender {
    [self.ticket returnToParentApp];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UIButton * editAccounts = [[UIButton alloc] initWithFrame:CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, footerView.frame.size.width, 30.0f)];
    editAccounts.titleEdgeInsets = UIEdgeInsetsMake(0, 28.0, 0, 0);
    [editAccounts setTitle:@"Edit Accounts" forState:UIControlStateNormal];
    [editAccounts setTitleColor:self.styles.activeColor forState:UIControlStateNormal];
    [editAccounts.titleLabel setFont: [UIFont systemFontOfSize:15.0f]];
    editAccounts.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [editAccounts setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer * editAccountsTap = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(editAccountsPressed:)];
    [editAccounts addGestureRecognizer:editAccountsTap];
    
    footerView.backgroundColor = self.styles.pageBackgroundColor;
    
    [footerView addSubview:editAccounts];
    
    return footerView;
}

-(IBAction) editAccountsPressed:(id)sender {
    [self performSegueWithIdentifier:@"AccountSelectToAccountLink" sender:self];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * accountIdentifier = @"AccountSelectIdentifier";
    TTSDKAccountSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountIdentifier];
    if (cell == nil) {
        NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];

        [tableView registerNib:[UINib nibWithNibName:@"TTSDKAccountSelectCell" bundle:resourceBundle] forCellReuseIdentifier:accountIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:accountIdentifier];
    }

    TTSDKPortfolioAccount * account = [portfolioService.accounts objectAtIndex: indexPath.row];

    [cell configureCellWithAccount: account loaded: account.balanceComplete];

    if (self.ticket.currentAccount && [[self.ticket.currentAccount valueForKey:@"accountNumber"] isEqualToString: account.accountNumber]) {
        [cell configureSelectedState:YES];
    } else {
        [cell configureSelectedState:NO];
    }

    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"AccountSelectToBrokerSelect"]) {
        UINavigationController *dest = (UINavigationController *)[segue destinationViewController];

        UIStoryboard *ticket = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];

        TTSDKBrokerSelectViewController *brokerSelectController = [ticket instantiateViewControllerWithIdentifier:@"BROKER_SELECT"];
        brokerSelectController.isModal = YES;

        [dest pushViewController:brokerSelectController animated:NO];
    } else if ([segue.identifier isEqualToString:@"AccountSelectToAccountLink"]) {
        TTSDKAccountLinkViewController * dest = (TTSDKAccountLinkViewController *)segue.destinationViewController;
        dest.pushed = YES;
    }
}


@end
