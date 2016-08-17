//
//  TTSDKOnboardingViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/4/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKOnboardingViewController.h"
#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKLoginViewController.h"
#import "TTSDKPrimaryButton.h"
#import "TTSDKBrokerCenterViewController.h"
#import <TradeItIosAdSdk/TradeItIosAdSdk-Swift.h>

@interface TTSDKOnboardingViewController () {
    NSArray * brokers;
}
@property (weak, nonatomic) IBOutlet UIView *bullet1;
@property (weak, nonatomic) IBOutlet UIView *bullet2;
@property (weak, nonatomic) IBOutlet UIView *bullet3;
@property (weak, nonatomic) IBOutlet UIView *bullet4;
@property (weak, nonatomic) IBOutlet UIView *bullet5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brokerTitleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brokerDetailsTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropdownButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brokerDetailsHeightConstraint;

@property (weak, nonatomic) IBOutlet TTSDKPrimaryButton *brokerSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *preferredBrokerButton;
@property (weak, nonatomic) IBOutlet UIButton *openAccountButton;
@property (weak, nonatomic) IBOutlet TradeItAdView *adView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewHeightConstraint;

@end

@implementation TTSDKOnboardingViewController


#pragma mark Constants

static NSString * kLoginViewControllerIdentifier = @"LOGIN";


#pragma mark Orientation

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}


#pragma mark Initialization

-(void) viewDidLoad {
    [super viewDidLoad];

    [self.brokerSelectButton activate];

    [self styleCustomDropdownButton: self.preferredBrokerButton];

    self.bullet1.backgroundColor = self.styles.secondaryActiveColor;
    self.bullet1.layer.cornerRadius = 2.0f;
    self.bullet2.backgroundColor = self.styles.secondaryActiveColor;
    self.bullet2.layer.cornerRadius = 2.0f;
    self.bullet3.backgroundColor = self.styles.secondaryActiveColor;
    self.bullet3.layer.cornerRadius = 2.0f;
    self.bullet4.backgroundColor = self.styles.secondaryActiveColor;
    self.bullet4.layer.cornerRadius = 2.0f;
    self.bullet5.backgroundColor = self.styles.secondaryActiveColor;
    self.bullet5.layer.cornerRadius = 2.0f;

    [self showOrHideOpenAccountButton];

    brokers = [self.ticket getDefaultBrokerList];

    [self initializeAd];

    if (!self.ticket.publisherService.publisherDataLoaded) {
        [self wait];
    }
}

-(void) setViewStyles {
    [super setViewStyles];

    if ([TradeItAdConfig enabled]) {
        self.brokerTitleTopConstraint.constant = 75.0f;
        self.brokerDetailsTopConstraint.constant = 5.0f;
        self.brokerDetailsHeightConstraint.constant = 120.0f;
        self.dropdownButtonTopConstraint.constant = 5.0f;
    }
}

-(void) initializeAd {
    [self.adView configureWithAdType:@"account"
                    heightConstraint:[self adViewHeightConstraint]];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    self.currentSelection = @"Fidelity";
}

-(void) showOrHideOpenAccountButton {
    if (self.ticket.publisherService.publisherDataLoaded && self.ticket.publisherService.brokerCenterActive) {
        self.openAccountButton.hidden = NO;
    } else {
        self.openAccountButton.hidden = YES;
    }
}

-(void) wait {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        int cycles = 0;

        while(!self.ticket.publisherService.publisherDataLoaded && cycles < 75) {
            [NSThread sleepForTimeInterval:0.2f];
            cycles++;
        }

        // We want to hide the broker center button if we either can't get the data or the broker center is disabled
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showOrHideOpenAccountButton];
        });

        if([self.ticket.brokerList count] >= 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                brokers = self.ticket.brokerList;
            });
        }
    });
}

-(void) styleCustomDropdownButton: (UIButton *)button {
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = self.styles.secondaryActiveColor.CGColor;
    button.layer.borderWidth = 1.5f;
    button.layer.cornerRadius = 5.0f;
    [button setTitleColor:self.styles.primaryTextColor forState:UIControlStateNormal];

    UILabel * preferredBrokerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width / 2, 8)];
    preferredBrokerLabel.backgroundColor = [UIColor clearColor];
    preferredBrokerLabel.font = [UIFont systemFontOfSize:8.0f];
    preferredBrokerLabel.textColor = [UIColor clearColor]; // temporarily removing preferred broker
    preferredBrokerLabel.text = @"PREFERRED BROKER";

    [button.titleLabel addSubview:preferredBrokerLabel];

    button.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    preferredBrokerLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:preferredBrokerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem: button.titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:preferredBrokerLabel attribute:NSLayoutAttributeTrailingMargin relatedBy:NSLayoutRelationEqual toItem: button attribute: NSLayoutAttributeTrailingMargin multiplier:1.0 constant:-30.0]];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect bounds = CGRectMake(preferredBrokerLabel.frame.size.width - 9, 0, 8, 8);
    CGFloat radius = bounds.size.width / 2;
    CGFloat a = radius * sqrt((CGFloat)3.0) / 2;
    CGFloat b = radius / 2;
    [path moveToPoint:CGPointMake(0, b)];
    [path addLineToPoint:CGPointMake(a, -radius)];
    [path addLineToPoint:CGPointMake(-a, -radius)];

    [path closePath];
    [path applyTransform:CGAffineTransformMakeTranslation(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    shapeLayer.path = path.CGPath;

    shapeLayer.strokeColor = self.styles.secondaryActiveColor.CGColor;
    shapeLayer.fillColor = self.styles.secondaryActiveColor.CGColor;

    [preferredBrokerLabel.layer addSublayer: shapeLayer];
}


#pragma mark Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"onboardingToBrokerCenter"]) {
        UINavigationController * nav = (UINavigationController *)segue.destinationViewController;

        TTSDKBrokerCenterViewController * dest = (TTSDKBrokerCenterViewController *)[nav.viewControllers objectAtIndex:0];
        dest.isModal = YES;
    }
}

-(IBAction) openAccountPressed:(id)sender {
    [self performSegueWithIdentifier:@"onboardingToBrokerCenter" sender:self];
}

-(IBAction) brokerSelectPressed:(id)sender {
    [self selectBroker: self.currentSelection];
}

-(void) selectBroker:(NSString *)broker {
    UIStoryboard *ticket = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
    TTSDKLoginViewController *loginViewController = [ticket instantiateViewControllerWithIdentifier: kLoginViewControllerIdentifier];
    [loginViewController setAddBroker: broker];
    [self.navigationController pushViewController: loginViewController animated:YES];
}

-(IBAction) preferredBrokerPressed:(id)sender {
    NSArray * brokerList;

    if (!self.ticket.brokerList || !self.ticket.brokerList.count) {
        brokerList = brokers;
    } else {
        brokerList = self.ticket.brokerList;
    }

    NSMutableArray * optionsArray = [[NSMutableArray alloc] init];

    for (NSArray * broker in brokerList) {
        NSDictionary * brokerDict = @{broker[0]: broker[1]};
        [optionsArray addObject:brokerDict];
    }

    if (self.ticket.publisherService.publisherDataLoaded && self.ticket.publisherService.brokerCenterActive) {
        [optionsArray insertObject:@{@"Open an account": @"OPEN"} atIndex:0];
    }

    [self showPicker:@"Select account to trade with" withSelection:@"Fidelity" andOptions:[optionsArray copy] onSelection:^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.currentSelection isEqualToString:@"OPEN"]) {
                [self performSegueWithIdentifier:@"onboardingToBrokerCenter" sender:self];
            } else {
                [self populateBrokerButton];
                [self performSelector:@selector(brokerSelectPressed:) withObject:nil];
            }
        });
    }];
}

-(void) populateBrokerButton {
    [UIView setAnimationsEnabled:NO];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    [self.preferredBrokerButton setTitle:self.currentSelection forState:UIControlStateNormal];

    [CATransaction commit];

    [UIView setAnimationsEnabled:YES];
}

-(IBAction) closePressed:(id)sender {
    [self.ticket returnToParentApp];
}


@end
