//
//  ViewController.m
//  CocoapodsObjCExample
//
//  Created by James Robert Somers on 8/17/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "ViewController.h"
#import <TradeItIosTicketSDK/TradeItTicketController.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launch:(id)sender {
    [TradeItTicketController showAccountsWithApiKey:@"tradeit-test-api-key"
                                     viewController:self
                                          withDebug:YES
                                       onCompletion:nil];
}

@end
