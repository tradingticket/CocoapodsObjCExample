//
//  TTSDKSearchViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKSearchViewController.h"
#import <TradeItIosEmsApi/TradeItSymbolLookupRequest.h>
#import <TradeItIosEmsApi/TradeItSymbolLookupCompany.h>
#import <TradeItIosEmsApi/TradeItSymbolLookupResult.h>
#import <TradeItIosEmsApi/TradeItMarketDataService.h>
#import "TTSDKSearchBar.h"

@interface TTSDKSearchViewController() {
    TradeItMarketDataService * marketService;
}

@property NSArray * symbolSearchResults;
@property (weak, nonatomic) IBOutlet TTSDKSearchBar *searchBar;
@property TradeItSymbolLookupRequest * searchRequest;

@end

@implementation TTSDKSearchViewController


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.symbolSearchResults = [[NSArray alloc] init];

    marketService = [[TradeItMarketDataService alloc] initWithSession:self.ticket.currentSession];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];

    self.searchRequest = [[TradeItSymbolLookupRequest alloc] init];

    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];

    [self.searchBar becomeFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.symbolSearchResults.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Company" forIndexPath:indexPath];

    TradeItSymbolLookupCompany * company = (TradeItSymbolLookupCompany *)[self.symbolSearchResults objectAtIndex:indexPath.row];

    cell.textLabel.text = company.symbol;
    cell.detailTextLabel.text = company.name;
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = self.styles.pageBackgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = self.styles.primaryTextColor;
    cell.detailTextLabel.textColor = self.styles.smallTextColor;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];

    TradeItSymbolLookupCompany *selectedCompany = (TradeItSymbolLookupCompany *)[self.symbolSearchResults objectAtIndex:indexPath.row];

    TradeItQuote *quote = [[TradeItQuote alloc] init];
    quote.symbol = selectedCompany.symbol;
    quote.companyName = selectedCompany.name;
    self.ticket.quote = quote;
    self.ticket.previewRequest.orderSymbol = quote.symbol;

    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - private

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if (![searchBar.text isEqualToString:@""]) {
        [self setResultsToLoading];
        TradeItSymbolLookupRequest * lookupRequest = [[TradeItSymbolLookupRequest alloc] initWithQuery:searchBar.text];

        [marketService symbolLookup:lookupRequest withCompletionBlock:^(TradeItResult * res) {
            [self setResultsToLoaded];
            if ([res isKindOfClass:TradeItSymbolLookupResult.class]) {
                TradeItSymbolLookupResult * result = (TradeItSymbolLookupResult *)res;
                [self resultsDidReturn:result.results];
            }
        }];
    } else {
        [self resultsDidReturn:[[NSArray alloc] init]];
    }
}

- (void)resultsDidReturn:(NSArray *)results {
    self.symbolSearchResults = results;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)setResultsToLoading {
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.frame = CGRectMake(loadingIndicator.bounds.size.width, loadingIndicator.bounds.size.height, 20, 20);
    
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    
    [loadingView addSubview:loadingIndicator];

    self.tableView.backgroundView = loadingView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

-(void) setResultsToLoaded {
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}

-(IBAction) closePressed:(id)sender {
    if (self.noSymbol) {
        self.noSymbol = NO; // reset
    }

//    [self dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.ticket.lastUsed = [NSDate date];
}


@end
