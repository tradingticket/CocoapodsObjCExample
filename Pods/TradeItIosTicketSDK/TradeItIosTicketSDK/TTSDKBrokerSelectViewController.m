//
//  BrokerSelectViewController.m
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 7/20/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKBrokerSelectTableViewCell.h"
#import "TTSDKLabel.h"
#import "TTSDKBrokerSelectFooterView.h"
#import "TTSDKWebViewController.h"
#import "TTSDKAlertController.h"


@implementation TTSDKBrokerSelectViewController {
    NSArray * brokers;
    NSArray * linkedBrokers;
    NSString * selectedBroker;
    TTSDKBrokerSelectFooterView * footerView;
}


#pragma mark Constants

static NSString * kCellIdentifier = @"BrokerCell";
static NSString * kBrokerToLoginSegueIdentifier = @"BrokerSelectToLogin";
static NSString * kBrokerToBrokerCenterSegueIdentifier = @"BrokerSelectToBrokerCenter";


#pragma mark Initialization

-(void) viewDidLoad {
    [super viewDidLoad];

    [self.tableView setContentInset: UIEdgeInsetsZero];

    brokers = self.ticket.brokerList;

    if(!self.ticket.publisherService || !self.ticket.publisherService.publisherDataLoaded){
        [self showLoadingAndWait];
    } else {
        [self brokersLoaded];
    }

    if (self.isModal) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationController.navigationItem.hidesBackButton = YES;
        [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
        [self.navigationController.navigationItem setHidesBackButton:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationController.navigationItem.leftBarButtonItem = nil;
    }

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

// only call this when the brokers array is loaded
-(void) brokersLoaded {
    NSMutableArray * mutableBrokers = [self.ticket.brokerList mutableCopy];

    if (self.ticket.publisherService.brokerCenterActive) {
        [mutableBrokers insertObject:@"Open an account" atIndex:0];
    } else {
        [mutableBrokers removeObject:@"Open an account"];
    }

    brokers = [mutableBrokers copy];
    [self.tableView reloadData];
}


#pragma mark Table Delegate Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [brokers count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * displayText;

    TTSDKBrokerSelectTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];

    if ([[brokers objectAtIndex: indexPath.row] isKindOfClass:NSString.class]) {
        displayText = [brokers objectAtIndex: indexPath.row];
        [cell configureCellWithText:displayText isOpenAccountCell:YES];
    } else {
        displayText = [[brokers objectAtIndex:indexPath.row] objectAtIndex:0];
        [cell configureCellWithText:displayText isOpenAccountCell:NO];
    }

    if ((indexPath.row + 1) == brokers.count) {
        [self performSelectorOnMainThread:@selector(showFooterView) withObject:nil waitUntilDone:NO];
    }

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    headerView.backgroundColor = self.styles.pageBackgroundColor;

    return headerView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (footerView) {
        return footerView;
    }

    NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];
    NSArray * footerViewArray = [resourceBundle loadNibNamed:@"TTSDKBrokerSelectFooterView" owner:self options:nil];
    
    footerView = [footerViewArray firstObject];

    UITapGestureRecognizer * helpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(helpTapped:)];
    [footerView.help addGestureRecognizer: helpTap];

    UITapGestureRecognizer * privacyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyTapped:)];
    [footerView.privacy addGestureRecognizer: privacyTap];

    UITapGestureRecognizer * termsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(termsTapped:)];
    [footerView.terms addGestureRecognizer: termsTap];

    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[brokers objectAtIndex:indexPath.row] isKindOfClass:NSString.class]) {
        [self performSegueWithIdentifier:kBrokerToBrokerCenterSegueIdentifier sender:self];
    } else {
        selectedBroker = [brokers objectAtIndex:[[self.tableView indexPathForSelectedRow] row]][1];
        [self performSegueWithIdentifier:kBrokerToLoginSegueIdentifier sender:self];
    }
}

-(void)helpTapped:(id)sender {
    [self showWebViewWithURL:@"https://www.trade.it/faq" andTitle:@"Help"];
}

-(void)privacyTapped:(id)sender {
    [self showWebViewWithURL:@"https://www.trade.it/privacy" andTitle:@"Privacy"];
}

-(void)termsTapped:(id)sender {
    [self showWebViewWithURL:@"https://www.trade.it/terms" andTitle:@"Terms"];
}


#pragma mark Custom UI

-(void) showFooterView {
    footerView.hidden = NO;
}

-(void) showLoadingAndWait {
    [TTSDKMBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        int cycles = 0;

        while([self.ticket.brokerList count] < 1 && cycles < 15) {
            sleep(1);
            cycles++;
        }

        if([self.ticket.brokerList count] < 1) {
            if(![UIAlertController class]) {
                [self showOldErrorAlert:@"An Error Has Occurred" withMessage:@"TradeIt is temporarily unavailable. Please try again in a few minutes."];
                return;
            }

            TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:@"An Error Has Occurred"
                                                                            message:@"TradeIt is temporarily unavailable. Please try again in a few minutes."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            alert.modalPresentationStyle = UIModalPresentationPopover;

            NSAttributedString * attributedMessage = [[NSAttributedString alloc] initWithString:@"An Error Has Occurred" attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
            NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:@"TradeIt is temporarily unavailable. Please try again in a few minutes." attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];

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
                brokers = self.ticket.brokerList;
                [self brokersLoaded];

                [TTSDKMBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    });
}


#pragma mark Navigation

-(IBAction) closePressed:(id)sender {
    if (self.cancelToParent) {
        [self.ticket returnToParentApp];
        return;
    }

    if (self.isModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    if(self.ticket.presentationMode == TradeItPresentationModeAuth && self.ticket.brokerSignUpCallback) {
        TradeItAuthControllerResult * res = [[TradeItAuthControllerResult alloc] init];
        res.success = false;
        res.errorTitle = @"Cancelled";

        self.ticket.brokerSignUpCallback(res);
    }

    [self.ticket returnToParentApp];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if([segue.identifier isEqualToString:kBrokerToLoginSegueIdentifier]) {
        TTSDKLoginViewController * dest = (TTSDKLoginViewController *)[segue destinationViewController];
        [dest setIsModal: self.isModal];
        [dest setAddBroker: selectedBroker];
        [dest setCancelToParent: self.cancelToParent];
    }
}


#pragma mark iOS7 fallbacks

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.ticket returnToParentApp];
}


@end
