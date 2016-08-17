//
//  TTSDKPortfolioService.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPortfolioService.h"
#import "TTSDKTradeItTicket.h"
#import <TradeItIosEmsApi/TradeItMarketDataService.h>
#import <TradeItIosEmsApi/TradeItQuotesResult.h>

typedef void(^DataCompletionBlock)(void);

typedef void(^SummaryCompletionBlock)(TTSDKAccountSummaryResult *);
typedef void(^BalancesCompletionBlock)(NSArray *);

@interface TTSDKPortfolioService() {
    TTSDKTradeItTicket * globalTicket;
    BalancesCompletionBlock balancesBlock;
    DataCompletionBlock dataBlock;
    NSTimer * dataTimer;
}

@property BOOL isAllAccountsService;

@end

@implementation TTSDKPortfolioService


// naming it 'highlighted' to distinguish from last account selected for trading
static NSString * kLastHighlightedAccountKey = @"TRADEIT_LAST_HIGHLIGHTED_ACCOUNT";
static NSString * kLastSelectedKey = @"TRADEIT_LAST_SELECTED";
static NSString * kAccountsKey = @"TRADEIT_ACCOUNTS";


+(id) serviceForAllAccounts {
    NSArray * allAccounts = [TTSDKPortfolioService allAccounts];
    TTSDKPortfolioService * service = [[self alloc] initWithAccounts: allAccounts];

    service.isAllAccountsService = YES;

    return service;
}

+(id) serviceForLinkedAccounts {
    NSArray * linkedAccounts = [TTSDKPortfolioService linkedAccounts];
    TTSDKPortfolioService * service = [[self alloc] initWithAccounts: linkedAccounts];

    return service;
}

-(id) init {
    if (self = [super init]) {
        globalTicket = [TTSDKTradeItTicket globalTicket];
    }
    return self;
}

-(id) initWithAccounts:(NSArray *)accounts {
    if (self = [super init]) {
        globalTicket = [TTSDKTradeItTicket globalTicket];

        NSMutableArray * portfolioAccounts = [[NSMutableArray alloc] init];
        for (NSDictionary *accountData in accounts) {
            TTSDKPortfolioAccount * portfolioAccount = [[TTSDKPortfolioAccount alloc] initWithAccountData: accountData];
            [portfolioAccounts addObject:portfolioAccount];
        }

        self.accounts = portfolioAccounts;
    }

    return self;
}

+(NSArray *)allAccounts {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * accounts = [defaults objectForKey: kAccountsKey];

    if (accounts == nil) {
        accounts = [[NSArray alloc] init];
    }

    return accounts;
}

+(NSArray *)linkedAccounts {
    NSMutableArray * linkedAccounts = [[NSMutableArray alloc] init];
    NSArray * storedAccounts = [TTSDKPortfolioService allAccounts];

    int i;
    for (i = 0; i < storedAccounts.count; i++) {
        NSDictionary * account = [storedAccounts objectAtIndex:i];
        NSNumber * active = [account valueForKey: @"active"];
        
        if ([active boolValue]) {
            [linkedAccounts addObject: account];
        }
    }
    
    return [linkedAccounts copy];
}

-(TTSDKPortfolioAccount *) retrieveAutoSelectedAccount {
    /*
     Algorithm for auto account selection:
     1. Check for initial selected account
     2. Check for last highlighted account
     3. If it doesn't exist, check for last traded account
     4. If that doesn't exist, find the first linked account
     */

    TTSDKPortfolioAccount * selectedAccount = nil;

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * lastHighlighted = [defaults objectForKey: kLastHighlightedAccountKey];
    NSString * lastSelected = [defaults objectForKey: kLastSelectedKey];

    if (globalTicket.initialHighlightedAccountNumber) {
        selectedAccount = [self accountByAccountNumber: globalTicket.initialHighlightedAccountNumber];
        if (!selectedAccount || !selectedAccount.active) {
            selectedAccount = nil;
        } else {
            globalTicket.initialHighlightedAccountNumber = nil;
        }
    }

    if (!selectedAccount && lastHighlighted) {
        selectedAccount = [self accountByAccountNumber: lastHighlighted];
        if (!selectedAccount || !selectedAccount.active) {
            selectedAccount = nil;
        }
    }

    if (!selectedAccount && lastSelected) {
        selectedAccount = [self accountByAccountNumber: lastSelected];
        if (!selectedAccount || !selectedAccount.active) {
            selectedAccount = nil;
        }
    }

    if (!selectedAccount) {
        for (TTSDKPortfolioAccount * portfolioAccount in self.accounts) {
            if (portfolioAccount.active) {
                selectedAccount = portfolioAccount;
            }
        }
    }

    return selectedAccount;
}

-(TTSDKPortfolioAccount *) accountByAccountNumber:(NSString *)accountNumber {
    TTSDKPortfolioAccount * account = nil;

    for (TTSDKPortfolioAccount * portfolioAccount in self.accounts) {
        if ([portfolioAccount.accountNumber isEqualToString:accountNumber]) {
            account = portfolioAccount;
        }
    }

    return account;
}

-(void) selectAccount:(NSString *)accountNumber {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    TTSDKPortfolioAccount * selectedAccount;

    for (TTSDKPortfolioAccount * account in self.accounts) {
        if ([account.accountNumber isEqualToString: accountNumber]) {
            selectedAccount = account;
            break;
        }
    }

    if (!selectedAccount) {
        if (self.accounts && [self.accounts count]) {
            selectedAccount = [self.accounts firstObject];
        } else {
            return;
        }
    }

    self.selectedAccount = selectedAccount;

    [defaults setObject:selectedAccount.accountNumber forKey:kLastHighlightedAccountKey];
    [defaults synchronize];
}

-(NSArray *) positionsForAccounts {
    NSMutableArray * positions = [[NSMutableArray alloc] init];

    if (self.accounts) {
        for (TTSDKPortfolioAccount *account in self.accounts) {
            [positions addObjectsFromArray: account.positions];
        }
    }

    return positions;
}

-(NSArray *) filterPositionsByAccount:(TTSDKPortfolioAccount *)portfolioAccount {
    NSArray * positions = portfolioAccount.positions;

    return positions;
}

-(void) getQuotesForAccounts:(void (^)(void)) completionBlock {
    TradeItMarketDataService * marketService = [[TradeItMarketDataService alloc] initWithSession: globalTicket.currentSession];

    NSArray * symbols = [[NSArray alloc] init];

    NSCharacterSet * digits = [NSCharacterSet decimalDigitCharacterSet];
    for (TTSDKPortfolioAccount *portfolioAccount in self.accounts) {
        for (TTSDKPosition *position in portfolioAccount.positions) {
            if ([position.symbol rangeOfCharacterFromSet:digits].location == NSNotFound) {
                NSArray * symArr = @[position.symbol];
                symbols = [symbols arrayByAddingObjectsFromArray:symArr];
            }
        }
    }

    // Note: I can't find a better/faster way to do this
    TradeItQuotesRequest * quoteRequest = [[TradeItQuotesRequest alloc] initWithSymbols:symbols];
    [marketService getQuoteData:quoteRequest withCompletionBlock:^(TradeItResult * res) {
        if ([res isKindOfClass:TradeItQuotesResult.class]) {
            TradeItQuotesResult * result = (TradeItQuotesResult *)res;

            for (NSDictionary *quoteData in result.quotes) {
                for (TTSDKPortfolioAccount *portfolioAccount in self.accounts) {
                    for (TTSDKPosition * position in portfolioAccount.positions) {
                        if ([position.symbol isEqualToString:[quoteData valueForKey:@"symbol"]]) {
                            position.quote = [[TradeItQuote alloc] initWithQuoteData:quoteData];
                        }
                    }
                }
            }
        }
    }];
}

-(void) getQuoteForPosition:(TTSDKPosition *)position withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    TradeItMarketDataService * marketService = [[TradeItMarketDataService alloc] initWithSession: globalTicket.currentSession];
    TradeItQuotesRequest * quoteRequest = [[TradeItQuotesRequest alloc] initWithSymbol:position.symbol];

    [marketService getQuoteData:quoteRequest withCompletionBlock:^(TradeItResult * res) {
        if (completionBlock) {
            completionBlock(res);
        }
    }];
}

-(void) getSummaryForAccounts:(void (^)(void)) completionBlock {
    if (!self.accounts) {
        completionBlock();
        return;
    }

    dataTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkSummary) userInfo:nil repeats:YES];
    dataBlock = completionBlock;

    for (TTSDKPortfolioAccount * portfolioAccount in self.accounts) {
        [portfolioAccount retrieveAccountSummary];
    }
}

-(void) getSummaryForSelectedAccount:(void (^)(void)) completionBlock {
    [self getSummaryForAccount:self.selectedAccount withCompletionBlock:completionBlock];
}

-(void) getSummaryForAccount:(TTSDKPortfolioAccount *) account withCompletionBlock:(void (^)(void)) completionBlock {
    if (!account) {
        if(completionBlock) {
            completionBlock();
        }
        return;
    }
    
    [account retrieveAccountSummaryWithCompletionBlock: ^(void) {
        if(completionBlock) {
            completionBlock();
        }
    }];
}


-(void) checkSummary {
    BOOL complete = YES;

    for (TTSDKPortfolioAccount * portfolioAccount in self.accounts) {
        if (![portfolioAccount dataComplete] && ![portfolioAccount needsAuthentication]) {
            complete = NO;
        }
    }

    if (complete) {
        [dataTimer invalidate];
        dataBlock();
    }
}

-(void) getBalancesForAccounts:(void (^)(void)) completionBlock {
    if (!self.accounts) {
        completionBlock();
        return;
    }

    dataTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkSummary) userInfo:nil repeats:YES];
    dataBlock = completionBlock;

    for (TTSDKPortfolioAccount * portfolioAccount in self.accounts) {
        portfolioAccount.positionsComplete = YES; // bypasses position retrieval
        [portfolioAccount retrieveBalance];
    }
}

-(void) toggleAccount:(TTSDKPortfolioAccount *)account {
    BOOL active = account.active;

    NSArray * accounts = self.accounts;

    int i;
    for (i = 0; i < accounts.count; i++) {
        TTSDKPortfolioAccount * currentAccount = [accounts objectAtIndex: i];

        if ([currentAccount.accountNumber isEqualToString: account.accountNumber]) {
            currentAccount.active = !active;
        }
    }

    [self saveToUserDefaults];
}

-(void) deleteAccounts:(NSString *)userId session:(TTSDKTicketSession *)session {
    NSMutableArray * keptAccounts = [[NSMutableArray alloc] init];

    int numAccountsToDelete = 0;
    for (TTSDKPortfolioAccount *portfolioAccount in self.accounts) {
        if (![portfolioAccount.userId isEqualToString:userId]) {
            [keptAccounts addObject: portfolioAccount];
        } else {
            numAccountsToDelete++;
        }
    }

    [globalTicket removeSession: session];

    self.accounts = [keptAccounts copy];

    // Save new accounts list to user defaults
    [self saveToUserDefaults];
}

-(void) deleteAccount:(TTSDKPortfolioAccount *)account {
    // First, check to see if this is the last account in its respective linked login. If so, we want to delete the session.
    BOOL isLastAccount = YES;
    for (TTSDKPortfolioAccount *portfolioAccount in self.accounts) {
        if ([portfolioAccount.userId isEqualToString:account.userId] && ![portfolioAccount.accountNumber isEqualToString:account.accountNumber]) {
            isLastAccount = NO;
        }
    }

    if (isLastAccount) {
        // delete the session
        [globalTicket removeSession: account.session];
    }

    // Remove account from the service accounts list
    NSMutableArray * mutableAccounts = [self.accounts mutableCopy];
    [mutableAccounts removeObject:account];
    self.accounts = [mutableAccounts copy];

    // Save new accounts list to user defaults
    [self saveToUserDefaults];
}

-(int) linkedAccountsCount {
    int n = 0;

    for (TTSDKPortfolioAccount * portfolioAccount in self.accounts) {
        if (portfolioAccount.active) {
            n++;
        }
    }

    return n;
}

-(void) saveToUserDefaults {
    if (!self.isAllAccountsService) {
        // we should never save directly to user defaults unless it we are referencing all accounts
        return;
    }

    // Build out an array of simple dictionaries to save to user defaults
    NSMutableArray * accountsList = [[NSMutableArray alloc] init];
    for (TTSDKPortfolioAccount * account in self.accounts) {
        [accountsList addObject:[account accountData]];
    }

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [accountsList copy] forKey:kAccountsKey];
    [defaults synchronize];
}


@end
