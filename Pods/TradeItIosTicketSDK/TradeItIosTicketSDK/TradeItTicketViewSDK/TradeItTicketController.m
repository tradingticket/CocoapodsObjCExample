//
//  TradeItTicketController.m
//  TradeItTicketViewSDK
//
//  Created by Antonio Reyes on 7/2/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import "TradeItTicketController.h"
#import "TTSDKTradeItTicket.h"
#import "TTSDKTradeViewController.h"
#import "TTSDKCompanyDetails.h"
#import "TTSDKKeypad.h"
#import "TTSDKBrokerCenterViewController.h"
#import "TTSDKBrokerCenterTableViewCell.h"
#import "TTSDKPublisherService.h"
#import "TTSDKAccountSelectViewController.h"
#import "TTSDKAccountSelectTableViewCell.h"
#import "TTSDKReviewScreenViewController.h"
#import "TTSDKSuccessViewController.h"
#import "TTSDKOnboardingViewController.h"
#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKLoginViewController.h"
#import "TTSDKBrokerSelectTableViewCell.h"
#import "TTSDKBrokerSelectFooterView.h"
#import "TTSDKPortfolioViewController.h"
#import "TTSDKPortfolioHoldingTableViewCell.h"
#import "TTSDKPortfolioAccountsTableViewCell.h"
#import "TTSDKWebViewController.h"
#import "TTSDKTabBarViewController.h"
#import "TTSDKUtils.h"
#import "TTSDKAccountLinkViewController.h"
#import "TTSDKAccountLinkTableViewCell.h"
#import <TradeItIosEmsApi/TradeItConnector.h>
#import "TTSDKPosition.h"
#import "TTSDKPortfolioService.h"
#import "TTSDKAccountSummaryResult.h"
#import "TTSDKSearchViewController.h"
#import "TTSDKPortfolioAccount.h"
#import "TTSDKAccountsHeaderView.h"
#import "TTSDKHoldingsHeaderView.h"
#import "TTSDKLabel.h"
#import "TTSDKSmallLabel.h"
#import "TTSDKViewController.h"
#import "TTSDKNavigationController.h"
#import "TTSDKTableViewController.h"
#import "TTSDKTextField.h"
#import "TTSDKPrimaryButton.h"
#import "TTSDKImageView.h"
#import "TTSDKSearchBar.h"
#import "TTSDKSeparator.h"
#import "TTSDKAlertController.h"
#import <TradeItIosAdSdk/TradeItIosAdSdk-Swift.h>

@implementation TradeItTicketController {
    TTSDKUtils * utils;
}

static NSString * kDefaultOrderAction = @"buy";
static NSString * kDefaultOrderType = @"market";
static NSString * kDefaultOrderExpiration = @"day";
static int kDefaultOrderQuantity = 0; // nsnumbers cannot be compile-time constants

#pragma mark - Class Initialization

+(void) showTicket {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    [ticket setResultContainer: [[TradeItTicketControllerResult alloc] initNoBrokerStatus]];
    [self initializeAdConfig];
    
    switch (ticket.presentationMode) {
        case TradeItPresentationModePortfolioOnly:
            [ticket launchPortfolioFlow];
            break;
        case TradeItPresentationModePortfolio:
            [ticket launchTradeOrPortfolioFlow];
            break;
        case TradeItPresentationModeTrade:
            [ticket launchTradeOrPortfolioFlow];
            break;
        case TradeItPresentationModeTradeOnly:
            [ticket launchTradeFlow];
            break;
        case TradeItPresentationModeAuth:
            [ticket launchAuthFlow];
            break;
        default:
            [ticket launchTradeOrPortfolioFlow];
            break;
    }
}

+ (void)initializePublisherData:(NSString *)apiKey
                         onLoad:(void (^)(BOOL))load {
    [TradeItTicketController initializePublisherData:apiKey
                                           withDebug:NO
                                              onLoad:load];
}

+ (void)initializePublisherData:(NSString *)apiKey
                      withDebug:(BOOL)debug
                         onLoad:(void(^)(BOOL))load {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModeBrokerCenter;
    
    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];
    ticket.debugMode = debug;
    
    if (debug) {
        ticket.connector.environment = TradeItEmsTestEnv;
    }
    
    [ticket retrievePublisherData: load];
}

+ (void)showBrokerCenterWithApiKey:(NSString *)apiKey
                    viewController:(UIViewController *)view {
    [TradeItTicketController showBrokerCenterWithApiKey:apiKey
                                         viewController:view
                                              withDebug:NO
                                                 onLoad:nil
                                           onCompletion:nil];
}

+ (void)showBrokerCenterWithApiKey:(NSString *)apiKey
                    viewController:(UIViewController *)view
                         withDebug:(BOOL)debug
                            onLoad:(void(^)(BOOL))load
                      onCompletion:(void(^)(TradeItTicketControllerResult * result))callback {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModeBrokerCenter;

    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];
    ticket.parentView = view;
    ticket.callback = callback;
    ticket.debugMode = debug;

    if (debug) {
        ticket.connector.environment = TradeItEmsTestEnv;
    }

    [self initializeAdConfig];

    [ticket launchBrokerCenterFlow: load];
}

+ (void)showAccountsWithApiKey:(NSString *)apiKey
                viewController:(UIViewController *)view {
    [self showAccountsWithApiKey:apiKey
                  viewController:view
                       withDebug:NO
                    onCompletion:nil];
}

+ (void)showAccountsWithApiKey:(NSString *)apiKey
                viewController:(UIViewController *)view
                     withDebug:(BOOL)debug
                  onCompletion:(void(^)(TradeItTicketControllerResult * result))callback {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModeAccounts;
    
    ticket.parentView = view;
    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];
    ticket.debugMode = debug;
    ticket.callback = nil;
    
    if (debug) {
        ticket.connector.environment = TradeItEmsTestEnv;
    }

    [self initializeAdConfig];

    [ticket launchAccountsFlow];
}

#pragma mark - Authentication Initialization

+ (void)showAuthenticationWithApiKey:(NSString *)apiKey
                      viewController:(UIViewController *)view {
    [TradeItTicketController showAuthenticationWithApiKey:apiKey
                                           viewController:view
                                                withDebug:NO
                                             onCompletion:nil];
}

+ (void)showAuthenticationWithApiKey:(NSString *)apiKey
                      viewController:(UIViewController *)view
                           withDebug:(BOOL)debug onCompletion:(void(^)(TradeItTicketControllerResult * result))callback {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModeAuth;

    ticket.parentView = view;
    ticket.connector = [[TradeItConnector alloc] initWithApiKey:apiKey];
    ticket.debugMode = debug;
    ticket.callback = callback;

    if (debug) {
        ticket.connector.environment = TradeItEmsTestEnv;
    }

    [ticket launchAuthFlow];
}


#pragma mark - Portfolio Initialization

+ (void)showPortfolioWithApiKey:(NSString *)apiKey
                 viewController:(UIViewController *) view {
    [TradeItTicketController showPortfolioWithApiKey:apiKey
                                      viewController:view
                                           withDebug:NO
                                        onCompletion:nil];
}

+ (void)showPortfolioWithApiKey:(NSString *)apiKey
                 viewController:(UIViewController *)view
                  accountNumber:(NSString *)accountNumber {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.initialHighlightedAccountNumber = accountNumber;

    [TradeItTicketController showPortfolioWithApiKey:apiKey
                                      viewController:view
                                           withDebug:NO
                                        onCompletion:nil];
}

+ (void)showPortfolioWithApiKey:(NSString *)apiKey
                 viewController:(UIViewController *)view
                      withDebug:(BOOL)debug
                   onCompletion:(void(^)(TradeItTicketControllerResult * result))callback {
    [TradeItTicketController forceClassesIntoLinker];

    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];

    ticket.callback = callback;
    ticket.parentView = view;
    ticket.debugMode = debug;
    ticket.quote = [[TradeItQuote alloc] init];

    ticket.previewRequest = [[TradeItPreviewTradeRequest alloc] init];
    ticket.previewRequest.orderAction = kDefaultOrderAction;
    ticket.previewRequest.orderPriceType = kDefaultOrderType;
    ticket.previewRequest.orderQuantity = [NSNumber numberWithInt:kDefaultOrderQuantity];
    ticket.previewRequest.orderExpiration = kDefaultOrderExpiration;

    if (ticket.presentationMode == TradeItPresentationModeNone) {
        ticket.presentationMode = TradeItPresentationModePortfolio;
    }

    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];

    if (debug) {
        ticket.connector.environment = TradeItEmsTestEnv;
    }

    [TradeItTicketController showTicket];
}

+ (void)showRestrictedPortfolioWithApiKey:(NSString *)apiKey
                           viewController:(UIViewController *)view {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModePortfolioOnly;

    [TradeItTicketController showPortfolioWithApiKey:apiKey viewController:view];
}

+ (void)showRestrictedPortfolioWithApiKey:(NSString *)apiKey
                           viewController:(UIViewController *)view
                            accountNumber:(NSString *)accountNumber {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.initialHighlightedAccountNumber = accountNumber;

    [TradeItTicketController showRestrictedPortfolioWithApiKey:apiKey viewController:view];
}

+ (void)showRestrictedPortfolioWithApiKey:(NSString *)apiKey
                           viewController:(UIViewController *)view
                                withDebug:(BOOL)debug
                             onCompletion:(void (^)(TradeItTicketControllerResult *))callback {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModePortfolioOnly;
    
    [TradeItTicketController showPortfolioWithApiKey:apiKey viewController:view withDebug:debug onCompletion:callback];
}


#pragma mark - Ticket Initialization

+ (void)showTicketWithApiKey:(NSString *)apiKey
                      symbol:(NSString *)symbol
              viewController:(UIViewController *)view {
    [TradeItTicketController showTicketWithApiKey:apiKey symbol:symbol orderAction:nil orderQuantity:nil viewController:view withDebug:NO onCompletion:nil];
}

+ (void)showTicketWithApiKey:(NSString *)apiKey
                      symbol:(NSString *)symbol
                 orderAction:(NSString *)action
               orderQuantity:(NSNumber *)quantity
              viewController:(UIViewController *)view
                   withDebug:(BOOL)debug
                onCompletion:(void(^)(TradeItTicketControllerResult * result))callback {
    [TradeItTicketController forceClassesIntoLinker];

    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];

    [ticket setCallback: callback];
    [ticket setParentView: view];
    [ticket setDebugMode: debug];

    ticket.quote = [[TradeItQuote alloc] init];
    ticket.quote.symbol = [symbol uppercaseString];

    ticket.previewRequest = [[TradeItPreviewTradeRequest alloc] init];
    ticket.previewRequest.orderSymbol = [symbol uppercaseString];
    ticket.previewRequest.orderAction = [TradeItTicketController retrieveValidatedOrderAction: action];
    ticket.previewRequest.orderPriceType = kDefaultOrderType;
    ticket.previewRequest.orderQuantity = [TradeItTicketController retrieveValidatedOrderQuantity: quantity];
    ticket.previewRequest.orderExpiration = kDefaultOrderExpiration;

    if (ticket.presentationMode == TradeItPresentationModeNone) {
        ticket.presentationMode = TradeItPresentationModeTrade;
    }

    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];

    if (debug) {
        ticket.connector.environment = TradeItEmsTestEnv;
    }

    [self initializeAdConfig];
    [TradeItTicketController showTicket];
}

+ (void)showRestrictedTicketWithApiKey:(NSString *)apiKey
                                symbol:(NSString *)symbol
                        viewController:(UIViewController *)view {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModeTradeOnly;

    [TradeItTicketController showTicketWithApiKey:apiKey symbol:symbol viewController:view];
}

+ (void)showRestrictedTicketWithApiKey:(NSString *)apiKey
                                symbol:(NSString *)symbol
                           orderAction:(NSString *)action
                         orderQuantity:(NSNumber *)quantity
                        viewController:(UIViewController *)view
                             withDebug:(BOOL)debug
                          onCompletion:(void (^)(TradeItTicketControllerResult *))callback {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.presentationMode = TradeItPresentationModeTradeOnly;

    [TradeItTicketController showTicketWithApiKey:apiKey symbol:symbol orderAction:action orderQuantity:quantity viewController:view withDebug:debug onCompletion:callback];
}


#pragma mark - Order Validation

+ (NSString *)retrieveValidatedOrderAction:(NSString *)action {
    NSString * defaultAction = @"buy";

    // protects against nil and empty values
    if (!action || [action isEqualToString:@""]) {
        return defaultAction;
    }

    action = [action stringByReplacingOccurrencesOfString:@" " withString:@""]; // protects against spaces like 'Buy To Cover'
    action = [action lowercaseString]; // protects against incorrect capitalization like 'sEll'

    if (![action isEqualToString:@"buy"]
        && ![action isEqualToString:@"sell"]
        && ![action isEqualToString:@"buytocover"]
        && ![action isEqualToString:@"sellshort"]
        ) {
        return defaultAction;
    }

    if ([action isEqualToString:@"buytocover"]) {
        return @"buyToCover"; // protects against values such as 'buytoCover'
    } else if ([action isEqualToString:@"sellshort"]) {
        return @"sellShort"; // protects against values such as 'Sellshort'
    } else {
        return action; // at this point we know the value is either 'buy' or 'sell'
    }
}

+ (NSNumber *)retrieveValidatedOrderQuantity:(NSNumber *)quantity {
    NSNumber * defaultOrderQuantity = @0;

    // protects against null and negative values
    if (!quantity || ([quantity intValue] < 0)) {
        return defaultOrderQuantity;
    }

    int quantityInt = [quantity intValue]; // protects against floating point numbers

    return [NSNumber numberWithInt: quantityInt];
}

+ (NSString *)retrieveValidatedOrderType:(NSString *)orderType {
    NSString * defaultOrderType = @"market";

    if (!orderType || [orderType isEqualToString:@""]) {
        return defaultOrderType;
    }

    orderType = [orderType stringByReplacingOccurrencesOfString:@" " withString:@""]; // protects against spaces like 'stop limit'
    orderType = [orderType lowercaseString]; // protects against capitalizations like 'Market'

    if (![orderType isEqualToString:@"market"]
        && ![orderType isEqualToString:@"limit"]
        && ![orderType isEqualToString:@"stopmarket"]
        && ![orderType isEqualToString:@"stoplimit"]) {
        return defaultOrderType;
    }

    if ([orderType isEqualToString:@"stoplimit"]) {
        return @"stopLimit";
    } else if ([orderType isEqualToString:@"stopmarket"]) {
        return @"stopMarket";
    } else {
        return orderType;
    }
}

+ (NSString *)retrieveValidatedOrderExpiration:(NSString *)expiration {
    NSString * defaultExpiration = @"day";

    if (!expiration || [expiration isEqualToString:@""]) {
        return defaultExpiration;
    }

    expiration = [expiration stringByReplacingOccurrencesOfString:@" " withString:@""]; // protects against spaces like 'g t c'
    expiration = [expiration lowercaseString]; // protects against capitalizations like 'Day'

    if (![expiration isEqualToString:@"day"]
        && ![expiration isEqualToString:@"gtc"]) {
        return defaultExpiration;
    }

    return expiration;
}


#pragma mark - Ticket Utilities

+ (void)clearSavedData {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    
    [ticket unlinkAccounts];
}

+ (NSArray *)getLinkedAccounts {
    // If linkedAccounts fails, it will return an empty array
    NSArray * linkedAccounts = [TTSDKPortfolioService linkedAccounts];

    NSMutableArray * mutableLinkedAccounts = [[NSMutableArray alloc] init];

    for (NSDictionary * account in linkedAccounts) {
        NSMutableDictionary * mutableAccount = [[NSMutableDictionary alloc] initWithDictionary:account];
        [mutableAccount removeObjectForKey:@"active"];
        [mutableAccount removeObjectForKey:@"UserId"];

        [mutableLinkedAccounts addObject:[mutableAccount copy]];
    }

    return [mutableLinkedAccounts copy];
}

+ (NSArray *)getLinkedBrokers {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    
    return [ticket.connector getLinkedLogins];
}

+ (NSString *)getBrokerDisplayString:(NSString *) brokerIdentifier {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    
    return [ticket getBrokerDisplayString: brokerIdentifier];
}

#pragma mark Instance Initialization

- (id)initWithApiKey:(NSString *)apiKey
              symbol:(NSString *)symbol
      viewController:(UIViewController *)view {
    self = [super init];

    if (self) {
        TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
        ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];
        self.symbol = symbol;
        [ticket setParentView:view];
        self.styles = [TradeItStyles sharedStyles];
    }
    
    return self;
}

- (void)showTicket {
    utils = [TTSDKUtils sharedUtils];
    
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];

    // initialize quote
    ticket.quote = [[TradeItQuote alloc] init];

    if(self.companyName != nil && ![self.companyName isEqualToString:@""]) {
        ticket.quote.companyName = self.companyName;
    }

    // initialize preview request
    ticket.previewRequest = [[TradeItPreviewTradeRequest alloc] init];
    ticket.previewRequest.orderQuantity = [TradeItTicketController retrieveValidatedOrderQuantity:[NSNumber numberWithInt: self.quantity]];
    ticket.previewRequest.orderAction = [TradeItTicketController retrieveValidatedOrderAction: self.action];
    ticket.previewRequest.orderPriceType = [TradeItTicketController retrieveValidatedOrderType: self.orderType];
    ticket.previewRequest.orderExpiration = [TradeItTicketController retrieveValidatedOrderExpiration: self.expiration];

    // initialize symbol
    if (self.symbol != nil && ![self.symbol isEqualToString:@""]) {
        ticket.quote.symbol = [self.symbol uppercaseString];
        [ticket.previewRequest setOrderSymbol: [self.symbol uppercaseString]];
    }

    // initialize presentation mode
    if (self.presentationMode) {
        ticket.presentationMode = self.presentationMode;
    }

    // initialize debug mode
    if (self.debugMode) {
        [ticket setDebugMode: YES];
        ticket.connector.environment = TradeItEmsTestEnv;
    }

    // initialize completion block
    if (self.onCompletion != nil) {
        [ticket setCallback: self.onCompletion];
    }


    [TradeItTicketController initializeAdConfig];

    // show
    [TradeItTicketController showTicket];
}

+(void)getSessions: (UIViewController *) viewController withApiKey:(NSString *) apiKey onCompletion:(void(^)(NSArray * sessions)) callback {
    NSMutableArray * sessions = [[NSMutableArray alloc] init];
    NSMutableArray * sessionsInAuth = [[NSMutableArray alloc] init];
    NSMutableArray * sessionsToAuth = [[NSMutableArray alloc] init];
    NSMutableArray * sessionsNeedingManualAuth = [[NSMutableArray alloc] init];
    
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];
    
    if(!ticket.sessions || ![ticket.sessions count]) {
        [ticket createSessions: nil];
    }
    
    for (TTSDKTicketSession * session in ticket.sessions) {
        if(session.isAuthenticated) {
            [sessions addObject:session];
        } else if(session.authenticating) {
            [sessionsInAuth addObject:session];
        } else if(session.needsAuthentication || session.needsManualAuthentication || !session.isAuthenticated) {
            [sessionsToAuth addObject:session];
        } else {
            NSLog(@"WHAT?! Shouldn't be in this state");
        }
    }
    
    __block int sessionToAuthCounter = 0;
    int totalSessionsToAuthCount = (int)[sessionsToAuth count] + (int)[sessionsInAuth count];
    
    for (TTSDKTicketSession * session in sessionsToAuth) {
        
        [session authenticateFromViewController:viewController withCompletionBlock:^(TradeItResult * result) {
            sessionToAuthCounter++;
            
            if(![result isKindOfClass:[TradeItErrorResult class]]) {
                [sessions addObject:session];
            } else {
                if(session.needsManualAuthentication) {
                    [sessionsNeedingManualAuth addObject:session];
                } else {
                    //TODO think about how to handle this
                }
            }
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        while (sessionToAuthCounter < totalSessionsToAuthCount) {
            
            for(TTSDKTicketSession * session in sessionsInAuth) {
                if(session.needsManualAuthentication) {
                    sessionToAuthCounter++;
                    [sessionsNeedingManualAuth addObject:session];
                } else if(session.needsAuthentication) {
                    sessionToAuthCounter++;
                    //TODO think about how to handle this
                } else if(session.isAuthenticated) {
                    sessionToAuthCounter++;
                    [sessions addObject:session];
                } else if(!session.authenticating){
                    sessionToAuthCounter++;
                    //TODO think about how to handle this, this doesn't exist
                }
            }
            
            [NSThread sleepForTimeInterval:0.2f];
        }
        
        [TradeItTicketController handleManualLogin:viewController sessions:sessions sessionsToAuth:sessionsNeedingManualAuth ogCallback:callback];
    });
}

+(void)getSessions: (UIViewController *) viewController withApiKey:(NSString *) apiKey updateInvalidSession:(NSDictionary *) invalidSession onCompletion:(void(^)(NSArray * sessions)) callback {
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
    ticket.connector = [[TradeItConnector alloc] initWithApiKey: apiKey];
    
    if(ticket.sessions && [ticket.sessions count]) {
        for (TTSDKTicketSession * session in ticket.sessions) {
            if([session.login.userId isEqualToString:invalidSession[@"UserId"]]) {
                session.isAuthenticated = NO;
                session.needsAuthentication = YES;
                break;
            }
        }
    }
    
    [self getSessions:viewController withApiKey:apiKey onCompletion:callback];
}

+(void) handleManualLogin: (UIViewController *) viewController sessions:(NSMutableArray *) sessions sessionsToAuth:(NSMutableArray *) sessionsToAuth ogCallback:(void(^)(NSArray * sessions)) ogCallback {
    
    if([sessionsToAuth count]) {
        TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];
        ticket.presentationMode = TradeItPresentationModeAuth;
        
        TTSDKTicketSession * session = sessionsToAuth[0];

        UIStoryboard *ticketStoryboard = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
        UINavigationController *loginNav = (UINavigationController *)[ticketStoryboard instantiateViewControllerWithIdentifier: @"AUTH_NAV"];
        TTSDKLoginViewController *loginViewController = [ticketStoryboard instantiateViewControllerWithIdentifier: @"LOGIN"];
        [loginViewController setAddBroker: session.broker];
        loginViewController.reAuthenticate = YES;
        loginViewController.isModal = YES;
        [loginNav pushViewController: loginViewController animated:YES];
        [ticket removeBrokerSelectFromNav: loginNav cancelToParent: YES];
        
        ticket.brokerSignUpCallback = ^(TradeItAuthControllerResult * result) {
            if(result.success) {
                [sessions addObject:session];
            }
            [sessionsToAuth removeObjectAtIndex:0];
            [self handleManualLogin:viewController sessions:sessions sessionsToAuth:sessionsToAuth ogCallback:ogCallback];
        };

        [viewController presentViewController:loginNav animated:YES completion:nil];
    } else {
        ogCallback([self mapSessionsWithAccounts:sessions]);
    }
}

+(void) initializeAdConfig{
    TTSDKTradeItTicket * ticket = [TTSDKTradeItTicket globalTicket];

    TradeItConnector * connector = [[TradeItConnector alloc] initWithApiKey:TradeItAdConfig.apiKey];
    NSArray *linkedLogins = [connector getLinkedLogins];
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (TradeItLinkedLogin *linkedLogin in linkedLogins) {
        NSString *userToken = [connector userTokenFromKeychainId:linkedLogin.keychainId];

        if (userToken == nil) {
            userToken = [NSString stringWithFormat:@"Missing userToken in Bundle Id: %@", [[NSBundle mainBundle] bundleIdentifier]];
        }

        NSDictionary *user = @{ @"userId": linkedLogin.userId, @"userToken": userToken };
        [users addObject:user];
    }

    TradeItAdConfig.users = users;
    TradeItAdConfig.apiKey = [ticket.connector apiKey];
}

+(NSMutableArray *) mapSessionsWithAccounts: (NSMutableArray *) sessions {
    NSMutableArray * mappedSessions = [[NSMutableArray alloc] init];
    NSArray * storedAccounts = [TTSDKPortfolioService allAccounts];
    
    for (NSDictionary * account in storedAccounts) {
        if(account[@"active"]) {
            for (TTSDKTicketSession * session in sessions) {
                if([session.login.userId isEqualToString:account[@"UserId"]]) {
                    NSMutableDictionary * mappedSession = [[NSMutableDictionary alloc] initWithDictionary:account];
                    mappedSession[@"token"] = session.token;
                    [mappedSessions addObject:mappedSession];
                    break;
                }
            }
        }
    }
    
    return mappedSessions;
}

/*
 Storyboards in bundles are static, non-compiled resources.
 Therefore when the linker goes through the library it doesn't
 think any of the classes setup for the storyboard are in use,
 so when we actually go to load up the storyboard, it explodes
 because all those classes aren't loaded into the app. So,
 we simply call a method on every view class which forces
 the linker to load the classes :)
 */
+ (void)forceClassesIntoLinker {
    [TTSDKTradeViewController class];
    [TTSDKCompanyDetails class];
    [TTSDKKeypad class];
    [TTSDKAccountSelectViewController class];
    [TTSDKWebViewController class];
    [TTSDKBrokerCenterViewController class];
    [TTSDKBrokerCenterTableViewCell class];
    [TTSDKPublisherService class];
    [TTSDKAccountSelectTableViewCell class];
    [TTSDKReviewScreenViewController class];
    [TTSDKSuccessViewController class];
    [TTSDKOnboardingViewController class];
    [TTSDKBrokerSelectViewController class];
    [TTSDKBrokerSelectFooterView class];
    [TTSDKLoginViewController class];
    [TTSDKBrokerSelectTableViewCell class];
    [TTSDKPortfolioViewController class];
    [TTSDKPortfolioHoldingTableViewCell class];
    [TTSDKPortfolioAccountsTableViewCell class];
    [TTSDKTabBarViewController class];
    [TTSDKAccountLinkViewController class];
    [TTSDKAccountLinkTableViewCell class];
    [TTSDKPosition class];
    [TTSDKPortfolioService class];
    [TTSDKAccountSummaryResult class];
    [TTSDKSearchViewController class];
    [TTSDKPortfolioAccount class];
    [TTSDKAccountsHeaderView class];
    [TTSDKHoldingsHeaderView class];
    [TTSDKLabel class];
    [TTSDKSmallLabel class];
    [TTSDKTextField class];
    [TTSDKPrimaryButton class];
    [TTSDKImageView class];
    [TTSDKSearchBar class];
    [TTSDKSeparator class];
    [TTSDKViewController class];
    [TTSDKNavigationController class];
    [TTSDKTableViewController class];
    [TTSDKAlertController class];
    [TradeItStyles class];
}

@end
